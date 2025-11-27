import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StreakRepository {
  Stream<Map<String, dynamic>> getStreakData(String userId);
  Future<Map<String, dynamic>> logSession(String userId);
  Future<void> resetStreak(String userId);
}

class FirestoreStreakRepository implements StreakRepository {
  final FirebaseFirestore _firestore;

  FirestoreStreakRepository(this._firestore);

  @override
  Stream<Map<String, dynamic>> getStreakData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('streak')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return _getDefaultStreakData();
      }
      final data = doc.data()!;
      // Handle Timestamp conversion
      if (data['lastLogDate'] is Timestamp) {
        data['lastLogDate'] = (data['lastLogDate'] as Timestamp).toDate().toIso8601String().split('T')[0];
      }
      return {
        'currentStreak': data['currentStreak'] ?? 0,
        'longestStreak': data['longestStreak'] ?? 0,
        'totalSessions': data['totalSessions'] ?? 0,
        'lastLogDate': data['lastLogDate'],
        'achievements': List<String>.from(data['achievements'] ?? []),
      };
    });
  }

  @override
  Future<Map<String, dynamic>> logSession(String userId) async {
    final streakRef = _firestore.collection('users').doc(userId).collection('stats').doc('streak');
    final streakDoc = await streakRef.get();
    
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    
    int currentStreak = 0;
    int longestStreak = 0;
    int totalSessions = 0;
    String? lastLogDateStr;
    List<String> achievements = [];

    if (streakDoc.exists) {
      final data = streakDoc.data()!;
      currentStreak = data['currentStreak'] ?? 0;
      longestStreak = data['longestStreak'] ?? 0;
      totalSessions = data['totalSessions'] ?? 0;
      achievements = List<String>.from(data['achievements'] ?? []);
      
      if (data['lastLogDate'] is Timestamp) {
        lastLogDateStr = (data['lastLogDate'] as Timestamp).toDate().toIso8601String().split('T')[0];
      } else if (data['lastLogDate'] is String) {
        lastLogDateStr = data['lastLogDate'];
      }
    }

    bool isConsecutive = false;
    if (lastLogDateStr != null) {
      final lastDate = DateTime.parse(lastLogDateStr);
      final difference = today.difference(lastDate).inDays;
      isConsecutive = difference == 1;
      
      // If user logs multiple times in one day, don't increment streak
      if (difference == 0) {
        totalSessions++;
        await streakRef.set({
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'totalSessions': totalSessions,
          'lastLogDate': Timestamp.fromDate(today),
          'achievements': achievements,
        }, SetOptions(merge: true));
        
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
    final newAchievements = _checkAchievements(currentStreak, totalSessions, achievements);
    achievements.addAll(newAchievements);

    // Save data
    await streakRef.set({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSessions': totalSessions,
      'lastLogDate': Timestamp.fromDate(today),
      'achievements': achievements,
    }, SetOptions(merge: true));

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSessions': totalSessions,
      'isConsecutive': isConsecutive,
      'newAchievements': newAchievements,
      'streakBroken': !isConsecutive && lastLogDateStr != null,
    };
  }

  @override
  Future<void> resetStreak(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('streak')
        .set(_getDefaultStreakData());
  }

  Map<String, dynamic> _getDefaultStreakData() {
    return {
      'currentStreak': 0,
      'longestStreak': 0,
      'totalSessions': 0,
      'lastLogDate': null,
      'achievements': <String>[],
    };
  }

  List<String> _checkAchievements(int currentStreak, int totalSessions, List<String> existingAchievements) {
    final achievements = <String>[];
    
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
}

