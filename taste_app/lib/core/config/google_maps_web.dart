import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web implementation for Google Maps
Future<void> initializeGoogleMaps(String apiKey) async {
  // Verifica se o Google Maps já está carregado
  if (isGoogleMapsAvailable()) {
    if (kDebugMode) {
      print('✅ Google Maps API já está disponível');
    }
    return;
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
  
  // Cria novo script com a API key correta
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places'
    ..async = true
    ..defer = true;
  
  if (kDebugMode) {
    print('📍 Carregando Google Maps API: ${script.src}');
  }
  
  html.document.head?.append(script);
  
  // Aguarda o carregamento do script
  await _waitForGoogleMapsLoad();
}

bool isGoogleMapsAvailable() {
  try {
    final google = (html.window as dynamic).google;
    return google != null && google.maps != null;
  } catch (e) {
    return false;
  }
}

/// Aguarda o carregamento da API do Google Maps
Future<void> _waitForGoogleMapsLoad() async {
  int attempts = 0;
  const maxAttempts = 50; // 5 segundos máximo
  
  while (attempts < maxAttempts) {
    try {
      // Verifica se o Google Maps está disponível
      final google = (html.window as dynamic).google;
      if (google != null && google.maps != null) {
        if (kDebugMode) {
          print('✅ Google Maps API carregada com sucesso');
        }
        return;
      }
    } catch (e) {
      // Continua tentando
    }
    
      await Future.delayed(const Duration(milliseconds: 100));
    attempts++;
  }
  
  if (kDebugMode) {
    print('⚠️ Timeout: Google Maps API não foi carregada');
  }
}