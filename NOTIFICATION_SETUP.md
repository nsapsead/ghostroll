# GhostRoll Push Notification System Setup

This guide will help you set up and configure the comprehensive push notification system for GhostRoll using Firebase Cloud Messaging (FCM) and local notifications.

## 🚀 Features Implemented

### ✅ FCM Integration
- Firebase Cloud Messaging setup for both Android and iOS
- Background message handling
- Foreground message handling with custom local notifications
- App opened from notification navigation
- Permission requests for iOS

### ✅ Local Notifications
- Daily reminder notifications at 8 PM (customizable)
- Streak encouragement notifications
- Goal reflection notifications
- Milestone celebration notifications
- Custom notification channels for Android
- Rich notification styling with GhostRoll branding

### ✅ User Preferences
- Toggle individual notification types on/off
- Customizable daily reminder time
- Persistent preferences storage
- Beautiful settings UI integrated into profile screen

### ✅ Smart Notification Logic
- One notification per day maximum
- Milestone tracking (5, 10, 25, 50, 100, 250, 500 sessions)
- Goal reflection every 7 days
- Streak encouragement when user hasn't logged today

## 📱 Notification Types

### 1. Daily Reminders 👻
- **Title**: "Did you roll today, Ghost?"
- **Body**: "Time to log your training session and keep your streak alive!"
- **Schedule**: Daily at 8 PM (customizable)
- **Channel**: High priority with sound and vibration

### 2. Streak Encouragement 🔥
- **Title**: "Streak Alert!"
- **Body**: "You're just 1 day away from a new Ghost Streak!"
- **Trigger**: When user hasn't logged a session today
- **Channel**: High priority with sound and vibration

### 3. Goal Reflections 🎯
- **Title**: "Goal Check-in"
- **Body**: "Tap here to reflect on your training goal progress."
- **Schedule**: Every 7 days
- **Channel**: Medium priority with sound only

### 4. Training Milestones 🏆
- **Title**: "Training Milestone!"
- **Body**: "You've logged [X] training sessions! Keep up the great work!"
- **Trigger**: At 5, 10, 25, 50, 100, 250, 500 sessions
- **Channel**: High priority with sound and vibration

## 🔧 Setup Instructions

### Step 1: Firebase Configuration

1. **Create Firebase Project** (if not already done):
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```

2. **Update Firebase Options**:
   - Replace placeholder values in `lib/firebase_options.dart` with your actual Firebase project credentials
   - Download `google-services.json` for Android and place in `android/app/`
   - Download `GoogleService-Info.plist` for iOS and add to Xcode project

### Step 2: Android Configuration

1. **Add to `android/app/build.gradle`**:
   ```gradle
   android {
       defaultConfig {
           // ... existing config
           multiDexEnabled true
       }
   }
   
   dependencies {
       // ... existing dependencies
       implementation 'com.google.firebase:firebase-messaging:23.4.0'
   }
   ```

2. **Add to `android/app/src/main/AndroidManifest.xml`**:
   ```xml
   <manifest>
       <application>
           <!-- ... existing config -->
           <service
               android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
               android:exported="false">
               <intent-filter>
                   <action android:name="com.google.firebase.MESSAGING_EVENT" />
               </intent-filter>
           </service>
       </application>
   </manifest>
   ```

### Step 3: iOS Configuration

1. **Add to `ios/Runner/Info.plist`**:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>fetch</string>
       <string>remote-notification</string>
   </array>
   ```

2. **Add to `ios/Runner/AppDelegate.swift`**:
   ```swift
   import UIKit
   import Flutter
   import Firebase
   import FirebaseMessaging
   
   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       FirebaseApp.configure()
       
       if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self
         let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
         UNUserNotificationCenter.current().requestAuthorization(
           options: authOptions,
           completionHandler: { _, _ in }
         )
       } else {
         let settings: UIUserNotificationSettings =
           UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
         application.registerUserNotificationSettings(settings)
       }
       
       application.registerForRemoteNotifications()
       
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

## 🎯 Usage Examples

### Basic Usage

```dart
import 'package:your_app/services/push_notification_service.dart';

// Initialize the service (done in main.dart)
final notificationService = PushNotificationService();
await notificationService.initialize();

// Schedule daily reminder
await notificationService.scheduleDailyReminder();

// Show a milestone notification
await notificationService.showMilestoneNotification('10 training sessions logged! 🔥');

// Update user preferences
await notificationService.updatePreferences(
  dailyReminders: true,
  reminderTime: TimeOfDay(hour: 20, minute: 0),
);
```

### Advanced Usage with Example Service

```dart
import 'package:your_app/services/notification_example_service.dart';

final exampleService = NotificationExampleService();

// When user logs a training session
await exampleService.onSessionLogged();

// Check for streak encouragement
await exampleService.checkAndShowStreakEncouragement();

// Show periodic goal reflection
await exampleService.showPeriodicGoalReflection();
```

### Integration with Session Logging

```dart
// In your session logging service
class SessionService {
  final NotificationExampleService _notificationService = NotificationExampleService();
  
  Future<void> logSession(Session session) async {
    // ... existing session logging logic
    
    // Trigger notification checks
    await _notificationService.onSessionLogged();
  }
}
```

## 🎨 Customization

### Notification Strings

Edit `lib/core/constants/notification_strings.dart` to customize:
- Notification titles and messages
- Default reminder time
- Notification IDs and channel IDs
- Frequency limits

### Notification Styling

The notification system uses the GhostRoll theme colors:
- **Primary**: `GhostRollTheme.flowBlue`
- **Background**: `GhostRollTheme.card`
- **Text**: `GhostRollTheme.text`

### Custom Notification Types

To add new notification types:

1. **Add to constants**:
   ```dart
   // In notification_strings.dart
   static const String customNotificationTitle = 'Custom Title';
   static const String customNotificationBody = 'Custom body text';
   static const int customNotificationId = 1005;
   ```

2. **Add to service**:
   ```dart
   // In push_notification_service.dart
   Future<void> showCustomNotification() async {
     await _localNotifications.show(
       NotificationStrings.customNotificationId,
       NotificationStrings.customNotificationTitle,
       NotificationStrings.customNotificationBody,
       // ... notification details
     );
   }
   ```

## 🔍 Testing

### Test Notifications

1. **Use the test button** in the notification preferences screen
2. **Manual testing**:
   ```dart
   // Test daily reminder
   await notificationService.scheduleDailyReminder();
   
   // Test milestone
   await notificationService.showMilestoneNotification('Test milestone!');
   
   // Test goal reflection
   await notificationService.showGoalReflection();
   ```

### Debug Information

The service logs debug information:
- FCM token retrieval
- Permission status
- Notification scheduling
- Background message handling

### Reset for Testing

```dart
final exampleService = NotificationExampleService();
await exampleService.resetNotificationPreferences();
```

## 🚨 Troubleshooting

### Common Issues

1. **"Firebase not initialized"**
   - Ensure `Firebase.initializeApp()` is called in `main.dart`
   - Check Firebase configuration files are properly placed

2. **"Permission denied"**
   - Request permissions explicitly on iOS
   - Check device notification settings

3. **"Notifications not showing"**
   - Verify notification channels are created (Android)
   - Check notification preferences are enabled
   - Ensure app has notification permissions

4. **"Background messages not working"**
   - Verify background handler is properly registered
   - Check iOS background modes are configured

### Debug Commands

```dart
// Get FCM token
String? token = await notificationService.getFCMToken();
print('FCM Token: $token');

// Check notification preferences
print('Daily reminders: ${notificationService.dailyRemindersEnabled}');
print('Reminder time: ${notificationService.reminderTime}');

// Cancel all notifications
await notificationService.cancelAllNotifications();
```

## 📊 Analytics Integration

The notification system can be integrated with analytics:

```dart
// Track notification interactions
notificationService.onMessageOpenedAppStream.listen((message) {
  // Send analytics event
  analytics.track('notification_opened', {
    'type': message.data['type'],
    'title': message.notification?.title,
  });
});
```

## 🔒 Security Best Practices

1. **FCM Token Security**: Store tokens securely if needed for server-side messaging
2. **Permission Handling**: Always check and request permissions gracefully
3. **Rate Limiting**: Respect user preferences and avoid notification spam
4. **Data Privacy**: Don't include sensitive data in notification payloads

## 🎯 Next Steps

1. **Server Integration**: Set up Firebase Functions for server-side notification triggers
2. **Advanced Scheduling**: Implement more sophisticated notification timing logic
3. **Rich Notifications**: Add images and action buttons to notifications
4. **A/B Testing**: Test different notification messages and timing
5. **Analytics**: Track notification effectiveness and user engagement

---

Your GhostRoll app now has a comprehensive, user-friendly notification system that will help keep users motivated and engaged with their martial arts training! 🥋👻 