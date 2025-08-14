import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'favorites_service.dart';
import 'offline_favorites_service.dart';

/// Serviço para sincronização de favoritos entre offline e online
class FavoritesSyncService {
  final FavoritesService _favoritesService;
  final OfflineFavoritesService _offlineService;
  final Connectivity _connectivity;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  
  static const Duration _syncInterval = Duration(minutes: 5);
  
  FavoritesSyncService({
    required FavoritesService favoritesService,
    required OfflineFavoritesService offlineService,
    Connectivity? connectivity,
  }) : _favoritesService = favoritesService,
       _offlineService = offlineService,
       _connectivity = connectivity ?? Connectivity();
  
  /// Inicializar o serviço de sincronização
  void initialize() {
    // Monitorar mudanças de conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    
    // Configurar sincronização periódica
    _syncTimer = Timer.periodic(_syncInterval, (_) => _performPeriodicSync());
    
    debugPrint('Serviço de sincronização de favoritos inicializado');
  }
  
  /// Finalizar o serviço
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    debugPrint('Serviço de sincronização de favoritos finalizado');
  }
  
  /// Verificar se há conectividade
  Future<bool> hasConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade: $e');
      return false;
    }
  }
  
  /// Adicionar favorito com sincronização
  Future<bool> addFavorite(String userId, String restaurantId) async {
    try {
      // Sempre salvar offline primeiro
      await _offlineService.addOfflineFavorite(userId, restaurantId);
      
      // Tentar sincronizar online se houver conectividade
      if (await hasConnectivity()) {
        try {
          await _favoritesService.addFavorite(userId, restaurantId);
          debugPrint('Favorito adicionado online: $restaurantId');
        } catch (e) {
          debugPrint('Erro ao adicionar favorito online: $e');
          // Manter offline, será sincronizado depois
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar favorito: $e');
      return false;
    }
  }
  
  /// Remover favorito com sincronização
  Future<bool> removeFavorite(String userId, String restaurantId) async {
    try {
      // Sempre remover offline primeiro
      await _offlineService.removeOfflineFavorite(userId, restaurantId);
      
      // Tentar sincronizar online se houver conectividade
      if (await hasConnectivity()) {
        try {
          await _favoritesService.removeFavorite(userId, restaurantId);
          debugPrint('Favorito removido online: $restaurantId');
        } catch (e) {
          debugPrint('Erro ao remover favorito online: $e');
          // Manter offline, será sincronizado depois
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Erro ao remover favorito: $e');
      return false;
    }
  }
  
  /// Verificar se restaurante é favorito
  Future<bool> isFavorite(String userId, String restaurantId) async {
    try {
      // Verificar offline primeiro (mais rápido)
      final isOfflineFavorite = await _offlineService.isOfflineFavorite(userId, restaurantId);
      
      // Se houver conectividade, verificar online também
      if (await hasConnectivity()) {
        try {
          final isOnlineFavorite = await _favoritesService.isFavorite(userId, restaurantId);
          
          // Se houver discrepância, priorizar o estado online
          if (isOfflineFavorite != isOnlineFavorite) {
            debugPrint('Discrepância detectada para $restaurantId: offline=$isOfflineFavorite, online=$isOnlineFavorite');
            
            // Atualizar estado offline para corresponder ao online
            if (isOnlineFavorite) {
              await _offlineService.addOfflineFavorite(userId, restaurantId);
            } else {
              await _offlineService.removeOfflineFavorite(userId, restaurantId);
            }
            
            return isOnlineFavorite;
          }
        } catch (e) {
          debugPrint('Erro ao verificar favorito online: $e');
        }
      }
      
      return isOfflineFavorite;
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
      return false;
    }
  }
  
  /// Obter favoritos do usuário
  Future<List<String>> getUserFavoriteIds(String userId) async {
    try {
      // Se houver conectividade, buscar online
      if (await hasConnectivity()) {
        try {
          final onlineFavorites = await _favoritesService.getUserFavoriteIds(userId);
          final favoritesList = onlineFavorites.toList();
          
          // Atualizar cache offline
          await _offlineService.saveOfflineFavorites(userId, favoritesList);
          
          return favoritesList;
        } catch (e) {
          debugPrint('Erro ao buscar favoritos online: $e');
        }
      }
      
      // Fallback para favoritos offline
      return await _offlineService.getOfflineFavorites(userId);
    } catch (e) {
      debugPrint('Erro ao obter favoritos: $e');
      return [];
    }
  }
  
  /// Sincronização completa
  Future<SyncResult> performFullSync(String userId) async {
    try {
      if (!await hasConnectivity()) {
        return SyncResult(
          success: false,
          message: 'Sem conectividade com a internet',
          itemsSynced: 0,
        );
      }
      
      debugPrint('Iniciando sincronização completa para usuário: $userId');
      
      // Obter ações pendentes
      final pendingActions = await _offlineService.getPendingActions(userId);
      int itemsSynced = 0;
      
      // Executar ações pendentes
      for (final action in pendingActions) {
        try {
          if (action.action == 'add') {
            await _favoritesService.addFavorite(userId, action.restaurantId);
          } else if (action.action == 'remove') {
            await _favoritesService.removeFavorite(userId, action.restaurantId);
          }
          itemsSynced++;
        } catch (e) {
          debugPrint('Erro ao sincronizar ação ${action.action} para ${action.restaurantId}: $e');
        }
      }
      
      // Obter estado atual do servidor
      final serverFavorites = await _favoritesService.getUserFavoriteIds(userId);
      final localFavorites = await _offlineService.getOfflineFavorites(userId);
      
      // Sincronizar diferenças
      final toAddLocally = serverFavorites.where((id) => !localFavorites.contains(id));
      final toRemoveLocally = localFavorites.where((id) => !serverFavorites.contains(id));
      
      // Atualizar estado local
      for (final restaurantId in toAddLocally) {
        await _offlineService.addOfflineFavorite(userId, restaurantId);
        itemsSynced++;
      }
      
      for (final restaurantId in toRemoveLocally) {
        await _offlineService.removeOfflineFavorite(userId, restaurantId);
        itemsSynced++;
      }
      
      // Limpar ações pendentes
      await _offlineService.clearPendingActions(userId);
      
      // Atualizar timestamp da última sincronização
      await _offlineService.updateLastSyncTime(userId);
      
      debugPrint('Sincronização completa finalizada: $itemsSynced itens sincronizados');
      
      return SyncResult(
        success: true,
        message: 'Sincronização concluída com sucesso',
        itemsSynced: itemsSynced,
      );
    } catch (e) {
      debugPrint('Erro na sincronização completa: $e');
      return SyncResult(
        success: false,
        message: 'Erro na sincronização: $e',
        itemsSynced: 0,
      );
    }
  }
  
  /// Callback para mudanças de conectividade
  void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      debugPrint('Conectividade restaurada, iniciando sincronização...');
      _performPeriodicSync();
    }
  }
  
  /// Sincronização periódica
  Future<void> _performPeriodicSync() async {
    // TODO: Implementar lógica para obter usuário atual
    // Por enquanto, não executar sincronização automática
    // await performFullSync(currentUserId);
  }
  
  /// Obter status da sincronização
  Future<SyncStatus> getSyncStatus(String userId) async {
    try {
      final lastSync = await _offlineService.getLastSyncTime(userId);
      final pendingActions = await _offlineService.getPendingActions(userId);
      final hasConnectivity = await this.hasConnectivity();
      
      return SyncStatus(
        lastSyncTime: lastSync,
        pendingActionsCount: pendingActions.length,
        hasConnectivity: hasConnectivity,
        needsSync: pendingActions.isNotEmpty,
      );
    } catch (e) {
      debugPrint('Erro ao obter status da sincronização: $e');
      return SyncStatus(
        lastSyncTime: null,
        pendingActionsCount: 0,
        hasConnectivity: false,
        needsSync: false,
      );
    }
  }
}

/// Resultado da sincronização
class SyncResult {
  final bool success;
  final String message;
  final int itemsSynced;
  
  SyncResult({
    required this.success,
    required this.message,
    required this.itemsSynced,
  });
}

/// Status da sincronização
class SyncStatus {
  final DateTime? lastSyncTime;
  final int pendingActionsCount;
  final bool hasConnectivity;
  final bool needsSync;
  
  SyncStatus({
    required this.lastSyncTime,
    required this.pendingActionsCount,
    required this.hasConnectivity,
    required this.needsSync,
  });
}