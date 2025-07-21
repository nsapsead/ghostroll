import 'package:shared_preferences/shared_preferences.dart';
import 'push_notification_service.dart';

/// Example service demonstrating how to use the notification system
/// This service shows how to trigger notifications based on user actions
class NotificationExampleService {
  static final NotificationExampleService _instance = NotificationExampleService._internal();
  factory NotificationExampleService() => _instance;
  NotificationExampleService._internal();

  final PushNotificationService _notificationService = PushNotificationService();

  /// Check if user has logged a session today and show streak encouragement if needed
  Future<void> checkAndShowStreakEncouragement() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSessionDate = prefs.getString('last_session_date');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    
    // If user hasn't logged a session today, show encouragement
    if (lastSessionDate != currentDate) {
      await _notificationService.scheduleStreakEncouragement();
    }
  }

  /// Show milestone notification when user reaches certain log counts
  Future<void> checkAndShowMilestone(int sessionCount) async {
    final milestones = [5, 10, 25, 50, 100, 250, 500];
    
    if (milestones.contains(sessionCount)) {
      String milestoneText = '';
      switch (sessionCount) {
        case 5:
          milestoneText = '5 training sessions logged! 🥋';
          break;
        case 10:
          milestoneText = '10 training sessions logged! 🔥';
          break;
        case 25:
          milestoneText = '25 training sessions logged! 💪';
          break;
        case 50:
          milestoneText = '50 training sessions logged! 🏆';
          break;
        case 100:
          milestoneText = '100 training sessions logged! 🎯';
          break;
        case 250:
          milestoneText = '250 training sessions logged! 👑';
          break;
        case 500:
          milestoneText = '500 training sessions logged! 🏅';
          break;
      }
      
      await _notificationService.showMilestoneNotification(milestoneText);
    }
  }

  /// Show goal reflection notification periodically
  Future<void> showPeriodicGoalReflection() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGoalReflection = prefs.getString('last_goal_reflection');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    
    // Show goal reflection every 7 days
    if (lastGoalReflection == null || 
        DateTime.parse(lastGoalReflection).difference(DateTime.parse(currentDate)).inDays.abs() >= 7) {
      await _notificationService.showGoalReflection();
      await prefs.setString('last_goal_reflection', currentDate);
    }
  }

  /// Update last session date when user logs a training session
  Future<void> onSessionLogged() async {
    final prefs = await SharedPreferences.getInstance();
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_session_date', currentDate);
    
    // Get session count for milestone checking
    final sessionCount = prefs.getInt('total_sessions') ?? 0;
    final newCount = sessionCount + 1;
    await prefs.setInt('total_sessions', newCount);
    
    // Check for milestones
    await checkAndShowMilestone(newCount);
  }

  /// Reset notification preferences (useful for testing)
  Future<void> resetNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_session_date');
    await prefs.remove('last_goal_reflection');
    await prefs.remove('total_sessions');
  }

  /// Get current session count
  Future<int> getSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('total_sessions') ?? 0;
  }

  /// Check if user has logged a session today
  Future<bool> hasLoggedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSessionDate = prefs.getString('last_session_date');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    return lastSessionDate == currentDate;
  }
} 