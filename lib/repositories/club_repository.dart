import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club.dart';
import '../models/club_member.dart';

class ClubRepository {
  final FirebaseFirestore _firestore;

  ClubRepository(this._firestore);

  // --- Club Operations ---

  Future<String> createClub(Club club) async {
    await _firestore.collection('clubs').doc(club.id).set(club.toJson());
    return club.id;
  }

  Future<Club?> getClub(String clubId) async {
    final doc = await _firestore.collection('clubs').doc(clubId).get();
    if (doc.exists) {
      return Club.fromJson(doc.data()!);
    }
    return null;
  }

  Future<List<Club>> searchClubs(String query) async {
    // Simple search by name (case-sensitive in Firestore usually, but we'll just do simple query)
    // For better search, we'd need Algolia or similar, but for v1 we'll do basic startAt/endAt
    final snapshot = await _firestore
        .collection('clubs')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => Club.fromJson(doc.data())).toList();
  }

  Future<Club?> getClubByJoinCode(String joinCode) async {
    final snapshot = await _firestore
        .collection('clubs')
        .where('joinCode', isEqualTo: joinCode)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Club.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  // --- Club Member Operations ---

  Future<void> addMember(ClubMember member) async {
    await _firestore.collection('clubMembers').doc(member.id).set(member.toJson());
  }

  Future<ClubMember?> getMember(String clubId, String userId) async {
    final snapshot = await _firestore
        .collection('clubMembers')
        .where('clubId', isEqualTo: clubId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return ClubMember.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  Stream<List<ClubMember>> getClubMembers(String clubId) {
    return _firestore
        .collection('clubMembers')
        .where('clubId', isEqualTo: clubId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClubMember.fromJson(doc.data())).toList());
  }

  Stream<List<ClubMember>> getUserMemberships(String userId) {
    return _firestore
        .collection('clubMembers')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClubMember.fromJson(doc.data())).toList());
  }
}
