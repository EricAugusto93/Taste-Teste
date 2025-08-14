import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto do aplicativo Taste usando a fonte Poppins
class AppTextStyles {
  // Família de fonte base usando Google Fonts
  static TextStyle get _baseTextStyle => GoogleFonts.poppins();
  
  // Tamanhos de fonte
  static const double _h1Size = 28.0;
  static const double _h2Size = 24.0;
  static const double _h3Size = 18.0;
  static const double _bodyLargeSize = 16.0;
  static const double _bodyMediumSize = 14.0;
  static const double _bodySmallSize = 12.0;
  static const double _buttonSize = 16.0;
  static const double _inputSize = 16.0;
  static const double _captionSize = 12.0;
  
  // Títulos
  static TextStyle get h1 => _baseTextStyle.copyWith(
    fontSize: _h1Size,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.2,
  );
  
  static TextStyle get h2 => _baseTextStyle.copyWith(
    fontSize: _h2Size,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.3,
  );
  
  static TextStyle get h3 => _baseTextStyle.copyWith(
    fontSize: _h3Size,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.3,
  );
  
  // Alias para compatibilidade
  static TextStyle get headingMedium => h2;
  static TextStyle get headingSmall => h3;
  
  // Corpo de texto
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: _bodyLargeSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: _bodyMediumSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: _bodySmallSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.4,
  );
  
  // Botões
  static TextStyle get buttonText => _baseTextStyle.copyWith(
    fontSize: _buttonSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get buttonTextSecondary => _baseTextStyle.copyWith(
    fontSize: _buttonSize,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  
  // Campos de entrada
  static TextStyle get inputText => _baseTextStyle.copyWith(
    fontSize: _inputSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );
  
  static TextStyle get inputHint => _baseTextStyle.copyWith(
    fontSize: _inputSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
  
  // Legendas e textos pequenos
  static TextStyle get caption => _baseTextStyle.copyWith(
    fontSize: _captionSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
  
  // Estilos para estados especiais
  static TextStyle get emptyStateTitle => h2.copyWith(
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get emptyStateSubtitle => bodyLarge.copyWith(
    color: AppColors.textLight,
    height: 1.5,
  );
  
  // Textos específicos do app
  static TextStyle get greeting => _baseTextStyle.copyWith(
    fontSize: _h1Size,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static TextStyle get searchPlaceholder => _baseTextStyle.copyWith(
    fontSize: _bodyLargeSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
  
  static TextStyle get categoryTitle => _baseTextStyle.copyWith(
    fontSize: _bodyMediumSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static TextStyle get restaurantName => _baseTextStyle.copyWith(
    fontSize: _bodyLargeSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static TextStyle get restaurantDescription => _baseTextStyle.copyWith(
    fontSize: _bodyMediumSize,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
  
  static TextStyle get listTitle => _baseTextStyle.copyWith(
    fontSize: _bodyLargeSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}