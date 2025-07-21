import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/constants/notification_strings.dart';

// Global variable to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Stream controllers for notification events
  final StreamController<RemoteMessage> _onMessageStreamController = StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _onMessageOpenedAppStreamController = StreamController<RemoteMessage>.broadcast();
  
  // Getters for streams
  Stream<RemoteMessage> get onMessageStream => _onMessageStreamController.stream;
  Stream<RemoteMessage> get onMessageOpenedAppStream => _onMessageOpenedAppStreamController.stream;
  
  // Notification preferences
  bool _dailyRemindersEnabled = true;
  bool _streakNotificationsEnabled = true;
  bool _goalReflectionsEnabled = true;
  bool _milestoneNotificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0); // 8 PM default
  
  // Getters for preferences
  bool get dailyRemindersEnabled => _dailyRemindersEnabled;
  bool get streakNotificationsEnabled => _streakNotificationsEnabled;
  bool get goalReflectionsEnabled => _goalReflectionsEnabled;
  bool get milestoneNotificationsEnabled => _milestoneNotificationsEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      
      // Set up Firebase messaging
      await _setupFirebaseMessaging();
      
      // Set up local notifications
      await _setupLocalNotifications();
      
      // Load user preferences
      await _loadNotificationPreferences();
      
      // Request permissions
      await _requestPermissions();
      
      debugPrint('Push notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing push notification service: $e');
    }
  }

  /// Set up Firebase Cloud Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');
      
      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
      
      _onMessageStreamController.add(message);
    });
    
    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _onMessageOpenedAppStreamController.add(message);
    });
    
    // Handle initial message when app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state with message: ${initialMessage.data}');
      _onMessageOpenedAppStreamController.add(initialMessage);
    }
  }

  /// Set up local notifications
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channels
    await _createNotificationChannels();
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Daily reminders channel
      const AndroidNotificationChannel dailyRemindersChannel = AndroidNotificationChannel(
        NotificationStrings.dailyReminderChannel,
        'Daily Reminders',
        description: 'Daily training reminders',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      
      // Streak notifications channel
      const AndroidNotificationChannel streakChannel = AndroidNotificationChannel(
        NotificationStrings.streakChannel,
        'Streak Notifications',
        description: 'Training streak updates and encouragement',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      
      // Goal reflections channel
      const AndroidNotificationChannel goalChannel = AndroidNotificationChannel(
        NotificationStrings.goalChannel,
        'Goal Reflections',
        description: 'Goal check-ins and reflections',
        importance: Importance.low,
        playSound: true,
        enableVibration: false,
        showBadge: true,
      );
      
      // Milestones channel
      const AndroidNotificationChannel milestoneChannel = AndroidNotificationChannel(
        NotificationStrings.milestoneChannel,
        'Training Milestones',
        description: 'Achievement and milestone notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(dailyRemindersChannel);
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(streakChannel);
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(goalChannel);
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(milestoneChannel);
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request FCM permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    debugPrint('User granted permission: ${settings.authorizationStatus}');
    
    // Request local notification permissions for iOS
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Load notification preferences from SharedPreferences
  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _dailyRemindersEnabled = prefs.getBool('daily_reminders_enabled') ?? true;
    _streakNotificationsEnabled = prefs.getBool('streak_notifications_enabled') ?? true;
    _goalReflectionsEnabled = prefs.getBool('goal_reflections_enabled') ?? true;
    _milestoneNotificationsEnabled = prefs.getBool('milestone_notifications_enabled') ?? true;
    
    final reminderHour = prefs.getInt('reminder_hour') ?? 20;
    final reminderMinute = prefs.getInt('reminder_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
  }

  /// Save notification preferences to SharedPreferences
  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('daily_reminders_enabled', _dailyRemindersEnabled);
    await prefs.setBool('streak_notifications_enabled', _streakNotificationsEnabled);
    await prefs.setBool('goal_reflections_enabled', _goalReflectionsEnabled);
    await prefs.setBool('milestone_notifications_enabled', _milestoneNotificationsEnabled);
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);
  }

  /// Show a local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      NotificationStrings.dailyReminderChannel,
      'Daily Reminders',
      channelDescription: 'Daily training reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'GhostRoll',
      message.notification?.body ?? 'You have a new notification',
      platformChannelSpecifics,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on notification type
    // This will be implemented based on your app's navigation structure
  }

  /// Schedule daily reminder notification
  Future<void> scheduleDailyReminder() async {
    if (!_dailyRemindersEnabled) return;
    
    await _localNotifications.zonedSchedule(
      NotificationStrings.dailyReminderId,
      NotificationStrings.dailyReminderTitle,
      NotificationStrings.dailyReminderBody,
      _nextInstanceOfTime(_reminderTime.hour, _reminderTime.minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationStrings.dailyReminderChannel,
          'Daily Reminders',
          channelDescription: 'Daily training reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    debugPrint('Daily reminder scheduled for ${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}');
  }

  /// Schedule streak encouragement notification
  Future<void> scheduleStreakEncouragement() async {
    if (!_streakNotificationsEnabled) return;
    
    await _localNotifications.zonedSchedule(
      NotificationStrings.streakEncouragementId,
      NotificationStrings.streakEncouragementTitle,
      NotificationStrings.streakEncouragementBody,
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 2)), // Schedule for 2 hours from now
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationStrings.streakChannel,
          'Streak Notifications',
          channelDescription: 'Training streak updates and encouragement',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Show goal reflection notification
  Future<void> showGoalReflection() async {
    if (!_goalReflectionsEnabled) return;
    
    await _localNotifications.show(
      NotificationStrings.goalReflectionId,
      NotificationStrings.goalReflectionTitle,
      NotificationStrings.goalReflectionBody,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationStrings.goalChannel,
          'Goal Reflections',
          channelDescription: 'Goal check-ins and reflections',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          enableVibration: false,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show milestone notification
  Future<void> showMilestoneNotification(String milestone) async {
    if (!_milestoneNotificationsEnabled) return;
    
    await _localNotifications.show(
      NotificationStrings.logMilestoneId,
      NotificationStrings.logMilestoneTitle,
      'You\'ve achieved: $milestone! Keep up the great work! 🏆',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationStrings.milestoneChannel,
          'Training Milestones',
          channelDescription: 'Achievement and milestone notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Update notification preferences
  Future<void> updatePreferences({
    bool? dailyReminders,
    bool? streakNotifications,
    bool? goalReflections,
    bool? milestoneNotifications,
    TimeOfDay? reminderTime,
  }) async {
    if (dailyReminders != null) _dailyRemindersEnabled = dailyReminders;
    if (streakNotifications != null) _streakNotificationsEnabled = streakNotifications;
    if (goalReflections != null) _goalReflectionsEnabled = goalReflections;
    if (milestoneNotifications != null) _milestoneNotificationsEnabled = milestoneNotifications;
    if (reminderTime != null) _reminderTime = reminderTime;
    
    await _saveNotificationPreferences();
    
    // Reschedule daily reminder if time changed
    if (reminderTime != null && _dailyRemindersEnabled) {
      await cancelDailyReminder();
      await scheduleDailyReminder();
    }
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(NotificationStrings.dailyReminderId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Helper method to get next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Dispose resources
  void dispose() {
    _onMessageStreamController.close();
    _onMessageOpenedAppStreamController.close();
  }
} 