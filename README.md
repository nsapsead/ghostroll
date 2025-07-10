# GhostRoll

A mobile-first Flutter app for tracking martial arts training sessions with a clean, minimal dark theme UI.

## Features

- **Quick Log Screen**: Large centered ghost button for easy session logging
- **Journal Timeline**: View all past training sessions in a clean timeline
- **Log Session Form**: Comprehensive form for recording training details
- **Session Detail View**: Detailed view of individual training sessions

## Screens

1. **Quick Log Screen**
   - Dark theme with large ghost button
   - One-tap access to log new sessions

2. **Journal Timeline Screen**
   - List of past sessions with key information
   - Date, class type, focus area, and rounds display
   - Technique chips for quick overview

3. **Log Session Form**
   - Date selector (defaults to today)
   - Class type toggle buttons (Gi, No-Gi, Striking)
   - Focus area text input
   - Multi-select techniques using chips
   - Optional sparring notes and reflection fields

4. **Session Detail View**
   - Complete session information display
   - Techniques shown as chips
   - Sparring notes and reflection sections
   - Edit button for future functionality

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd GhostRoll
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## App Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── models/
│   └── session.dart         # Session data model
└── screens/
    ├── quick_log_screen.dart      # Quick log interface
    ├── journal_timeline_screen.dart # Session timeline
    ├── log_session_form.dart      # Session logging form
    └── session_detail_view.dart   # Session detail display
```

## Design Features

- **Dark Theme**: Black background with white/gray accents
- **Mobile-First**: Optimized for one-hand use
- **Minimal UI**: Clean, uncluttered interface
- **Modular Components**: Easy to style and extend
- **Bottom Navigation**: Quick access between main screens

## Future Enhancements

- Data persistence (local storage/database)
- Session editing functionality
- Statistics and progress tracking
- Photo/video attachments
- Social sharing features
- Training schedule integration

## Dependencies

- `flutter`: Core Flutter framework
- `intl`: Internationalization and date formatting
- `cupertino_icons`: iOS-style icons
- `flutter_svg`: SVG icon support

## Development

The app is built with Flutter and follows standard Flutter conventions. All UI components are modular and can be easily customized. The dark theme is consistently applied throughout the app for a cohesive user experience. 