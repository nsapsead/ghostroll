import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/ghostroll_theme.dart';
import '../../providers/club_providers.dart';
import '../../models/club.dart';
import 'join_club_screen.dart';
import 'create_club_screen.dart';
import 'club_detail_screen.dart';

class MyClubsScreen extends ConsumerWidget {
  const MyClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(currentUserClubsProvider);

    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Class Session', style: GhostRollTheme.textTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GhostRollTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: clubsAsync.when(
        data: (clubs) {
          if (clubs.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildClubsList(context, clubs);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: GhostRollTheme.activeHighlight)),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_martial_arts,
              size: 80,
              color: GhostRollTheme.textSecondary.withOpacity(0.3),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'You\'re not in a club yet',
              style: GhostRollTheme.textTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Join your gym to unlock shared class notes and connect with your teammates.',
              style: GhostRollTheme.textBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildActionButton(
              context,
              'Join a Club',
              Icons.search,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinClubScreen())),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              'Create a Club',
              Icons.add,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClubScreen())),
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubsList(BuildContext context, List<Club> clubs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...clubs.map((club) => _buildClubCard(context, club)),
        const SizedBox(height: 24),
        const Divider(color: GhostRollTheme.divider),
        const SizedBox(height: 24),
        Text(
          'Class Details',
          style: GhostRollTheme.textSectionHeader,
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context,
          'Join another Club',
          Icons.search,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinClubScreen())),
          isPrimary: false,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'Create a Club',
          Icons.add,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClubScreen())),
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildClubCard(BuildContext context, Club club) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: club.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GhostRollTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: GhostRollTheme.surfaceHighlight,
              backgroundImage: club.logoUrl != null ? NetworkImage(club.logoUrl!) : null,
              child: club.logoUrl == null
                  ? Text(
                      club.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GhostRollTheme.activeHighlight,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GhostRollTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${club.city}, ${club.country}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: GhostRollTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club.style,
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhostRollTheme.activeHighlight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: GhostRollTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ).animate().fadeIn().slideX(begin: 0.1),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? GhostRollTheme.activeHighlight : Colors.transparent,
          foregroundColor: isPrimary ? Colors.black : GhostRollTheme.activeHighlight,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isPrimary ? BorderSide.none : const BorderSide(color: GhostRollTheme.activeHighlight, width: 1.5),
          ),
          elevation: isPrimary ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
