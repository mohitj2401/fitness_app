# Fitness Pass App

A modern, feature-rich fitness application built with Flutter, featuring yoga sessions, workout exercises, and booking capabilities.

## Features

### 🧘 Yoga & Mindfulness
- Multiple yoga categories (Asanas, Pranayama, Meditation, Surya Namaskar)
- Session timer with pause/resume functionality
- Session history tracking with local storage
- Daily reports and statistics
- Beautiful gradient UI with realistic yoga images

### 💪 Workout Exercises
- **18 Exercises** across 6 categories:
  - Chest (Bench Press, Push-Ups, Dumbbell Flyes)
  - Back (Pull-Ups, Barbell Rows, Deadlifts)
  - Legs (Squats, Lunges, Leg Press)
  - Shoulders (Overhead Press, Lateral Raises, Front Raises)
  - Arms (Barbell Curls, Tricep Dips, Hammer Curls)
  - Core (Plank, Crunches, Russian Twists)
- Search and filter by difficulty level
- Detailed exercise instructions with step-by-step guidance
- Muscle group targeting information
- Color-coded categories

### 🏠 Modern Dashboard
- Gradient header with welcome message
- Stats cards (Workouts, Calories, Streak)
- Quick action cards for main features
- Recent activity feed
- Material 3 design with smooth animations

### 👤 Profile & Settings
- User profile with gradient header
- Stats overview (Sessions, Time, Achievements)
- Theme switcher (Light, Dark, AMOLED)
- Modern card-based settings layout

### 📅 Booking
- Class booking functionality
- Schedule management

## Tech Stack

- **Framework:** Flutter 3.10+
- **State Management:** flutter_bloc
- **Local Storage:** shared_preferences
- **Fonts:** Google Fonts (Inter)
- **Design:** Material 3

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  equatable: ^2.0.8
  shared_preferences: ^2.5.4
  google_fonts: ^7.0.0
  intl: ^0.20.2
  table_calendar: ^3.2.0
  uuid: ^4.5.2
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10.1 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/fitness_pass_app.git
cd fitness_pass_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_theme.dart
│       └── theme_bloc.dart
├── features/
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── yoga/
│   │   ├── models/
│   │   ├── data/
│   │   └── presentation/
│   ├── workout/
│   │   ├── models/
│   │   ├── data/
│   │   └── presentation/
│   ├── booking/
│   │   └── booking_screen.dart
│   └── auth/
└── main.dart
```

## Features in Detail

### Yoga Sessions
- Track yoga practice with built-in timer
- Save sessions with title, duration, and timestamp
- View session history
- Daily reports with statistics

### Workout Exercises
- Browse exercises by category
- Search exercises by name
- Filter by difficulty (Beginner/Intermediate/Advanced)
- View detailed instructions for each exercise
- Learn about targeted muscle groups

### Themes
- **Light Mode:** Clean, modern light theme
- **Dark Mode:** Eye-friendly dark theme
- **AMOLED Mode:** Pure black for OLED displays

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- Google Fonts for typography

---

**Built with ❤️ using Flutter**
