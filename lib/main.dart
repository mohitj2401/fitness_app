import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme_bloc.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc()..add(ThemeLoadStarted()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Fitness Pass App',
            debugShowCheckedModeBanner: false,
            theme: state.themeData,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
