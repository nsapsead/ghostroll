import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';

class GoalsService {
  static final GoalsService _instance = GoalsService._internal();
  factory GoalsService() => _instance;
  GoalsService._internal();

  static const String _goalsKey = 'user_goals';

  // Goal categories with their colors
  static const Map<String, Color> _categoryColors = {
    'shortTerm': Color(0xFF00F5FF), // Flow Blue
    'longTerm': Color(0xFF00FF88), // Recovery Green
    'competition': Color(0xFFFF4757), // Grind Red
    'skill': Color(0xFF00FF88), // Recovery Green
    'fitness': Color(0xFF00F5FF), // Flow Blue
  };

  // Get color for category
  Color getCategoryColor(String category) {
    return _categoryColors[category] ?? const Color(0xFF00F5FF);
  }

  // Get all categories
  List<String> getCategories() {
    return _categoryColors.keys.toList();
  }

  // Get category display name
  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'shortTerm':
        return 'Short-term Goals';
      case 'longTerm':
        return 'Long-term Goals';
      case 'competition':
        return 'Competition Goals';
      case 'skill':
        return 'Skill Development';
      case 'fitness':
        return 'Fitness & Conditioning';
      default:
        return 'Other Goals';
    }
  }

  // Load goals from local storage
  Future<List<Goal>> loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString('goals');
      
      if (goalsJson != null) {
        final List<dynamic> goalsList = jsonDecode(goalsJson);
        return goalsList.map((json) => Goal.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error loading goals: $e');
      return [];
    }
  }

  // Save goals to local storage
  Future<void> saveGoals(List<Goal> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = jsonEncode(goals.map((g) => g.toJson()).toList());
      await prefs.setString('goals', goalsJson);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error saving goals: $e');
    }
  }

  // Add a new goal
  Future<void> addGoal(Goal goal) async {
    final goals = await loadGoals();
    goals.add(goal);
    await saveGoals(goals);
  }

  // Update a goal
  Future<void> updateGoal(Goal updatedGoal) async {
    final goals = await loadGoals();
    final index = goals.indexWhere((goal) => goal.id == updatedGoal.id);
    
    if (index != -1) {
      goals[index] = updatedGoal;
      await saveGoals(goals);
    }
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    final goals = await loadGoals();
    goals.removeWhere((goal) => goal.id == goalId);
    await saveGoals(goals);
  }

  // Toggle goal completion
  Future<void> toggleGoalCompletion(String goalId) async {
    final goals = await loadGoals();
    final goal = goals.firstWhere((goal) => goal.id == goalId);
    goal.isCompleted = !goal.isCompleted;
    await saveGoals(goals);
  }

  // Get goals by category
  Future<List<Goal>> getGoalsByCategory(String category) async {
    final goals = await loadGoals();
    return goals.where((goal) => goal.category == category).toList();
  }

  // Get completion statistics
  Future<Map<String, dynamic>> getCompletionStats() async {
    final goals = await loadGoals();
    final totalGoals = goals.length;
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final progress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    // Category breakdown
    final categoryStats = <String, Map<String, int>>{};
    for (final category in _categoryColors.keys) {
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
  }

  // Create default goals for new users
  Future<void> createDefaultGoals() async {
    final existingGoals = await loadGoals();
    if (existingGoals.isNotEmpty) return; // Don't create if goals already exist

    final defaultGoals = [
      Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_1',
        title: 'Master Basic Techniques',
        description: 'Focus on perfecting fundamental movements and building a solid foundation.',
        category: 'shortTerm',
        createdAt: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 180)),
        color: getCategoryColor('shortTerm'),
      ),
      Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_2',
        title: 'Earn Next Belt Rank',
        description: 'Work towards your next belt promotion through consistent training and skill development.',
        category: 'longTerm',
        createdAt: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 365)),
        color: getCategoryColor('longTerm'),
      ),
      Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_3',
        title: 'Compete in Local Tournament',
        description: 'Prepare for and participate in your first competition to test your skills.',
        category: 'competition',
        createdAt: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 120)),
        color: getCategoryColor('competition'),
      ),
      Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_4',
        title: 'Improve Flexibility',
        description: 'Enhance your flexibility and mobility through dedicated stretching routines.',
        category: 'fitness',
        createdAt: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 90)),
        color: getCategoryColor('fitness'),
      ),
    ];

    await saveGoals(defaultGoals);
  }
} 