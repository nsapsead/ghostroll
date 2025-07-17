import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/ghostroll_theme.dart';
import '../widgets/ghost_mascot.dart';

class LoadingScreen extends StatefulWidget {
  final String? message;
  final VoidCallback? onComplete;

  const LoadingScreen({
    super.key,
    this.message,
    this.onComplete,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    
    // Auto-complete after 3 seconds if callback provided
    if (widget.onComplete != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onComplete!();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
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
            colors: GhostRollTheme.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ghost mascot
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: GhostMascot(
                    size: 150,
                    state: GhostMascotState.happy,
                    isAnimated: true,
                  ),
                ),
                const SizedBox(height: 40),
                
                // App title
                Text(
                  'GhostRoll',
                  style: GhostRollTheme.headlineLarge.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: GhostRollTheme.text.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.5, duration: 800.ms, delay: 300.ms),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Your Martial Arts Journey',
                  style: GhostRollTheme.titleMedium.copyWith(
                    color: GhostRollTheme.textSecondary,
                    fontSize: 18,
                  ),
                ).animate().slideY(begin: 0.5, duration: 800.ms, delay: 500.ms),
                
                const SizedBox(height: 60),
                
                // Loading message
                if (widget.message != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.card.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: GhostRollTheme.textSecondary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.message!,
                      style: GhostRollTheme.bodyMedium.copyWith(
                        color: GhostRollTheme.textSecondary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                
                const SizedBox(height: 40),
                
                // Loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => 
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: GhostRollTheme.flowBlue,
                        shape: BoxShape.circle,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).scale(
                      duration: 600.ms,
                      delay: Duration(milliseconds: index * 200),
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                    ).then().scale(
                      duration: 600.ms,
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(0.5, 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 