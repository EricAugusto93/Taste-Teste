import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color primaryDark = Color(0xFFE64A19);

  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textDark = Color(0xFF424242);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0xFF000000);
  static const Color overlay = Color(0x80000000);

  // Rating Colors
  static const Color ratingGold = Color(0xFFFFD700);
  static const Color ratingEmpty = Color(0xFFE0E0E0);

  // Delivery Status Colors
  static const Color deliveryPending = Color(0xFFFFC107);
  static const Color deliveryInProgress = Color(0xFF2196F3);
  static const Color deliveryCompleted = Color(0xFF4CAF50);
  static const Color deliveryCancelled = Color(0xFFF44336);

  // Food Category Colors
  static const Color categoryFast = Color(0xFFFF5722);
  static const Color categoryHealthy = Color(0xFF4CAF50);
  static const Color categoryDessert = Color(0xFFE91E63);
  static const Color categoryDrinks = Color(0xFF2196F3);
  static const Color categoryPizza = Color(0xFFFF9800);
  static const Color categoryAsian = Color(0xFF9C27B0);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Map Colors
  static const Color mapMarker = primary;
  static const Color mapCluster = primaryDark;
  static const Color mapRoute = Color(0xFF2196F3);

  // Chart Colors
  static const List<Color> chartColors = [
    primary,
    secondary,
    warning,
    info,
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
    Color(0xFF795548),
    Color(0xFF009688),
  ];
}