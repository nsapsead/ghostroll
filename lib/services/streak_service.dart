import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _currentStreakKey = 'ghost_current_streak';
  static const String _longestStreakKey = 'ghost_longest_streak';
  static const String _totalSessionsKey = 'ghost_total_sessions';
  static const String _lastLogDateKey = 'ghost_last_log_date';
  static const String _achievementsKey = 'ghost_achievements';

  // Get all streak data
  static Future<Map<String, dynamic>> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    final totalSessions = prefs.getInt(_totalSessionsKey) ?? 0;
    final lastLogDate = prefs.getString(_lastLogDateKey);
    final achievements = prefs.getStringList(_achievementsKey) ?? [];
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSessions': totalSessions,
      'lastLogDate': lastLogDate,
      'achievements': achievements,
    };
  }

  // Log a new session and update streaks
  static Future<Map<String, dynamic>> logSession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    final lastLogDateStr = prefs.getString(_lastLogDateKey);
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    int totalSessions = prefs.getInt(_totalSessionsKey) ?? 0;
    List<String> achievements = prefs.getStringList(_achievementsKey) ?? [];

    bool isConsecutive = false;
    if (lastLogDateStr != null) {
      final lastDate = DateTime.parse(lastLogDateStr);
      final difference = today.difference(lastDate).inDays;
      isConsecutive = difference == 1;
      // If user logs multiple times in one day, don't increment streak
      if (difference == 0) {
        // Still increment total sessions, but don't change streak
        totalSessions++;
        await prefs.setInt(_totalSessionsKey, totalSessions);
        return {
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'totalSessions': totalSessions,
          'isConsecutive': true,
          'newAchievements': [],
          'streakBroken': false,
        };
      }
    }

    // Update streak
    if (isConsecutive || lastLogDateStr == null) {
      currentStreak++;
    } else {
      currentStreak = 1; // Reset streak if not consecutive
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Update total sessions
    totalSessions++;

    // Check for achievements
    List<String> newAchievements = _checkAchievements(currentStreak, totalSessions, achievements);

    // Save data
    await prefs.setInt(_currentStreakKey, currentStreak);
    await prefs.setInt(_longestStreakKey, longestStreak);
    await prefs.setInt(_totalSessionsKey, totalSessions);
    await prefs.setString(_lastLogDateKey, todayStr);
    await prefs.setStringList(_achievementsKey, achievements + newAchievements);

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSessions': totalSessions,
      'isConsecutive': isConsecutive,
      'newAchievements': newAchievements,
      'streakBroken': !isConsecutive && lastLogDateStr != null,
    };
  }

  // Check for achievements
  static List<String> _checkAchievements(int currentStreak, int totalSessions, List<String> existingAchievements) {
    List<String> achievements = [];
    // Streak achievements
    if (currentStreak >= 3 && !existingAchievements.contains('ghost_beginner')) {
      achievements.add('ghost_beginner');
    }
    if (currentStreak >= 7 && !existingAchievements.contains('ghost_week_warrior')) {
      achievements.add('ghost_week_warrior');
    }
    if (currentStreak >= 14 && !existingAchievements.contains('ghost_fortnight')) {
      achievements.add('ghost_fortnight');
    }
    if (currentStreak >= 30 && !existingAchievements.contains('ghost_month_master')) {
      achievements.add('ghost_month_master');
    }
    if (currentStreak >= 100 && !existingAchievements.contains('ghost_century')) {
      achievements.add('ghost_century');
    }
    // Session achievements
    if (totalSessions >= 10 && !existingAchievements.contains('ghost_10_sessions')) {
      achievements.add('ghost_10_sessions');
    }
    if (totalSessions >= 50 && !existingAchievements.contains('ghost_50_sessions')) {
      achievements.add('ghost_50_sessions');
    }
    if (totalSessions >= 100 && !existingAchievements.contains('ghost_100_sessions')) {
      achievements.add('ghost_100_sessions');
    }
    if (totalSessions >= 500 && !existingAchievements.contains('ghost_500_sessions')) {
      achievements.add('ghost_500_sessions');
    }
    return achievements;
  }

  // Achievement metadata
  static Map<String, Map<String, dynamic>> getAchievementData() {
    return {
      'ghost_beginner': {
        'name': 'Beginner',
        'description': '3-day streak! You\'re getting the hang of this.',
        'emoji': '🌱',
        'color': 0xFF60A5FA,
      },
      'ghost_week_warrior': {
        'name': 'Week Warrior',
        'description': '7-day streak! You\'re building momentum.',
        'emoji': '⚔️',
        'color': 0xFF34D399,
      },
      'ghost_fortnight': {
        'name': 'Fortnight Fighter',
        'description': '14-day streak! You\'re becoming a regular.',
        'emoji': '🛡️',
        'color': 0xFFF59E0B,
      },
      'ghost_month_master': {
        'name': 'Month Master',
        'description': '30-day streak! You\'re unstoppable!',
        'emoji': '👑',
        'color': 0xFFEF4444,
      },
      'ghost_century': {
        'name': 'Century Ghost',
        'description': '100-day streak! You\'re legendary!',
        'emoji': '💎',
        'color': 0xFF8B5CF6,
      },
      'ghost_10_sessions': {
        'name': '10 Sessions',
        'description': 'You\'ve logged 10 training sessions!',
        'emoji': '🥋',
        'color': 0xFF60A5FA,
      },
      'ghost_50_sessions': {
        'name': '50 Sessions',
        'description': '50 sessions logged! You\'re dedicated.',
        'emoji': '🏅',
        'color': 0xFF34D399,
      },
      'ghost_100_sessions': {
        'name': '100 Sessions',
        'description': '100 sessions! You\'re a true martial artist.',
        'emoji': '🥇',
        'color': 0xFFF59E0B,
      },
      'ghost_500_sessions': {
        'name': '500 Sessions',
        'description': '500 sessions! You\'re a master of consistency.',
        'emoji': '🏆',
        'color': 0xFFEF4444,
      },
    };
  }

  // Get motivational message based on streak
  static String getMotivationalMessage(int streak, bool isNewAchievement) {
    if (isNewAchievement) {
      return 'Achievement unlocked! 🎉';
    }
    if (streak == 0) {
      return 'Ready to start your journey? 👻';
    } else if (streak == 1) {
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

  // Get streak emoji
  static String getStreakEmoji(int streak) {
    if (streak == 0) return '👻';
    if (streak < 3) return '🌱';
    if (streak < 7) return '🔥';
    if (streak < 14) return '⚔️';
    if (streak < 30) return '🚀';
    if (streak < 100) return '👑';
    return '💎';
  }

  // Reset streak (for testing or user request)
  static Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStreakKey, 0);
    await prefs.setInt(_longestStreakKey, 0);
    await prefs.setInt(_totalSessionsKey, 0);
    await prefs.remove(_lastLogDateKey);
    await prefs.setStringList(_achievementsKey, []);
  }
} 