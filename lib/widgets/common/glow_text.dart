import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlowText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final Color textColor;
  final Color glowColor;

  const GlowText({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = -0.5,
    this.textColor = Colors.white,
    this.glowColor = Colors.white,
  });

  @override
  State<GlowText> createState() => _GlowTextState();
}

class _GlowTextState extends State<GlowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.1,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              widget.textColor,
              widget.textColor.withOpacity(0.8),
              widget.textColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(_glowAnimation.value),
                  blurRadius: 6 + (_glowAnimation.value * 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: widget.glowColor.withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 12 + (_glowAnimation.value * 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                letterSpacing: widget.letterSpacing,
                color: widget.textColor,
              ),
            ),
          ),
        );
      },
    );
  }
} 