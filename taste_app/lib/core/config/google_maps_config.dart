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
        debugPrint('⚠️ Google Maps API Key não configurada. Usando fallback.');
      }
      return;
    }
    
    if (kIsWeb) {
      try {
        // Carrega a API dinamicamente com a chave do ambiente
        await web_impl.initializeGoogleMaps(apiKey);
        if (kDebugMode) {
          debugPrint('✅ Google Maps inicializado com sucesso');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Erro ao inicializar Google Maps: $e');
        }
        // Não impede a continuação da aplicação se o Maps falhar
        return;
      }
    }
    
    _isInitialized = true;
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
  
  /// Força uma nova tentativa de inicialização
  static Future<void> retryInitialization() async {
    _isInitialized = false;
    await initialize();
  }
  
  /// Verifica se há problemas conhecidos com a configuração
  static List<String> get configurationIssues {
    final issues = <String>[];
    
    if (!hasValidApiKey) {
      issues.add('API key não configurada ou inválida');
    }
    
    if (kIsWeb && !isAvailable && hasValidApiKey) {
      issues.add('Google Maps API não está disponível (possível problema de rede ou restrições)');
    }
    
    return issues;
  }
  
  /// Status da configuração para debug
  static Map<String, dynamic> get debugInfo {
    if (!kDebugMode) return {};
    
    return {
      'isInitialized': _isInitialized,
      'isAvailable': isAvailable,
      'hasValidApiKey': hasValidApiKey,
      'platform': kIsWeb ? 'web' : 'mobile',
      'apiKey': hasValidApiKey ? '${apiKey.substring(0, 8)}...' : 'not_configured',
      'issues': configurationIssues,
      'timestamp': DateTime.now().toIso8601String(),
      'userAgent': kIsWeb ? 'web_browser' : 'mobile_app',
    };
  }
  
  /// Executa um diagnóstico completo da configuração
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final diagnostics = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'platform': kIsWeb ? 'web' : 'mobile',
    };
    
    // Teste da API key
    diagnostics['apiKey'] = {
      'configured': hasValidApiKey,
      'value': hasValidApiKey ? '${apiKey.substring(0, 8)}...' : 'not_configured',
    };
    
    // Teste de inicialização
    diagnostics['initialization'] = {
      'completed': _isInitialized,
      'available': isAvailable,
    };
    
    // Teste de conectividade (apenas web)
    if (kIsWeb && hasValidApiKey) {
      try {
        diagnostics['connectivity'] = await _testConnectivity();
      } catch (e) {
        diagnostics['connectivity'] = {
          'status': 'error',
          'error': e.toString(),
        };
      }
    }
    
    // Issues conhecidos
    diagnostics['issues'] = configurationIssues;
    
    if (kDebugMode) {
      debugPrint('🔍 Diagnóstico completo do Google Maps:');
      diagnostics.forEach((key, value) {
        debugPrint('  $key: $value');
      });
    }
    
    return diagnostics;
  }
  
  /// Testa a conectividade com a API do Google Maps
  static Future<Map<String, dynamic>> _testConnectivity() async {
    if (!kIsWeb) {
      return {'status': 'skipped', 'reason': 'not_web_platform'};
    }
    
    try {
      // Tenta verificar se a API está acessível
      final isAccessible = web_impl.isGoogleMapsAvailable();
      
      return {
        'status': isAccessible ? 'success' : 'failed',
        'accessible': isAccessible,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}