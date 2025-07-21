import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Widget do logotipo Taste Test reutilizável
class TasteTestLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double? fontSize;
  final bool showSubtitle;
  final String? subtitle;
  final Color? primaryColor;
  final Color? secondaryColor;
  final MainAxisAlignment alignment;

  const TasteTestLogo({
    super.key,
    this.width,
    this.height,
    this.fontSize,
    this.showSubtitle = true,
    this.subtitle,
    this.primaryColor,
    this.secondaryColor,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    // Adaptação responsiva do tamanho da fonte
    final baseFontSize = fontSize ?? 32.0;
    final responsiveFontSize = screenWidth < 360 
        ? baseFontSize * 0.8  // Telas muito pequenas
        : screenWidth < 400 
            ? baseFontSize * 0.9  // Telas pequenas
            : baseFontSize;  // Telas normais e grandes
    
    final effectivePrimaryColor = primaryColor ?? AppColors.amareloMostarda;
    final effectiveSecondaryColor = secondaryColor ?? AppColors.vermelhoTelha;
    final effectiveFontSize = responsiveFontSize;
    final effectiveSubtitle = subtitle ?? 'GASTRO EXPERIENCE';

    return Semantics(
      label: showSubtitle 
          ? 'Taste Test $effectiveSubtitle'
          : 'Taste Test',
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo principal com gradiente
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [effectivePrimaryColor, effectiveSecondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                'Taste Test',
                style: TextStyle(
                  fontSize: effectiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            // Subtítulo (opcional)
            if (showSubtitle) ...[
              const SizedBox(height: 4),
              Text(
                effectiveSubtitle,
                style: TextStyle(
                  fontSize: effectiveFontSize * 0.3,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cinzaMedio,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Factory para logo grande (tela de login)
  factory TasteTestLogo.large({
    String? subtitle,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return TasteTestLogo(
      width: 200,
      fontSize: 36,
      subtitle: subtitle,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  /// Factory para logo médio (AppBar)
  factory TasteTestLogo.medium({
    bool showSubtitle = false,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return TasteTestLogo(
      width: 160,
      fontSize: 24,
      showSubtitle: showSubtitle,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  /// Factory para logo pequeno (ícone)
  factory TasteTestLogo.small({
    bool showSubtitle = false,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return TasteTestLogo(
      width: 120,
      fontSize: 18,
      showSubtitle: showSubtitle,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  /// Factory para logo AppBar (altura específica)
  factory TasteTestLogo.appBar({
    double height = 40,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return TasteTestLogo(
      height: height,
      fontSize: height * 0.6,
      showSubtitle: false,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }
} 