# GhostRoll - Martial Arts Training Journal

A modern, dark-themed Flutter app designed to help martial artists track their training progress, log sessions, and manage their martial arts journey.

![GhostRoll Logo](assets/images/GhostRollBeltMascot.png)

## 🥋 Features

### 📱 Core Functionality
- **Quick Log**: Fast session logging with body diagram for injury tracking
- **Journal Timeline**: Chronological view of all training sessions
- **Session Form**: Detailed session logging with structured forms
- **Profile Management**: Comprehensive martial artist profiles

### 🎯 Profile System
- **Personal Information**: Name, age, gender, weight, height, experience
- **Martial Arts Styles**: Support for multiple styles including:
  - Brazilian Jiu-Jitsu (BJJ) with stripe tracking
  - Karate with customizable belt orders
  - Judo, Taekwondo, Muay Thai, Boxing, Wrestling, Kickboxing, Krav Maga, Aikido
- **Belt Rank Tracking**: 
  - BJJ: White → Blue → Purple → Brown → Black (with 0-4 stripes per belt)
  - Karate: Customizable belt progression systems
  - Other styles: Standard belt systems

### 🎨 Design
- **Dark Theme**: Modern, sleek dark UI with gradient backgrounds
- **Responsive Design**: Optimized for various screen sizes
- **Smooth Animations**: Fluid transitions and interactions
- **Custom Branding**: GhostRoll logo integration throughout the app

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator (for iOS development) or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/GhostRoll.git
   cd GhostRoll
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase API keys**

   ```bash
   cp env/firebase_keys.env.example env/firebase_keys.env
   # edit env/firebase_keys.env with the rotated keys from Firebase Console
   ```

4. **Run the app (loads keys from the env file)**
   ```bash
   flutter run --dart-define-from-file=env/firebase_keys.env
   ```

### Building for Production

**Android APK (remember to include the env file):**
```bash
flutter build apk --release --dart-define-from-file=env/firebase_keys.env
```

**iOS:**
```bash
flutter build ios --release --dart-define-from-file=env/firebase_keys.env
```

**Web:**
```bash
flutter build web --release --dart-define-from-file=env/firebase_keys.env
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── screens/
│   ├── quick_log_screen.dart     # Quick session logging
│   ├── journal_timeline_screen.dart  # Training history
│   ├── log_session_form.dart     # Detailed session form
│   └── profile_screen.dart       # User profile management
└── widgets/                  # Reusable UI components

assets/
├── images/
│   └── GhostRollBeltMascot.png    # App logo
└── icons/                    # Custom app icons
```

## 🎯 Usage Guide

### Quick Log
- Tap the "+" button to quickly log a training session
- Use the body diagram to mark areas of focus or injury
- Add quick notes about your session

### Journal Timeline
- View all your training sessions in chronological order
- Tap on any session to view details
- Filter and search through your training history

### Session Form
- Complete detailed session logging with structured forms
- Track techniques practiced, sparring partners, and performance
- Add notes and observations for future reference

### Profile Management
- Complete your personal information and martial arts background
- Select multiple martial arts styles you practice
- Customize belt orders for Karate styles
- Track BJJ stripes for each belt level

## 🛠️ Technical Details

### Dependencies
- **Flutter**: Latest stable version
- **flutter_svg**: For SVG icon support
- **Standard Flutter packages**: Material Design, Cupertino

### Architecture
- **State Management**: Flutter's built-in StatefulWidget
- **Navigation**: Bottom navigation with tab-based routing
- **UI Framework**: Material Design 3 with custom dark theme
- **Asset Management**: Organized asset structure with proper pubspec.yaml configuration

### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS (with additional configuration)

## 🎨 Customization

### Adding New Martial Arts Styles
1. Edit the `_martialArtsStyles` list in `profile_screen.dart`
2. Add the style name, belt progression, and flags for stripes/customization
3. Update the UI logic as needed

### Modifying the Theme
1. Edit the `_buildFantasticTheme()` method in `main.dart`
2. Customize colors, typography, and component styles
3. Update gradient definitions throughout the app

### Adding New Features
1. Create new screen files in the `screens/` directory
2. Add navigation routes in `main.dart`
3. Update the bottom navigation if needed

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- Martial arts community for inspiration and feedback

## 📞 Support

If you have any questions or need help with the app, please:
- Open an issue on GitHub
- Check the documentation
- Review the code comments

---

**GhostRoll** - Track your martial arts journey with style and precision. 🥋👻 