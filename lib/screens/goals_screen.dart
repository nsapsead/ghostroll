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
  late AnimationController _pulseController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _staggerAnimation;

  // Goal completion tracking
  final Map<String, bool> _goalCompletion = {
    'shortTerm': false,
    'longTerm': false,
    'competition': false,
    'skill': false,
    'fitness': false,
  };

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
    _staggerController.forward();
    
    _loadGoals();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _staggerController.dispose();
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
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[300],
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Goals saved successfully!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.green.withOpacity(0.1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleGoalCompletion(String goalType) {
    setState(() {
      _goalCompletion[goalType] = !(_goalCompletion[goalType] ?? false);
    });
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
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GradientCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Define your path to martial arts excellence',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.2),
                        Colors.blue.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Set • Track • Achieve',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsOverview() {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _staggerAnimation.value)),
          child: Opacity(
            opacity: _staggerAnimation.value,
            child: GradientCard(
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
                          delay: 0.1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildOverviewCard(
                          icon: Icons.timeline,
                          title: 'Long-term',
                          count: '1-2 years',
                          color: Colors.green[300]!,
                          delay: 0.2,
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
                          delay: 0.3,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildOverviewCard(
                          icon: Icons.fitness_center,
                          title: 'Fitness',
                          count: 'Conditioning',
                          color: Colors.purple[300]!,
                          delay: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
    double delay = 0.0,
  }) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, child) {
        final animationValue = (_staggerAnimation.value - delay).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                    color.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, childWidget) {
        return Transform.translate(
          offset: Offset(0, 25 * (1 - _staggerAnimation.value)),
          child: Opacity(
            opacity: _staggerAnimation.value,
            child: GradientCard(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleGoalCompletion(title.toLowerCase().replaceAll(' ', '')),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.2),
                                Colors.green.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _goalCompletion[title.toLowerCase().replaceAll(' ', '')] == true
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: _goalCompletion[title.toLowerCase().replaceAll(' ', '')] == true
                                ? Colors.green[300]
                                : AppColors.textSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShortTermGoalsSection() {
    return _buildEnhancedTextField(
      controller: _shortTermGoalsController,
      label: 'Short-term Goals',
      hintText: 'e.g., Master basic takedowns, Improve cardio, Learn 3 new submissions',
      minLines: 3,
      maxLines: 4,
      icon: Icons.schedule,
      color: Colors.blue[300]!,
    );
  }

  Widget _buildLongTermGoalsSection() {
    return _buildEnhancedTextField(
      controller: _longTermGoalsController,
      label: 'Long-term Goals',
      hintText: 'e.g., Earn blue belt, Compete in tournaments, Open my own school',
      minLines: 3,
      maxLines: 4,
      icon: Icons.timeline,
      color: Colors.green[300]!,
    );
  }

  Widget _buildCompetitionGoalsSection() {
    return _buildEnhancedTextField(
      controller: _competitionGoalsController,
      label: 'Competition Goals',
      hintText: 'e.g., Win local tournament, Compete at nationals, Achieve podium finish',
      minLines: 2,
      maxLines: 3,
      icon: Icons.emoji_events,
      color: Colors.orange[300]!,
    );
  }

  Widget _buildSkillGoalsSection() {
    return _buildEnhancedTextField(
      controller: _skillGoalsController,
      label: 'Skill Development Goals',
      hintText: 'e.g., Improve guard passing, Master triangle choke, Better takedown defense',
      minLines: 2,
      maxLines: 3,
      icon: Icons.sports_martial_arts,
      color: Colors.purple[300]!,
    );
  }

  Widget _buildFitnessGoalsSection() {
    return _buildEnhancedTextField(
      controller: _fitnessGoalsController,
      label: 'Fitness & Conditioning Goals',
      hintText: 'e.g., Increase strength, Improve flexibility, Better endurance',
      minLines: 2,
      maxLines: 3,
      icon: Icons.fitness_center,
      color: Colors.red[300]!,
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required Color color,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: TextFormField(
              controller: controller,
              minLines: minLines,
              maxLines: maxLines,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AppButton(
              text: 'Save Goals',
              onPressed: _saveGoals,
              backgroundColor: Colors.transparent,
              textColor: AppColors.primary,
              height: 56,
            ),
          ),
        );
      },
    );
  }
} 