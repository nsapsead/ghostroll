import 'package:flutter/material.dart';
import 'quick_log_screen.dart';
import 'journal_timeline_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../theme/ghostroll_theme.dart';
import '../theme/app_theme.dart';
import 'training_calendar_screen.dart';
import '../widgets/ghost_confetti.dart';
import '../services/notification_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;
  bool _showConfetti = false;
  bool _profileShouldStartInEditMode = false;

  List<Widget> get _screens => [
    QuickLogScreen(onNavigateToProfile: _navigateToProfileInEditMode),
    const JournalTimelineScreen(),
    const TrainingCalendarScreen(),
    const GoalsScreen(),
    ProfileScreen(initialEditMode: _profileShouldStartInEditMode),
  ];

  void _navigateToProfileInEditMode() {
    setState(() {
      _profileShouldStartInEditMode = true;
      _selectedIndex = 4; // Profile tab index
    });
    _animationController.reset();
    _animationController.forward();
    
    // Reset the edit mode flag after a brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _profileShouldStartInEditMode = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: GhostRollTheme.background,
          body: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: _screens[_selectedIndex],
              ),

            ],
          ),
          bottomNavigationBar: _buildFantasticBottomNav(),
        ),
        // Confetti overlay
        if (_showConfetti)
          GhostConfetti(
            onComplete: () => setState(() => _showConfetti = false),
          ),
      ],
    );
  }

  Widget _buildFantasticBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: GhostRollTheme.primaryGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: GhostRollTheme.flowBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive padding based on screen width
            final isSmallScreen = constraints.maxWidth < 375;
            final isMediumScreen = constraints.maxWidth < 414;
            
            final horizontalPadding = isSmallScreen ? 6.0 : isMediumScreen ? 8.0 : 12.0;
            final verticalPadding = isSmallScreen ? 2.0 : 4.0;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, 
                vertical: verticalPadding
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changed from spaceAround
                children: [
                  Expanded(child: _buildNavItem(0, Icons.add_circle_outline, Icons.add_circle, 'Quick Log')),
                  Expanded(child: _buildNavItem(1, Icons.history_outlined, Icons.history, 'Journal')),
                  Expanded(child: _buildNavItem(2, Icons.calendar_today_outlined, Icons.calendar_today, 'Calendar')),
                  Expanded(child: _buildNavItem(3, Icons.flag_outlined, Icons.flag, 'Goals')),
                  Expanded(child: _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on available width
        final isSmallScreen = MediaQuery.of(context).size.width < 375;
        final isMediumScreen = MediaQuery.of(context).size.width < 414;
        
        final iconSize = isSmallScreen ? 20.0 : 24.0;
        final fontSize = isSmallScreen ? 10.0 : 12.0;
        final horizontalPadding = isSmallScreen ? 1.0 : isMediumScreen ? 2.0 : 3.0;
        final verticalPadding = isSmallScreen ? 2.0 : 3.0;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            _animationController.reset();
            _animationController.forward();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, 
              vertical: verticalPadding
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  size: iconSize,
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


} 