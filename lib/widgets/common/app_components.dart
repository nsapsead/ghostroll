import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/ghostroll_theme.dart';
import 'glow_text.dart';

// Gradient Card Component
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showBorder;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      margin: margin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: showBorder
            ? Border.all(color: AppColors.overlayMedium, width: 1)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

// App Text Field Component
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          onTap: onTap,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.overlayLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.overlayMedium),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.overlayMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

// App Button Component
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? 
        (isOutlined ? Colors.transparent : AppColors.accent);
    final effectiveTextColor = textColor ?? 
        (isOutlined ? AppColors.accent : AppColors.textPrimary);

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: isOutlined
                ? const BorderSide(color: AppColors.accent, width: 1)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: effectiveTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Skeleton Loading Component
class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.overlayMedium, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.overlayLight,
              AppColors.overlayMedium,
              AppColors.overlayLight,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

// Skeleton Text Component
class SkeletonText extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonText({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.overlayLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// Empty State Component
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Section Header Component
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// Enhanced Responsive Container Component
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableResponsivePadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.enableResponsivePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? 600,
      ),
      padding: enableResponsivePadding 
          ? (padding ?? ResponsiveUtils.responsivePadding(screenWidth))
          : padding,
      margin: margin,
      child: child,
    );
  }
}

// Mobile-optimized app bar component
class MobileAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const MobileAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveUtils.isSmallPhone(screenWidth);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.responsiveHorizontal(screenWidth), 
        vertical: isSmallScreen ? 12 : 16
      ),
      child: Row(
        children: [
          if (showBackButton || leading != null) ...[
            leading ?? IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: GhostRollTheme.text,
                size: ResponsiveUtils.responsiveIconSize(screenWidth, baseSize: 20),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
          ],
          Expanded(
            child: Container(
              height: isSmallScreen ? 48 : 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: GhostRollTheme.medium,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: GlowText(
                        text: title,
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          screenWidth, 
                          baseSize: 20, 
                          minSize: 16, 
                          maxSize: 24
                        ),
                        textColor: Colors.white,
                        glowColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (actions != null) ...[
            SizedBox(width: isSmallScreen ? 8 : 12),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

// Responsive card component
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final List<BoxShadow>? boxShadow;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveUtils.isSmallPhone(screenWidth);
    
    final responsivePadding = padding ?? EdgeInsets.all(
      isSmallScreen ? 16 : 20
    );
    
    final responsiveMargin = margin ?? EdgeInsets.symmetric(
      horizontal: AppSpacing.responsiveHorizontal(screenWidth),
      vertical: isSmallScreen ? 8 : 12,
    );

    return Container(
      margin: responsiveMargin,
      padding: responsivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? GhostRollTheme.card,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: boxShadow ?? (elevation != null 
            ? [BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: elevation!,
                offset: Offset(0, elevation! / 2),
              )]
            : GhostRollTheme.medium),
      ),
      child: child,
    );
  }
}

// Safe scrollable content wrapper
class SafeScrollableContent extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const SafeScrollableContent({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = ResponsiveUtils.safeBottomPadding(context);
    
    return SingleChildScrollView(
      padding: padding ?? EdgeInsets.only(
        left: AppSpacing.responsiveHorizontal(screenWidth),
        right: AppSpacing.responsiveHorizontal(screenWidth),
        top: AppSpacing.md,
        bottom: bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      ),
    );
  }
} 

class SocialAuthButton extends StatelessWidget {
  final String text;
  final String provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _getProviderGradient(),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _getProviderBorderColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getProviderShadowColor().withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_getProviderTextColor()),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _getProviderIcon(),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        text,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getProviderTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _getProviderIcon() {
    switch (provider.toLowerCase()) {
      case 'google':
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.g_mobiledata,
            color: Color(0xFF4285F4),
            size: 20,
          ),
        );
      case 'apple':
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.apple,
            color: Colors.black,
            size: 20,
          ),
        );
      case 'facebook':
        return const Icon(
          Icons.facebook,
          color: Colors.white,
          size: 24,
        );
      default:
        return const Icon(
          Icons.account_circle,
          color: Colors.white,
          size: 24,
        );
    }
  }

  LinearGradient _getProviderGradient() {
    switch (provider.toLowerCase()) {
      case 'google':
        return const LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'apple':
        return const LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF2D2D2D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'facebook':
        return const LinearGradient(
          colors: [Color(0xFF1877F2), Color(0xFF166FE5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  Color _getProviderBorderColor() {
    switch (provider.toLowerCase()) {
      case 'google':
        return const Color(0xFFDADCE0);
      case 'apple':
        return Colors.white;
      case 'facebook':
        return const Color(0xFF1877F2);
      default:
        return AppColors.primary;
    }
  }

  Color _getProviderShadowColor() {
    switch (provider.toLowerCase()) {
      case 'google':
        return const Color(0xFFDADCE0);
      case 'apple':
        return Colors.black;
      case 'facebook':
        return const Color(0xFF1877F2);
      default:
        return AppColors.primary;
    }
  }

  Color _getProviderTextColor() {
    switch (provider.toLowerCase()) {
      case 'google':
        return const Color(0xFF3C4043);
      case 'apple':
        return Colors.white;
      case 'facebook':
        return Colors.white;
      default:
        return AppColors.textPrimary;
    }
  }
} 