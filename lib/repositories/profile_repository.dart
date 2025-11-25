import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository(this._firestore);

  // Get user profile data
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Stream<Map<String, dynamic>> getProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    });
  }

  // Update user profile data
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Get selected martial arts styles
  Future<List<String>> getSelectedStyles(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('selectedStyles')) {
          return List<String>.from(data['selectedStyles']);
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching selected styles: $e');
    }
  }

  // Update selected martial arts styles
  Future<void> updateSelectedStyles(String userId, List<String> styles) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'selectedStyles': styles,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating selected styles: $e');
    }
  }
}
