import 'package:flutter/material.dart';

/// Paleta de cores do aplicativo Taste baseada nas referências visuais
class AppColors {
  // Cores Primárias
  static const Color primary = Color(0xFFFF6B47);     // Laranja vibrante
  static const Color primaryDark = Color(0xFFE55A2B);  // Laranja escuro
  static const Color secondary = Color(0xFF4A5FBF);    // Azul/Roxo
  static const Color secondaryLight = Color(0xFF6B73FF); // Azul claro
  
  // Cores de Fundo
  static const Color background = Color(0xFF2c3b83);   // Azul escuro personalizado
  static const Color backgroundLight = Color(0xFFFDFDFD);
  static const Color surface = Color(0xFFFFFFFF);      // Branco
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFAFAFA); // Cinza muito claro
  static const Color emptyStateBlue = Color(0xFF6BB6FF); // Azul estado vazio
  
  // Cores de Texto
  static const Color textPrimary = Color(0xFFFFFFFF);  // Branco
  static const Color textSecondary = Color(0xFFFFFFFF); // Branco
  static const Color textDark = Color(0xFF2C2C2C);     // Cinza escuro
  static const Color textLight = Color(0xFFB0B0B0);    // Cinza claro
  
  // Cores de divisores
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);    // Cinza claro para bordas
  
  // Cores de Categoria (Grid)
  static const Color categoryRed = Color(0xFFE74C3C);
  static const Color categoryBlue = Color(0xFF3498DB);
  static const Color categoryGreen = Color(0xFF2ECC71);
  static const Color categoryYellow = Color(0xFFF1C40F);
  static const Color categoryPurple = Color(0xFF9B59B6);
  static const Color categoryOrange = Color(0xFFE67E22);
  static const Color categoryGray = Color(0xFF95A5A6);
  static const Color categoryDarkOrange = Color(0xFFE67E22);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A5FBF), Color(0xFF6B73FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient profileWavesGradient = LinearGradient(
    colors: [Color(0xFF87CEEB), Color(0xFF4169E1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Estados
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  
  // Transparências
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFFE0E0E0);
  static const Color shadow = Color(0xFF000000);
}