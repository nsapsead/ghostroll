import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/club.dart';
import '../models/club_member.dart';
import '../repositories/club_repository.dart';
import 'auth_provider.dart';

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepository(FirebaseFirestore.instance);
});

// Stream of memberships for the current user
final currentUserMembershipsProvider = StreamProvider<List<ClubMember>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  
  final repository = ref.watch(clubRepositoryProvider);
  return repository.getUserMemberships(user.uid);
});

// Stream of Clubs the user is a member of
// This requires fetching the Club documents based on the membership clubIds
final currentUserClubsProvider = StreamProvider<List<Club>>((ref) {
  final membershipsAsync = ref.watch(currentUserMembershipsProvider);
  
  return membershipsAsync.when(
    data: (memberships) {
      if (memberships.isEmpty) return Stream.value([]);
      
      // This is a bit complex because we need to fetch multiple documents.
      // A better approach for Firestore might be to store a mini-club object on the member,
      // or just fetch them individually. For now, we'll fetch them.
      // Since we can't easily do a "whereIn" with a stream for IDs easily if > 10,
      // we might want to just fetch them once or use a different strategy.
      // For v1, let's just fetch them as futures and emit.
      
      // Actually, let's return a Stream by combining streams if needed, 
      // or just simple Future for the club details if they don't change often.
      // Let's try to keep it reactive.
      
      // Simplified: Just fetch the clubs once for now when memberships change.
      // Real-time updates for club details in the list might be overkill for v1.
      
      final repository = ref.watch(clubRepositoryProvider);
      final clubIds = memberships.map((m) => m.clubId).toList();
      
      if (clubIds.isEmpty) return Stream.value([]);

      // We can't easily stream a list of IDs. 
      // Let's just fetch them.
      return Stream.fromFuture(Future.wait(
        clubIds.map((id) async {
          final club = await repository.getClub(id);
          return club;
        })
      ).then((clubs) => clubs.whereType<Club>().toList()));
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Provider to get a specific club by ID
final clubProvider = FutureProvider.family<Club?, String>((ref, clubId) {
  final repository = ref.watch(clubRepositoryProvider);
  return repository.getClub(clubId);
});

// Provider to get members of a specific club
final clubMembersProvider = StreamProvider.family<List<ClubMember>, String>((ref, clubId) {
  final repository = ref.watch(clubRepositoryProvider);
  return repository.getClubMembers(clubId);
});
