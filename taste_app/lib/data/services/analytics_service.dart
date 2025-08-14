import 'package:flutter/foundation.dart';
import '../../core/config/environment_config.dart';

/// Serviço de analytics para rastreamento de eventos
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();
  AnalyticsService._();

  bool _isInitialized = false;
  final List<Map<String, dynamic>> _eventQueue = [];

  /// Inicializa o serviço de analytics
  Future<void> initialize() async {
    if (!EnvironmentConfig.enableAnalytics) {
      debugPrint('📊 Analytics desabilitado');
      return;
    }

    try {
      // Aqui seria a inicialização de serviços como Firebase Analytics, Mixpanel, etc.
      _isInitialized = true;
      debugPrint('📊 Analytics inicializado');
      
      // Processa eventos em fila
      await _processQueuedEvents();
    } catch (e) {
      debugPrint('❌ Erro ao inicializar analytics: $e');
    }
  }

  /// Rastreia evento de navegação
  void trackNavigation({
    required String action,
    required String route,
    Map<String, dynamic>? metadata,
  }) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = {
      'event_type': 'navigation',
      'action': action,
      'route': route,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
      ...?metadata,
    };

    _trackEvent(event);
  }

  /// Rastreia evento de busca
  void trackSearch({
    required String query,
    int? resultsCount,
    String? category,
    Map<String, dynamic>? filters,
  }) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = {
      'event_type': 'search',
      'query': query,
      'results_count': resultsCount,
      'category': category,
      'filters': filters,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
    };

    _trackEvent(event);
  }

  /// Rastreia visualização de restaurante
  void trackRestaurantView({
    required String restaurantId,
    String? restaurantName,
    String? category,
    String? source, // 'search', 'home', 'map', etc.
  }) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = {
      'event_type': 'restaurant_view',
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'category': category,
      'source': source,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
    };

    _trackEvent(event);
  }

  /// Rastreia ação de favoritar
  void trackFavoriteAction({
    required String restaurantId,
    required bool isFavorited,
    String? source,
  }) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = {
      'event_type': 'favorite_action',
      'restaurant_id': restaurantId,
      'action': isFavorited ? 'add' : 'remove',
      'source': source,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
    };

    _trackEvent(event);
  }

  /// Rastreia compartilhamento
  void trackShare({
    required String contentType, // 'restaurant', 'search', etc.
    required String contentId,
    required String method, // 'link', 'social', etc.
  }) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = {
      'event_type': 'share',
      'content_type': contentType,
      'content_id': contentId,
      'method': method,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
    };

    _trackEvent(event);
  }

  /// Rastreia erro da aplicação
  void trackError({
    required String error,
    String? stackTrace,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    // Sempre rastreia erros, independente da configuração
    final event = {
      'event_type': 'error',
      'error': error,
      'stack_trace': stackTrace,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
      ...?metadata,
    };

    _trackEvent(event);
  }

  /// Rastreia evento personalizado
  void trackCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = {
      'event_type': 'custom',
      'event_name': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
      ...?parameters,
    };

    _trackEvent(event);
  }

  /// Rastreia evento genérico
  void trackEvent(String eventName, Map<String, dynamic>? parameters) {
    trackCustomEvent(eventName: eventName, parameters: parameters);
  }

  /// Método interno para rastrear eventos
  void _trackEvent(Map<String, dynamic> event) {
    if (EnvironmentConfig.isDevelopment) {
      debugPrint('📊 Analytics Event: ${event['event_type']} - ${event}');
    }

    if (!_isInitialized) {
      // Adiciona à fila se não inicializado
      _eventQueue.add(event);
      return;
    }

    // Aqui seria o envio real para o serviço de analytics
    _sendEventToService(event);
  }

  /// Envia evento para o serviço de analytics
  Future<void> _sendEventToService(Map<String, dynamic> event) async {
    try {
      // Implementação real dependeria do serviço escolhido:
      // - Firebase Analytics: FirebaseAnalytics.instance.logEvent()
      // - Mixpanel: mixpanel.track()
      // - Custom API: http.post()
      
      // Por enquanto, apenas simula o envio
      if (EnvironmentConfig.isDevelopment) {
        debugPrint('📤 Enviando evento para analytics: ${event['event_type']}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao enviar evento para analytics: $e');
    }
  }

  /// Processa eventos em fila
  Future<void> _processQueuedEvents() async {
    if (_eventQueue.isEmpty) return;

    debugPrint('📊 Processando ${_eventQueue.length} eventos em fila');
    
    for (final event in _eventQueue) {
      await _sendEventToService(event);
    }
    
    _eventQueue.clear();
  }

  /// Define propriedades do usuário
  void setUserProperties(Map<String, dynamic> properties) {
    if (!EnvironmentConfig.enableAnalytics) return;

    if (EnvironmentConfig.isDevelopment) {
      debugPrint('👤 Definindo propriedades do usuário: $properties');
    }

    // Implementação real dependeria do serviço
  }

  /// Define ID do usuário
  void setUserId(String userId) {
    if (!EnvironmentConfig.enableAnalytics) return;

    if (EnvironmentConfig.isDevelopment) {
      debugPrint('👤 Definindo ID do usuário: $userId');
    }

    // Implementação real dependeria do serviço
  }

  /// Limpa dados do usuário
  void clearUserData() {
    if (!EnvironmentConfig.enableAnalytics) return;

    if (EnvironmentConfig.isDevelopment) {
      debugPrint('🧹 Limpando dados do usuário');
    }

    // Implementação real dependeria do serviço
  }

  /// Obtém estatísticas de eventos (apenas desenvolvimento)
  Map<String, dynamic> getEventStats() {
    if (!EnvironmentConfig.isDevelopment) return {};
    
    return {
      'is_initialized': _isInitialized,
      'queued_events': _eventQueue.length,
      'analytics_enabled': EnvironmentConfig.enableAnalytics,
    };
  }
}