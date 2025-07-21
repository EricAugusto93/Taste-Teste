import 'package:flutter/material.dart';

/// Cores Simplificadas do Gastro App
/// 
/// Versão mínima com todas as cores necessárias
class AppColors {
  // ===== CORES PRINCIPAIS =====
  static const Color primary = Color(0xFF2c3985);       // Azul profundo
  static const Color secondary = Color(0xFFee9d21);     // Amarelo mostarda
  static const Color danger = Color(0xFFd9502b);        // Vermelho telha
  static const Color background = Color(0xFFfbe9d2);    // Areia clara
  static const Color surface = Colors.white;
  
  // ===== CORES BÁSICAS =====
  static const Color white = Colors.white;
  static const Color branco = Colors.white;
  
  // ===== VARIAÇÕES DE AZUL =====
  static const Color azulProfundo = primary;
  static const Color azulProfundoClaro = Color(0xFF4A5BA6);
  static const Color azulProfundoMuitoClaro = Color(0xFFE3E7F1);
  
  // ===== VARIAÇÕES DE AMARELO =====
  static const Color amareloMostarda = secondary;
  static const Color mostarda = secondary;
  static const Color mostardaClara = Color(0xFFF2B347);
  static const Color mostardaEscura = Color(0xFFCC7A0A);
  static const Color amareloMostardaClaro = mostardaClara;
  static const Color amareloMostardaEscuro = mostardaEscura;
  
  // ===== VARIAÇÕES DE VERMELHO =====
  static const Color vermelhoTelha = danger;
  static const Color terracota = danger;
  static const Color vermelhoTelhaClaro = Color(0xFFE67A5A);
  static const Color vermelhoTelhaEscuro = Color(0xFFB83E1F);
  static const Color vermelhoTelhaMuitoClaro = Color(0xFFF2E1DD);
  
  // ===== VARIAÇÕES DE FUNDO =====
  static const Color areiaClara = background;
  static const Color areiaMedia = Color(0xFFF0DCC4);
  static const Color areiaMedio = areiaMedia;
  static const Color brancoQuente = Color(0xFFFAFAFA);
  
  // ===== CORES DE CINZA =====
  static const Color cinzaClaro = Color(0xFFF5F5F5);
  static const Color cinzaMedio = Color(0xFF757575);
  static const Color cinzaEscuro = Color(0xFF424242);
  
  // ===== CORES DE TEXTO =====
  static const Color textPrimary = cinzaEscuro;
  static const Color textSecondary = cinzaMedio;
  static const Color textTertiary = Color(0xFF9E9E9E);
  
  // ===== CORES DE BORDA =====
  static const Color border = Color(0xFFE0E0E0);
  static const Color bordoSuave = border;
  
  // ===== CORES DE SISTEMA =====
  static const Color sucesso = Color(0xFF4CAF50);
  static const Color sucessoClaro = Color(0xFFE8F5E8);
  static const Color sucessoEscuro = Color(0xFF2E7D32);
  
  static const Color aviso = Color(0xFFFF9800);
  static const Color avisoClaro = Color(0xFFFFF3E0);
  static const Color avisoEscuro = Color(0xFFE65100);
  
  static const Color favorito = Color(0xFFE91E63);
  
  // ===== CORES TEMÁTICAS =====
  static const Color primaryLight = azulProfundoClaro;
  static const Color primarySubtle = azulProfundoMuitoClaro;
  static const Color secondaryLight = mostardaClara;
  static const Color secondarySubtle = Color(0xFFFDF8E1);
  static const Color secondarySoft = Color(0xFFFFF9E6);
  
  // ===== CORES ESPECIAIS =====
  static const Color tertiary = Color(0xFF9C27B0);
  
  // ===== GRADIENTES =====
  static const LinearGradient gradientePrimario = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradienteSecundario = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ===== MÉTODOS UTILITÁRIOS =====
  
  /// Verifica se duas cores têm contraste adequado
  static bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    final ratio = (luminance1 + 0.05) / (luminance2 + 0.05);
    return ratio >= 4.5; // WCAG AA standard
  }
  
  /// Retorna cor de texto apropriada para um fundo
  static Color getTextColorForBackground(Color background) {
    return background.computeLuminance() > 0.5 ? textPrimary : white;
  }
} 