import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class SimpleNotificationService {
  static final SimpleNotificationService _instance = SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification channels
  static const String _dailyReminderChannel = 'daily_reminders';
  static const String _streakChannel = 'streak_encouragement';
  static const String _goalChannel = 'goal_reflection';
  static const String _milestoneChannel = 'milestones';

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels
      await _createNotificationChannels();

      _isInitialized = true;
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing SimpleNotificationService: $e');
    }
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const androidChannel = AndroidNotificationChannel(
      _dailyReminderChannel,
      'Daily Reminders',
      description: 'Daily training reminders',
      importance: Importance.high,
    );

    const streakChannel = AndroidNotificationChannel(
      _streakChannel,
      'Streak Encouragement',
      description: 'Motivational messages for your training streak',
      importance: Importance.low,
    );

    const goalChannel = AndroidNotificationChannel(
      _goalChannel,
      'Goal Reflection',
      description: 'Reminders to reflect on your training goals',
      importance: Importance.low,
    );

    const milestoneChannel = AndroidNotificationChannel(
      _milestoneChannel,
      'Milestones',
      description: 'Celebrations for training milestones',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(streakChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(goalChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(milestoneChannel);
  }

  // Handle notification taps
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // You can add navigation logic here later
  }

  // Schedule a daily reminder
  Future<void> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        1, // Daily reminder ID
        '👻 Time to Train!',
        'Your daily training session is calling. Ready to roll?',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyReminderChannel,
            'Daily Reminders',
            channelDescription: 'Daily training reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Save reminder time to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_reminder_hour', hour);
      await prefs.setInt('daily_reminder_minute', minute);

      debugPrint('Daily reminder scheduled for $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  // Send a test notification
  Future<void> sendTestNotification() async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.show(
        999, // Test notification ID
        '👻 GhostRoll Test',
        'This is a test notification from GhostRoll!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyReminderChannel,
            'Daily Reminders',
            channelDescription: 'Daily training reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'dailyReminderEnabled': prefs.getBool('daily_reminder_enabled') ?? false,
      'dailyReminderHour': prefs.getInt('daily_reminder_hour') ?? 20,
      'dailyReminderMinute': prefs.getInt('daily_reminder_minute') ?? 0,
    };
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (dailyReminderEnabled != null) {
      await prefs.setBool('daily_reminder_enabled', dailyReminderEnabled);
    }
    
    if (dailyReminderHour != null) {
      await prefs.setInt('daily_reminder_hour', dailyReminderHour);
    }
    
    if (dailyReminderMinute != null) {
      await prefs.setInt('daily_reminder_minute', dailyReminderMinute);
    }

    // If enabling daily reminder, schedule it
    if (dailyReminderEnabled == true) {
      final hour = dailyReminderHour ?? prefs.getInt('daily_reminder_hour') ?? 20;
      final minute = dailyReminderMinute ?? prefs.getInt('daily_reminder_minute') ?? 0;
      await scheduleDailyReminder(hour: hour, minute: minute);
    } else if (dailyReminderEnabled == false) {
      // Cancel daily reminder
      await _notifications.cancel(1);
    }
  }

  // Dispose resources
  void dispose() {
    // No specific disposal needed for local notifications
  }
} 