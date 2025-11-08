import 'package:flutter/material.dart';

/// App-wide color constants matching the UI design
class AppColors {
  // Primary Colors
  static const Color primaryNavy = Color(0xFF1E2541);
  static const Color accentYellow = Color(0xFFF6C744);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E2541);
  static const Color textSecondary = Color(0xFF000000); // Changed to pure black for better visibility
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Condition Badge Colors
  static const Color conditionNew = Color(0xFF4CAF50);
  static const Color conditionLikeNew = Color(0xFF8BC34A);
  static const Color conditionGood = Color(0xFFFF9800);
  static const Color conditionUsed = Color(0xFFE57373);
  
  // Swap Status Colors
  static const Color swapPending = Color(0xFFFF9800);
  static const Color swapAccepted = Color(0xFF4CAF50);
  static const Color swapRejected = Color(0xFFE53935);
  
  // UI Elements
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNavy, Color(0xFF2A3458)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
