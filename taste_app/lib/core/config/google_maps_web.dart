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
      print('! Erro durante verificação: $e');
    }
    return false;
  }
}

/// Web implementation for Google Maps
Future<void> initializeGoogleMaps(String apiKey) async {
  // Verifica se o Google Maps já está carregado
  if (isGoogleMapsAvailable()) {
    if (kDebugMode) {
      print('✅ Google Maps API já está disponível');
    }
    return;
  }
  
  // Verifica conectividade antes de tentar carregar
  if (!await _checkConnectivity()) {
    if (kDebugMode) {
      print('❌ Sem conectividade com a internet. Não é possível carregar Google Maps.');
    }
    throw Exception('Sem conectividade com a internet');
  }
  
  // Remove todos os scripts existentes do Google Maps para evitar conflitos
  final existingScripts = html.document.querySelectorAll('script[src*="maps.googleapis.com"]');
  for (final script in existingScripts) {
    script.remove();
    if (kDebugMode) {
      print('🗑️ Script do Google Maps removido: ${script.getAttribute('src')}');
    }
  }
  
  // Limpa qualquer referência global existente
  try {
    (html.window as dynamic).google = null;
  } catch (e) {
    // Ignora erros ao limpar
  }
  
  // Cria novo script sem callback - vamos usar polling para verificar quando carregou
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places'
    ..async = true
    ..defer = true;

  // Observa eventos de carregamento/erro do script para facilitar diagnóstico
  script.onLoad.listen((_) {
    if (kDebugMode) {
      print('⬇️ Script do Google Maps baixado (onLoad emitido)');
    }
  });
  script.onError.listen((event) {
    if (kDebugMode) {
      print('❌ Erro ao carregar script do Google Maps: $event');
    }
  });
  
  if (kDebugMode) {
    print('📍 Carregando Google Maps API: ${script.src}');
  }
  
  html.document.head?.append(script);
  
  // Aguarda o carregamento do script e disponibilidade da API com retry
  await _waitForGoogleMapsLoadWithRetry(apiKey);
}

/// Verifica conectividade com a internet
Future<bool> _checkConnectivity() async {
  try {
    // Usa apenas navigator.onLine para verificar conectividade sem causar CORS
    final isOnline = html.window.navigator.onLine ?? true; // Assume online por padrão
    
    if (kDebugMode) {
      print('🌐 Status de conectividade (navigator.onLine): $isOnline');
    }
    
    return isOnline;
  } catch (e) {
    if (kDebugMode) {
      print('🌐 Erro ao verificar conectividade: $e');
    }
    // Em caso de erro, assume que há conectividade
    return true;
  }
}

/// Aguarda o carregamento da API do Google Maps com retry e backoff
Future<void> _waitForGoogleMapsLoadWithRetry(String apiKey) async {
  const maxRetries = 3;
  
  for (int retry = 0; retry < maxRetries; retry++) {
    try {
      await _waitForGoogleMapsLoad();
      return; // Sucesso, sai da função
    } catch (e) {
      if (kDebugMode) {
        print('🔄 Tentativa ${retry + 1}/$maxRetries falhou: $e');
      }
      
      if (retry < maxRetries - 1) {
        // Backoff exponencial: 2s, 4s, 8s
        final delaySeconds = 2 << retry;
        if (kDebugMode) {
          print('⏳ Aguardando ${delaySeconds}s antes da próxima tentativa...');
        }
        await Future.delayed(Duration(seconds: delaySeconds));
        
        // Verifica se ainda há conectividade antes de tentar novamente
        if (!await _checkConnectivity()) {
          throw Exception('Conectividade perdida durante retry');
        }
      }
    }
  }
  
  // Se chegou aqui, todas as tentativas falharam
  throw Exception('Google Maps API falhou após $maxRetries tentativas');
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
              print('✅ Google Maps API carregada com sucesso');
            }
            return;
          }
        }
      }
      
      // Verifica erros específicos da API key
      await _checkForApiKeyErrors();
      
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro durante verificação: $e');
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
      print('⏳ Aguardando Google Maps API... (${attempts ~/ 10}s)');
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
    final errors = html.window.console;
    // Nota: Não é possível acessar diretamente os logs do console via Dart
    // mas podemos verificar o estado do objeto google
    
    final google = js.context['google'];
    if (google != null) {
      final maps = js.context['google']['maps'];
      if (maps == null) {
        // Google object existe mas maps não - possível erro de API key
        if (kDebugMode) {
          print('🔍 Google object existe mas maps é null - possível erro de API key');
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
  
  print('🔍 === DIAGNÓSTICO DETALHADO ===');
  
  // Verifica conectividade
  final hasConnectivity = await _checkConnectivity();
  print('🌐 Conectividade: ${hasConnectivity ? "OK" : "FALHA"}');
  
  // Verifica se o script foi carregado
  final scripts = html.document.querySelectorAll('script[src*="maps.googleapis.com"]');
  print('📜 Scripts do Google Maps encontrados: ${scripts.length}');
  
  for (final script in scripts) {
    print('   - ${script.getAttribute("src")}');
  }
  
  // Verifica o estado do objeto google
  try {
    final google = js.context['google'];
    print('🗺️ Objeto google: ${google != null ? "existe" : "null"}');
    if (google != null) {
      final maps = js.context['google']['maps'];
      print('   - google.maps: ${maps != null ? "existe" : "null"}');
      if (maps != null) {
        final mapClass = js.context['google']['maps']['Map'];
        print('   - google.maps.Map: ${mapClass != null ? "existe" : "null"}');
      }
    }
  } catch (e) {
    print('❌ Erro ao verificar objeto google: $e');
  }
  
  // Verifica erros de rede
  print('🔗 Verifique o console do navegador para erros de rede ou API key');
  print('💡 Possíveis causas:');
  print('   - API key inválida ou expirada');
  print('   - Restrições de domínio na API key');
  print('   - Serviços não habilitados (Maps JavaScript API, Places API)');
  print('   - Cota da API excedida');
  print('   - Problemas de conectividade');
  print('🔍 === FIM DO DIAGNÓSTICO ===');
}