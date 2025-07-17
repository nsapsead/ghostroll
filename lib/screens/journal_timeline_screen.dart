import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../theme/ghostroll_theme.dart';
import 'session_detail_view.dart';
import '../widgets/common/glow_text.dart';

class JournalTimelineScreen extends StatefulWidget {
  const JournalTimelineScreen({super.key});

  @override
  State<JournalTimelineScreen> createState() => _JournalTimelineScreenState();
}

class _JournalTimelineScreenState extends State<JournalTimelineScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock data for demonstration
  final List<Session> _sessions = [
    Session(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      classType: ClassType.gi,
      focusArea: 'Guard Passes',
      rounds: 5,
      techniquesLearned: ['Double Leg Pass', 'Knee Cut Pass'],
      sparringNotes: 'Felt strong in top position',
      reflection: 'Need to work on guard retention',
    ),
    Session(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 3)),
      classType: ClassType.noGi,
      focusArea: 'Leg Locks',
      rounds: 3,
      techniquesLearned: ['Heel Hook', 'Ankle Lock'],
    ),
    Session(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 5)),
      classType: ClassType.striking,
      focusArea: 'Boxing Combinations',
      rounds: 4,
      techniquesLearned: ['Jab-Cross-Hook', 'Body Shots'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ghost watermark background
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/GhostRollBeltMascot.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Main content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: GhostRollTheme.primaryGradient,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _sessions.isEmpty
                            ? _buildEmptyState()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: _buildTimeline(),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: GhostRollTheme.medium,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: GlowText(
                    text: 'GhostRoll',
                    fontSize: 20,
                    textColor: Colors.white,
                    glowColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: GhostRollTheme.flowGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: GhostRollTheme.glow,
              ),
              child: Icon(
                Icons.history,
                size: 64,
                color: GhostRollTheme.text,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No sessions yet',
              style: GhostRollTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Log your first training session to get started',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to log session form
              },
              icon: const Icon(Icons.add),
              label: const Text('Log Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GhostRollTheme.flowBlue,
                foregroundColor: GhostRollTheme.text,
                elevation: 12,
                shadowColor: GhostRollTheme.flowBlue.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training History',
          style: GhostRollTheme.headlineLarge.copyWith(
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        ..._sessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Session session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SessionDetailView(session: session),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GhostRollTheme.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: GhostRollTheme.medium,
            border: Border.all(
              color: GhostRollTheme.textSecondary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getClassTypeColor(session.classType).withOpacity(0.2),
                              _getClassTypeColor(session.classType).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getClassTypeColor(session.classType).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getClassTypeIcon(session.classType),
                          color: _getClassTypeColor(session.classType),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(session.date),
                            style: GhostRollTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE').format(session.date),
                            style: GhostRollTheme.bodySmall.copyWith(
                              color: GhostRollTheme.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getClassTypeColor(session.classType),
                          _getClassTypeColor(session.classType).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getClassTypeColor(session.classType).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      session.classTypeDisplay,
                      style: GhostRollTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                session.focusArea,
                style: GhostRollTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.timer,
                      size: 16,
                      color: GhostRollTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${session.rounds} rounds',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      color: GhostRollTheme.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (session.techniquesLearned.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: session.techniquesLearned
                      .take(3)
                      .map((technique) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: GhostRollTheme.overlayDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GhostRollTheme.textSecondary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              technique,
                              style: GhostRollTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                if (session.techniquesLearned.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${session.techniquesLearned.length - 3} more techniques',
                      style: GhostRollTheme.bodySmall.copyWith(
                        color: GhostRollTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getClassTypeColor(ClassType classType) {
    switch (classType) {
      case ClassType.gi:
        return GhostRollTheme.flowBlue;
      case ClassType.noGi:
        return GhostRollTheme.grindRed;
      case ClassType.striking:
        return GhostRollTheme.recoveryGreen;
    }
  }

  IconData _getClassTypeIcon(ClassType classType) {
    switch (classType) {
      case ClassType.gi:
        return Icons.sports_martial_arts;
      case ClassType.noGi:
        return Icons.fitness_center;
      case ClassType.striking:
        return Icons.sports_kabaddi;
    }
  }
} 