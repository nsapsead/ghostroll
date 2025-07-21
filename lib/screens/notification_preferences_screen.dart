import 'package:flutter/material.dart';
import '../theme/ghostroll_theme.dart';
import '../services/simple_notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final SimpleNotificationService _notificationService = SimpleNotificationService();
  
  bool _dailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final settings = await _notificationService.getNotificationSettings();
      setState(() {
        _dailyReminderEnabled = settings['dailyReminderEnabled'] ?? false;
        _dailyReminderTime = TimeOfDay(
          hour: settings['dailyReminderHour'] ?? 20,
          minute: settings['dailyReminderMinute'] ?? 0,
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDailyReminder(bool enabled) async {
    setState(() {
      _dailyReminderEnabled = enabled;
    });

    try {
      await _notificationService.updateNotificationSettings(
        dailyReminderEnabled: enabled,
        dailyReminderHour: _dailyReminderTime.hour,
        dailyReminderMinute: _dailyReminderTime.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? 'Daily reminder enabled!' : 'Daily reminder disabled'),
            backgroundColor: enabled 
                ? GhostRollTheme.recoveryGreen.withOpacity(0.9)
                : GhostRollTheme.textSecondary.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Error updating daily reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating notification settings: $e'),
            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _updateReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );

    if (picked != null) {
      setState(() {
        _dailyReminderTime = picked;
      });

      try {
        await _notificationService.updateNotificationSettings(
          dailyReminderEnabled: _dailyReminderEnabled,
          dailyReminderHour: picked.hour,
          dailyReminderMinute: picked.minute,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder time updated to ${picked.format(context)}'),
              backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        print('Error updating reminder time: $e');
      }
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Test notification sent!'),
            backgroundColor: GhostRollTheme.flowBlue.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Error sending test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending test notification: $e'),
            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GhostRollTheme.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: GhostRollTheme.flowBlue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GhostRollTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification Settings',
          style: GhostRollTheme.headlineSmall.copyWith(
            color: GhostRollTheme.text,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Stay Motivated',
              style: GhostRollTheme.headlineMedium.copyWith(
                color: GhostRollTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure notifications to keep your training momentum going',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Daily Reminder Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GhostRollTheme.card.withOpacity(0.8),
                    GhostRollTheme.card.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: GhostRollTheme.flowBlue.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: GhostRollTheme.flowBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Daily Training Reminder',
                        style: GhostRollTheme.titleMedium.copyWith(
                          color: GhostRollTheme.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Get a daily reminder to log your training session and maintain your streak',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      color: GhostRollTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Toggle Switch
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Enable Daily Reminder',
                          style: GhostRollTheme.bodyMedium.copyWith(
                            color: GhostRollTheme.text,
                          ),
                        ),
                      ),
                      Switch(
                        value: _dailyReminderEnabled,
                        onChanged: _updateDailyReminder,
                        activeColor: GhostRollTheme.flowBlue,
                        activeTrackColor: GhostRollTheme.flowBlue.withOpacity(0.3),
                      ),
                    ],
                  ),
                  
                  if (_dailyReminderEnabled) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reminder Time',
                            style: GhostRollTheme.bodyMedium.copyWith(
                              color: GhostRollTheme.text,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _updateReminderTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: GhostRollTheme.flowBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: GhostRollTheme.flowBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _dailyReminderTime.format(context),
                              style: GhostRollTheme.bodyMedium.copyWith(
                                color: GhostRollTheme.flowBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Test Notification Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GhostRollTheme.card.withOpacity(0.8),
                    GhostRollTheme.card.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: GhostRollTheme.recoveryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.science,
                        color: GhostRollTheme.recoveryGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Test Notifications',
                        style: GhostRollTheme.titleMedium.copyWith(
                          color: GhostRollTheme.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Send a test notification to make sure everything is working correctly',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      color: GhostRollTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendTestNotification,
                      icon: const Icon(Icons.send),
                      label: const Text('Send Test Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GhostRollTheme.recoveryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GhostRollTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GhostRollTheme.textSecondary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: GhostRollTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifications help you stay consistent with your training. You can adjust these settings anytime.',
                      style: GhostRollTheme.bodySmall.copyWith(
                        color: GhostRollTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 