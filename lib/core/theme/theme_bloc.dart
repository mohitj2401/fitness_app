import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

// EVENTS
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final AppThemeMode themeMode;
  const ThemeChanged(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

class ThemeLoadStarted extends ThemeEvent {}

// STATE
class ThemeState extends Equatable {
  final AppThemeMode themeMode;
  final ThemeData themeData;

  const ThemeState({required this.themeMode, required this.themeData});

  @override
  List<Object> get props => [themeMode, themeData];
}

// BLOC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themePrefsKey = 'theme_mode';

  ThemeBloc()
    : super(
        ThemeState(
          themeMode: AppThemeMode.light,
          themeData: AppThemes.lightTheme,
        ),
      ) {
    on<ThemeLoadStarted>(_onThemeLoadStarted);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeLoadStarted(
    ThemeLoadStarted event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefsKey) ?? 0;

    // Map index back to enum safely
    AppThemeMode mode = AppThemeMode.light;
    if (themeIndex >= 0 && themeIndex < AppThemeMode.values.length) {
      mode = AppThemeMode.values[themeIndex];
    }

    emit(ThemeState(themeMode: mode, themeData: AppThemes.getTheme(mode)));
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefsKey, event.themeMode.index);

    emit(
      ThemeState(
        themeMode: event.themeMode,
        themeData: AppThemes.getTheme(event.themeMode),
      ),
    );
  }
}
