import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';
import '../models/favorite_model.dart';
import '../repositories/restaurant_repository.dart';
import '../../core/di/injection_container.dart';

/// Serviço para gerenciar favoritos
class FavoritesService {
  static FavoritesService? _instance;
  static FavoritesService get instance => _instance ??= FavoritesService._();
  FavoritesService._();

  final SupabaseClient _client = Supabase.instance.client;
  final RestaurantRepository _restaurantRepository = getIt<RestaurantRepository>();
  static const String _tableName = 'favorites';

  /// Cache de favoritos do usuário
  final Map<String, Set<String>> _favoritesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  /// Duração do cache (5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Adicionar restaurante aos favoritos
  Future<void> addFavorite(String userId, String restaurantId) async {
    try {
      // Verificar se já existe
      final existing = await _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (existing != null) {
        debugPrint('Restaurante já está nos favoritos');
        return;
      }

      // Inserir novo favorito
      await _client.from(_tableName).insert({
        'user_id': userId,
        'restaurant_id': restaurantId,
        'favorited_at': DateTime.now().toIso8601String(),
      });

      // Atualizar cache
      _updateCache(userId, restaurantId, true);
      
      debugPrint('Restaurante adicionado aos favoritos: $restaurantId');
    } catch (e) {
      debugPrint('Erro ao adicionar favorito: $e');
      rethrow;
    }
  }

  /// Remover restaurante dos favoritos
  Future<void> removeFavorite(String userId, String restaurantId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId);

      // Atualizar cache
      _updateCache(userId, restaurantId, false);
      
      debugPrint('Restaurante removido dos favoritos: $restaurantId');
    } catch (e) {
      debugPrint('Erro ao remover favorito: $e');
      rethrow;
    }
  }

  /// Verificar se restaurante é favorito
  Future<bool> isFavorite(String userId, String restaurantId) async {
    try {
      // Verificar cache primeiro
      if (_isCacheValid(userId)) {
        final userFavorites = _favoritesCache[userId] ?? {};
        return userFavorites.contains(restaurantId);
      }

      // Buscar no banco
      final result = await _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
      return false;
    }
  }

  /// Obter todos os favoritos do usuário
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*, restaurants(*)')
          .eq('user_id', userId)
          .order('favorited_at', ascending: false);

      final favorites = response
          .map<FavoriteModel>((json) => FavoriteModel.fromJson(json))
          .toList();

      // Atualizar cache
      final restaurantIds = favorites.map((f) => f.restaurantId).toSet();
      _favoritesCache[userId] = restaurantIds;
      _cacheTimestamps[userId] = DateTime.now();

      return favorites;
    } catch (e) {
      debugPrint('Erro ao obter favoritos: $e');
      return [];
    }
  }

  /// Obter restaurantes favoritos do usuário
  Future<List<RestaurantModel>> getUserFavoriteRestaurants(String userId) async {
    try {
      final favorites = await getUserFavorites(userId);
      final restaurants = <RestaurantModel>[];

      for (final favorite in favorites) {
        if (favorite.restaurant != null) {
          restaurants.add(RestaurantModel.fromEntity(favorite.restaurant!));
        }
      }

      return restaurants;
    } catch (e) {
      debugPrint('Erro ao obter restaurantes favoritos: $e');
      return [];
    }
  }

  /// Obter IDs dos restaurantes favoritos
  Future<Set<String>> getUserFavoriteIds(String userId) async {
    try {
      // Verificar cache primeiro
      if (_isCacheValid(userId)) {
        return _favoritesCache[userId] ?? {};
      }

      final response = await _client
          .from(_tableName)
          .select('restaurant_id')
          .eq('user_id', userId);

      final ids = response
          .map<String>((item) => item['restaurant_id'] as String)
          .toSet();

      // Atualizar cache
      _favoritesCache[userId] = ids;
      _cacheTimestamps[userId] = DateTime.now();

      return ids;
    } catch (e) {
      debugPrint('Erro ao obter IDs dos favoritos: $e');
      return {};
    }
  }

  /// Alternar status de favorito
  Future<bool> toggleFavorite(String userId, String restaurantId) async {
    try {
      final isFav = await isFavorite(userId, restaurantId);
      
      if (isFav) {
        await removeFavorite(userId, restaurantId);
        return false;
      } else {
        await addFavorite(userId, restaurantId);
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao alternar favorito: $e');
      rethrow;
    }
  }

  /// Limpar todos os favoritos do usuário
  Future<void> clearUserFavorites(String userId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('user_id', userId);

      // Limpar cache
      _favoritesCache.remove(userId);
      _cacheTimestamps.remove(userId);
      
      debugPrint('Favoritos limpos para usuário: $userId');
    } catch (e) {
      debugPrint('Erro ao limpar favoritos: $e');
      rethrow;
    }
  }

  /// Obter estatísticas de favoritos
  Future<FavoritesStats> getFavoritesStats(String userId) async {
    try {
      // Total de favoritos
      final totalFavorites = await _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId);

      // Favoritos recentes (últimos 7 dias)
      final recentFavorites = await _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .gte('favorited_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String());

      // Categoria mais favoritada
      final favoritesWithCategories = await _client
          .from(_tableName)
          .select('restaurants(category_id, categories(name))')
          .eq('user_id', userId);

      String? mostFavoritedCategory;
      if (favoritesWithCategories.isNotEmpty) {
        final categoryCount = <String, int>{};
        for (final item in favoritesWithCategories) {
          final restaurant = item['restaurants'];
          if (restaurant != null && restaurant['categories'] != null) {
            final categoryName = restaurant['categories']['name'] as String;
            categoryCount[categoryName] = (categoryCount[categoryName] ?? 0) + 1;
          }
        }
        
        if (categoryCount.isNotEmpty) {
          mostFavoritedCategory = categoryCount.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
        }
      }

      return FavoritesStats(
        totalFavorites: totalFavorites.length,
        recentFavorites: recentFavorites.length,
        mostFavoritedCategory: mostFavoritedCategory,
      );
    } catch (e) {
      debugPrint('Erro ao obter estatísticas de favoritos: $e');
      return FavoritesStats(
        totalFavorites: 0,
        recentFavorites: 0,
        mostFavoritedCategory: null,
      );
    }
  }

  /// Obter restaurantes mais favoritados (globalmente)
  Future<List<RestaurantModel>> getMostFavoritedRestaurants({int limit = 10}) async {
    try {
      final response = await _client
          .rpc('get_most_favorited_restaurants', params: {'result_limit': limit});

      if (response is List) {
        final restaurantIds = response
            .map<String>((item) => item['restaurant_id'].toString())
            .toList();

        // Buscar dados completos dos restaurantes
        final restaurants = <RestaurantModel>[];
        for (final id in restaurantIds) {
          try {
            final restaurant = await _restaurantRepository.getRestaurantById(id);
            if (restaurant != null) {
              restaurants.add(restaurant);
            }
          } catch (e) {
            debugPrint('Erro ao buscar restaurante $id: $e');
          }
        }

        return restaurants;
      }
      
      return [];
    } catch (e) {
      debugPrint('Erro ao obter restaurantes mais favoritados: $e');
      return [];
    }
  }

  /// Sincronizar favoritos offline
  Future<void> syncOfflineFavorites(String userId, List<String> offlineFavorites) async {
    try {
      // Obter favoritos atuais do servidor
      final serverFavorites = await getUserFavoriteIds(userId);
      
      // Encontrar diferenças
      final toAdd = offlineFavorites.where((id) => !serverFavorites.contains(id));
      final toRemove = serverFavorites.where((id) => !offlineFavorites.contains(id));
      
      // Adicionar novos favoritos
      for (final restaurantId in toAdd) {
        await addFavorite(userId, restaurantId);
      }
      
      // Remover favoritos não presentes offline
      for (final restaurantId in toRemove) {
        await removeFavorite(userId, restaurantId);
      }
      
      debugPrint('Sincronização de favoritos concluída');
    } catch (e) {
      debugPrint('Erro na sincronização de favoritos: $e');
    }
  }

  /// Atualizar cache
  void _updateCache(String userId, String restaurantId, bool isFavorite) {
    final userFavorites = _favoritesCache[userId] ?? <String>{};
    
    if (isFavorite) {
      userFavorites.add(restaurantId);
    } else {
      userFavorites.remove(restaurantId);
    }
    
    _favoritesCache[userId] = userFavorites;
    _cacheTimestamps[userId] = DateTime.now();
  }

  /// Verificar se o cache é válido
  bool _isCacheValid(String userId) {
    if (!_favoritesCache.containsKey(userId) || !_cacheTimestamps.containsKey(userId)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[userId]!;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Limpar cache
  void clearCache() {
    _favoritesCache.clear();
    _cacheTimestamps.clear();
    debugPrint('Cache de favoritos limpo');
  }

  /// Pré-carregar favoritos do usuário
  Future<void> preloadUserFavorites(String userId) async {
    try {
      await getUserFavoriteIds(userId);
      debugPrint('Favoritos pré-carregados para usuário: $userId');
    } catch (e) {
      debugPrint('Erro ao pré-carregar favoritos: $e');
    }
  }
}

/// Estatísticas de favoritos
class FavoritesStats {
  final int totalFavorites;
  final int recentFavorites;
  final String? mostFavoritedCategory;

  FavoritesStats({
    required this.totalFavorites,
    required this.recentFavorites,
    this.mostFavoritedCategory,
  });
}