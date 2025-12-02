import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';

/// ResponsiveGrid - A flexible grid layout helper
/// 
/// Provides consistent grid layouts across the app with configurable
/// cross-axis count, spacing, and aspect ratio.
/// 
/// Example:
/// ```dart
/// ResponsiveGrid(
///   crossAxisCount: 2,
///   childAspectRatio: 1.2,
///   spacing: GhostRollSpacing.md,
///   children: [widget1, widget2, widget3],
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final double runSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.spacing = GhostRollSpacing.md,
    this.runSpacing = GhostRollSpacing.md,
    this.shrinkWrap = true,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// ResponsiveGridBuilder - Builds grid items on demand
/// 
/// More memory efficient for large lists.
class ResponsiveGridBuilder extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final double runSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const ResponsiveGridBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.spacing = GhostRollSpacing.md,
    this.runSpacing = GhostRollSpacing.md,
    this.shrinkWrap = true,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

