import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../theme/ghostroll_theme.dart';
import '../../providers/club_providers.dart';
import '../../providers/class_session_providers.dart';
import '../../providers/auth_provider.dart';
import '../../models/club.dart';
import '../../models/club_member.dart';
import '../../models/class_session.dart';
import 'create_class_session_screen.dart';
import 'class_session_detail_screen.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ClubDetailScreen({super.key, required this.clubId});

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubProvider(widget.clubId));
    final membersAsync = ref.watch(clubMembersProvider(widget.clubId));
    final currentUser = ref.read(currentUserProvider);

    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      body: clubAsync.when(
        data: (club) {
          if (club == null) return const Center(child: Text('Club not found'));
          
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: GhostRollTheme.background,
                  expandedHeight: 200,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: GhostRollTheme.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: GhostRollTheme.primaryGradient,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: GhostRollTheme.surfaceHighlight,
                              backgroundImage: club.logoUrl != null ? NetworkImage(club.logoUrl!) : null,
                              child: club.logoUrl == null
                                  ? Text(
                                      club.name[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: GhostRollTheme.activeHighlight),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              club.name,
                              style: GhostRollTheme.textTitle.copyWith(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${club.city}, ${club.country}',
                              style: GhostRollTheme.bodyMedium.copyWith(color: GhostRollTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            membersAsync.when(
                              data: (members) => Text(
                                '${members.length} members',
                                style: GhostRollTheme.bodySmall.copyWith(color: GhostRollTheme.textSecondary),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: GhostRollTheme.activeHighlight,
                    labelColor: GhostRollTheme.activeHighlight,
                    unselectedLabelColor: GhostRollTheme.textSecondary,
                    tabs: const [
                      Tab(text: 'Classes'),
                      Tab(text: 'Members'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildClassesTab(club, membersAsync.value),
                _buildMembersTab(membersAsync),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: GhostRollTheme.activeHighlight)),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: _buildFloatingActionButton(membersAsync.value, currentUser?.uid),
    );
  }

  Widget _buildFloatingActionButton(List<ClubMember>? members, String? currentUserId) {
    if (members == null || currentUserId == null) return const SizedBox.shrink();
    
    final currentUserMember = members.firstWhere(
      (m) => m.userId == currentUserId,
      orElse: () => ClubMember(
        id: '', 
        clubId: '', 
        userId: '', 
        role: ClubRole.member, 
        joinedAt: DateTime.now()
      ),
    );

    // Only instructors and owners can create classes
    if (currentUserMember.role == ClubRole.instructor || currentUserMember.role == ClubRole.owner) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateClassSessionScreen(clubId: widget.clubId)),
          );
        },
        backgroundColor: GhostRollTheme.activeHighlight,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('New Class'),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildClassesTab(Club club, List<ClubMember>? members) {
    // Filter for this week by default for now
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    // For v1, let's just show past month and future month to be safe
    final startDate = now.subtract(const Duration(days: 30));
    final endDate = now.add(const Duration(days: 30));

    final filter = ClassSessionFilter(
      clubId: club.id,
      startDate: startDate,
      endDate: endDate,
    );
    
    final sessionsAsync = ref.watch(classSessionsForClubProvider(filter));

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 48, color: GhostRollTheme.textSecondary),
                const SizedBox(height: 16),
                Text('No classes scheduled recently', style: GhostRollTheme.bodyMedium.copyWith(color: GhostRollTheme.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return _buildClassSessionCard(session);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: GhostRollTheme.activeHighlight)),
      error: (error, stack) => Center(child: Text('Error loading classes: $error')),
    );
  }

  Widget _buildClassSessionCard(ClassSession session) {
    final dateFormat = DateFormat('EEE, MMM d · h:mm a');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClassSessionDetailScreen(sessionId: session.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GhostRollTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GhostRollTheme.textSecondary.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.classType,
                  style: const TextStyle(
                    color: GhostRollTheme.activeHighlight,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (session.duration != null)
                  Text(
                    '${session.duration} min',
                    style: const TextStyle(color: GhostRollTheme.textSecondary, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              session.focusArea ?? 'General Training',
              style: const TextStyle(
                color: GhostRollTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: GhostRollTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(session.date),
                  style: const TextStyle(color: GhostRollTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }

  Widget _buildMembersTab(AsyncValue<List<ClubMember>> membersAsync) {
    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return Center(child: Text('No members yet', style: GhostRollTheme.bodyMedium.copyWith(color: GhostRollTheme.textSecondary)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: GhostRollTheme.surfaceHighlight,
                child: Text(
                  (member.displayNameOverride ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: GhostRollTheme.textPrimary),
                ),
              ),
              title: Text(
                member.displayNameOverride ?? 'Unknown User',
                style: const TextStyle(color: GhostRollTheme.textPrimary),
              ),
              subtitle: member.beltRank != null 
                  ? Text(member.beltRank!, style: const TextStyle(color: GhostRollTheme.textSecondary))
                  : null,
              trailing: member.role != ClubRole.member
                  ? Chip(
                      label: Text(
                        member.role.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.black),
                      ),
                      backgroundColor: GhostRollTheme.activeHighlight,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: GhostRollTheme.activeHighlight)),
      error: (error, stack) => Center(child: Text('Error loading members: $error')),
    );
  }
}
