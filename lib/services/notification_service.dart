import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class NotificationService {
  static void showAchievementNotification(BuildContext context, String achievementName, String description, String emoji) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    achievementName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.currentThemeData.primary.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '🎉',
          textColor: Colors.white,
          onPressed: () {
            HapticFeedback.mediumImpact();
          },
        ),
      ),
    );
  }

  static void showStreakNotification(BuildContext context, int streak, bool isNewAchievement) {
    HapticFeedback.lightImpact();
    final emoji = _getStreakEmoji(streak);
    final message = _getStreakMessage(streak, isNewAchievement);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$streak Day Streak!',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.currentThemeData.accent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '🔥',
          textColor: Colors.white,
          onPressed: () {
            HapticFeedback.mediumImpact();
          },
        ),
      ),
    );
  }

  static void showEncouragementNotification(BuildContext context, String message, String emoji) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.currentThemeData.secondary.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSessionLoggedNotification(BuildContext context, int totalSessions) {
    HapticFeedback.lightImpact();
    final messages = [
      'Great session! 👻',
      'You\'re crushing it! 💪',
      'Another step forward! 🚀',
      'Keep the momentum! 🔥',
      'You\'re unstoppable! ⚔️',
    ];
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('👻', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    randomMessage,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Total sessions: $totalSessions',
                    style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.currentThemeData.primary.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _getStreakEmoji(int streak) {
    if (streak == 0) return '👻';
    if (streak < 3) return '🌱';
    if (streak < 7) return '🔥';
    if (streak < 14) return '⚔️';
    if (streak < 30) return '🚀';
    if (streak < 100) return '👑';
    return '💎';
  }

  static String _getStreakMessage(int streak, bool isNewAchievement) {
    if (isNewAchievement) {
      return 'Achievement unlocked! 🎉';
    }
    if (streak == 1) {
      return 'First step taken! 🌱';
    } else if (streak < 3) {
      return 'Building momentum! 💪';
    } else if (streak < 7) {
      return 'You\'re on fire! 🔥';
    } else if (streak < 14) {
      return 'Week warrior! ⚔️';
    } else if (streak < 30) {
      return 'Unstoppable! 🚀';
    } else if (streak < 100) {
      return 'Month master! 👑';
    } else {
      return 'Legendary! 💎';
    }
  }
} 