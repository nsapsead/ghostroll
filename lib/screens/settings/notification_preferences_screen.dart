import 'package:flutter/material.dart';
import '../../services/push_notification_service.dart';
import '../../theme/ghostroll_theme.dart';
import '../../widgets/common/glow_text.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final PushNotificationService _notificationService = PushNotificationService();
  
  bool _dailyRemindersEnabled = true;
  bool _streakNotificationsEnabled = true;
  bool _goalReflectionsEnabled = true;
  bool _milestoneNotificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _dailyRemindersEnabled = _notificationService.dailyRemindersEnabled;
      _streakNotificationsEnabled = _notificationService.streakNotificationsEnabled;
      _goalReflectionsEnabled = _notificationService.goalReflectionsEnabled;
      _milestoneNotificationsEnabled = _notificationService.milestoneNotificationsEnabled;
      _reminderTime = _notificationService.reminderTime;
      _isLoading = false;
    });
  }

  Future<void> _updatePreferences() async {
    await _notificationService.updatePreferences(
      dailyReminders: _dailyRemindersEnabled,
      streakNotifications: _streakNotificationsEnabled,
      goalReflections: _goalReflectionsEnabled,
      milestoneNotifications: _milestoneNotificationsEnabled,
      reminderTime: _reminderTime,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification preferences updated!'),
          backgroundColor: GhostRollTheme.flowBlue.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: GhostRollTheme.flowBlue,
              onPrimary: Colors.white,
              surface: GhostRollTheme.card,
              onSurface: GhostRollTheme.text,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: GhostRollTheme.card,
              hourMinuteTextColor: GhostRollTheme.text,
              hourMinuteColor: GhostRollTheme.overlayDark,
              dialBackgroundColor: GhostRollTheme.overlayDark,
              dialHandColor: GhostRollTheme.flowBlue,
              dialTextColor: GhostRollTheme.text,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _updatePreferences();
    }
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? GhostRollTheme.flowBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? GhostRollTheme.flowBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: GhostRollTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: GhostRollTheme.flowBlue,
              activeTrackColor: GhostRollTheme.flowBlue.withOpacity(0.3),
              inactiveThumbColor: GhostRollTheme.textSecondary,
              inactiveTrackColor: GhostRollTheme.textSecondary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GhostRollTheme.flowBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.schedule,
                color: GhostRollTheme.flowBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reminder Time',
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get reminded to log your training session',
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: GhostRollTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: GhostRollTheme.flowBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: GhostRollTheme.flowBlue.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _reminderTime.format(context),
                  style: GhostRollTheme.bodyMedium.copyWith(
                    color: GhostRollTheme.flowBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: GhostRollTheme.primaryGradient,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GhostRollTheme.overlayDark.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const GlowText(
                      text: 'Notifications',
                      fontSize: 24,
                      textColor: Colors.white,
                      glowColor: Colors.white,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: GhostRollTheme.flowBlue,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: GhostRollTheme.overlayDark.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: GhostRollTheme.textSecondary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.notifications_active,
                                    color: GhostRollTheme.flowBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Stay motivated with helpful reminders and celebrate your progress! 👻',
                                      style: GhostRollTheme.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Notification Settings
                            Text(
                              'Notification Settings',
                              style: GhostRollTheme.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Daily Reminders
                            _buildNotificationCard(
                              title: 'Daily Reminders',
                              description: 'Get reminded to log your training session each day',
                              icon: Icons.schedule,
                              value: _dailyRemindersEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _dailyRemindersEnabled = value;
                                });
                                _updatePreferences();
                              },
                            ),
                            
                            // Streak Notifications
                            _buildNotificationCard(
                              title: 'Streak Encouragement',
                              description: 'Get motivated when you\'re close to achieving a new streak',
                              icon: Icons.local_fire_department,
                              value: _streakNotificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _streakNotificationsEnabled = value;
                                });
                                _updatePreferences();
                              },
                              iconColor: Colors.orange,
                            ),
                            
                            // Goal Reflections
                            _buildNotificationCard(
                              title: 'Goal Check-ins',
                              description: 'Periodic reminders to reflect on your training goals',
                              icon: Icons.flag,
                              value: _goalReflectionsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _goalReflectionsEnabled = value;
                                });
                                _updatePreferences();
                              },
                              iconColor: Colors.green,
                            ),
                            
                            // Milestone Notifications
                            _buildNotificationCard(
                              title: 'Training Milestones',
                              description: 'Celebrate when you reach training milestones',
                              icon: Icons.emoji_events,
                              value: _milestoneNotificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _milestoneNotificationsEnabled = value;
                                });
                                _updatePreferences();
                              },
                              iconColor: Colors.amber,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Time Settings
                            if (_dailyRemindersEnabled) ...[
                              Text(
                                'Reminder Time',
                                style: GhostRollTheme.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              _buildTimeCard(),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            // Test Notifications Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: GhostRollTheme.flowGradient,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: GhostRollTheme.small,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await _notificationService.showGoalReflection();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Test notification sent!'),
                                          backgroundColor: GhostRollTheme.flowBlue.withOpacity(0.9),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Send Test Notification',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Info Text
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: GhostRollTheme.overlayDark.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: GhostRollTheme.textSecondary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: GhostRollTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Notifications are designed to be helpful, not annoying. You\'ll receive at most one notification per day.',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
} 