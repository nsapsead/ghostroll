import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal.dart';

abstract class GoalRepository {
  Stream<List<Goal>> getGoals(String userId);
  Future<void> addGoal(String userId, Goal goal);
  Future<void> updateGoal(String userId, Goal goal);
  Future<void> deleteGoal(String userId, String goalId);
  Future<void> toggleGoalCompletion(String userId, String goalId);
  Stream<List<Goal>> getGoalsByCategory(String userId, String category);
}

class FirestoreGoalRepository implements GoalRepository {
  final FirebaseFirestore _firestore;

  FirestoreGoalRepository(this._firestore);

  @override
  Stream<List<Goal>> getGoals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Handle Firestore Timestamp to DateTime conversion
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['targetDate'] is Timestamp) {
          data['targetDate'] = (data['targetDate'] as Timestamp).toDate().toIso8601String();
        }
        return Goal.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<void> addGoal(String userId, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .add({
          ...goal.toJson(),
          'createdAt': Timestamp.fromDate(goal.createdAt),
          'targetDate': goal.targetDate != null 
              ? Timestamp.fromDate(goal.targetDate!) 
              : null,
        });
  }

  @override
  Future<void> updateGoal(String userId, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goal.id)
        .update({
          ...goal.toJson(),
          'createdAt': Timestamp.fromDate(goal.createdAt),
          'targetDate': goal.targetDate != null 
              ? Timestamp.fromDate(goal.targetDate!) 
              : null,
        });
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  @override
  Future<void> toggleGoalCompletion(String userId, String goalId) async {
    final goalDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .get();
    
    if (goalDoc.exists) {
      final currentValue = goalDoc.data()?['isCompleted'] ?? false;
      await goalDoc.reference.update({'isCompleted': !currentValue});
    }
  }

  @override
  Stream<List<Goal>> getGoalsByCategory(String userId, String category) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Handle Firestore Timestamp to DateTime conversion
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['targetDate'] is Timestamp) {
          data['targetDate'] = (data['targetDate'] as Timestamp).toDate().toIso8601String();
        }
        return Goal.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }
}


