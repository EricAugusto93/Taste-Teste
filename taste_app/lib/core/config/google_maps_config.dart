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
      await _initializeWeb(apiKey);
    }
    
    _isInitialized = true;
  }
  
  /// Inicializa o Google Maps para web
  static Future<void> _initializeWeb(String apiKey) async {
    if (kIsWeb) {
      try {
        if (kDebugMode) {
          debugPrint('🔄 Iniciando carregamento do Google Maps...');
          debugPrint('📍 API Key: ${apiKey.substring(0, 8)}...');
        }
        
        await web_impl.initializeGoogleMaps(apiKey);
        
        if (kDebugMode) {
          debugPrint('✅ Google Maps inicializado com sucesso');
          debugPrint('🌐 Status da API: ${isAvailable ? "Disponível" : "Indisponível"}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Erro ao inicializar Google Maps: $e');
          debugPrint('🔍 Tipo do erro: ${e.runtimeType}');
          
          // Diagnóstico adicional
          if (e.toString().contains('API key')) {
            debugPrint('🔑 Problema relacionado à API key detectado');
            debugPrint('💡 Verifique se a API key está correta e tem as permissões necessárias');
          } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
            debugPrint('🌐 Problema de conectividade detectado');
            debugPrint('💡 Verifique sua conexão com a internet');
          } else if (e.toString().contains('CORS') || e.toString().contains('blocked')) {
            debugPrint('🚫 Problema de CORS ou bloqueio detectado');
            debugPrint('💡 Verifique as configurações de CSP no index.html');
          }
          
          debugPrint('🔄 Aplicação continuará com fallback (mapa não disponível)');
        }
        // Não relança a exceção para permitir que a aplicação continue
        // com fallback quando o mapa não estiver disponível
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