import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/error/failures.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../models/restaurant_model.dart';
import '../../core/services/cache_service.dart';

/// Implementação simplificada do repositório de favoritos
class FavoritesRepositoryImpl implements FavoritesRepository {
  final SupabaseClient _supabaseClient;
  final CacheService _cacheService = CacheService();
  
  // Cache local para melhor performance
  final Map<String, bool> _favoritesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // ID do usuário mock para demonstração
  static const String _mockUserId = 'mock_user_123';
  
  // Chave para persistir favoritos mock excluídos
  static const String _excludedMockFavoritesKey = 'excluded_mock_favorites';

  FavoritesRepositoryImpl(this._supabaseClient);
  
  /// Finalizar o repositório
  void dispose() {
    // Cleanup cache
    _favoritesCache.clear();
    _cacheTimestamps.clear();
  }

  /// Adicionar favorito (método simplificado da interface)
  @override
  Future<Either<Failure, void>> addToFavorites(String restaurantId) async {
    final result = await addToFavoritesLegacy(restaurantId: restaurantId);
    return result.fold(
      (failure) => Left(failure),
      (success) => const Right(null),
    );
  }

  /// Remover favorito (método simplificado da interface)
  @override
  Future<Either<Failure, void>> removeFromFavorites(String restaurantId) async {
    final result = await removeFromFavoritesLegacy(restaurantId: restaurantId);
    return result.fold(
      (failure) => Left(failure),
      (success) => const Right(null),
    );
  }

  /// Verificar se é favorito (método simplificado da interface)
  @override
  Future<Either<Failure, bool>> isFavorite(String restaurantId) async {
    return await isFavoriteLegacy(restaurantId: restaurantId);
  }

  /// Obter lista de favoritos (método simplificado da interface)
  @override
  Future<Either<Failure, List<Restaurant>>> getFavorites() async {
    return await getFavoriteRestaurants();
  }

  @override
  Future<Either<Failure, bool>> addToFavoritesLegacy({
    required String restaurantId,
    String? userId,
    double? rating,
    String? comment,
  }) async {
    try {
      final currentUserId = userId ?? _mockUserId;
      
      // Atualizar cache local
      _updateCache(restaurantId, true, currentUserId);
      debugPrint('🟢 Restaurante $restaurantId adicionado aos favoritos (modo local)');
      return const Right(true);
    } catch (e) {
      debugPrint('❌ Erro ao adicionar favorito: $e');
      return const Left(ServerFailure('Erro inesperado ao adicionar aos favoritos'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavoritesLegacy({
    required String restaurantId,
    String? userId,
  }) async {
    try {
      final currentUserId = userId ?? _mockUserId;
      
      // Atualizar cache local
      _updateCache(restaurantId, false, currentUserId);
      debugPrint('🔴 Restaurante $restaurantId removido dos favoritos (modo local)');
      return const Right(true);
    } catch (e) {
      debugPrint('❌ Erro ao remover favorito: $e');
      return const Left(ServerFailure('Erro inesperado ao remover dos favoritos'));
    }
  }

  Future<Either<Failure, bool>> isFavoriteLegacy({
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
      final isFav = _favoritesCache[cacheKey] ?? false;
      
      // Atualizar cache
      _updateCache(restaurantId, isFav, currentUserId);

      return Right(isFav);
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
      return const Left(ServerFailure('Erro inesperado ao verificar favorito'));
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
              is_open,
              is_featured,
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

      final restaurants = response
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
        return const Left(AuthFailure('Usuário não autenticado'));
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
      return const Left(ServerFailure('Erro inesperado ao adicionar avaliação'));
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

      final count = response.length;
      return Right(count);
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao contar favoritos: ${e.message}');
      return Left(ServerFailure('Erro ao contar favoritos: ${e.message}'));
    } catch (e) {
      debugPrint('Erro ao contar favoritos: $e');
      return const Left(ServerFailure('Erro inesperado ao contar favoritos'));
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

      final ids = response
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
      return const Left(ServerFailure('Erro inesperado ao buscar IDs favoritos'));
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
      // final mockFavoriteIds = ['mock_1', 'mock_3', 'mock_5', 'mock_8', 'mock_12'];
      
      // Obter lista de favoritos mock excluídos
      final excludedIds = await _getExcludedMockFavorites();
      
      // Filtrar IDs que não foram excluídos
      // final activeIds = mockFavoriteIds.where((id) => !excludedIds.contains(id)).toList();
      
      // Retornar lista vazia por enquanto (modo simplificado)
      final favoriteRestaurants = <Restaurant>[];
      
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
  @override
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
        return const Left(ValidationFailure('ID deve ser de um restaurante mock'));
      }
      
      await _removeExcludedMockFavorite(restaurantId);
      debugPrint('Favorito mock $restaurantId foi restaurado');
      return const Right(true);
    } catch (e) {
      debugPrint('Erro ao restaurar favorito mock: $e');
      return const Left(ServerFailure('Erro ao restaurar favorito mock'));
    }
  }

  /// Obtém a lista de IDs de favoritos mock excluídos (método público para debug)
  Future<List<String>> getExcludedMockFavoriteIds() async {
    final excludedIds = await _getExcludedMockFavorites();
    return excludedIds.toList();
  }

  /// Sincronizar favoritos (útil para quando o usuário faz login)
  @override
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
      return const Left(ServerFailure('Erro ao sincronizar favoritos'));
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
      return const Left(ServerFailure('Erro ao buscar favoritos próximos'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFavorite(String restaurantId) async {
    return await removeFromFavoritesLegacy(restaurantId: restaurantId);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportFavorites({String? userId}) async {
    try {
      final currentUserId = userId ?? _getCurrentUserId();
      
      if (currentUserId == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
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
      return const Left(ServerFailure('Erro ao exportar favoritos'));
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
        return const Left(AuthFailure('Usuário não autenticado'));
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
      return const Left(ServerFailure('Erro ao importar favoritos'));
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

      // Retornar estatísticas básicas (modo simplificado)
      return {
        'total_count': _favoritesCache.values.where((isFav) => isFav).length,
        'recent_count': 0,
        'top_category': 'Restaurantes',
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
