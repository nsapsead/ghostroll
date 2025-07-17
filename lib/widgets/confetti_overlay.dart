import 'package:flutter/material.dart';
import 'confetti_widget.dart';
import 'dart:math' as math;

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool showConfetti;
  final VoidCallback? onConfettiComplete;

  const ConfettiOverlay({
    Key? key,
    required this.child,
    this.showConfetti = false,
    this.onConfettiComplete,
  }) : super(key: key);

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _showConfetti = widget.showConfetti;
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      setState(() {
        _showConfetti = true;
      });
    }
  }

  void _onConfettiComplete() {
    setState(() {
      _showConfetti = false;
    });
    widget.onConfettiComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showConfetti)
          Positioned.fill(
            child: GestureDetector(
              onTap: _onConfettiComplete,
              child: Container(
                color: Colors.transparent,
                child: ConfettiWidget(
                  duration: const Duration(seconds: 3),
                  numberOfPieces: 100                ).withCallback(_onConfettiComplete),
              ),
            ),
          ),
      ],
    );
  }
}

// Extension to add onComplete callback to ConfettiWidget
extension ConfettiWidgetExtension on ConfettiWidget {
  Widget withCallback(VoidCallback? onComplete) {
    return ConfettiWidgetWithCallback(
      duration: duration,
      numberOfPieces: numberOfPieces,
      colors: colors,
      onComplete: onComplete,
    );
  }
}

class ConfettiWidgetWithCallback extends StatefulWidget {
  final Duration duration;
  final int numberOfPieces;
  final List<Color> colors;
  final VoidCallback? onComplete;

  const ConfettiWidgetWithCallback({
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
    this.onComplete,
  }) : super(key: key);

  @override
  State<ConfettiWidgetWithCallback> createState() => _ConfettiWidgetWithCallbackState();
}

class _ConfettiWidgetWithCallbackState extends State<ConfettiWidgetWithCallback>
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
        velocityX: (_random.nextDouble() - 0.5) * 0.5,
        velocityY: _random.nextDouble() * 0.5,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
        shape: ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)],
      );
    });
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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