import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../repositories/goal_repository.dart';
import 'auth_provider.dart';
import 'session_provider.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return FirestoreGoalRepository(ref.watch(firebaseFirestoreProvider));
});

final goalListProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(goalRepositoryProvider).getGoals(user.uid);
});

final goalListByCategoryProvider = StreamProvider.family<List<Goal>, String>((ref, category) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(goalRepositoryProvider).getGoalsByCategory(user.uid, category);
});

// Goal statistics provider
final goalStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final goalsAsync = ref.watch(goalListProvider);
  
  return goalsAsync.when(
    data: (goals) {
      final totalGoals = goals.length;
      final completedGoals = goals.where((goal) => goal.isCompleted).length;
      final progress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

      // Category breakdown
      final categoryStats = <String, Map<String, int>>{};
      const categories = ['shortTerm', 'longTerm', 'competition', 'skill', 'fitness'];
      
      for (final category in categories) {
        final categoryGoals = goals.where((goal) => goal.category == category).toList();
        final categoryCompleted = categoryGoals.where((goal) => goal.isCompleted).length;
        
        categoryStats[category] = {
          'total': categoryGoals.length,
          'completed': categoryCompleted,
        };
      }

      return {
        'totalGoals': totalGoals,
        'completedGoals': completedGoals,
        'progress': progress,
        'categoryStats': categoryStats,
      };
    },
    loading: () => {
      'totalGoals': 0,
      'completedGoals': 0,
      'progress': 0.0,
      'categoryStats': <String, Map<String, int>>{},
    },
    error: (_, __) => {
      'totalGoals': 0,
      'completedGoals': 0,
      'progress': 0.0,
      'categoryStats': <String, Map<String, int>>{},
    },
  );
});

// Goal category utilities (moved from GoalsService)
final goalCategoryColorsProvider = Provider<Map<String, int>>((ref) {
  return {
    'shortTerm': 0xFF00F5FF, // Flow Blue
    'longTerm': 0xFF00FF88, // Recovery Green
    'competition': 0xFFFF4757, // Grind Red
    'skill': 0xFF00FF88, // Recovery Green
    'fitness': 0xFF00F5FF, // Flow Blue
  };
});

final goalCategoryNamesProvider = Provider<Map<String, String>>((ref) {
  return {
    'shortTerm': 'Short-term Goals',
    'longTerm': 'Long-term Goals',
    'competition': 'Competition Goals',
    'skill': 'Skill Development',
    'fitness': 'Fitness & Conditioning',
  };
});


