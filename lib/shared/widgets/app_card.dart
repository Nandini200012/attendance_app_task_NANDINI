import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Reusable card component adhering to 16px radius, subtle border,
/// and soft elevation shadows for standard corporate polish.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(
      color: borderColor ?? AppColors.border,
      width: 1.0,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      side: border,
    );

    final shadows = hasShadow
        ? [
            const BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ]
        : null;

    if (onTap != null) {
      return Container(
        decoration: ShapeDecoration(
          color: backgroundColor ?? AppColors.card,
          shape: shape,
          shadows: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
    }

    return Container(
      decoration: ShapeDecoration(
        color: backgroundColor ?? AppColors.card,
        shape: shape,
        shadows: shadows,
      ),
      padding: padding,
      child: child,
    );
  }
}
