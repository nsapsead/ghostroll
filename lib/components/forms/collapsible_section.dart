import 'package:flutter/material.dart';
import '../../theme/ghostroll_theme.dart';
import '../../core/constants/spacing.dart';

/// CollapsibleSection - A collapsible form section with header
/// 
/// Provides a clean way to organize form content into collapsible sections.
/// Useful for long forms like the Log Session Form.
/// 
/// Example:
/// ```dart
/// CollapsibleSection(
///   title: 'Session Details',
///   icon: Icons.fitness_center,
///   initiallyExpanded: true,
///   child: Column(
///     children: [/* form fields */],
///   ),
/// )
/// ```
class CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final IconData? icon;
  final EdgeInsetsGeometry? contentPadding;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    this.icon,
    this.contentPadding,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: GhostRollSpacing.md),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: GhostRollTheme.small,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(GhostRollSpacing.md),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(GhostRollSpacing.xs),
                      decoration: BoxDecoration(
                        color: GhostRollTheme.flowBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: GhostRollTheme.flowBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: GhostRollSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GhostRollTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: Icon(
                      Icons.expand_more,
                      color: GhostRollTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: widget.contentPadding ??
                  const EdgeInsets.fromLTRB(
                    GhostRollSpacing.md,
                    0,
                    GhostRollSpacing.md,
                    GhostRollSpacing.md,
                  ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

