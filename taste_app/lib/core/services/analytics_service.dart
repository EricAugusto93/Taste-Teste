import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/data/services/connectivity_service.dart';

/// Tipos de eventos de analytics
enum AnalyticsEventType {
  // Eventos de navegação
  screenView,
  pageView,
  
  // Eventos de interação
  buttonTap,
  search,
  filter,
  
  // Eventos de restaurante
  restaurantView,
  restaurantFavorite,
  restaurantShare,
  restaurantCall,
  restaurantDirections,
  
  // Eventos de usuário
  userLogin,
  userLogout,
  userRegister,
  profileUpdate,
  
  // Eventos de erro
  error,
  crash,
  
  // Eventos de performance
  loadTime,
  apiResponse,
  
  // Eventos personalizados
  custom,
}

/// Modelo de evento de analytics
class AnalyticsEvent {
  final String id;
  final AnalyticsEventType type;
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic>? userProperties;
  
  AnalyticsEvent({
    required this.id,
    required this.type,
    required this.name,
    required this.parameters,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.userProperties,
  });
  
  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      id: json['id'] as String,
      type: AnalyticsEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnalyticsEventType.custom,
      ),
      name: json['name'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
      userProperties: json['userProperties'] != null
          ? Map<String, dynamic>.from(json['userProperties'] as Map)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
      'userProperties': userProperties,
    };
  }
}

/// Configurações de analytics
class AnalyticsConfig {
  final bool enabled;
  final bool debugMode;
  final int batchSize;
  final Duration flushInterval;
  final Duration sessionTimeout;
  final List<String> excludedEvents;
  final Map<String, dynamic> defaultParameters;
  
  const AnalyticsConfig({
    this.enabled = true,
    this.debugMode = false,
    this.batchSize = 50,
    this.flushInterval = const Duration(minutes: 5),
    this.sessionTimeout = const Duration(minutes: 30),
    this.excludedEvents = const [],
    this.defaultParameters = const {},
  });
  
  factory AnalyticsConfig.fromJson(Map<String, dynamic> json) {
    return AnalyticsConfig(
      enabled: json['enabled'] as bool? ?? true,
      debugMode: json['debugMode'] as bool? ?? false,
      batchSize: json['batchSize'] as int? ?? 50,
      flushInterval: Duration(
        milliseconds: json['flushIntervalMs'] as int? ?? 300000,
      ),
      sessionTimeout: Duration(
        milliseconds: json['sessionTimeoutMs'] as int? ?? 1800000,
      ),
      excludedEvents: List<String>.from(json['excludedEvents'] as List? ?? []),
      defaultParameters: Map<String, dynamic>.from(
        json['defaultParameters'] as Map? ?? {},
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'debugMode': debugMode,
      'batchSize': batchSize,
      'flushIntervalMs': flushInterval.inMilliseconds,
      'sessionTimeoutMs': sessionTimeout.inMilliseconds,
      'excludedEvents': excludedEvents,
      'defaultParameters': defaultParameters,
    };
  }
}

/// Sessão de analytics
class AnalyticsSession {
  final String id;
  final DateTime startTime;
  DateTime lastActivity;
  int eventCount;
  final Map<String, dynamic> properties;
  
  AnalyticsSession({
    required this.id,
    required this.startTime,
    required this.lastActivity,
    this.eventCount = 0,
    this.properties = const {},
  });
  
  bool get isExpired {
    final timeout = const Duration(minutes: 30);
    return DateTime.now().difference(lastActivity) > timeout;
  }
  
  Duration get duration => lastActivity.difference(startTime);
  
  void updateActivity() {
    lastActivity = DateTime.now();
    eventCount++;
  }
  
  factory AnalyticsSession.fromJson(Map<String, dynamic> json) {
    return AnalyticsSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      eventCount: json['eventCount'] as int? ?? 0,
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'eventCount': eventCount,
      'properties': properties,
    };
  }
}

/// Serviço de analytics
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();
  
  /// Reset instance for testing purposes
  static void resetInstance() {
    _instance = null;
  }
  
  AnalyticsService._();
  
  final CacheService _cacheService = GetIt.instance<CacheService>();
  final ConnectivityService _connectivityService = GetIt.instance<ConnectivityService>();
  
  static const String _configKey = 'analytics_config';
  static const String _eventsKey = 'analytics_events';
  static const String _sessionKey = 'analytics_session';
  static const String _userPropertiesKey = 'analytics_user_properties';
  
  AnalyticsConfig _config = const AnalyticsConfig();
  AnalyticsSession? _currentSession;
  String? _userId;
  Map<String, dynamic> _userProperties = {};
  final List<AnalyticsEvent> _eventQueue = [];
  Timer? _flushTimer;
  
  /// Configuração atual
  AnalyticsConfig get config => _config;
  
  /// Sessão atual
  AnalyticsSession? get currentSession => _currentSession;
  
  /// ID do usuário atual
  String? get userId => _userId;
  
  /// Propriedades do usuário
  Map<String, dynamic> get userProperties => Map.from(_userProperties);
  
  /// Inicializa o serviço de analytics
  Future<void> initialize({
    AnalyticsConfig? config,
    String? userId,
    Map<String, dynamic>? userProperties,
  }) async {
    try {
      // Carrega configurações
      if (config != null) {
        _config = config;
        await _saveConfig();
      } else {
        await _loadConfig();
      }
      
      // Define usuário
      if (userId != null) {
        await setUserId(userId);
      }
      
      // Define propriedades do usuário
      if (userProperties != null) {
        await setUserProperties(userProperties);
      }
      
      // Carrega dados salvos
      await _loadUserProperties();
      await _loadEventQueue();
      
      // Inicia nova sessão
      await _startNewSession();
      
      // Configura timer de flush
      _setupFlushTimer();
      
      debugPrint('Analytics service initialized');
    } catch (e) {
      debugPrint('Error initializing analytics service: $e');
    }
  }
  
  /// Carrega configurações
  Future<void> _loadConfig() async {
    try {
      final data = await _cacheService.get(_configKey);
      if (data != null) {
        _config = AnalyticsConfig.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading analytics config: $e');
    }
  }
  
  /// Salva configurações
  Future<void> _saveConfig() async {
    try {
      await _cacheService.set(_configKey, _config.toJson());
    } catch (e) {
      debugPrint('Error saving analytics config: $e');
    }
  }
  
  /// Carrega propriedades do usuário
  Future<void> _loadUserProperties() async {
    try {
      final data = await _cacheService.get(_userPropertiesKey);
      if (data != null) {
        _userProperties = Map<String, dynamic>.from(data as Map);
      }
    } catch (e) {
      debugPrint('Error loading user properties: $e');
    }
  }
  
  /// Salva propriedades do usuário
  Future<void> _saveUserProperties() async {
    try {
      await _cacheService.set(_userPropertiesKey, _userProperties);
    } catch (e) {
      debugPrint('Error saving user properties: $e');
    }
  }
  
  /// Carrega fila de eventos
  Future<void> _loadEventQueue() async {
    try {
      final data = await _cacheService.get(_eventsKey);
      if (data != null) {
        final events = (data as List)
            .map((e) => AnalyticsEvent.fromJson(e as Map<String, dynamic>))
            .toList();
        _eventQueue.addAll(events);
      }
    } catch (e) {
      debugPrint('Error loading event queue: $e');
    }
  }
  
  /// Salva fila de eventos
  Future<void> _saveEventQueue() async {
    try {
      final data = _eventQueue.map((e) => e.toJson()).toList();
      await _cacheService.set(_eventsKey, data);
    } catch (e) {
      debugPrint('Error saving event queue: $e');
    }
  }
  
  /// Inicia nova sessão
  Future<void> _startNewSession() async {
    try {
      final now = DateTime.now();
      _currentSession = AnalyticsSession(
        id: _generateId(),
        startTime: now,
        lastActivity: now,
      );
      
      await _cacheService.set(_sessionKey, _currentSession!.toJson());
      
      // Registra evento de início de sessão
      await trackEvent(
        type: AnalyticsEventType.custom,
        name: 'session_start',
        parameters: {
          'session_id': _currentSession!.id,
        },
      );
      
      debugPrint('New analytics session started: ${_currentSession!.id}');
    } catch (e) {
      debugPrint('Error starting new session: $e');
    }
  }
  
  /// Configura timer de flush
  void _setupFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_config.flushInterval, (_) {
      flush();
    });
  }
  
  /// Gera ID único
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (1000 + (999 * (DateTime.now().microsecond / 1000000)).round()).toString();
  }
  
  /// Define ID do usuário
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await _cacheService.set('analytics_user_id', userId);
    debugPrint('Analytics user ID set: $userId');
  }
  
  /// Define propriedades do usuário
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    _userProperties.addAll(properties);
    await _saveUserProperties();
    debugPrint('Analytics user properties updated');
  }
  
  /// Registra evento
  Future<void> trackEvent({
    required AnalyticsEventType type,
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_config.enabled) return;
    
    // Verifica se o evento está excluído
    if (_config.excludedEvents.contains(name)) return;
    
    try {
      // Atualiza sessão
      if (_currentSession == null || _currentSession!.isExpired) {
        await _startNewSession();
      } else {
        _currentSession!.updateActivity();
      }
      
      // Cria evento
      final event = AnalyticsEvent(
        id: _generateId(),
        type: type,
        name: name,
        parameters: {
          ..._config.defaultParameters,
          ...parameters ?? {},
          'timestamp': DateTime.now().toIso8601String(),
          'platform': defaultTargetPlatform.name,
        },
        timestamp: DateTime.now(),
        userId: _userId,
        sessionId: _currentSession?.id,
        userProperties: _userProperties.isNotEmpty ? _userProperties : null,
      );
      
      // Adiciona à fila
      _eventQueue.add(event);
      
      // Salva fila
      await _saveEventQueue();
      
      // Debug
      if (_config.debugMode) {
        debugPrint('Analytics event tracked: ${event.name}');
        debugPrint('Parameters: ${event.parameters}');
      }
      
      // Flush automático se a fila estiver cheia
      if (_eventQueue.length >= _config.batchSize) {
        await flush();
      }
    } catch (e) {
      debugPrint('Error tracking analytics event: $e');
    }
  }
  
  /// Registra visualização de tela
  Future<void> trackScreenView(String screenName, {Map<String, dynamic>? parameters}) async {
    await trackEvent(
      type: AnalyticsEventType.screenView,
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        ...parameters ?? {},
      },
    );
  }
  
  /// Registra busca
  Future<void> trackSearch(String query, {Map<String, dynamic>? parameters}) async {
    await trackEvent(
      type: AnalyticsEventType.search,
      name: 'search',
      parameters: {
        'search_term': query,
        'query_length': query.length,
        ...parameters ?? {},
      },
    );
  }
  
  /// Registra erro
  Future<void> trackError(String error, {Map<String, dynamic>? parameters}) async {
    await trackEvent(
      type: AnalyticsEventType.error,
      name: 'error',
      parameters: {
        'error_message': error,
        ...parameters ?? {},
      },
    );
  }
  
  /// Registra tempo de carregamento
  Future<void> trackLoadTime(String operation, Duration duration, {Map<String, dynamic>? parameters}) async {
    await trackEvent(
      type: AnalyticsEventType.loadTime,
      name: 'load_time',
      parameters: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        ...parameters ?? {},
      },
    );
  }
  
  /// Envia eventos para o servidor
  Future<void> flush() async {
    if (_eventQueue.isEmpty) return;
    
    try {
      // Verifica conectividade
      if (!_connectivityService.isOnline) {
        debugPrint('No internet connection, skipping analytics flush');
        return;
      }
      
      // Cria cópia dos eventos para envio
      final eventsToSend = List<AnalyticsEvent>.from(_eventQueue);
      
      // Simula envio (aqui você integraria com seu backend)
      await _sendEventsToServer(eventsToSend);
      
      // Remove eventos enviados da fila
      _eventQueue.clear();
      await _saveEventQueue();
      
      debugPrint('Analytics events flushed: ${eventsToSend.length} events');
    } catch (e) {
      debugPrint('Error flushing analytics events: $e');
    }
  }
  
  /// Simula envio de eventos para o servidor
  Future<void> _sendEventsToServer(List<AnalyticsEvent> events) async {
    // Aqui você implementaria a integração com seu backend de analytics
    // Por exemplo: Firebase Analytics, Mixpanel, etc.
    
    if (_config.debugMode) {
      debugPrint('Sending ${events.length} events to analytics server');
      for (final event in events) {
        debugPrint('Event: ${event.name} - ${event.parameters}');
      }
    }
    
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Obtém estatísticas de analytics
  Map<String, dynamic> getAnalyticsStats() {
    return {
      'config': _config.toJson(),
      'session': _currentSession?.toJson(),
      'userId': _userId,
      'userProperties': _userProperties,
      'queueSize': _eventQueue.length,
      'totalEvents': _currentSession?.eventCount ?? 0,
      'sessionDuration': _currentSession?.duration.inMinutes ?? 0,
    };
  }
  
  /// Limpa dados de analytics
  Future<void> clearData() async {
    try {
      _eventQueue.clear();
      _userProperties.clear();
      _userId = null;
      _currentSession = null;
      
      await _cacheService.remove(_eventsKey);
      await _cacheService.remove(_userPropertiesKey);
      await _cacheService.remove(_sessionKey);
      await _cacheService.remove('analytics_user_id');
      
      debugPrint('Analytics data cleared');
    } catch (e) {
      debugPrint('Error clearing analytics data: $e');
    }
  }
  
  /// Finaliza o serviço
  void dispose() {
    _flushTimer?.cancel();
    flush(); // Envia eventos pendentes
  }
}

/// Mixin para tracking automático de telas
mixin AnalyticsScreenMixin {
  String get screenName;
  
  void trackScreenView({Map<String, dynamic>? parameters}) {
    AnalyticsService.instance.trackScreenView(
      screenName,
      parameters: parameters,
    );
  }
}

/// Widget para tracking automático de interações
class AnalyticsTracker extends StatelessWidget {
  final Widget child;
  final String? eventName;
  final Map<String, dynamic>? parameters;
  final AnalyticsEventType eventType;
  
  const AnalyticsTracker({
    super.key,
    required this.child,
    this.eventName,
    this.parameters,
    this.eventType = AnalyticsEventType.custom,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (eventName != null) {
          AnalyticsService.instance.trackEvent(
            type: eventType,
            name: eventName!,
            parameters: parameters,
          );
        }
      },
      child: child,
    );
  }
}