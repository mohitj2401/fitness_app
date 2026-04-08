# Fitness Pass App

A modern, feature-rich fitness application built with Flutter, featuring integrated workout tracking, yoga sessions, and a comprehensive achievements system.

## 🚀 Key Features

### 🏅 Achievements System (v2)
- **11 Unique Milestones** across categories like consistency, intensity, and timing.
- **Milestones include**: Century Club (100 sessions), Calorie Crusher, Early Bird (pre-8 AM), and Night Owl (post-9 PM).
- **Celebratory UI**: Animated unlock dialogs with custom icons.
- **Progress Tracking**: Persistent badge grid with unlock dates.

### 🏆 Gamification & Mastery (v3.1)
- **Unified Activity Feed**: Intelligent dashboard timeline that automatically merges and sorts Gym workouts and Yoga practices by date.
- **Intelligent XP Engine**: Dynamic XP rewards based on workout intensity (sets) and yoga duration (minutes), persisted via `SharedPreferences`.
- **Mastery Path**: High-end visual "roadmap" of 6 prestige ranks: Novice, Athlete, Warrior, Elite, Master, and Legend.
- **Tiered Branding**: Signature colors and badges for each rank (Iron to Diamond) integrated across the dashboard HUD and session screens.
- **Interactive Map**: Tap the Level HUD to explore the full Mastery Path, requirements, and rank titles.

### 💪 Gym Workout Tracking
- **Session Logging**: Track start/end times and duration with automatic XP calculation.
- **Exercise Logging**: Log sets, reps, and weights for 18+ exercises.
- **History View**: Detailed logs of past workouts with set-by-set breakdown.
- **Muscle Focused**: Exercises categorized by Back, Chest, Core, Legs, and more.

### 🧘 Yoga & Mindfulness
- **Dynamic Session Engine**: Context-aware activity screen that automatically shifts images, poses (e.g., Tadasana, Dhyana), and focus instructions based on the selected discipline.
- **Guided Categories**: Dedicated sessions for Asanas, Pranayama, Meditation, and Surya Namaskar.
- **Restored Navigation**: Multi-point access via the **Workouts Library** and a high-speed **Home HUD Shortcut**.
- **Smart Timer**: Persistent session timer with tracking for yoga intensity and mindful duration.
- **AMOLED UX**: Optimized dark-mode visuals for a focused, premium session experience.
- **SQL-Backed History**: Reliable SQLite storage for all yoga mindfulness sessions.

### 🔄 Real-Time Dashboard
- **Unified HUD**: Glassmorphism progress bar with dynamic Level, XP, and Mastery Rank display.
- **Unified Stats**: Live synchronization across Home, Progress, and Library tabs.
- **Stat Cards**: Track Sessions, Total Minutes, Calories, and Badges earned.
- **Navigation HUB**: 4-tab premium navigation (Home, Progress, Library, Profile).

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
