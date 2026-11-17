import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Clean, professional typography scale for REBS HRMS.
///
/// Designed with high legibility, strict contrast hierarchy, and consistent
/// line heights across all screen sizes.
abstract final class AppTypography {
  /// Large screen or branding title
  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: -0.4,
  );

  /// Standard screen title and section headlines
  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: -0.2,
  );

  /// Card titles and highlighted sub-headers
  static const TextStyle headingSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  /// Primary body copy for tiles, values, and input fields
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    height: 1.4,
  );

  /// Emphasized body text for key metrics and bold descriptors
  static const TextStyle bodyMediumBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  /// Secondary subdued text for labels, descriptions, and timestamps
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.3,
  );

  /// Status badge and tiny badge labels
  static const TextStyle labelBadge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Button text style with balanced letter spacing
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
    letterSpacing: 0.1,
  );
}
