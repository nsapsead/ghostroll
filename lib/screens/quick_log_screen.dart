import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'log_session_form.dart';
import '../theme/ghostroll_theme.dart';

import '../widgets/common/glow_text.dart';
import '../services/calendar_service.dart';
import '../services/profile_service.dart';
import '../services/session_service.dart';
import 'dart:math' as math;

// Custom clipper for radical button shape
class RadicalButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Start from top-left with a curve
    path.moveTo(30, 0);
    
    // Top edge with wave
    path.quadraticBezierTo(size.width * 0.3, -10, size.width * 0.7, 15);
    path.quadraticBezierTo(size.width * 0.9, 25, size.width - 20, 0);
    
    // Right edge with angular cut
    path.lineTo(size.width, 20);
    path.lineTo(size.width - 15, size.height * 0.6);
    path.lineTo(size.width, size.height - 10);
    
    // Bottom edge with reverse wave
    path.quadraticBezierTo(size.width * 0.8, size.height + 5, size.width * 0.4, size.height - 8);
    path.quadraticBezierTo(size.width * 0.2, size.height - 15, 40, size.height);
    
    // Left edge with curve
    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(-5, size.height * 0.5, 15, size.height * 0.3);
    path.quadraticBezierTo(25, size.height * 0.1, 30, 0);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom clipper for accent overlay
class AccentShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.3, 0, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.7, size.height, 0, size.height * 0.7);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Modern angular button clipper
class ModernButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Start from top-left with rounded corner
    path.moveTo(16, 0);
    path.lineTo(size.width - 40, 0);
    
    // Top-right with angular cut
    path.lineTo(size.width, 16);
    path.lineTo(size.width, size.height - 16);
    
    // Bottom-right with cut
    path.lineTo(size.width - 16, size.height);
    path.lineTo(16, size.height);
    
    // Bottom-left rounded
    path.quadraticBezierTo(0, size.height, 0, size.height - 16);
    path.lineTo(0, 16);
    
    // Top-left rounded
    path.quadraticBezierTo(0, 0, 16, 0);
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Modern button border for ink well
class ModernButtonBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Size size = rect.size;
    Path path = Path();
    
    // Mirror the ModernButtonClipper shape
    path.moveTo(16, 0);
    path.lineTo(size.width - 40, 0);
    path.lineTo(size.width, 16);
    path.lineTo(size.width, size.height - 16);
    path.lineTo(size.width - 16, size.height);
    path.lineTo(16, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 16);
    path.lineTo(0, 16);
    path.quadraticBezierTo(0, 0, 16, 0);
    path.close();
    
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

// Hexagon button clipper
class HexagonButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    final width = size.width;
    final height = size.height;
    final cornerRadius = height * 0.15;
    
    // Start from left side
    path.moveTo(cornerRadius, 0);
    
    // Top edge with slight angle
    path.lineTo(width - cornerRadius * 2, 0);
    path.lineTo(width, cornerRadius);
    
    // Right edge
    path.lineTo(width, height - cornerRadius);
    path.lineTo(width - cornerRadius * 2, height);
    
    // Bottom edge
    path.lineTo(cornerRadius, height);
    path.lineTo(0, height - cornerRadius);
    
    // Left edge
    path.lineTo(0, cornerRadius);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Hexagon button border
class HexagonButtonBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Size size = rect.size;
    Path path = Path();
    
    final width = size.width;
    final height = size.height;
    final cornerRadius = height * 0.15;
    
    path.moveTo(cornerRadius, 0);
    path.lineTo(width - cornerRadius * 2, 0);
    path.lineTo(width, cornerRadius);
    path.lineTo(width, height - cornerRadius);
    path.lineTo(width - cornerRadius * 2, height);
    path.lineTo(cornerRadius, height);
    path.lineTo(0, height - cornerRadius);
    path.lineTo(0, cornerRadius);
    path.close();
    
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

// Custom border for ink well
class RadicalButtonBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Size size = rect.size;
    Path path = Path();
    
    // Same shape as RadicalButtonClipper
    path.moveTo(rect.left + 30, rect.top);
    path.quadraticBezierTo(rect.left + size.width * 0.3, rect.top - 10, rect.left + size.width * 0.7, rect.top + 15);
    path.quadraticBezierTo(rect.left + size.width * 0.9, rect.top + 25, rect.right - 20, rect.top);
    path.lineTo(rect.right, rect.top + 20);
    path.lineTo(rect.right - 15, rect.top + size.height * 0.6);
    path.lineTo(rect.right, rect.bottom - 10);
    path.quadraticBezierTo(rect.left + size.width * 0.8, rect.bottom + 5, rect.left + size.width * 0.4, rect.bottom - 8);
    path.quadraticBezierTo(rect.left + size.width * 0.2, rect.bottom - 15, rect.left + 40, rect.bottom);
    path.lineTo(rect.left, rect.bottom - 25);
    path.quadraticBezierTo(rect.left - 5, rect.top + size.height * 0.5, rect.left + 15, rect.top + size.height * 0.3);
    path.quadraticBezierTo(rect.left + 25, rect.top + size.height * 0.1, rect.left + 30, rect.top);
    path.close();
    
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

class QuickLogScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  
  const QuickLogScreen({super.key, this.onNavigateToProfile});

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _upcomingClasses = [];
  bool _isLoadingClasses = true;
  String _userName = 'Guest'; // Default to Guest

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
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
    
    _loadUpcomingClasses();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final profileData = await ProfileService.loadProfileData();
      setState(() {
        String firstName = '';
        
        // Try to get firstName directly
        if (profileData['firstName'] != null && profileData['firstName'].toString().trim().isNotEmpty) {
          firstName = profileData['firstName'];
        } 
        // Fall back to splitting existing 'name' field for backward compatibility
        else if (profileData['name'] != null && profileData['name'].toString().trim().isNotEmpty) {
          final nameParts = profileData['name'].toString().trim().split(' ');
          firstName = nameParts.isNotEmpty ? nameParts.first : '';
        }
        
        _userName = firstName.isNotEmpty ? firstName : 'Guest';
      });
    } catch (e) {
      setState(() {
        _userName = 'Guest';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh upcoming classes when screen becomes visible
    _loadUpcomingClasses();
    _loadUserName(); // Also refresh user name
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadUpcomingClasses() async {
    try {
      final selectedStyles = await ProfileService.loadSelectedStyles();
      final upcomingClasses = await CalendarService.getUpcomingClasses();
      
      // Filter classes based on selected martial arts styles
      final filteredClasses = upcomingClasses.where((c) => 
        _matchesSelectedStyle(c['classType'], selectedStyles)).toList();
      
      setState(() {
        _upcomingClasses = filteredClasses.take(5).toList(); // Limit to 5 classes
        _isLoadingClasses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  bool _matchesSelectedStyle(String classType, List<String> selectedStyles) {
    if (selectedStyles.isEmpty) return true; // Show all if none selected
    
    // Mapping from class types to martial arts styles
    final classTypeToStyleMapping = {
      'BJJ': 'Brazilian Jiu-Jitsu (BJJ)',
      'Brazilian Jiu-Jitsu': 'Brazilian Jiu-Jitsu (BJJ)',
      'Muay Thai': 'Muay Thai',
      'Boxing': 'Boxing',
      'Wrestling': 'Wrestling',
      'Judo': 'Judo',
      'Karate': 'Karate',
      'Taekwondo': 'Taekwondo',
      'Kickboxing': 'Kickboxing',
      'Krav Maga': 'Krav Maga',
      'Aikido': 'Aikido',
    };
    
    final matchingStyle = classTypeToStyleMapping[classType];
    return matchingStyle != null && selectedStyles.contains(matchingStyle);
  }

  String _getDayName(int dayOfWeek) {
    return CalendarService.getDayName(dayOfWeek);
  }

  String _formatTime(String timeString) {
    return CalendarService.formatTime(timeString);
  }


  void _onLogSession() {
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogSessionForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildWelcomeSection(),
                              const SizedBox(height: 20),
                              _buildMainLogButton(),
                              const SizedBox(height: 24),
                              _buildQuickStatsSection(),
                              const SizedBox(height: 20),
                              _buildUpcomingClassesSection(),
                              const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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

  Widget _buildWelcomeSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    final mascotSize = isSmallScreen ? 120.0 : 140.0;
    
    return Column(
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Ghost mascot tap effect
            },
            child: Container(
              width: mascotSize,
              height: mascotSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Tight glow layer - positioned slightly offset to create edge glow
                    Positioned(
                      left: 2,
                      top: 2,
                      right: 2,
                      bottom: 2,
                      child: Image.asset(
                        'assets/images/GhostRollBeltMascot.png',
                        fit: BoxFit.contain,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    // Main image layer
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/GhostRollBeltMascot.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _userName == 'Guest' ? () {
            // Use callback to navigate to profile tab
            widget.onNavigateToProfile?.call();
          } : null,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GhostRollTheme.headlineLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(text: "Welcome back, "),
                TextSpan(
                  text: _userName,
                  style: _userName == 'Guest' 
                    ? GhostRollTheme.headlineLarge.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: GhostRollTheme.flowBlue,
                        decoration: TextDecoration.underline,
                        decorationColor: GhostRollTheme.flowBlue,
                      )
                    : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Track the invisible work!",
          style: GhostRollTheme.titleMedium.copyWith(
            color: GhostRollTheme.textSecondary,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainLogButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    final buttonHeight = isSmallScreen ? 90.0 : 100.0;
    
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        child: Stack(
          children: [
            // Main gradient background with hexagon shape
            ClipPath(
              clipper: HexagonButtonClipper(),
              child: Container(
                width: double.infinity,
                height: buttonHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00F5FF), // Electric cyan
                      Color(0xFF1F8EF1), // GhostRoll blue
                      Color(0xFF0066FF), // Deep blue
                      Color(0xFF8A2BE2), // Purple accent
                    ],
                    begin: Alignment(-1.0, -1.0),
                    end: Alignment(1.0, 1.0),
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F5FF).withOpacity(0.5),
                      blurRadius: 25,
                      spreadRadius: 3,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF8A2BE2).withOpacity(0.3),
                      blurRadius: 35,
                      spreadRadius: 1,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
              ),
            ),
            // Simplified energy accent
            Positioned(
              right: 20,
              top: 20,
              bottom: 20,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.cyan.withOpacity(0.6),
                          Colors.white.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5 * _pulseAnimation.value),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Main interactive area
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onLogSession,
                  customBorder: HexagonButtonBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Martial arts icon
                        Container(
                          width: isSmallScreen ? 60 : 65,
                          height: isSmallScreen ? 60 : 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.sports_martial_arts,
                            color: Colors.white,
                            size: isSmallScreen ? 28 : 32,
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Dynamic text
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFE0E0E0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  'Log Training',
                                  style: GhostRollTheme.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 24 : 26,
                                    shadows: [
                                      Shadow(
                                        color: Colors.cyan.withOpacity(0.5),
                                        offset: const Offset(0, 0),
                                        blurRadius: 12,
                                      ),
                                      Shadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        // Forward arrow
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.8),
                          size: isSmallScreen ? 16 : 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return FutureBuilder<Map<String, dynamic>>(
      future: SessionService.getTrainingStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};
        final thisWeek = stats['thisWeekSessions']?.toString() ?? '0';
        final total = stats['totalSessions']?.toString() ?? '0';
        
        // Calculate streak (simplified - just show days since last session)
        final streakText = total == '0' ? '0' : '1+';
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'This Week',
                value: thisWeek,
                color: GhostRollTheme.flowBlue,
                isSmall: isSmallScreen,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: '${streakText} day${streakText != '1' ? 's' : ''}',
                color: GhostRollTheme.grindRed,
                isSmall: isSmallScreen,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                label: 'Total',
                value: total,
                color: GhostRollTheme.recoveryGreen,
                isSmall: isSmallScreen,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 12 : 16,
        horizontal: isSmall ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: isSmall ? 4 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: isSmall ? 16 : 20,
          ),
          SizedBox(height: isSmall ? 4 : 6),
          Text(
            value,
            style: GhostRollTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 14 : 16,
            ),
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            label,
            style: GhostRollTheme.bodySmall.copyWith(
              color: GhostRollTheme.textSecondary,
              fontSize: isSmall ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingClassesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: GhostRollTheme.flowGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Upcoming Classes',
                style: GhostRollTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingClasses)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: GhostRollTheme.flowBlue,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_upcomingClasses.isEmpty)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GhostRollTheme.overlayDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: GhostRollTheme.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No upcoming classes found',
                        style: GhostRollTheme.titleMedium.copyWith(
                          color: GhostRollTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add classes in Training Calendar or select martial arts styles in Profile',
                        style: GhostRollTheme.bodySmall.copyWith(
                          color: GhostRollTheme.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => _isLoadingClasses = true);
                    _loadUpcomingClasses();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.flowBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GhostRollTheme.flowBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: GhostRollTheme.flowBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Refresh',
                          style: GhostRollTheme.bodyMedium.copyWith(
                            color: GhostRollTheme.flowBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: _upcomingClasses.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GhostRollTheme.overlayDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GhostRollTheme.textSecondary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getClassTypeGradient(c['classType']),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getClassTypeIcon(c['classType']),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['classType'],
                            style: GhostRollTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: GhostRollTheme.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: GhostRollTheme.textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_getDayName(c['dayOfWeek'])} @ ${_formatTime(c['startTime'])}',
                                style: GhostRollTheme.bodyMedium.copyWith(
                                  color: GhostRollTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: GhostRollTheme.textTertiary,
                      size: 16,
                    ),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  IconData _getClassTypeIcon(String classType) {
    switch (classType.toLowerCase()) {
      case 'bjj':
      case 'brazilian jiu-jitsu':
        return Icons.sports_martial_arts;
      case 'muay thai':
      case 'boxing':
        return Icons.sports_mma;
      case 'wrestling':
        return Icons.fitness_center;
      case 'judo':
        return Icons.self_improvement;
      case 'karate':
      case 'taekwondo':
        return Icons.sports_kabaddi;
      case 'kickboxing':
        return Icons.sports_martial_arts;
      case 'krav maga':
        return Icons.security;
      case 'aikido':
        return Icons.self_improvement;
      default:
        return Icons.sports_martial_arts;
    }
  }

  List<Color> _getClassTypeGradient(String classType) {
    switch (classType.toLowerCase()) {
      case 'bjj':
      case 'brazilian jiu-jitsu':
        return [Colors.purple.shade600, Colors.purple.shade800];
      case 'muay thai':
        return [Colors.red.shade600, Colors.red.shade800];
      case 'boxing':
        return [Colors.orange.shade600, Colors.orange.shade800];
      case 'wrestling':
        return [Colors.blue.shade600, Colors.blue.shade800];
      case 'judo':
        return [Colors.green.shade600, Colors.green.shade800];
      case 'karate':
        return [Colors.amber.shade600, Colors.amber.shade800];
      case 'taekwondo':
        return [Colors.indigo.shade600, Colors.indigo.shade800];
      case 'kickboxing':
        return [Colors.teal.shade600, Colors.teal.shade800];
      case 'krav maga':
        return [Colors.grey.shade600, Colors.grey.shade800];
      case 'aikido':
        return [Colors.cyan.shade600, Colors.cyan.shade800];
      default:
        return GhostRollTheme.flowGradient;
    }
  }
} 