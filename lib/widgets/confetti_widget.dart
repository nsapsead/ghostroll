import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiWidget extends StatefulWidget {
  final Duration duration;
  final int numberOfPieces;
  final List<Color> colors;
  
  const ConfettiWidget({
    Key? key,
    this.duration = const Duration(seconds: 3),
    this.numberOfPieces = 50,
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ],
  }) : super(key: key);

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiPiece> _pieces;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _pieces = List.generate(widget.numberOfPieces, (index) {
      return ConfettiPiece(
        color: widget.colors[_random.nextInt(widget.colors.length)],
        size: _random.nextDouble() * 8 + 4,
        startX: _random.nextDouble(),
        startY: -0.2 + _random.nextDouble() * 0.3,
        velocityX: (_random.nextDouble() - 0.5) * 100,
        velocityY: _random.nextDouble() * 0.5 * 100,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
        shape: ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)],
      );
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

enum ConfettiShape { circle, square, triangle, star }

class ConfettiPiece {
  final Color color;
  final double size;
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double rotationSpeed;
  final ConfettiShape shape;

  ConfettiPiece({
    required this.color,
    required this.size,
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.rotationSpeed,
    required this.shape,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;

  ConfettiPainter({
    required this.pieces,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final paint = Paint()
        ..color = piece.color
        ..style = PaintingStyle.fill;

      // Calculate position with gravity
      final gravity = 0.001;
      final time = progress * 3; // Assuming 3 seconds duration
      
      final x = piece.startX * size.width + piece.velocityX * size.width * time;
      final y = piece.startY * size.height + piece.velocityY * size.height * time + 
             0.5 * gravity * time * time * size.height;
      
      final rotation = piece.rotationSpeed * time * 2 * math.pi;
      
      // Don't draw if piece is off screen
      if (y > size.height || x < -piece.size || x > size.width + piece.size) {
        continue;
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      switch (piece.shape) {
        case ConfettiShape.circle:
          canvas.drawCircle(
            Offset.zero,
            piece.size / 2,
            paint,
          );
          break;
        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: piece.size,
              height: piece.size,
            ),
            paint,
          );
          break;
        case ConfettiShape.triangle:
          final path = Path();
          path.moveTo(0 - piece.size / 2, 0);
          path.lineTo(-piece.size / 2, piece.size / 2);
          path.lineTo(piece.size / 2, piece.size / 2);
          path.lineTo(0, 0);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case ConfettiShape.star:
          _drawStar(canvas, paint, piece.size);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.4;
    final points = 5;
    
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = i * math.pi / points;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
} 