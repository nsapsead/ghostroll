import 'package:flutter/material.dart';
import '../theme/ghostroll_theme.dart';
import '../widgets/common/glow_text.dart';

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
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
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _staggerController.forward();
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

  void _saveGoals() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Goals saved successfully!'),
          backgroundColor: GhostRollTheme.flowBlue.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _toggleGoalCompletion(String goalKey) {
    setState(() {
      _goalCompletion[goalKey] = !(_goalCompletion[goalKey] ?? false);
    });
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
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 24),
                                _buildGoalsSection(),
                                const SizedBox(height: 24),
                                _buildProgressSection(),
                                const SizedBox(height: 24),
                                _buildSaveButton(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
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

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GhostRollTheme.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: GhostRollTheme.glow,
          border: Border.all(
            color: GhostRollTheme.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: GhostRollTheme.flowGradient,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: GhostRollTheme.small,
              ),
              child: Icon(
                Icons.flag,
                size: 48,
                color: GhostRollTheme.text,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Training Journey',
              style: GhostRollTheme.headlineLarge.copyWith(
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Define your path to martial arts excellence',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GhostRollTheme.recoveryGreen, GhostRollTheme.flowBlue],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GhostRollTheme.textSecondary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Set • Track • Achieve',
                style: GhostRollTheme.labelSmall.copyWith(
                  color: GhostRollTheme.text,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Goals',
          style: GhostRollTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildGoalCard(
          title: 'Short-term Goals (3-6 months)',
          icon: Icons.schedule,
          controller: _shortTermGoalsController,
          goalKey: 'shortTerm',
          color: GhostRollTheme.flowBlue,
        ),
        const SizedBox(height: 16),
        _buildGoalCard(
          title: 'Long-term Goals (1-2 years)',
          icon: Icons.timeline,
          controller: _longTermGoalsController,
          goalKey: 'longTerm',
          color: GhostRollTheme.recoveryGreen,
        ),
        const SizedBox(height: 16),
        _buildGoalCard(
          title: 'Competition Goals',
          icon: Icons.emoji_events,
          controller: _competitionGoalsController,
          goalKey: 'competition',
          color: GhostRollTheme.grindRed,
        ),
        const SizedBox(height: 16),
        _buildGoalCard(
          title: 'Skill Development Goals',
          icon: Icons.sports_martial_arts,
          controller: _skillGoalsController,
          goalKey: 'skill',
          color: GhostRollTheme.recoveryGreen,
        ),
        const SizedBox(height: 16),
        _buildGoalCard(
          title: 'Fitness & Conditioning Goals',
          icon: Icons.fitness_center,
          controller: _fitnessGoalsController,
          goalKey: 'fitness',
          color: GhostRollTheme.flowBlue,
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String goalKey,
    required Color color,
  }) {
    final isCompleted = _goalCompletion[goalKey] ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: isCompleted 
              ? color.withOpacity(0.5)
              : GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? color.withOpacity(0.2)
                  : GhostRollTheme.overlayDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleGoalCompletion(goalKey),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? color : GhostRollTheme.textSecondary.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? color : GhostRollTheme.textSecondary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: GhostRollTheme.text,
                            size: 16,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your goals...',
                hintStyle: TextStyle(color: GhostRollTheme.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color),
                ),
                filled: true,
                fillColor: GhostRollTheme.overlayDark,
              ),
              style: TextStyle(color: GhostRollTheme.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final completedGoals = _goalCompletion.values.where((completed) => completed).length;
    final totalGoals = _goalCompletion.length;
    final progress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(20),
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
            children: [
              Icon(
                Icons.trending_up,
                color: GhostRollTheme.recoveryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Progress Overview',
                style: GhostRollTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed Goals',
                      style: GhostRollTheme.bodyMedium.copyWith(
                        color: GhostRollTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedGoals of $totalGoals',
                      style: GhostRollTheme.headlineSmall.copyWith(
                        color: GhostRollTheme.recoveryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: GhostRollTheme.flowGradient,
                  ),
                  boxShadow: GhostRollTheme.small,
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: GhostRollTheme.titleMedium.copyWith(
                      color: GhostRollTheme.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: GhostRollTheme.overlayDark,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: GhostRollTheme.flowGradient,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progress >= 1.0 
                ? '🎉 All goals completed! Amazing work!'
                : progress >= 0.8
                    ? '🔥 Almost there! Keep pushing!'
                    : progress >= 0.5
                        ? '💪 Halfway there! Stay focused!'
                        : '🚀 Great start! Keep going!',
            style: GhostRollTheme.bodyMedium.copyWith(
              color: GhostRollTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveGoals,
        icon: const Icon(Icons.save, size: 24),
        label: Text(
          'Save Goals',
          style: GhostRollTheme.labelLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GhostRollTheme.flowBlue,
          foregroundColor: GhostRollTheme.text,
          elevation: 12,
          shadowColor: GhostRollTheme.flowBlue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
      ),
    );
  }
} 