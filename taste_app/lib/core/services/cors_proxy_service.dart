import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Serviço para contornar CORS em desenvolvimento web
class CorsProxyService {
  static const String _proxyBaseUrl = 'http://localhost:3000/api/proxy/supabase';
  static const bool _useProxy = kIsWeb && kDebugMode;
  
  /// Faz uma requisição GET através do proxy se necessário
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    if (!_useProxy) {
      // Para mobile ou produção, usa diretamente
      throw UnsupportedError('Proxy apenas para web em desenvolvimento');
    }
    
    debugPrint('🔄 CorsProxy: Fazendo requisição GET para $endpoint');
    
    try {
      // Construir URL do proxy
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': endpoint,
          ...?queryParams,
        },
      );
      
      debugPrint('📡 CorsProxy: URL final: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );
      
      debugPrint('✅ CorsProxy: Resposta ${response.statusCode}: ${response.body.substring(0, 200)}...');
      
      return response;
    } catch (e) {
      debugPrint('❌ CorsProxy: Erro na requisição: $e');
      rethrow;
    }
  }
  
  /// Faz uma requisição POST através do proxy se necessário
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    if (!_useProxy) {
      throw UnsupportedError('Proxy apenas para web em desenvolvimento');
    }
    
    debugPrint('🔄 CorsProxy: Fazendo requisição POST para $endpoint');
    
    try {
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': endpoint,
          ...?queryParams,
        },
      );
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );
      
      debugPrint('✅ CorsProxy: Resposta POST ${response.statusCode}');
      
      return response;
    } catch (e) {
      debugPrint('❌ CorsProxy: Erro na requisição POST: $e');
      rethrow;
    }
  }
  
  /// Verifica se deve usar proxy
  static bool get shouldUseProxy => _useProxy;
}