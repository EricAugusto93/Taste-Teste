import 'package:flutter/foundation.dart';
import 'environment_config.dart';

// Conditional imports
import 'google_maps_web_stub.dart'
    if (dart.library.html) 'google_maps_web.dart' as web_impl;

/// Configuração do Google Maps para diferentes plataformas
class GoogleMapsConfig {
  static bool _isInitialized = false;
  
  /// Inicializa a configuração do Google Maps
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    final apiKey = EnvironmentConfig.googleMapsApiKey;
    
    if (apiKey.isEmpty || apiKey == 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
      if (kDebugMode) {
        print('⚠️ Google Maps API Key não configurada. Usando fallback.');
      }
      return;
    }
    
    if (kIsWeb) {
      await _initializeWeb(apiKey);
    }
    
    _isInitialized = true;
  }
  
  /// Inicializa o Google Maps para web
  static Future<void> _initializeWeb(String apiKey) async {
    if (kIsWeb) {
      try {
        await web_impl.initializeGoogleMaps(apiKey);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Erro ao inicializar Google Maps: $e');
        }
      }
    }
  }
  

  
  /// Verifica se o Google Maps está disponível
  static bool get isAvailable {
    if (!kIsWeb) return true; // Para mobile, assumimos que está configurado
    
    try {
      return web_impl.isGoogleMapsAvailable();
    } catch (e) {
      return false;
    }
  }
  
  /// Verifica se a API key está configurada
  static bool get hasValidApiKey {
    final apiKey = EnvironmentConfig.googleMapsApiKey;
    return apiKey.isNotEmpty && apiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  }
  
  /// Obtém a API key configurada
  static String get apiKey => EnvironmentConfig.googleMapsApiKey;
  
  /// Status da configuração para debug
  static Map<String, dynamic> get debugInfo {
    if (!kDebugMode) return {};
    
    return {
      'isInitialized': _isInitialized,
      'isAvailable': isAvailable,
      'hasValidApiKey': hasValidApiKey,
      'platform': kIsWeb ? 'web' : 'mobile',
      'apiKey': hasValidApiKey ? '${apiKey.substring(0, 8)}...' : 'not_configured',
    };
  }
}