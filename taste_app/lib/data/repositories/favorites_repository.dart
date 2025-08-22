import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/error/failures.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../models/restaurant_model.dart';
import '../models/favorite_model.dart';
import '../../core/error/exceptions.dart';
import '../services/favorites_sync_service.dart';
import '../services/favorites_service.dart';
import '../services/offline_favorites_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/models/cache_item.dart';
import '../../core/di/injection_container.dart';
import '../../core/utils/logger.dart';
import 'restaurant_repository.dart';

/// Implementação do repositório de favoritos usando Supabase com sincronização offline
class FavoritesRepositoryImpl implements FavoritesRepository {
  final SupabaseClient _supabaseClient;
  final FavoritesSyncService _syncService;
  final CacheService _cacheService = InjectionContainer.get<CacheService>();
  final RestaurantRepository _restaurantRepository = getIt<RestaurantRepository>();
  
  // Cache local para melhor performance
  final Map<String, bool> _favoritesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // ID do usuário mock para demonstração
  static const String _mockUserId = 'mock_user_123';
  
  // Chave para persistir favoritos mock excluídos
  static const String _excludedMockFavoritesKey = 'excluded_mock_favorites';
  
  /// Getter para acessar o serviço de sincronização
  FavoritesSyncService get syncService => _syncService;

  FavoritesRepositoryImpl(
    this._supabaseClient, {
    FavoritesSyncService? syncService,
  }) : _syncService = syncService ?? FavoritesSyncService(
         favoritesService: FavoritesService.instance,
         offlineService: OfflineFavoritesService(),
       ) {
    _syncService.initialize();
  }
  
  /// Finalizar o repositório
  void dispose() {
    _syncService.dispose();
  }

  @override
  Future<Either<Failure, bool>> addToFavorites({
    required String restaurantId,
    String? userId,
    double? rating,
    String? comment,
  }) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return Left(AuthFailure('Usuário não autenticado'));
      }

      // Verificar se já é favorito
      final isAlreadyFavorite = await _syncService.isFavorite(currentUserId, restaurantId);
      if (isAlreadyFavorite) {
        return Left(CacheFailure('Restaurante já está nos favoritos'));
      }

      // Usar serviço de sincronização para adicionar
      final success = await _syncService.addFavorite(currentUserId, restaurantId);
      
      if (success) {
        // Atualizar cache local
        _updateCache(restaurantId, true, currentUserId);
        debugPrint('Restaurante $restaurantId adicionado aos favoritos');
        return const Right(true);
      } else {
        return Left(ServerFailure('Erro ao adicionar aos favoritos'));
      }
    } catch (e) {
      debugPrint('Erro ao adicionar favorito: $e');
      return Left(ServerFailure('Erro inesperado ao adicionar aos favoritos'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavorites({
    required String restaurantId,
    String? userId,
  }) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      // Verificar se é um favorito mock (IDs que começam com 'mock_')
      final isMockFavorite = restaurantId.startsWith('mock_');
      
      if (isMockFavorite) {
        // Para favoritos mock, apenas salvar na lista de excluídos
        await _addExcludedMockFavorite(restaurantId);
        debugPrint('Favorito mock $restaurantId adicionado à lista de excluídos');
        return const Right(true);
      }
      
      if (currentUserId == null) {
        return Left(AuthFailure('Usuário não autenticado'));
      }

      // Usar serviço de sincronização para remover favoritos reais
      final success = await _syncService.removeFavorite(currentUserId, restaurantId);
      
      if (success) {
        // Atualizar cache local
        _updateCache(restaurantId, false, currentUserId);
        debugPrint('Restaurante $restaurantId removido dos favoritos');
        return const Right(true);
      } else {
        return Left(ServerFailure('Erro ao remover dos favoritos'));
      }
    } catch (e) {
      debugPrint('Erro ao remover favorito: $e');
      return Left(ServerFailure('Erro inesperado ao remover dos favoritos'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite({
    required String restaurantId,
    String? userId,
  }) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return const Right(false);
      }

      // Verificar cache primeiro
      final cacheKey = '${currentUserId}_$restaurantId';
      if (_isCacheValid(cacheKey)) {
        return Right(_favoritesCache[cacheKey] ?? false);
      }

      // Usar serviço de sincronização
      final isFav = await _syncService.isFavorite(currentUserId, restaurantId);
      
      // Atualizar cache
      _updateCache(restaurantId, isFav, currentUserId);

      return Right(isFav);
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
      return Left(ServerFailure('Erro inesperado ao verificar favorito'));
    }
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getFavoriteRestaurants({
    String? userId,
    int? limit,
    int? offset,
  }) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      // Se não há usuário autenticado, retornar dados mock
      if (currentUserId == null) {
        debugPrint('Usuário não autenticado, retornando favoritos mock');
        final mockFavorites = await _getMockFavorites();
        
        // Aplicar limite e offset aos dados mock
        var filteredFavorites = mockFavorites;
        if (offset != null) {
          filteredFavorites = filteredFavorites.skip(offset).toList();
        }
        if (limit != null) {
          filteredFavorites = filteredFavorites.take(limit).toList();
        }
        
        return Right(filteredFavorites);
      }

      // Gerar chave de cache
      final cacheKey = 'favorites_${currentUserId}_${limit ?? 'all'}_${offset ?? 0}';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get(cacheKey);
      if (cachedData != null) {
        final restaurants = (cachedData as List<dynamic>)
            .map((json) => RestaurantModel.fromJson(json))
            .map((r) => r.toEntity())
            .toList();
        return Right(restaurants);
      }

      var query = _supabaseClient
          .from('favorites')
          .select('''
            *,
            restaurants!inner(
              id,
              name,
              description,
              image_url,
              rating,
              price_range,
              category_id,
              address,
              latitude,
              longitude,
              phone,
              website,
              opening_hours,
              is_open,
              is_featured,
              tags,
              created_at,
              updated_at,
              categories!inner(
                id,
                name,
                icon,
                color
              )
            )
          ''')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      final restaurants = (response as List)
          .map((item) => RestaurantModel.fromJson(item['restaurants']))
          .toList();

      // Se não há dados reais, retornar dados mock
      if (restaurants.isEmpty) {
        debugPrint('Nenhum favorito real encontrado, retornando favoritos mock');
        final mockFavorites = await _getMockFavorites();
        
        // Aplicar limite e offset aos dados mock
        var filteredFavorites = mockFavorites;
        if (offset != null) {
          filteredFavorites = filteredFavorites.skip(offset).toList();
        }
        if (limit != null) {
          filteredFavorites = filteredFavorites.take(limit).toList();
        }
        
        return Right(filteredFavorites);
      }

      // Salvar no cache
      await _cacheService.set(
        cacheKey,
        restaurants.map((r) => r.toJson()).toList(),
        ttl: const Duration(minutes: 10),
      );

      debugPrint('Carregados ${restaurants.length} restaurantes favoritos');
      return Right(restaurants.map((r) => r.toEntity()).toList());
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao buscar favoritos: ${e.message}');
      // Em caso de erro, retornar dados mock
      debugPrint('Erro ao buscar favoritos reais, retornando favoritos mock');
      final mockFavorites = await _getMockFavorites();
      
      // Aplicar limite e offset aos dados mock
      var filteredFavorites = mockFavorites;
      if (offset != null) {
        filteredFavorites = filteredFavorites.skip(offset).toList();
      }
      if (limit != null) {
        filteredFavorites = filteredFavorites.take(limit).toList();
      }
      
      return Right(filteredFavorites);
    } catch (e) {
      debugPrint('Erro ao buscar favoritos: $e');
      // Em caso de erro, retornar dados mock
      debugPrint('Erro inesperado ao buscar favoritos, retornando favoritos mock');
      final mockFavorites = await _getMockFavorites();
      
      // Aplicar limite e offset aos dados mock
      var filteredFavorites = mockFavorites;
      if (offset != null) {
        filteredFavorites = filteredFavorites.skip(offset).toList();
      }
      if (limit != null) {
        filteredFavorites = filteredFavorites.take(limit).toList();
      }
      
      return Right(filteredFavorites);
    }
  }

  @override
  Future<Either<Failure, bool>> addQuickReview({
    required String restaurantId,
    required double rating,
    String? comment,
    String? userId,
  }) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return Left(AuthFailure('Usuário não autenticado'));
      }

      // Verificar se já existe um favorito
      final existingFavorite = await _supabaseClient
          .from('favorites')
          .select('id')
          .eq('user_id', currentUserId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (existingFavorite != null) {
        // Atualizar favorito existente com avaliação
        await _supabaseClient
            .from('favorites')
            .update({
              'rating': rating,
              'comment': comment,
              'reviewed_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', currentUserId)
            .eq('restaurant_id', restaurantId);
      } else {
        // Criar novo favorito com avaliação
        await _supabaseClient
            .from('favorites')
            .insert({
              'user_id': currentUserId,
              'restaurant_id': restaurantId,
              'rating': rating,
              'comment': comment,
              'created_at': DateTime.now().toIso8601String(),
              'reviewed_at': DateTime.now().toIso8601String(),
            });
      }

      // Atualizar cache
      _updateCache(restaurantId, true, currentUserId);

      debugPrint('Avaliação rápida adicionada para restaurante $restaurantId');
      return const Right(true);
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao adicionar avaliação: ${e.message}');
      return Left(ServerFailure('Erro ao adicionar avaliação: ${e.message}'));
    } catch (e) {
      debugPrint('Erro ao adicionar avaliação: $e');
      return Left(ServerFailure('Erro inesperado ao adicionar avaliação'));
    }
  }

  @override
  Future<Either<Failure, int>> getFavoritesCount({String? userId}) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return const Right(0);
      }

      final response = await _supabaseClient
          .from('favorites')
          .select('id')
          .eq('user_id', currentUserId);

      final count = (response as List).length;
      return Right(count);
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao contar favoritos: ${e.message}');
      return Left(ServerFailure('Erro ao contar favoritos: ${e.message}'));
    } catch (e) {
      debugPrint('Erro ao contar favoritos: $e');
      return Left(ServerFailure('Erro inesperado ao contar favoritos'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteIds({String? userId}) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return const Right([]);
      }

      // Gerar chave de cache
      final cacheKey = 'favorite_ids_$currentUserId';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get(cacheKey);
      if (cachedData != null) {
        final ids = (cachedData as List<dynamic>)
            .map((id) => id as String)
            .toList();
        return Right(ids);
      }

      final response = await _supabaseClient
          .from('favorites')
          .select('restaurant_id')
          .eq('user_id', currentUserId);

      final ids = (response as List)
          .map((item) => item['restaurant_id'] as String)
          .toList();

      // Salvar no cache
      await _cacheService.set(
        cacheKey,
        ids,
        ttl: const Duration(minutes: 15),
      );

      return Right(ids);
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao buscar IDs favoritos: ${e.message}');
      return Left(ServerFailure('Erro ao buscar IDs favoritos: ${e.message}'));
    } catch (e) {
      debugPrint('Erro ao buscar IDs favoritos: $e');
      return Left(ServerFailure('Erro inesperado ao buscar IDs favoritos'));
    }
  }

  /// Obter ID do usuário atual
  String? _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    return user?.id;
  }

  /// Obter dados mock de favoritos para demonstração
  Future<List<Restaurant>> _getMockFavorites() async {
    try {
      // IDs dos restaurantes favoritos mock
      final mockFavoriteIds = ['mock_1', 'mock_3', 'mock_5', 'mock_8', 'mock_12'];
      
      // Obter lista de favoritos mock excluídos
      final excludedIds = await _getExcludedMockFavorites();
      
      // Filtrar IDs que não foram excluídos
      final activeIds = mockFavoriteIds.where((id) => !excludedIds.contains(id)).toList();
      
      // Buscar todos os restaurantes mock
      final allRestaurants = await _restaurantRepository.getRestaurants();
      
      // Filtrar apenas os restaurantes que estão na lista de favoritos mock ativos
      final favoriteRestaurants = allRestaurants
          .where((restaurant) => activeIds.contains(restaurant.id))
          .map((restaurantModel) => restaurantModel.toEntity())
          .toList();
      
      debugPrint('Carregados ${favoriteRestaurants.length} restaurantes favoritos mock (${excludedIds.length} excluídos)');
      return favoriteRestaurants;
    } catch (e) {
      debugPrint('Erro ao carregar favoritos mock: $e');
      return [];
    }
  }

  /// Atualizar cache de favoritos
  void _updateCache(String restaurantId, bool isFavorite, String userId) {
    final cacheKey = '${userId}_$restaurantId';
    _favoritesCache[cacheKey] = isFavorite;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  /// Verificar se o cache é válido
  bool _isCacheValid(String cacheKey) {
    if (!_favoritesCache.containsKey(cacheKey) || !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Limpar cache
  void clearCache() {
    _favoritesCache.clear();
    _cacheTimestamps.clear();
    debugPrint('Cache de favoritos limpo');
  }

  /// Obtém a lista de IDs de favoritos mock excluídos
  Future<Set<String>> _getExcludedMockFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final excludedJson = prefs.getString(_excludedMockFavoritesKey);
      if (excludedJson != null) {
        final List<dynamic> excludedList = json.decode(excludedJson);
        return excludedList.cast<String>().toSet();
      }
      return <String>{};
    } catch (e) {
      debugPrint('Erro ao obter favoritos mock excluídos: $e');
      return <String>{};
    }
  }

  /// Adiciona um ID à lista de favoritos mock excluídos
  Future<void> _addExcludedMockFavorite(String restaurantId) async {
    try {
      final excludedIds = await _getExcludedMockFavorites();
      excludedIds.add(restaurantId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _excludedMockFavoritesKey,
        json.encode(excludedIds.toList()),
      );
    } catch (e) {
      debugPrint('Erro ao adicionar favorito mock excluído: $e');
    }
  }

  /// Remove um ID da lista de favoritos mock excluídos
  Future<void> _removeExcludedMockFavorite(String restaurantId) async {
    try {
      final excludedIds = await _getExcludedMockFavorites();
      excludedIds.remove(restaurantId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _excludedMockFavoritesKey,
        json.encode(excludedIds.toList()),
      );
    } catch (e) {
      debugPrint('Erro ao remover favorito mock excluído: $e');
    }
  }

  /// Limpa todos os favoritos mock excluídos
  Future<void> clearExcludedMockFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_excludedMockFavoritesKey);
      debugPrint('Lista de favoritos mock excluídos foi limpa');
    } catch (e) {
      debugPrint('Erro ao limpar favoritos mock excluídos: $e');
    }
  }

  /// Restaura um favorito mock específico (remove da lista de excluídos)
  Future<Either<Failure, bool>> restoreMockFavorite(String restaurantId) async {
    try {
      if (!restaurantId.startsWith('mock_')) {
        return Left(ValidationFailure('ID deve ser de um restaurante mock'));
      }
      
      await _removeExcludedMockFavorite(restaurantId);
      debugPrint('Favorito mock $restaurantId foi restaurado');
      return const Right(true);
    } catch (e) {
      debugPrint('Erro ao restaurar favorito mock: $e');
      return Left(ServerFailure('Erro ao restaurar favorito mock'));
    }
  }

  /// Obtém a lista de IDs de favoritos mock excluídos (método público para debug)
  Future<List<String>> getExcludedMockFavoriteIds() async {
    final excludedIds = await _getExcludedMockFavorites();
    return excludedIds.toList();
  }

  /// Sincronizar favoritos (útil para quando o usuário faz login)
  Future<Either<Failure, bool>> syncFavorites({String? userId}) async {
    try {
      clearCache();
      
      // Pré-carregar favoritos para cache
      final result = await getFavoriteIds(userId: userId);
      
      return result.fold(
        (failure) => Left(failure),
        (ids) {
          debugPrint('Sincronizados ${ids.length} favoritos');
          return const Right(true);
        },
      );
    } catch (e) {
      debugPrint('Erro ao sincronizar favoritos: $e');
      return Left(ServerFailure('Erro ao sincronizar favoritos'));
    }
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getNearbyFavorites({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? userId,
  }) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return const Right([]);
      }

      // TODO: Implementar busca por proximidade usando PostGIS
      // Por enquanto, retorna todos os favoritos
      final result = await getFavoriteRestaurants(userId: currentUserId);
      return result;
    } catch (e) {
      debugPrint('Erro ao buscar favoritos próximos: $e');
      return Left(ServerFailure('Erro ao buscar favoritos próximos'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFavorite(String restaurantId) async {
    return await removeFromFavorites(restaurantId: restaurantId);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportFavorites({String? userId}) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return Left(AuthFailure('Usuário não autenticado'));
      }

      final response = await _supabaseClient
          .from('favorites')
          .select('restaurant_id, rating, comment, created_at')
          .eq('user_id', currentUserId);

      final exportData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'user_id': currentUserId,
        'favorites': response,
      };

      return Right(exportData);
    } catch (e) {
      debugPrint('Erro ao exportar favoritos: $e');
      return Left(ServerFailure('Erro ao exportar favoritos'));
    }
  }

  @override
  Future<Either<Failure, bool>> importFavorites({
    required Map<String, dynamic> data,
    String? userId,
  }) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return Left(AuthFailure('Usuário não autenticado'));
      }

      final favorites = data['favorites'] as List<dynamic>;
      
      for (final favorite in favorites) {
        await _supabaseClient
            .from('favorites')
            .upsert({
              'user_id': currentUserId,
              'restaurant_id': favorite['restaurant_id'],
              'rating': favorite['rating'],
              'comment': favorite['comment'],
              'created_at': favorite['created_at'],
            });
      }

      clearCache();
      return const Right(true);
    } catch (e) {
      debugPrint('Erro ao importar favoritos: $e');
      return Left(ServerFailure('Erro ao importar favoritos'));
    }
  }

  @override
  Future<Map<String, dynamic>> getFavoritesStats({String? userId}) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return {
          'total_count': 0,
          'recent_count': 0,
          'top_category': null,
        };
      }

      // Usar o serviço de favoritos para obter estatísticas
      final favoritesService = FavoritesService.instance;
      final stats = await favoritesService.getFavoritesStats(currentUserId);
      
      return {
        'total_count': stats.totalFavorites,
        'recent_count': stats.recentFavorites,
        'top_category': stats.mostFavoritedCategory,
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas de favoritos: $e');
      return {
        'total_count': 0,
        'recent_count': 0,
        'top_category': null,
      };
    }
  }
}