import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/club_providers.dart';
import '../models/class_session.dart';
import '../models/class_note.dart';
import '../repositories/class_session_repository.dart';

final classSessionRepositoryProvider = Provider<ClassSessionRepository>((ref) {
  return ClassSessionRepository(FirebaseFirestore.instance);
});

// Provider to get class sessions for a club within a date range
// We'll use a tuple or a custom object for the family parameter
class ClassSessionFilter {
  final String clubId;
  final DateTime startDate;
  final DateTime endDate;

  ClassSessionFilter({required this.clubId, required this.startDate, required this.endDate});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassSessionFilter &&
          runtimeType == other.runtimeType &&
          clubId == other.clubId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => clubId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

final classSessionsForClubProvider = StreamProvider.family<List<ClassSession>, ClassSessionFilter>((ref, filter) {
  final repository = ref.watch(classSessionRepositoryProvider);
  return repository.getClassSessionsForClub(filter.clubId, filter.startDate, filter.endDate);
});

// Provider to get notes for a specific class session
final classNotesForSessionProvider = StreamProvider.family<List<ClassNote>, String>((ref, sessionId) {
  final repository = ref.watch(classSessionRepositoryProvider);
  return repository.getClassNotes(sessionId);
});

// Provider to get a single class session
final classSessionProvider = FutureProvider.family<ClassSession?, String>((ref, sessionId) {
  final repository = ref.watch(classSessionRepositoryProvider);
  return repository.getClassSession(sessionId);
});

// Provider to get all class sessions for all clubs the user is a member of
final allUserClassSessionsProvider = StreamProvider<List<ClassSession>>((ref) {
  final clubsAsync = ref.watch(currentUserClubsProvider);
  
  return clubsAsync.when(
    data: (clubs) {
      if (clubs.isEmpty) return Stream.value([]);
      
      final repository = ref.watch(classSessionRepositoryProvider);
      final now = DateTime.now();
      // Fetch for a wide range, e.g. -3 months to +3 months
      final startDate = now.subtract(const Duration(days: 90));
      final endDate = now.add(const Duration(days: 90));
      
      final streams = clubs.map((club) {
        return repository.getClassSessionsForClub(club.id, startDate, endDate);
      }).toList();
      
      return CombineLatestStream.list(streams).map((lists) {
        return lists.expand((x) => x).toList();
      });
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
