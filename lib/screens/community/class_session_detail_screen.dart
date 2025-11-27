import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../theme/ghostroll_theme.dart';
import '../../providers/class_session_providers.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_session.dart';
import '../../models/class_note.dart';
import '../../repositories/class_session_repository.dart';
import '../log_session_form.dart';

class ClassSessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ClassSessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ClassSessionDetailScreen> createState() => _ClassSessionDetailScreenState();
}

class _ClassSessionDetailScreenState extends ConsumerState<ClassSessionDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noteController = TextEditingController();
  String _selectedSection = 'techniques';

  final List<Map<String, String>> _sections = [
    {'id': 'techniques', 'label': 'Techniques'},
    {'id': 'details', 'label': 'Key Details'},
    {'id': 'sparring', 'label': 'Sparring'},
    {'id': 'reflection', 'label': 'Reflections'},
    {'id': 'question', 'label': 'Questions'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedSection = _sections[_tabController.index]['id']!;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addNote(String clubId) async {
    if (_noteController.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final content = _noteController.text.trim();
    _noteController.clear(); // Clear immediately for better UX

    try {
      final noteId = DateTime.now().millisecondsSinceEpoch.toString();
      final note = ClassNote(
        id: noteId,
        classSessionId: widget.sessionId,
        clubId: clubId,
        authorUserId: user.uid,
        section: _selectedSection,
        content: content,
        createdAt: DateTime.now(),
      );

      await ref.read(classSessionRepositoryProvider).createClassNote(note);
      
      // No need to setState as the stream will update
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding note: $e')),
        );
      }
    }
  }

  void _logThisClass(ClassSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogSessionForm(linkedClassSession: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(classSessionProvider(widget.sessionId));
    final notesAsync = ref.watch(classNotesForSessionProvider(widget.sessionId));
    final user = ref.read(currentUserProvider);

    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Class Session', style: GhostRollTheme.textTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GhostRollTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          sessionAsync.when(
            data: (session) => session != null 
                ? IconButton(
                    icon: const Icon(Icons.add_box_outlined, color: GhostRollTheme.activeHighlight),
                    tooltip: 'Log to Journal',
                    onPressed: () => _logThisClass(session),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) return const Center(child: Text('Session not found'));

          return Column(
            children: [
              _buildSessionHeader(session),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: GhostRollTheme.activeHighlight,
                labelColor: GhostRollTheme.activeHighlight,
                unselectedLabelColor: GhostRollTheme.textSecondary,
                tabs: _sections.map((s) => Tab(text: s['label'])).toList(),
              ),
              Expanded(
                child: notesAsync.when(
                  data: (notes) {
                    final filteredNotes = notes.where((n) => n.section == _selectedSection).toList();
                    
                    if (filteredNotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_alt_outlined, size: 48, color: GhostRollTheme.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'No notes in this section yet.\nBe the first to add one!',
                              textAlign: TextAlign.center,
                              style: GhostRollTheme.bodyMedium.copyWith(color: GhostRollTheme.textSecondary.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return _buildNoteCard(note, user?.uid);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: GhostRollTheme.activeHighlight)),
                  error: (error, stack) => Center(child: Text('Error loading notes: $error')),
                ),
              ),
              _buildNoteInput(session.clubId),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: GhostRollTheme.activeHighlight)),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSessionHeader(ClassSession session) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: GhostRollTheme.primaryGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(session.classType, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                backgroundColor: GhostRollTheme.activeHighlight,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                DateFormat('MMM d, y · h:mm a').format(session.date),
                style: const TextStyle(color: GhostRollTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            session.focusArea ?? 'General Training',
            style: GhostRollTheme.textTitle.copyWith(fontSize: 24),
          ),
          if (session.duration != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: GhostRollTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${session.duration} minutes',
                  style: const TextStyle(color: GhostRollTheme.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteCard(ClassNote note, String? currentUserId) {
    final isAuthor = note.authorUserId == currentUserId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhostRollTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAuthor 
              ? GhostRollTheme.activeHighlight.withOpacity(0.3) 
              : GhostRollTheme.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ideally we fetch the author's name, but for now we'll just show "Member" or "You"
              Text(
                isAuthor ? 'You' : 'Member',
                style: TextStyle(
                  color: isAuthor ? GhostRollTheme.activeHighlight : GhostRollTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                DateFormat('MMM d, h:mm a').format(note.createdAt),
                style: TextStyle(color: GhostRollTheme.textSecondary.withOpacity(0.5), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: const TextStyle(color: GhostRollTheme.textPrimary, height: 1.4),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildNoteInput(String clubId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhostRollTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _noteController,
                style: const TextStyle(color: GhostRollTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add a note to ${_sections.firstWhere((s) => s['id'] == _selectedSection)['label']}...',
                  hintStyle: const TextStyle(color: GhostRollTheme.textSecondary),
                  filled: true,
                  fillColor: GhostRollTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: GhostRollTheme.activeHighlight,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black, size: 20),
                onPressed: () => _addNote(clubId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
