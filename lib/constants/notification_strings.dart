class NotificationStrings {
  // Daily reminder notifications
  static const String dailyReminderTitle = 'Did you roll today, Ghost? 👻';
  static const String dailyReminderBody = 'Time to log your training session and keep your streak alive!';
  
  // Streak encouragement notifications
  static const String streakEncouragementTitle = 'Streak Alert! 🔥';
  static const String streakEncouragementBody = 'You\'re just 1 day away from a new Ghost Streak!';
  static const String streakMilestoneTitle = 'Ghost Streak Achieved! 👻✨';
  static const String streakMilestoneBody = 'Congratulations! You\'ve maintained your training streak!';
  
  // Goal reflection notifications
  static const String goalReflectionTitle = 'Goal Check-in 🎯';
  static const String goalReflectionBody = 'Tap here to reflect on your training goal progress.';
  
  // Milestone notifications
  static const String logMilestoneTitle = 'Training Milestone! 🏆';
  static const String logMilestoneBody = 'You\'ve logged 10 training sessions! Keep up the great work!';
  
  // General notification strings
  static const String appName = 'GhostRoll';
  static const String channelName = 'GhostRoll Notifications';
  static const String channelDescription = 'Stay motivated with your martial arts training';
  
  // Notification IDs
  static const int dailyReminderId = 1001;
  static const int streakEncouragementId = 1002;
  static const int goalReflectionId = 1003;
  static const int logMilestoneId = 1004;
  
  // Channel IDs
  static const String dailyReminderChannel = 'daily_reminders';
  static const String streakChannel = 'streak_notifications';
  static const String goalChannel = 'goal_reflections';
  static const String milestoneChannel = 'milestones';
  
  // Default notification times (24-hour format)
  static const int defaultReminderHour = 20; // 8 PM
  static const int defaultReminderMinute = 0;
  
  // Notification frequency limits
  static const int maxDailyNotifications = 1;
  static const int minHoursBetweenNotifications = 6;
} 