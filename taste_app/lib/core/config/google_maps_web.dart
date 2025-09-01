// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Verifica se o Google Maps está disponível
bool isGoogleMapsAvailable() {
  try {
    // Verifica se o objeto google existe no contexto global
    final google = js.context['google'];
    if (google == null) return false;
    
    // Verifica se google.maps existe
    final maps = js.context['google']['maps'];
    if (maps == null) return false;
    
    // Verifica se google.maps.Map existe (classe principal)
    final mapClass = js.context['google']['maps']['Map'];
    return mapClass != null;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('! Erro durante verificação: $e');
    }
    return false;
  }
}

/// Web implementation for Google Maps
Future<void> initializeGoogleMaps(String apiKey) async {
  // Verifica se o Google Maps já está carregado
  if (isGoogleMapsAvailable()) {
    if (kDebugMode) {
      debugPrint('✅ Google Maps API já está disponível');
    }
    return;
  }
  
  if (kDebugMode) {
    debugPrint('📍 Carregando Google Maps API com chave do ambiente...');
  }
  
  try {
    // Usa a função JavaScript definida no index.html para carregar o Google Maps
    final loadGoogleMapsAPI = js.context['loadGoogleMapsAPI'];
    if (loadGoogleMapsAPI != null) {
      // Chama a função JavaScript que retorna uma Promise
      final promise = js.context.callMethod('loadGoogleMapsAPI', [apiKey]);
      
      // Aguarda a Promise usando completer
      final completer = Completer<void>();
      
      // Converte a Promise JavaScript para Future Dart
      final promiseObject = promise as js.JsObject;
      promiseObject.callMethod('then', [
        js.allowInterop((result) {
          if (kDebugMode) {
            debugPrint('✅ Google Maps API carregada via JavaScript');
          }
          completer.complete();
        })
      ]);
      
      promiseObject.callMethod('catch', [
        js.allowInterop((error) {
          if (kDebugMode) {
            debugPrint('❌ Erro na Promise do Google Maps: $error');
          }
          completer.completeError(Exception('Erro ao carregar Google Maps: $error'));
        })
      ]);
      
      await completer.future;
    } else {
      // Fallback: carrega diretamente se a função não existir
      if (kDebugMode) {
        debugPrint('⚠️ Função loadGoogleMapsAPI não encontrada, usando fallback');
      }
      await _loadGoogleMapsDirect(apiKey);
    }
    
    // Verifica se foi carregado com sucesso
    if (!isGoogleMapsAvailable()) {
      throw Exception('Google Maps API não está disponível após carregamento');
    }
    
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Erro ao inicializar Google Maps: $e');
    }
    rethrow;
  }
}

/// Carregamento direto como fallback
Future<void> _loadGoogleMapsDirect(String apiKey) async {
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places'
    ..async = true
    ..defer = true;

  html.document.head?.append(script);
  
  // Aguarda até que esteja disponível
  await _waitForGoogleMapsLoad();
}

/// Verifica conectividade com a internet
Future<bool> _checkConnectivity() async {
  try {
    // Usa apenas navigator.onLine para verificar conectividade sem causar CORS
    final isOnline = html.window.navigator.onLine ?? true; // Assume online por padrão
    
    if (kDebugMode) {
      debugPrint('🌐 Status de conectividade (navigator.onLine): $isOnline');
    }
    
    return isOnline;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('🌐 Erro ao verificar conectividade: $e');
    }
    // Em caso de erro, assume que há conectividade
    return true;
  }
}


/// Aguarda o carregamento da API do Google Maps
Future<void> _waitForGoogleMapsLoad() async {
  int attempts = 0;
  const maxAttempts = 200; // ~20 segundos máximo
  
  while (attempts < maxAttempts) {
    try {
      // Verifica se o Google Maps está disponível usando js.context
      final google = js.context['google'];
      if (google != null) {
        final maps = js.context['google']['maps'];
        if (maps != null) {
          final mapClass = js.context['google']['maps']['Map'];
          if (mapClass != null) {
            if (kDebugMode) {
              debugPrint('✅ Google Maps API carregada com sucesso');
            }
            return;
          }
        }
      }
      
      // Verifica erros específicos da API key
      await _checkForApiKeyErrors();
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erro durante verificação: $e');
      }
      // Se for erro de API key, não vale a pena continuar tentando
      if (e.toString().contains('API key') || e.toString().contains('InvalidKeyMapError')) {
        throw Exception('Erro de API key: $e');
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    attempts++;

    if (kDebugMode && attempts % 20 == 0) {
      // Log a cada ~2s para depuração sem poluir demais o console
      debugPrint('⏳ Aguardando Google Maps API... (${attempts ~/ 10}s)');
    }
  }
  
  // Diagnóstico detalhado em caso de timeout
  await _performDetailedDiagnosis();
  throw Exception('Timeout: Google Maps API não foi carregada após 20 segundos');
}

/// Verifica erros específicos da API key
Future<void> _checkForApiKeyErrors() async {
  try {
    // Verifica se há erros no console relacionados à API key
    // Nota: Não é possível acessar diretamente os logs do console via Dart
    // mas podemos verificar o estado do objeto google
    
    final google = js.context['google'];
    if (google != null) {
      final maps = js.context['google']['maps'];
      if (maps == null) {
        // Google object existe mas maps não - possível erro de API key
        if (kDebugMode) {
          debugPrint('🔍 Google object existe mas maps é null - possível erro de API key');
        }
      }
    }
  } catch (e) {
    // Ignora erros nesta verificação
  }
}

/// Realiza diagnóstico detalhado em caso de falha
Future<void> _performDetailedDiagnosis() async {
  if (!kDebugMode) return;
  
  debugPrint('🔍 === DIAGNÓSTICO DETALHADO ===');
  
  // Verifica conectividade
  final hasConnectivity = await _checkConnectivity();
  debugPrint('🌐 Conectividade: ${hasConnectivity ? "OK" : "FALHA"}');
  
  // Verifica se o script foi carregado
  final scripts = html.document.querySelectorAll('script[src*="maps.googleapis.com"]');
  debugPrint('📜 Scripts do Google Maps encontrados: ${scripts.length}');
  
  for (final script in scripts) {
    debugPrint('   - ${script.getAttribute("src")}');
  }
  
  // Verifica o estado do objeto google
  try {
    final google = js.context['google'];
    debugPrint('🗺️ Objeto google: ${google != null ? "existe" : "null"}');
    if (google != null) {
      final maps = js.context['google']['maps'];
      debugPrint('   - google.maps: ${maps != null ? "existe" : "null"}');
      if (maps != null) {
        final mapClass = js.context['google']['maps']['Map'];
        debugPrint('   - google.maps.Map: ${mapClass != null ? "existe" : "null"}');
      }
    }
  } catch (e) {
    debugPrint('❌ Erro ao verificar objeto google: $e');
  }
  
  // Verifica erros de rede
  debugPrint('🔗 Verifique o console do navegador para erros de rede ou API key');
  debugPrint('💡 Possíveis causas:');
  debugPrint('   - API key inválida ou expirada');
  debugPrint('   - Restrições de domínio na API key');
  debugPrint('   - Serviços não habilitados (Maps JavaScript API, Places API)');
  debugPrint('   - Cota da API excedida');
  debugPrint('   - Problemas de conectividade');
  debugPrint('🔍 === FIM DO DIAGNÓSTICO ===');
}