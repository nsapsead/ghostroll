import 'package:flutter/material.dart';
import '../../theme/ghostroll_theme.dart';
import '../../core/constants/spacing.dart';

/// StatCard - Displays a single statistic with icon, value, and label
/// 
/// Used for displaying metrics like "This Week", "Streak", "Total Sessions"
/// 
/// Example:
/// ```dart
/// StatCard(
///   label: 'This Week',
///   value: '5',
///   icon: Icons.trending_up,
///   color: GhostRollTheme.flowBlue,
/// )
/// ```
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? GhostRollTheme.flowBlue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(GhostRollSpacing.md),
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(GhostRollSpacing.sm),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: cardColor,
                size: 24,
              ),
            ),
            const SizedBox(height: GhostRollSpacing.sm),
            Text(
              value,
              style: GhostRollTheme.headlineMedium.copyWith(
                color: cardColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GhostRollSpacing.xs),
            Text(
              label,
              style: GhostRollTheme.bodySmall.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

