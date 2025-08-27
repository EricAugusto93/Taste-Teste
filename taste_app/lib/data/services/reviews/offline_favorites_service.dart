import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar favoritos offline usando SharedPreferences
class OfflineFavoritesService {
  static const String _favoritesKey = 'offline_favorites';
  static const String _pendingActionsKey = 'pending_favorites_actions';
  static const String _lastSyncKey = 'last_favorites_sync';
  
  /// Obter favoritos salvos offline
  Future<List<String>> getOfflineFavorites(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('${_favoritesKey}_$userId');
      
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        return favoritesList.cast<String>();
      }
      
      return [];
    } catch (e) {
      debugPrint('Erro ao obter favoritos offline: $e');
      return [];
    }
  }
  
  /// Salvar favoritos offline
  Future<void> saveOfflineFavorites(String userId, List<String> favoriteIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(favoriteIds);
      await prefs.setString('${_favoritesKey}_$userId', favoritesJson);
      
      debugPrint('Favoritos salvos offline: ${favoriteIds.length} itens');
    } catch (e) {
      debugPrint('Erro ao salvar favoritos offline: $e');
    }
  }
  
  /// Adicionar favorito offline
  Future<void> addOfflineFavorite(String userId, String restaurantId) async {
    try {
      final favorites = await getOfflineFavorites(userId);
      if (!favorites.contains(restaurantId)) {
        favorites.add(restaurantId);
        await saveOfflineFavorites(userId, favorites);
        
        // Registrar ação pendente
        await _addPendingAction(userId, 'add', restaurantId);
      }
    } catch (e) {
      debugPrint('Erro ao adicionar favorito offline: $e');
    }
  }
  
  /// Remover favorito offline
  Future<void> removeOfflineFavorite(String userId, String restaurantId) async {
    try {
      final favorites = await getOfflineFavorites(userId);
      if (favorites.contains(restaurantId)) {
        favorites.remove(restaurantId);
        await saveOfflineFavorites(userId, favorites);
        
        // Registrar ação pendente
        await _addPendingAction(userId, 'remove', restaurantId);
      }
    } catch (e) {
      debugPrint('Erro ao remover favorito offline: $e');
    }
  }
  
  /// Verificar se restaurante é favorito offline
  Future<bool> isOfflineFavorite(String userId, String restaurantId) async {
    try {
      final favorites = await getOfflineFavorites(userId);
      return favorites.contains(restaurantId);
    } catch (e) {
      debugPrint('Erro ao verificar favorito offline: $e');
      return false;
    }
  }
  
  /// Obter ações pendentes de sincronização
  Future<List<PendingFavoriteAction>> getPendingActions(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = prefs.getString('${_pendingActionsKey}_$userId');
      
      if (actionsJson != null) {
        final List<dynamic> actionsList = json.decode(actionsJson);
        return actionsList
            .map((json) => PendingFavoriteAction.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Erro ao obter ações pendentes: $e');
      return [];
    }
  }
  
  /// Adicionar ação pendente
  Future<void> _addPendingAction(String userId, String action, String restaurantId) async {
    try {
      final pendingActions = await getPendingActions(userId);
      
      // Remover ações conflitantes (ex: add seguido de remove)
      pendingActions.removeWhere((a) => 
          a.restaurantId == restaurantId && a.action != action);
      
      // Verificar se já existe a mesma ação
      final existingAction = pendingActions.firstWhere(
        (a) => a.restaurantId == restaurantId && a.action == action,
        orElse: () => PendingFavoriteAction(
          action: '',
          restaurantId: '',
          timestamp: DateTime.now(),
        ),
      );
      
      if (existingAction.action.isEmpty) {
        pendingActions.add(PendingFavoriteAction(
          action: action,
          restaurantId: restaurantId,
          timestamp: DateTime.now(),
        ));
        
        await _savePendingActions(userId, pendingActions);
      }
    } catch (e) {
      debugPrint('Erro ao adicionar ação pendente: $e');
    }
  }
  
  /// Salvar ações pendentes
  Future<void> _savePendingActions(String userId, List<PendingFavoriteAction> actions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = json.encode(actions.map((a) => a.toJson()).toList());
      await prefs.setString('${_pendingActionsKey}_$userId', actionsJson);
    } catch (e) {
      debugPrint('Erro ao salvar ações pendentes: $e');
    }
  }
  
  /// Limpar ações pendentes após sincronização
  Future<void> clearPendingActions(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_pendingActionsKey}_$userId');
      debugPrint('Ações pendentes limpas para usuário: $userId');
    } catch (e) {
      debugPrint('Erro ao limpar ações pendentes: $e');
    }
  }
  
  /// Obter timestamp da última sincronização
  Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('${_lastSyncKey}_$userId');
      
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao obter timestamp da última sincronização: $e');
      return null;
    }
  }
  
  /// Atualizar timestamp da última sincronização
  Future<void> updateLastSyncTime(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_lastSyncKey}_$userId', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Erro ao atualizar timestamp da sincronização: $e');
    }
  }
  
  /// Limpar todos os dados offline
  Future<void> clearOfflineData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_favoritesKey}_$userId');
      await prefs.remove('${_pendingActionsKey}_$userId');
      await prefs.remove('${_lastSyncKey}_$userId');
      
      debugPrint('Dados offline limpos para usuário: $userId');
    } catch (e) {
      debugPrint('Erro ao limpar dados offline: $e');
    }
  }
}

/// Modelo para ações pendentes de sincronização
class PendingFavoriteAction {
  final String action; // 'add' ou 'remove'
  final String restaurantId;
  final DateTime timestamp;
  
  PendingFavoriteAction({
    required this.action,
    required this.restaurantId,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'action': action,
    'restaurantId': restaurantId,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
  
  factory PendingFavoriteAction.fromJson(Map<String, dynamic> json) => PendingFavoriteAction(
    action: json['action'],
    restaurantId: json['restaurantId'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
  );
}