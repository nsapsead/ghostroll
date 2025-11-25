import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../repositories/instructor_repository.dart';
import 'auth_provider.dart';

// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(FirebaseFirestore.instance);
});

// Instructor Repository Provider
final instructorRepositoryProvider = Provider<InstructorRepository>((ref) {
  return InstructorRepository(FirebaseFirestore.instance);
});

// User Profile Stream Provider
final userProfileProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfileStream(user.uid);
});

// Selected Styles Provider (Future)
final selectedStylesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getSelectedStyles(user.uid);
});

// Instructors Stream Provider
final instructorsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  
  final repository = ref.watch(instructorRepositoryProvider);
  return repository.getInstructors(user.uid);
});
