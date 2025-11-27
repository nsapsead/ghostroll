import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../repositories/session_repository.dart';
import 'auth_provider.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return FirestoreSessionRepository(ref.watch(firebaseFirestoreProvider));
});

final sessionListProvider = StreamProvider<List<Session>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  // Load first 50 sessions (can be extended with pagination later)
  return ref.watch(sessionRepositoryProvider).getSessions(user.uid, limit: 50);
});
