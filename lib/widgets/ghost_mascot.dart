import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/ghostroll_theme.dart';

class GhostMascot extends StatefulWidget {
  final double size;
  final bool isAnimated;
  final GhostMascotState state;
  final VoidCallback? onTap;

  const GhostMascot({
    super.key,
    this.size = 120,
    this.isAnimated = true,
    this.state = GhostMascotState.idle,
    this.onTap,
  });

  @override
  State<GhostMascot> createState() => _GhostMascotState();
}

enum GhostMascotState {
  idle,
  happy,
  excited,
  training,
  celebrating,
}

class _GhostMascotState extends State<GhostMascot>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimated) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _bounceController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _blinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceController, _floatController, _blinkController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.isAnimated ? _floatAnimation.value : 0),
            child: Container(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: GhostPainter(
                  state: widget.state,
                  bounceValue: widget.isAnimated ? _bounceAnimation.value : 1.0,
                  blinkValue: widget.isAnimated ? _blinkAnimation.value : 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GhostPainter extends CustomPainter {
  final GhostMascotState state;
  final double bounceValue;
  final double blinkValue;

  GhostPainter({
    required this.state,
    required this.bounceValue,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = 0.8 + (bounceValue * 0.1);

    // Apply bounce scaling
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    // Draw ghost body
    _drawGhostBody(canvas, size);
    
    // Draw BJJ belt
    _drawBJJBelt(canvas, size);
    
    // Draw face
    _drawFace(canvas, size);

    canvas.restore();
  }

  void _drawGhostBody(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bodyWidth = size.width * 0.6;
    final bodyHeight = size.height * 0.7;

    // Simple, clean ghost body
    final bodyPath = Path();
    
    // Top - simple rounded rectangle
    bodyPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - bodyHeight * 0.1),
        width: bodyWidth,
        height: bodyHeight * 0.8,
      ),
      const Radius.circular(30),
    ));

    // Clean white fill
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(bodyPath, bodyPaint);

    // Simple outline
    final outlinePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(bodyPath, outlinePaint);
  }

  void _drawBJJBelt(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final beltWidth = size.width * 0.5;
    final beltHeight = size.height * 0.08;
    final beltY = center.dy + size.height * 0.15;

    // Simple black belt
    final beltRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, beltY),
        width: beltWidth,
        height: beltHeight,
      ),
      const Radius.circular(4),
    );

    final beltPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRRect(beltRect, beltPaint);

    // Simple red bar
    final redBarWidth = beltWidth * 0.25;
    final redBarX = center.dx + beltWidth / 2 - redBarWidth - 8;

    final redBarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(redBarX, beltY),
        width: redBarWidth,
        height: beltHeight,
      ),
      const Radius.circular(3),
    );

    final redBarPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawRRect(redBarRect, redBarPaint);

    // Simple white stripe
    final stripeWidth = redBarWidth * 0.1;
    final stripeX = redBarX - redBarWidth / 2 + redBarWidth * 0.15;

    final stripeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(stripeX, beltY),
        width: stripeWidth,
        height: beltHeight * 0.8,
      ),
      const Radius.circular(2),
    );

    final stripePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(stripeRect, stripePaint);
  }

  void _drawFace(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eyeSize = size.width * 0.08;
    final eyeSpacing = size.width * 0.15;

    // Simple black eyes
    final leftEyeCenter = Offset(center.dx - eyeSpacing / 2, center.dy - size.height * 0.05);
    final rightEyeCenter = Offset(center.dx + eyeSpacing / 2, center.dy - size.height * 0.05);

    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Eyes with blink effect
    final currentEyeSize = eyeSize * blinkValue;
    canvas.drawCircle(leftEyeCenter, currentEyeSize, eyePaint);
    canvas.drawCircle(rightEyeCenter, currentEyeSize, eyePaint);

    // Simple mouth
    final mouthY = center.dy + size.height * 0.1;
    final mouthWidth = size.width * 0.2;
    
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    switch (state) {
      case GhostMascotState.idle:
      case GhostMascotState.happy:
        // Simple smile
        final smilePath = Path();
        smilePath.moveTo(center.dx - mouthWidth / 2, mouthY);
        smilePath.quadraticBezierTo(
          center.dx, mouthY + 8,
          center.dx + mouthWidth / 2, mouthY,
        );
        canvas.drawPath(smilePath, mouthPaint);
        break;
      
      case GhostMascotState.excited:
        // Big smile
        final smilePath = Path();
        smilePath.moveTo(center.dx - mouthWidth / 2, mouthY);
        smilePath.quadraticBezierTo(
          center.dx, mouthY + 12,
          center.dx + mouthWidth / 2, mouthY,
        );
        canvas.drawPath(smilePath, mouthPaint);
        break;
      
      case GhostMascotState.training:
        // Straight line
        canvas.drawLine(
          Offset(center.dx - mouthWidth / 2, mouthY),
          Offset(center.dx + mouthWidth / 2, mouthY),
          mouthPaint,
        );
        break;
      
      case GhostMascotState.celebrating:
        // Open mouth
        canvas.drawCircle(Offset(center.dx, mouthY), mouthWidth / 3, mouthPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 