import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'cache_service.dart';

/// Serviço para gerenciar conectividade e estado offline
class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();
  
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<ConnectivityStatus> _statusNotifier = 
      ValueNotifier(ConnectivityStatus.unknown);
  
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isInitialized = false;

  /// Status atual da conectividade
  ConnectivityStatus get status => _statusNotifier.value;
  
  /// Stream para ouvir mudanças no status de conectividade
  ValueListenable<ConnectivityStatus> get statusStream => _statusNotifier;
  
  /// Verifica se está online
  bool get isOnline => status == ConnectivityStatus.connected;
  
  /// Verifica se está offline
  bool get isOffline => status == ConnectivityStatus.disconnected;

  /// Inicializa o serviço de conectividade
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Verifica o status inicial
      final initialResult = await _connectivity.checkConnectivity();
      _updateStatus(initialResult);
      
      // Escuta mudanças na conectividade
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (error) {
          debugPrint('Erro no ConnectivityService: $error');
          _statusNotifier.value = ConnectivityStatus.unknown;
        },
      );
      
      _isInitialized = true;
      debugPrint('ConnectivityService inicializado com status: ${status.name}');
    } catch (e) {
      debugPrint('Erro ao inicializar ConnectivityService: $e');
      _statusNotifier.value = ConnectivityStatus.unknown;
    }
  }

  /// Atualiza o status baseado no resultado da conectividade
  void _updateStatus(ConnectivityResult result) {
    final newStatus = _mapConnectivityResult(result);
    
    if (_statusNotifier.value != newStatus) {
      final oldStatus = _statusNotifier.value;
      _statusNotifier.value = newStatus;
      
      debugPrint('Conectividade mudou: ${oldStatus.name} -> ${newStatus.name}');
      
      // Notifica sobre mudanças importantes
      if (oldStatus == ConnectivityStatus.disconnected && 
          newStatus == ConnectivityStatus.connected) {
        _onConnectionRestored();
      } else if (oldStatus == ConnectivityStatus.connected && 
                 newStatus == ConnectivityStatus.disconnected) {
        _onConnectionLost();
      }
    }
  }

  /// Mapeia o resultado da conectividade para nosso enum
  ConnectivityStatus _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.connected;
      case ConnectivityResult.none:
        return ConnectivityStatus.disconnected;
      default:
        return ConnectivityStatus.unknown;
    }
  }

  /// Chamado quando a conexão é restaurada
  void _onConnectionRestored() {
    debugPrint('Conexão restaurada - sincronizando dados pendentes');
    // Aqui podemos implementar lógica para sincronizar dados pendentes
    _syncPendingData();
  }

  /// Chamado quando a conexão é perdida
  void _onConnectionLost() {
    debugPrint('Conexão perdida - modo offline ativado');
    // Aqui podemos implementar lógica para preparar o modo offline
  }

  /// Sincroniza dados pendentes quando a conexão é restaurada
  Future<void> _syncPendingData() async {
    try {
      final cacheService = GetIt.instance<CacheService>();
      
      // Busca ações pendentes no cache
      final pendingActions = await cacheService.get('pending_actions') as List<Map<String, dynamic>>? ?? [];
      
      if (pendingActions.isNotEmpty) {
        debugPrint('Sincronizando ${pendingActions.length} ações pendentes');
        
        // Aqui implementaríamos a lógica específica para cada tipo de ação
        // Por exemplo: favoritos, avaliações, pedidos, etc.
        
        // Remove as ações do cache após sincronizar
        await cacheService.remove('pending_actions');
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar dados pendentes: $e');
    }
  }

  /// Adiciona uma ação à fila de sincronização
  Future<void> queueAction(OfflineAction action) async {
    try {
      final cacheService = GetIt.instance<CacheService>();
      final pendingActions = await cacheService.get('pending_actions') as List<Map<String, dynamic>>? ?? [];
      
      pendingActions.add(action.toMap());
      await cacheService.set('pending_actions', pendingActions);
      
      debugPrint('Ação adicionada à fila offline: ${action.type}');
      
      // Se estiver online, tenta sincronizar imediatamente
      if (isOnline) {
        _syncPendingData();
      }
    } catch (e) {
      debugPrint('Erro ao adicionar ação à fila: $e');
    }
  }

  /// Verifica se há dados em cache para uma chave específica
  Future<bool> hasCachedData(String key) async {
    try {
      final cacheService = GetIt.instance<CacheService>();
      final data = await cacheService.get(key);
      return data != null;
    } catch (e) {
      return false;
    }
  }

  /// Obtém dados do cache quando offline
  Future<T?> getCachedData<T>(String key) async {
    try {
      final cacheService = GetIt.instance<CacheService>();
      return await cacheService.get(key) as T?;
    } catch (e) {
      debugPrint('Erro ao obter dados do cache: $e');
      return null;
    }
  }

  /// Salva dados no cache
  Future<void> cacheData(String key, dynamic data) async {
    try {
      final cacheService = GetIt.instance<CacheService>();
      await cacheService.set(key, data);
    } catch (e) {
      debugPrint('Erro ao salvar dados no cache: $e');
    }
  }

  /// Limpa o cache de dados offline
  Future<void> clearOfflineCache() async {
    try {
      final cacheService = GetIt.instance<CacheService>();
      await cacheService.remove('pending_actions');
      debugPrint('Cache offline limpo');
    } catch (e) {
      debugPrint('Erro ao limpar cache offline: $e');
    }
  }

  /// Força uma verificação de conectividade
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
      return status;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade: $e');
      return ConnectivityStatus.unknown;
    }
  }

  /// Dispose do serviço
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }
}

/// Status de conectividade
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// Extensão para facilitar o uso do status
extension ConnectivityStatusExtension on ConnectivityStatus {
  bool get isConnected => this == ConnectivityStatus.connected;
  bool get isDisconnected => this == ConnectivityStatus.disconnected;
  bool get isUnknown => this == ConnectivityStatus.unknown;
  
  String get displayName {
    switch (this) {
      case ConnectivityStatus.connected:
        return 'Online';
      case ConnectivityStatus.disconnected:
        return 'Offline';
      case ConnectivityStatus.unknown:
        return 'Desconhecido';
    }
  }
}

/// Representa uma ação que pode ser executada offline
class OfflineAction {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  OfflineAction({
    required this.id,
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OfflineAction.fromMap(Map<String, dynamic> map) {
    return OfflineAction(
      id: map['id'],
      type: map['type'],
      data: Map<String, dynamic>.from(map['data']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

/// Tipos de ações offline suportadas
class OfflineActionTypes {
  static const String addFavorite = 'add_favorite';
  static const String removeFavorite = 'remove_favorite';
  static const String addReview = 'add_review';
  static const String updateProfile = 'update_profile';
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
}