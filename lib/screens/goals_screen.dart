import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/gradient_card.dart';
import '../components/app_button.dart';
import '../components/app_text_field.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _shortTermGoalsController = TextEditingController();
  final _longTermGoalsController = TextEditingController();
  final _competitionGoalsController = TextEditingController();
  final _skillGoalsController = TextEditingController();
  final _fitnessGoalsController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    
    _loadGoals();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shortTermGoalsController.dispose();
    _longTermGoalsController.dispose();
    _competitionGoalsController.dispose();
    _skillGoalsController.dispose();
    _fitnessGoalsController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    // TODO: Load goals from storage
    // For now, we'll use placeholder data
  }

  void _saveGoals() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Save goals to storage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Goals saved successfully!'),
          backgroundColor: Colors.white.withOpacity(0.1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
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
              _buildAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _buildGoalsHeader(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildGoalsOverview(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Short-term Goals (3-6 months)',
                            icon: Icons.schedule,
                            child: _buildShortTermGoalsSection(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Long-term Goals (1-2 years)',
                            icon: Icons.timeline,
                            child: _buildLongTermGoalsSection(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Competition Goals',
                            icon: Icons.emoji_events,
                            child: _buildCompetitionGoalsSection(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Skill Development Goals',
                            icon: Icons.sports_martial_arts,
                            child: _buildSkillGoalsSection(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Fitness & Conditioning Goals',
                            icon: Icons.fitness_center,
                            child: _buildFitnessGoalsSection(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildSaveButton(),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
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

  Widget _buildAppBar() {
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
            child: Text(
              'Training Goals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsHeader() {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.flag,
              size: 48,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your Training Journey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Define your path to martial arts excellence',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsOverview() {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.insights,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Goals Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.schedule,
                  title: 'Short-term',
                  count: '3-6 months',
                  color: Colors.blue[300]!,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.timeline,
                  title: 'Long-term',
                  count: '1-2 years',
                  color: Colors.green[300]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.emoji_events,
                  title: 'Competition',
                  count: 'Tournaments',
                  color: Colors.orange[300]!,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.fitness_center,
                  title: 'Fitness',
                  count: 'Conditioning',
                  color: Colors.purple[300]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildShortTermGoalsSection() {
    return AppTextField(
      controller: _shortTermGoalsController,
      label: 'Short-term Goals',
      hintText: 'e.g., Master basic takedowns, Improve cardio, Learn 3 new submissions',
      minLines: 3,
      maxLines: 4,
    );
  }

  Widget _buildLongTermGoalsSection() {
    return AppTextField(
      controller: _longTermGoalsController,
      label: 'Long-term Goals',
      hintText: 'e.g., Earn blue belt, Compete in tournaments, Open my own school',
      minLines: 3,
      maxLines: 4,
    );
  }

  Widget _buildCompetitionGoalsSection() {
    return AppTextField(
      controller: _competitionGoalsController,
      label: 'Competition Goals',
      hintText: 'e.g., Win local tournament, Compete at nationals, Achieve podium finish',
      minLines: 2,
      maxLines: 3,
    );
  }

  Widget _buildSkillGoalsSection() {
    return AppTextField(
      controller: _skillGoalsController,
      label: 'Skill Development Goals',
      hintText: 'e.g., Improve guard passing, Master triangle choke, Better takedown defense',
      minLines: 2,
      maxLines: 3,
    );
  }

  Widget _buildFitnessGoalsSection() {
    return AppTextField(
      controller: _fitnessGoalsController,
      label: 'Fitness & Conditioning Goals',
      hintText: 'e.g., Increase strength, Improve flexibility, Better endurance',
      minLines: 2,
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return AppButton(
      text: 'Save Goals',
      onPressed: _saveGoals,
      backgroundColor: Colors.white,
      textColor: AppColors.primary,
    );
  }
} 