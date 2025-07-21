import 'package:flutter/material.dart';

/// 🎨 Tema Simplificado do Gastro App
/// 
/// Versão mínima e funcional baseada em Material 3
class AppTheme {
  // 🎨 CORES PRINCIPAIS
  static const Color primary = Color(0xFF2c3985);     // Azul profundo
  static const Color secondary = Color(0xFFee9d21);   // Amarelo mostarda  
  static const Color danger = Color(0xFFd9502b);      // Vermelho telha
  static const Color background = Color(0xFFfbe9d2);  // Areia clara
  static const Color surface = Colors.white;
  
  // 🔧 MEDIDAS BÁSICAS
  static const double radiusPequeno = 8.0;
  static const double radiusMedio = 12.0;
  static const double radiusGrande = 16.0;
  static const double radiusExtraGrande = 24.0;
  
  static const double espacoPequeno = 8.0;
  static const double espacoMedio = 16.0;
  static const double espacoGrande = 24.0;
  static const double espacoExtraGrande = 32.0;
  
  // 🎨 CORES AUXILIARES SIMPLIFICADAS
  static const Color cinzaClaro = Color(0xFFF5F5F5);
  static const Color cinzaMedio = Color(0xFF757575);
  static const Color cinzaEscuro = Color(0xFF424242);
  
  static const Color mostarda = secondary;
  static const Color mostardaClara = Color(0xFFF2B347);
  static const Color mostardaEscura = Color(0xFFCC7A0A);
  
  static const Color bordoSuave = Color(0xFFE0E0E0);
  static const Color brancoQuente = Color(0xFFFAFAFA);
  static const Color terracota = danger;
  static const Color areiaClara = background;

  // 📦 SOMBRAS SIMPLES
  static const List<BoxShadow> sombraCard = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> sombraElevada = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // 🌈 GRADIENTES BÁSICOS
  static const LinearGradient gradientPrimario = LinearGradient(
    colors: [primary, Color(0xFF4A5BA6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientSuave = LinearGradient(
    colors: [surface, cinzaClaro],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 🎨 CORES CUSTOMIZADAS (Para compatibilidade)
  static const Map<String, Color> customColors = {
    'success': Color(0xFF4CAF50),
    'warning': Color(0xFFFF9800),
    'info': Color(0xFF2196F3),
  };

  // 🎨 CORES AUXILIARES (Para compatibilidade com código existente)
  static const Map<String, Color> cores = {
    'primary': primary,
    'secondary': secondary,
    'danger': danger,
    'white': surface,
    'cinzaClaro': cinzaClaro,
    'cinzaMedio': cinzaMedio,
    'cinzaEscuro': cinzaEscuro,
  };

  // 📏 PROPRIEDADES AUXILIARES (Para compatibilidade)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = espacoMedio;
  static const double spacingL = espacoGrande;
  static const double spacingXL = espacoExtraGrande;
  
  static const double radiusS = radiusPequeno;
  static const double radiusM = radiusMedio;
  static const double radiusL = radiusGrande;
  static const double radiusXL = radiusExtraGrande;
  
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  
  // 📦 SOMBRAS AUXILIARES (Para compatibilidade)
  static const List<BoxShadow> shadowLight = sombraCard;
  static const List<BoxShadow> shadowMedium = sombraElevada;

  // 🎨 TEMA PRINCIPAL SIMPLIFICADO
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      error: danger,
      surface: surface,
      background: background,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedio),
        ),
      ),
      
      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedio),
          ),
        ),
      ),
      
      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
} 