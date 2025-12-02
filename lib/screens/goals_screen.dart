import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/ghostroll_theme.dart';
import '../providers/goal_providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/glow_text.dart';
import '../components/gradient_card.dart';
import '../models/goal.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  String _selectedCategory = 'all';

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

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Toggle goal completion
  Future<void> _toggleGoalCompletion(Goal goal) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      
      final repository = ref.read(goalRepositoryProvider);
      await repository.toggleGoalCompletion(user.uid, goal.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: GhostRollTheme.grindRed,
          ),
        );
      }
    }
  }

  // Delete a goal
  Future<void> _deleteGoal(Goal goal) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      
      final repository = ref.read(goalRepositoryProvider);
      await repository.deleteGoal(user.uid, goal.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Goal deleted successfully'),
            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: GhostRollTheme.grindRed,
          ),
        );
      }
    }
  }

  List<Goal> _filteredGoals(List<Goal> goals) {
    if (_selectedCategory == 'all') {
      return goals;
    }
    return goals.where((goal) => goal.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalListProvider);
    final stats = ref.watch(goalStatsProvider);
    
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
                    child: goalsAsync.when(
                      data: (goals) => FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 24),
                                _buildProgressOverview(stats),
                                const SizedBox(height: 24),
                                _buildCategoryFilter(),
                                const SizedBox(height: 16),
                                _buildGoalsList(goals),
                                const SizedBox(height: 24),
                                _buildAddGoalButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      loading: () => _buildLoadingState(),
                      error: (error, stack) => _buildErrorState(error),
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
          IconButton(
            onPressed: () => ref.invalidate(goalListProvider),
            icon: Icon(
              Icons.refresh,
              color: GhostRollTheme.text,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/GhostRollBeltMascot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your goals...',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: GhostRollTheme.grindRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading goals',
              style: GhostRollTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(goalListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: GradientCard(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverview(Map<String, dynamic> stats) {
    final progress = stats['progress'] ?? 0.0;
    final completedGoals = stats['completedGoals'] ?? 0;
    final totalGoals = stats['totalGoals'] ?? 0;
    
    return GradientCard(
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

  Widget _buildCategoryFilter() {
    final categoryColors = ref.watch(goalCategoryColorsProvider);
    final categoryNames = ref.watch(goalCategoryNamesProvider);
    final categories = ['all', ...categoryColors.keys];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Category',
          style: GhostRollTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              final displayName = category == 'all' 
                  ? 'All Goals' 
                  : categoryNames[category] ?? category;
              final colorValue = category == 'all' 
                  ? GhostRollTheme.flowBlue.value 
                  : categoryColors[category] ?? GhostRollTheme.flowBlue.value;
              final color = Color(colorValue);
              
              return Padding(
                padding: EdgeInsets.only(
                  right: index < categories.length - 1 ? 12 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : GhostRollTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : GhostRollTheme.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      displayName,
                      style: GhostRollTheme.bodySmall.copyWith(
                        color: isSelected ? GhostRollTheme.text : GhostRollTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(List<Goal> goals) {
    final filteredGoals = _filteredGoals(goals);
    
    if (filteredGoals.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: GhostRollTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No goals found',
              style: GhostRollTheme.titleMedium.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first goal to get started!',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredGoals.length,
      itemBuilder: (context, index) {
        final goal = filteredGoals[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index < filteredGoals.length - 1 ? 16 : 0),
          child: _buildGoalCard(goal),
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final daysUntilTarget = goal.targetDate != null 
        ? goal.targetDate!.difference(DateTime.now()).inDays 
        : null;
    
    return Container(
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: goal.isCompleted 
              ? goal.color.withOpacity(0.5)
              : GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: goal.isCompleted 
                  ? goal.color.withOpacity(0.2)
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
                    color: goal.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getGoalIcon(goal.category),
                    color: goal.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: GhostRollTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (daysUntilTarget != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          daysUntilTarget > 0 
                              ? '$daysUntilTarget days remaining'
                              : daysUntilTarget == 0
                                  ? 'Due today!'
                                  : '${daysUntilTarget.abs()} days overdue',
                          style: GhostRollTheme.bodySmall.copyWith(
                            color: daysUntilTarget <= 0 
                                ? GhostRollTheme.grindRed 
                                : GhostRollTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleGoalCompletion(goal),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: goal.isCompleted ? goal.color : GhostRollTheme.textSecondary.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: goal.isCompleted ? goal.color : GhostRollTheme.textSecondary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: goal.isCompleted
                            ? Icon(
                                Icons.check,
                                color: GhostRollTheme.text,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: GhostRollTheme.textSecondary,
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteGoal(goal);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Goal'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              goal.description,
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGoalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAddGoalModal,
        icon: const Icon(Icons.add, size: 24),
        label: Text(
          'Add New Goal',
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

  void _showAddGoalModal() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'shortTerm';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    
    // Capture ref values before modal
    final categoryColors = ref.read(goalCategoryColorsProvider);
    final categoryNames = ref.read(goalCategoryNamesProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: GhostRollTheme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: GhostRollTheme.large,
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GhostRollTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Text(
                      'New Goal',
                      style: GhostRollTheme.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: GhostRollTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Input
                      Text('Goal Title', style: GhostRollTheme.labelMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: GhostRollTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'e.g., Earn Blue Belt',
                          hintStyle: GhostRollTheme.bodyLarge.copyWith(
                            color: GhostRollTheme.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Category Selection
                      Text('Category', style: GhostRollTheme.labelMedium),
                      const SizedBox(height: 12),
                      Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categoryColors.keys.map((category) {
                              final isSelected = selectedCategory == category;
                              final colorValue = categoryColors[category] ?? GhostRollTheme.flowBlue.value;
                              final color = Color(colorValue);
                              
                              return GestureDetector(
                                onTap: () => setModalState(() => selectedCategory = category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? color.withOpacity(0.2) : GhostRollTheme.overlayDark,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? color : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getGoalIcon(category),
                                        size: 16,
                                        color: isSelected ? color : GhostRollTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        categoryNames[category] ?? category,
                                        style: GhostRollTheme.bodySmall.copyWith(
                                          color: isSelected ? color : GhostRollTheme.textSecondary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Target Date
                      Text('Target Date', style: GhostRollTheme.labelMedium),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            builder: (context, child) {
                              return Theme(
                                data: GhostRollTheme.dark.copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: GhostRollTheme.flowBlue,
                                    onPrimary: GhostRollTheme.text,
                                    surface: GhostRollTheme.card,
                                    onSurface: GhostRollTheme.text,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setModalState(() => selectedDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: GhostRollTheme.overlayDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: GhostRollTheme.textSecondary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: GhostRollTheme.flowBlue),
                              const SizedBox(width: 12),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: GhostRollTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Description Input
                      Text('Description', style: GhostRollTheme.labelMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        style: GhostRollTheme.bodyLarge,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe what you want to achieve...',
                          hintStyle: GhostRollTheme.bodyLarge.copyWith(
                            color: GhostRollTheme.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              
              // Save Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a goal title'),
                            backgroundColor: GhostRollTheme.grindRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      
                      final user = ref.read(currentUserProvider);
                      if (user == null) {
                        Navigator.pop(context);
                        return;
                      }
                      
                      final colorValue = categoryColors[selectedCategory] ?? GhostRollTheme.flowBlue.value;
                      
                      final newGoal = Goal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: descriptionController.text,
                        category: selectedCategory,
                        createdAt: DateTime.now(),
                        targetDate: selectedDate,
                        color: Color(colorValue),
                      );
                      
                      final repository = ref.read(goalRepositoryProvider);
                      await repository.addGoal(user.uid, newGoal);
                      
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Goal added successfully!'),
                            backgroundColor: GhostRollTheme.recoveryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GhostRollTheme.flowBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Save Goal',
                      style: GhostRollTheme.titleMedium.copyWith(
                        color: GhostRollTheme.text,
                        fontWeight: FontWeight.bold,
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

  IconData _getGoalIcon(String category) {
    switch (category) {
      case 'shortTerm':
        return Icons.schedule;
      case 'longTerm':
        return Icons.timeline;
      case 'competition':
        return Icons.emoji_events;
      case 'skill':
        return Icons.sports_martial_arts;
      case 'fitness':
        return Icons.fitness_center;
      default:
        return Icons.flag;
    }
  }
} 
      case 'longTerm':
        return Icons.timeline;
      case 'competition':
        return Icons.emoji_events;
      case 'skill':
        return Icons.sports_martial_arts;
      case 'fitness':
        return Icons.fitness_center;
      default:
        return Icons.flag;
    }
  }
} 