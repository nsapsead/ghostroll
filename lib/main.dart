import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/quick_log_screen.dart';
import 'screens/journal_timeline_screen.dart';
import 'screens/log_session_form.dart';
import 'screens/profile_screen.dart';
import 'theme/ghostroll_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
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

class GhostRollApp extends StatelessWidget {
  const GhostRollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhostRoll',
      debugShowCheckedModeBanner: false,
      theme: GhostRollTheme.dark,
      home: const MainNavigationScreen(), // TEMP: bypass auth for now
      routes: {
        '/quick-log': (context) => const QuickLogScreen(),
        '/journal-timeline': (context) => const JournalTimelineScreen(),
        '/log-session': (context) => const LogSessionForm(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
} 