import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/ghostroll_theme.dart';

class GhostConfetti extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const GhostConfetti({super.key, this.onComplete});

  @override
  State<GhostConfetti> createState() => _GhostConfettiState();
}

class _GhostConfettiState extends State<GhostConfetti> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    
    // Call onComplete when animation finishes
    Future.delayed(const Duration(seconds: 3), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ghost emoji confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            colors: [
              GhostRollTheme.flowBlue,
              GhostRollTheme.grindRed,
              GhostRollTheme.recoveryGreen,
              GhostRollTheme.text,
            ],
            createParticlePath: (size) {
              return Path()
                ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
            },
          ),
        ),
        
        // Floating ghost particles
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 3,
            minBlastForce: 1,
            emissionFrequency: 0.1,
            numberOfParticles: 10,
            gravity: 0.05,
            colors: [
              GhostRollTheme.text.withOpacity(0.8),
              GhostRollTheme.flowBlue.withOpacity(0.6),
            ],
            createParticlePath: (size) {
              return Path()
                ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
            },
          ),
        ),
      ],
    );
  }
} 