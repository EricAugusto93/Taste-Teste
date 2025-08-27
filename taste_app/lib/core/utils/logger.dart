import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Classe utilitária para logging com diferentes níveis
class Logger {
  Logger._();

  /// Nível de log atual (pode ser configurado)
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Define o nível mínimo de log
  static void setLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// Log de debug (apenas em modo debug)
  static void debug(String message, [Map<String, dynamic>? data]) {
    if (_shouldLog(LogLevel.debug)) {
      _log('DEBUG', message, data);
    }
  }

  /// Log de informação
  static void info(String message, [Map<String, dynamic>? data]) {
    if (_shouldLog(LogLevel.info)) {
      _log('INFO', message, data);
    }
  }

  /// Log de warning
  static void warning(String message, [Map<String, dynamic>? data]) {
    if (_shouldLog(LogLevel.warning)) {
      _log('WARNING', message, data);
    }
  }

  /// Log de erro
  static void error(
    String message, 
    [Object? error, 
    StackTrace? stackTrace, 
    Map<String, dynamic>? data]
  ) {
    if (_shouldLog(LogLevel.error)) {
      _log('ERROR', message, data);
      if (error != null) {
        _log('ERROR', 'Exception: $error', null);
      }
      if (stackTrace != null) {
        _log('ERROR', 'StackTrace: $stackTrace', null);
      }
    }
  }

  /// Log crítico (sempre exibido)
  static void critical(
    String message, 
    [Object? error, 
    StackTrace? stackTrace, 
    Map<String, dynamic>? data]
  ) {
    _log('CRITICAL', message, data);
    if (error != null) {
      _log('CRITICAL', 'Exception: $error', null);
    }
    if (stackTrace != null) {
      _log('CRITICAL', 'StackTrace: $stackTrace', null);
    }
  }

  /// Verifica se deve fazer log baseado no nível
  static bool _shouldLog(LogLevel level) {
    return level.index >= _currentLevel.index;
  }

  /// Método interno para fazer o log
  static void _log(String level, String message, Map<String, dynamic>? data) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';
    
    if (kDebugMode) {
      // Em modo debug, usa developer.log para melhor integração com DevTools
      developer.log(
        message,
        time: DateTime.now(),
        level: _getLevelValue(level),
        name: 'TasteApp',
        error: data,
      );
    } else {
      // Em produção, usa print simples
      // ignore: avoid_print
      debugPrint(logMessage);
    }
    
    if (data != null && data.isNotEmpty) {
      if (kDebugMode) {
        developer.log(
          'Data: $data',
          time: DateTime.now(),
          name: 'TasteApp',
        );
      } else {
        // ignore: avoid_print
        debugPrint('Data: $data');
      }
    }
  }

  /// Converte string de nível para valor numérico
  static int _getLevelValue(String level) {
    switch (level) {
      case 'DEBUG':
        return 500;
      case 'INFO':
        return 800;
      case 'WARNING':
        return 900;
      case 'ERROR':
        return 1000;
      case 'CRITICAL':
        return 1200;
      default:
        return 800;
    }
  }

  /// Log de performance para medir tempo de execução
  static void performance(String operation, Duration duration, [Map<String, dynamic>? data]) {
    final perfData = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'duration_readable': '${duration.inMilliseconds}ms',
      ...?data,
    };
    info('Performance: $operation completed', perfData);
  }

  /// Wrapper para medir performance de uma função
  static Future<T> measurePerformance<T>(
    String operation,
    Future<T> Function() function, {
    Map<String, dynamic>? additionalData,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      performance(operation, stopwatch.elapsed, additionalData);
      return result;
    } catch (e) {
      stopwatch.stop();
      error('Performance: $operation failed after ${stopwatch.elapsed}', e, null, additionalData);
      rethrow;
    }
  }

  /// Log de evento de usuário
  static void userEvent(String event, [Map<String, dynamic>? data]) {
    info('User Event: $event', data);
  }

  /// Log de navegação
  static void navigation(String from, String to, [Map<String, dynamic>? data]) {
    info('Navigation: $from -> $to', data);
  }

  /// Log de API call
  static void apiCall(String method, String endpoint, [Map<String, dynamic>? data]) {
    info('API Call: $method $endpoint', data);
  }

  /// Log de resposta de API
  static void apiResponse(String endpoint, int statusCode, [Map<String, dynamic>? data]) {
    if (statusCode >= 200 && statusCode < 300) {
      info('API Response: $endpoint [$statusCode]', data);
    } else {
      warning('API Response: $endpoint [$statusCode]', data);
    }
  }

  /// Log de erro de API
  static void apiError(String endpoint, Object error, [StackTrace? stackTrace, Map<String, dynamic>? data]) {
    Logger.error('API Error: $endpoint', error, stackTrace, data);
  }
}

/// Níveis de log disponíveis
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Extensão para facilitar o uso do Logger
extension LoggerExtension on Object {
  /// Log de debug para qualquer objeto
  void logDebug(String message, [Map<String, dynamic>? data]) {
    Logger.debug('$runtimeType: $message', data);
  }

  /// Log de info para qualquer objeto
  void logInfo(String message, [Map<String, dynamic>? data]) {
    Logger.info('$runtimeType: $message', data);
  }

  /// Log de warning para qualquer objeto
  void logWarning(String message, [Map<String, dynamic>? data]) {
    Logger.warning('$runtimeType: $message', data);
  }

  /// Log de erro para qualquer objeto
  void logError(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? data]) {
    Logger.error('$runtimeType: $message', error, stackTrace, data);
  }
}