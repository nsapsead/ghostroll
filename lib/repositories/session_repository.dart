import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';

abstract class SessionRepository {
  Stream<List<Session>> getSessions(String userId);
  Future<void> addSession(String userId, Session session);
  Future<void> updateSession(String userId, Session session);
  Future<void> deleteSession(String userId, String sessionId);
}

class FirestoreSessionRepository implements SessionRepository {
  final FirebaseFirestore _firestore;

  FirestoreSessionRepository(this._firestore);

  @override
  Stream<List<Session>> getSessions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Handle Firestore Timestamp to DateTime conversion
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        return Session.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<void> addSession(String userId, Session session) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .add({
          ...session.toJson(),
          'date': Timestamp.fromDate(session.date), // Store as Timestamp
        });
  }

  @override
  Future<void> updateSession(String userId, Session session) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(session.id)
        .update({
          ...session.toJson(),
          'date': Timestamp.fromDate(session.date),
        });
  }

  @override
  Future<void> deleteSession(String userId, String sessionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .delete();
  }
}
