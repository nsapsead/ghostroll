import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/ghostroll_theme.dart';
import '../../providers/club_providers.dart';
import '../../providers/auth_provider.dart';
import '../../models/club.dart';
import '../../models/club_member.dart';
import '../../repositories/club_repository.dart';

class JoinClubScreen extends ConsumerStatefulWidget {
  const JoinClubScreen({super.key});

  @override
  ConsumerState<JoinClubScreen> createState() => _JoinClubScreenState();
}

class _JoinClubScreenState extends ConsumerState<JoinClubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _joinCodeController = TextEditingController();
  
  List<Club> _searchResults = [];
  bool _isSearching = false;
  bool _isJoining = false;
  String? _joinCodeError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await ref.read(clubRepositoryProvider).searchClubs(_searchController.text.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching clubs: $e')),
        );
      }
    }
  }

  Future<void> _joinClub(Club club) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isJoining = true;
    });

    try {
      // Check if already a member
      final existingMember = await ref.read(clubRepositoryProvider).getMember(club.id, user.uid);
      if (existingMember != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already a member of this club.')),
          );
          setState(() {
            _isJoining = false;
          });
        }
        return;
      }

      final member = ClubMember(
        id: '${club.id}_${user.uid}',
        clubId: club.id,
        userId: user.uid,
        role: ClubRole.member,
        joinedAt: DateTime.now(),
        displayNameOverride: user.displayName,
      );

      await ref.read(clubRepositoryProvider).addMember(member);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully joined ${club.name}!')),
        );
        Navigator.of(context).pop(); // Go back to My Clubs
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining club: $e')),
        );
      }
    }
  }

  Future<void> _joinByCode() async {
    final code = _joinCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isJoining = true;
      _joinCodeError = null;
    });

    try {
      final club = await ref.read(clubRepositoryProvider).getClubByJoinCode(code);
      
      if (club == null) {
        if (mounted) {
          setState(() {
            _isJoining = false;
            _joinCodeError = 'Invalid join code. Please check with your instructor.';
          });
        }
        return;
      }

      await _joinClub(club);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoining = false;
          _joinCodeError = 'Error: $e';
        });
      }
    }
  }

  void _showJoinConfirmation(Club club) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GhostRollTheme.surface,
        title: Text('Join ${club.name}?', style: GhostRollTheme.textTitle),
        content: Text(
          'Your name and avatar will be visible to other members.',
          style: GhostRollTheme.textBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: GhostRollTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinClub(club);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GhostRollTheme.activeHighlight,
              foregroundColor: Colors.black,
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Join a Club', style: GhostRollTheme.textTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GhostRollTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GhostRollTheme.activeHighlight,
          labelColor: GhostRollTheme.activeHighlight,
          unselectedLabelColor: GhostRollTheme.textSecondary,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Join Code'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildJoinCodeTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: GhostRollTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by club name',
              hintStyle: const TextStyle(color: GhostRollTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, color: GhostRollTheme.textSecondary),
              filled: true,
              fillColor: GhostRollTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, color: GhostRollTheme.activeHighlight),
                onPressed: _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator(color: GhostRollTheme.activeHighlight))
              : _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'Search for your gym to join',
                        style: GhostRollTheme.bodyMedium.copyWith(color: GhostRollTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final club = _searchResults[index];
                        return _buildClubCard(club);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildJoinCodeTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.vpn_key,
            size: 64,
            color: GhostRollTheme.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'Have a join code?',
            style: GhostRollTheme.textTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the code provided by your instructor to join a private club.',
            style: GhostRollTheme.textBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _joinCodeController,
            style: const TextStyle(color: GhostRollTheme.textPrimary, fontSize: 24, letterSpacing: 2),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'CODE',
              hintStyle: TextStyle(color: GhostRollTheme.textSecondary.withOpacity(0.5)),
              filled: true,
              fillColor: GhostRollTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorText: _joinCodeError,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isJoining ? null : _joinByCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: GhostRollTheme.activeHighlight,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isJoining
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Join Club', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(Club club) {
    return Card(
      color: GhostRollTheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: GhostRollTheme.surfaceHighlight,
          backgroundImage: club.logoUrl != null ? NetworkImage(club.logoUrl!) : null,
          child: club.logoUrl == null
              ? Text(club.name[0].toUpperCase(), style: const TextStyle(color: GhostRollTheme.activeHighlight))
              : null,
        ),
        title: Text(club.name, style: const TextStyle(color: GhostRollTheme.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text('${club.city}, ${club.country}', style: const TextStyle(color: GhostRollTheme.textSecondary)),
        trailing: ElevatedButton(
          onPressed: () => _showJoinConfirmation(club),
          style: ElevatedButton.styleFrom(
            backgroundColor: GhostRollTheme.activeHighlight.withOpacity(0.1),
            foregroundColor: GhostRollTheme.activeHighlight,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Join'),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
