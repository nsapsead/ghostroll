import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_session.dart';
import '../models/class_note.dart';

class ClassSessionRepository {
  final FirebaseFirestore _firestore;

  ClassSessionRepository(this._firestore);

  // --- Class Session Operations ---

  Future<String> createClassSession(ClassSession session) async {
    await _firestore.collection('classSessions').doc(session.id).set(session.toJson());
    return session.id;
  }

  Future<ClassSession?> getClassSession(String sessionId) async {
    final doc = await _firestore.collection('classSessions').doc(sessionId).get();
    if (doc.exists) {
      return ClassSession.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<List<ClassSession>> getClassSessionsForClub(String clubId, DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('classSessions')
        .where('clubId', isEqualTo: clubId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClassSession.fromJson(doc.data())).toList());
  }

  // --- Class Note Operations ---

  Future<String> createClassNote(ClassNote note) async {
    await _firestore.collection('classNotes').doc(note.id).set(note.toJson());
    return note.id;
  }

  Stream<List<ClassNote>> getClassNotes(String classSessionId) {
    return _firestore
        .collection('classNotes')
        .where('classSessionId', isEqualTo: classSessionId)
        .orderBy('isPinned', descending: true) // Pinned notes first
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClassNote.fromJson(doc.data())).toList());
  }

  Future<void> updateClassNote(ClassNote note) async {
    await _firestore.collection('classNotes').doc(note.id).update(note.toJson());
  }

  Future<void> deleteClassNote(String noteId) async {
    await _firestore.collection('classNotes').doc(noteId).delete();
  }
}
