import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/quick_log_screen.dart';
import 'screens/journal_timeline_screen.dart';
import 'screens/log_session_form.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_preferences_screen.dart';
import 'services/simple_notification_service.dart';
import 'theme/ghostroll_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Initialize notification service
    final notificationService = SimpleNotificationService();
    await notificationService.initialize();
    debugPrint('Notification service initialized successfully');
  } catch (e, stackTrace) {
    // Log detailed error information but don't crash the app
    debugPrint('Error initializing services: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Check if it's a Firebase configuration error
    if (e.toString().contains('API_KEY') || 
        e.toString().contains('appId') || 
        e.toString().contains('projectId')) {
      debugPrint('CRITICAL: Firebase configuration error detected!');
      debugPrint('Please check your firebase_options.dart file and ensure all placeholder values are replaced with real Firebase configuration.');
      debugPrint('Also verify that google-services.json (Android) and GoogleService-Info.plist (iOS) contain real values.');
    }
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const GhostRollApp());
}

class GhostRollApp extends StatefulWidget {
  const GhostRollApp({super.key});

  @override
  State<GhostRollApp> createState() => _GhostRollAppState();
}

class _GhostRollAppState extends State<GhostRollApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhostRoll',
      debugShowCheckedModeBanner: false,
      theme: GhostRollTheme.dark,
      navigatorKey: _navigatorKey,
      home: const AuthWrapper(),
      routes: {
        '/quick-log': (context) => const QuickLogScreen(),
        '/journal-timeline': (context) => const JournalTimelineScreen(),
        '/log-session': (context) => const LogSessionForm(),
        '/profile': (context) => const ProfileScreen(),
        '/notification-preferences': (context) => const NotificationPreferencesScreen(),
      },
    );
  }
  

} 