/// GhostRoll Spacing System
/// 
/// Consistent spacing scale for the entire app.
/// Based on 4px base unit for harmony and rhythm.
class GhostRollSpacing {
  GhostRollSpacing._(); // Private constructor to prevent instantiation

  // Base spacing units (4px increments)
  static const double xs = 4.0;   // Extra small - tight spacing
  static const double sm = 8.0;   // Small - compact spacing
  static const double md = 16.0;  // Medium - standard spacing
  static const double lg = 24.0;  // Large - generous spacing
  static const double xl = 32.0;  // Extra large - section spacing
  static const double xxl = 48.0; // 2X large - major section spacing

  // Screen padding
  static const double screenHorizontal = md; // 16px
  static const double screenVertical = md;  // 16px

  // Component spacing
  static const double cardPadding = md;      // 16px
  static const double cardMargin = md;      // 16px
  static const double cardSpacing = sm;     // 8px between cards

  // Section spacing
  static const double sectionSpacing = lg; // 24px between sections
  static const double subsectionSpacing = md; // 16px between subsections

  // Grid spacing
  static const double gridSpacing = md;     // 16px grid gap
  static const double gridItemSpacing = sm; // 8px between grid items
}

