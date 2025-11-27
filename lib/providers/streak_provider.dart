import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/streak_repository.dart';
import 'auth_provider.dart';
import 'session_provider.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return FirestoreStreakRepository(ref.watch(firebaseFirestoreProvider));
});

final streakDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value({
      'currentStreak': 0,
      'longestStreak': 0,
      'totalSessions': 0,
      'lastLogDate': null,
      'achievements': <String>[],
    });
  }
  return ref.watch(streakRepositoryProvider).getStreakData(user.uid);
});

// Achievement metadata (moved from StreakService)
final achievementDataProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
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
});


