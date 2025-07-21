import 'package:flutter/material.dart';

/// 🎨 Tema Clean e Sofisticado do Gastro App
/// 
/// Design minimalista com cores suaves e elementos arredondados
class AppTheme {
  // 🎨 CORES PRINCIPAIS
  static const Color primary = Color(0xFF2c3985);     // Azul profundo
  static const Color secondary = Color(0xFFee9d21);   // Amarelo mostarda  
  static const Color danger = Color(0xFFd9502b);      // Vermelho telha
  static const Color background = Color(0xFFfbe9d2);  // Areia clara
  static const Color surface = Colors.white;
  
  // 🔧 MEDIDAS CLEAN (Bordas mais arredondadas)
  static const double radiusPequeno = 12.0;
  static const double radiusMedio = 16.0;
  static const double radiusGrande = 20.0;
  static const double radiusExtraGrande = 28.0;
  
  static const double espacoPequeno = 12.0;
  static const double espacoMedio = 20.0;
  static const double espacoGrande = 28.0;
  static const double espacoExtraGrande = 36.0;
  
  // 🎨 CORES AUXILIARES SOFISTICADAS
  static const Color cinzaClaro = Color(0xFFF8F9FA);
  static const Color cinzaMedio = Color(0xFF6C757D);
  static const Color cinzaEscuro = Color(0xFF495057);
  
  static const Color mostarda = secondary;
  static const Color mostardaClara = Color(0xFFF5C547);
  static const Color mostardaEscura = Color(0xFFB8730A);
  
  static const Color bordoSuave = Color(0xFFE9ECEF);
  static const Color brancoQuente = Color(0xFFFFFFFE);
  static const Color terracota = danger;
  static const Color areiaClara = background;
  
  // Cores suaves para elementos
  static const Color azulSuave = Color(0xFFF8F9FF);
  static const Color mostardaSuave = Color(0xFFFFF8E1);
  static const Color vermelhSuave = Color(0xFFFFF5F5);

  // 📦 SOMBRAS SUAVES E ELEGANTES
  static const List<BoxShadow> sombraCard = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> sombraElevada = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> sombraIntensa = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // 🌈 GRADIENTES SOFISTICADOS
  static const LinearGradient gradientPrimario = LinearGradient(
    colors: [primary, Color(0xFF3d4a9a)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientSecundario = LinearGradient(
    colors: [secondary, Color(0xFFf5b041)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientSuave = LinearGradient(
    colors: [brancoQuente, Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient gradientFundo = LinearGradient(
    colors: [background, Color(0xFFF5E6C8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 🎨 CORES CUSTOMIZADAS (Para componentes específicos)
  static const Map<String, Color> customColors = {
    'success': Color(0xFF28A745),
    'warning': Color(0xFFFFC107),
    'info': Color(0xFF17A2B8),
    'light': Color(0xFFF8F9FA),
    'dark': Color(0xFF343A40),
  };

  // 🎨 CORES AUXILIARES (Para compatibilidade com código existente)
  static const Map<String, Color> cores = {
    'primary': primary,
    'secondary': secondary,
    'danger': danger,
    'white': surface,
    'background': background,
    'cinzaClaro': cinzaClaro,
    'cinzaMedio': cinzaMedio,
    'cinzaEscuro': cinzaEscuro,
    'azulMarinho': primary,
    'amareloMostarda': secondary,
    'vermelhoTelha': danger,
  };

  // 📏 PROPRIEDADES AUXILIARES (Para compatibilidade)
  static const double spacingXS = 6.0;
  static const double spacingS = espacoPequeno;
  static const double spacingM = espacoMedio;
  static const double spacingL = espacoGrande;
  static const double spacingXL = espacoExtraGrande;
  
  static const double radiusS = radiusPequeno;
  static const double radiusM = radiusMedio;
  static const double radiusL = radiusGrande;
  static const double radiusXL = radiusExtraGrande;
  
  static const double elevationS = 2.0;
  static const double elevationM = 6.0;
  static const double elevationL = 12.0;
  
  // 📦 SOMBRAS AUXILIARES (Para compatibilidade)
  static const List<BoxShadow> shadowLight = sombraCard;
  static const List<BoxShadow> shadowMedium = sombraElevada;
  static const List<BoxShadow> shadowHeavy = sombraIntensa;

  // 🎨 TEMA PRINCIPAL CLEAN E SOFISTICADO
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      error: danger,
      surface: surface,
      background: background,
      surfaceVariant: cinzaClaro,
      outline: bordoSuave,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      
      // AppBar Clean
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      
      // Cards Elegantes
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedio),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Botões Sofisticados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedio),
          ),
        ),
      ),
      
      // Botões de Texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPequeno),
          ),
        ),
      ),
      
      // Campos de Texto Clean
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedio),
          borderSide: BorderSide(color: bordoSuave, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedio),
          borderSide: BorderSide(color: bordoSuave, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedio),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      
      // FAB Elegante
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedio),
        ),
      ),
      
      // BottomNavigationBar Clean
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: cinzaMedio,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
} 