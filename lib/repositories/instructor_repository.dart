import 'package:cloud_firestore/cloud_firestore.dart';

class InstructorRepository {
  final FirebaseFirestore _firestore;

  InstructorRepository(this._firestore);

  CollectionReference _instructorsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('instructors');
  }

  // Get all instructors
  Stream<List<Map<String, dynamic>>> getInstructors(String userId) {
    return _instructorsCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    });
  }

  // Add a new instructor
  Future<void> addInstructor(String userId, Map<String, dynamic> instructor) async {
    try {
      await _instructorsCollection(userId).add(instructor);
    } catch (e) {
      throw Exception('Error adding instructor: $e');
    }
  }

  // Update an existing instructor
  Future<void> updateInstructor(String userId, String instructorId, Map<String, dynamic> instructor) async {
    try {
      await _instructorsCollection(userId).doc(instructorId).update(instructor);
    } catch (e) {
      throw Exception('Error updating instructor: $e');
    }
  }

  // Delete an instructor
  Future<void> deleteInstructor(String userId, String instructorId) async {
    try {
      await _instructorsCollection(userId).doc(instructorId).delete();
    } catch (e) {
      throw Exception('Error deleting instructor: $e');
    }
  }
  
  // Get instructors for a specific style (Future)
  Future<List<Map<String, dynamic>>> getInstructorsForStyle(String userId, String style) async {
    try {
      final snapshot = await _instructorsCollection(userId)
          .where('style', isEqualTo: style)
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching instructors for style: $e');
    }
  }
}
