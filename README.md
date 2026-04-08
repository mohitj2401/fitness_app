# Fitness Pass App

A modern, feature-rich fitness application built with Flutter, featuring integrated workout tracking, yoga sessions, and a comprehensive achievements system.

## 🚀 Key Features

### 🏅 Achievements System (v2)
- **11 Unique Milestones** across categories like consistency, intensity, and timing.
- **Milestones include**: Century Club (100 sessions), Calorie Crusher, Early Bird (pre-8 AM), and Night Owl (post-9 PM).
- **Celebratory UI**: Animated unlock dialogs with custom icons.
- **Progress Tracking**: Persistent badge grid with unlock dates.

### 💪 Gym Workout Tracking
- **Session Logging**: Track start/end times and duration.
- **Exercise Logging**: Log sets, reps, and weights for 18+ exercises.
- **History View**: Detailed logs of past workouts with set-by-set breakdown.
- **Muscle Focused**: Exercises categorized by Back, Chest, Core, Legs, and more.

### 🏆 Gamification & Mastery (v3)
- **Intelligent XP Engine**: Dynamic XP rewards based on workout intensity (sets) and yoga duration (minutes).
- **Mastery Path**: High-end visual "roadmap" of 6 prestige ranks: Novice, Athlete, Warrior, Elite, Master, and Legend.
- **Tiered Branding**: Signature colors and badges for each rank (Iron to Diamond) integrated across the dashboard and session screens.
- **Interactive Map**: Tap the Level HUD to explore the full Mastery Path and requirements.
- **Streak Tracker**: Integrated fire-streak tracking with dashboard HUD to encourage daily consistency.

### 🧘 Yoga & Mindfulness
- **Guided Sessions**: Categories for Asanas, Pranayama, Meditation, and Surya Namaskar.
- **Smart Timer**: Persistent session timer with tracking for yoga intensity.
- **AMOLED UX**: Optimized dark-mode visuals for a focused, premium session experience.
- **SQL-Backed History**: Reliable storage for all yoga mindfulness sessions.

### 🔄 Real-Time Dashboard
- **Unified HUD**: Glassmorphism progress bar with dynamic Level and Mastery Rank display.
- **Unified Stats**: Live synchronization across Home and Account tabs.
- **Stat Cards**: Track Sessions, Total Minutes, Calories, and Badges earned.
- **Quick Links**: Instant access to workouts, yoga, history, and achievements.

### 👤 Profile & System Tools
- **Theme Engine**: Switch between Light, Dark, and AMOLED (OLED-friendly) modes.
- **Data Privacy**: "Reset All Data" feature to securely wipe progress and start fresh.
- **State Management**: Robust BLoC-based theme and sync management.

## 🛠 Tech Stack

- **Framework:** Flutter 3.10+
- **State Management:** flutter_bloc
- **Database:** SQLite (sqflite) for high-performance session and achievement storage.
- **Synchronization:** Custom ValueNotifier-based dashboard refresh system.
- **UI Design:** Material 3 with custom glassmorphism and gradient aesthetics.

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  sqflite: ^2.4.1
  path: ^1.9.1
  intl: ^0.20.2
  uuid: ^4.5.2
  google_fonts: ^7.0.0
  shared_preferences: ^2.5.4
```

## 📂 Project Structure

```
lib/
├── core/
│   └── theme/            # ThemeBloc and AppTheme
├── features/
│   ├── dashboard/       # Main Dashboard & Home screens
│   ├── achievements/    # Achievement logic, models, and UI
│   ├── workout/         # Gym logging and exercise database
│   ├── yoga/            # Yoga session tracking
│   └── booking/         # Class booking module
└── main.dart            # App entry & Global Navigator setup
```

## 🏁 Getting Started

1. **Clone & Install**:
   ```bash
   git clone https://github.com/mohitj2401/fitness_app.git
   cd fitness_pass_app
   flutter pub get
   ```
2. **Run the App**:
   ```bash
   flutter run
   ```

---

**Built with ❤️ for Fitness Enthusiasts**
