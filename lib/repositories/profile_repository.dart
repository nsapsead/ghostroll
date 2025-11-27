import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository(this._firestore);

  // Get user profile data
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      debugPrint('ProfileRepository: ========== LOAD OPERATION ==========');
      debugPrint('ProfileRepository: User ID: $userId');
      debugPrint('ProfileRepository: Firestore path: users/$userId');
      
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('ProfileRepository: ✅ Document exists');
        debugPrint('ProfileRepository: Document keys: ${data.keys.toList()}');
        debugPrint('ProfileRepository: firstName: ${data['firstName']}');
        debugPrint('ProfileRepository: surname: ${data['surname']}');
        debugPrint('ProfileRepository: weight: ${data['weight']}');
        debugPrint('ProfileRepository: height: ${data['height']}');
        debugPrint('ProfileRepository: ====================================');
        return data;
      } else {
        debugPrint('ProfileRepository: ⚠️ Document does not exist');
        debugPrint('ProfileRepository: This is normal for new users');
        debugPrint('ProfileRepository: ====================================');
        return {};
      }
    } catch (e, stackTrace) {
      debugPrint('ProfileRepository: ❌ ERROR fetching profile: $e');
      debugPrint('ProfileRepository: Error type: ${e.runtimeType}');
      debugPrint('ProfileRepository: Stack trace: $stackTrace');
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
      // Remove null values to avoid overwriting with null
      final cleanData = Map<String, dynamic>.from(data);
      cleanData.removeWhere((key, value) => value == null);
      
      debugPrint('ProfileRepository: ========== SAVE OPERATION ==========');
      debugPrint('ProfileRepository: User ID: $userId');
      debugPrint('ProfileRepository: Firestore path: users/$userId');
      debugPrint('ProfileRepository: Data keys being saved: ${cleanData.keys.toList()}');
      debugPrint('ProfileRepository: Full data: $cleanData');
      
      await _firestore.collection('users').doc(userId).set(cleanData, SetOptions(merge: true));
      
      debugPrint('ProfileRepository: ✅ Write operation completed');
      
      // Verify the data was saved
      final verifyDoc = await _firestore.collection('users').doc(userId).get();
      if (verifyDoc.exists) {
        final savedData = verifyDoc.data() ?? {};
        debugPrint('ProfileRepository: ✅ Verified - document exists');
        debugPrint('ProfileRepository: Saved document keys: ${savedData.keys.toList()}');
        debugPrint('ProfileRepository: Saved firstName: ${savedData['firstName']}');
        debugPrint('ProfileRepository: Saved surname: ${savedData['surname']}');
        debugPrint('ProfileRepository: Saved weight: ${savedData['weight']}');
        debugPrint('ProfileRepository: Saved height: ${savedData['height']}');
      } else {
        debugPrint('ProfileRepository: ❌ WARNING - document does not exist after save!');
        debugPrint('ProfileRepository: This might indicate a Firestore security rules issue');
      }
      debugPrint('ProfileRepository: ====================================');
    } catch (e, stackTrace) {
      debugPrint('ProfileRepository: ❌ ERROR updating profile: $e');
      debugPrint('ProfileRepository: Error type: ${e.runtimeType}');
      debugPrint('ProfileRepository: Stack trace: $stackTrace');
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
