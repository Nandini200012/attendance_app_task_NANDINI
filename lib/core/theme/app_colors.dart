import 'package:flutter/material.dart';

/// Centralized color palette for the REBS HRMS application.
///
/// Combines a clean executive background (#F7F7F7) and crisp cards (#FFFFFF)
/// with purposeful corporate accents (Royal Blue, Emerald, Amber, Rose, Purple)
/// to provide visual clarity, depth, and intuitive affordances.
abstract final class AppColors {
  /// Primary screen background: #F7F7F7
  static const Color background = Color(0xFFF7F7F7);

  /// Card surface color: #FFFFFF
  static const Color card = Color(0xFFFFFFFF);

  /// Primary high-contrast text and dark components: #0F172A
  static const Color primaryText = Color(0xFF0F172A);

  /// Secondary subdued text for labels and captions: #64748B
  static const Color secondaryText = Color(0xFF64748B);

  /// Subtle container and card borders: #E2E8F0
  static const Color border = Color(0xFFE2E8F0);

  /// Primary button fill color: #0F172A (Deep Slate Navy)
  static const Color primaryButton = Color(0xFF0F172A);

  /// Primary button text color: #FFFFFF
  static const Color buttonText = Color(0xFFFFFFFF);

  /// Corporate Brand Accent (Royal Blue) for focus, links, and hero highlights
  static const Color primaryAccent = Color(0xFF2563EB);

  /// Soft tint for primary accent icon containers
  static const Color primaryAccentLight = Color(0xFFEFF6FF);

  /// Muted green for approved, synced, and verified states
  static const Color success = Color(0xFF16A34A);

  /// Soft background tint for success badges
  static const Color successLight = Color(0xFFDCFCE7);

  /// Muted amber for pending sync and in-review leave requests
  static const Color pending = Color(0xFFD97706);

  /// Soft background tint for pending badges
  static const Color pendingLight = Color(0xFFFEF3C7);

  /// Muted red for rejected attendance, sync errors, and failed validation
  static const Color error = Color(0xFFDC2626);

  /// Soft background tint for error badges
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Purple accent for leave management and categorical highlights
  static const Color purpleAccent = Color(0xFF7C3AED);

  /// Purple soft tint background
  static const Color purpleAccentLight = Color(0xFFF5F3FF);

  /// Teal accent for check-in and location telemetry
  static const Color tealAccent = Color(0xFF0D9488);

  /// Teal soft tint background
  static const Color tealAccentLight = Color(0xFFF0FDFA);

  /// Subtle divider color matching the border specification
  static const Color divider = Color(0xFFE2E8F0);

  /// Shimmer base color for loading skeleton states
  static const Color shimmerBase = Color(0xFFE2E8F0);

  /// Shimmer highlight color for loading skeleton states
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
