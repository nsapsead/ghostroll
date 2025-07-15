import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_components.dart';
import 'session_detail_view.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFantasticAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _sessions.isEmpty
                        ? _buildFantasticEmptyState()
                        : ResponsiveContainer(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: _buildFantasticTimeline(),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFantasticAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.small,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.asset(
                'assets/images/ghostroll_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          GradientCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${_sessions.length} Sessions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFantasticEmptyState() {
    return EmptyState(
      icon: Icons.history,
      title: 'No sessions yet',
      subtitle: 'Log your first training session to get started',
      actionText: 'Log Session',
      onAction: () {
        // Navigate to log session form
      },
    );
  }

  Widget _buildFantasticTimeline() {
    return ListView.builder(
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildFantasticSessionCard(session, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFantasticSessionCard(Session session, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
        child: GradientCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getClassTypeColor(session.classType).withOpacity(0.2),
                              _getClassTypeColor(session.classType).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(session.date),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE').format(session.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getClassTypeColor(session.classType),
                          _getClassTypeColor(session.classType).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                session.focusArea,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.overlayMedium,
                          AppColors.overlayLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Icon(
                      Icons.timer,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${session.rounds} rounds',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (session.techniquesLearned.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: session.techniquesLearned
                      .take(3)
                      .map((technique) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.overlayLight,
                                  AppColors.overlayMedium,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.overlayMedium,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              technique,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                if (session.techniquesLearned.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '+${session.techniquesLearned.length - 3} more techniques',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
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
        return AppColors.info;
      case ClassType.noGi:
        return AppColors.accent;
      case ClassType.striking:
        return AppColors.error;
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