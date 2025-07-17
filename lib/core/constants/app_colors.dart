import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Modern blue theme
  static const Color primary = Color(0xFF3B82F6); // Modern blue
  static const Color primaryLight = Color(0xFF60A5FA); // Light blue
  static const Color primaryDark = Color(0xFF1D4ED8); // Deep blue

  // Secondary colors - Complementary tones
  static const Color secondary = Color(0xFF06B6D4); // Cyan blue
  static const Color secondaryLight = Color(0xFF22D3EE); // Light cyan
  static const Color accent =
      Color(0xFFF59E0B); // Golden accent for premium feel

  // Fashion-specific colors
  static const Color donation = Color(0xFF10B981); // Green for donation actions
  static const Color rental = Color(0xFF3B82F6); // Blue for rental actions
  static const Color premium =
      Color(0xFFEF4444); // Red for premium/featured items

  // Background and surface colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Status colors
  static const Color success = Color(0xFF059669); // Success green
  static const Color warning = Color(0xFFD97706); // Warning orange
  static const Color error = Color(0xFFDC2626); // Error red
  static const Color info = Color(0xFF0EA5E9); // Info blue

  // Text colors
  static const Color textPrimary = Color(0xFF111827); // Dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textHint = Color(0xFF9CA3AF); // Light gray
  static const Color textLight = Colors.white;

  // Fashion category colors
  static const Color casual = Color(0xFF84CC16); // Lime green
  static const Color formal = Color(0xFF1E40AF); // Deep blue
  static const Color luxury = Color(0xFFDC2626); // Luxury red
  static const Color vintage = Color(0xFF92400E); // Brown
  static const Color trendy = Color(0xFF3B82F6); // Blue trendy

  // Gradient colors for modern UI
  static const Color gradient1 = Color(0xFF3B82F6); // Blue
  static const Color gradient2 = Color(0xFF06B6D4); // Cyan
  static const Color gradient3 = Color(0xFFF59E0B); // Gold

  // Additional UI colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color disabled = Color(0xFF9CA3AF);
  static const Color shadow = Color(0x1A000000);

  // Card colors for different item conditions
  static const Color newItem = Color(0xFFECFDF5); // Light green background
  static const Color goodCondition = Color(0xFFEFF6FF); // Light blue background
  static const Color fairCondition =
      Color(0xFFFEF3C7); // Light yellow background

  // Rating and review colors
  static const Color star = Color(0xFFFBBF24); // Gold star
  static const Color starEmpty = Color(0xFFE5E7EB); // Gray star
}
