import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/favorite_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../domain/repositories/favorites_repository.dart' as domain_favorites;
import '../../domain/usecases/favorites/add_favorite_usecase.dart';
import '../../domain/usecases/favorites/remove_favorite_usecase.dart';
import '../../domain/usecases/favorites/get_favorites_usecase.dart';
import '../../../core/di/injection_container.dart';
import '../../data/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Estatísticas dos favoritos
class FavoritesStats {
  final int totalFavorites;
  final int totalRestaurants;
  final double averageRating;
  final String mostFavoriteCategory;
  final int recentFavorites;

  const FavoritesStats({
    required this.totalFavorites,
    required this.totalRestaurants,
    required this.averageRating,
    required this.mostFavoriteCategory,
    required this.recentFavorites,
  });
}

/// Provider para o repositório de favoritos (via GetIt)
final favoritesRepositoryProvider = Provider<domain_favorites.FavoritesRepository>((ref) {
  return getIt<domain_favorites.FavoritesRepository>();
});

/// Provider para Use Cases de favoritos
final addFavoriteUseCaseProvider = Provider<AddFavoriteUseCase>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return AddFavoriteUseCase(repository);
});

final removeFavoriteUseCaseProvider = Provider<RemoveFavoriteUseCase>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return RemoveFavoriteUseCase(repository);
});

final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return GetFavoritesUseCase(repository);
});

/// Provider para a lista de favoritos do usuário
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<FavoriteModel>>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repository);
});

/// Provider para verificar se um restaurante é favorito
final isFavoriteProvider = Provider.family<bool, String>((ref, restaurantId) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.when(
    data: (favorites) => favorites.any((fav) => fav.restaurantId == restaurantId),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider para estatísticas de favoritos
final favoritesStatsProvider = FutureProvider<FavoritesStats>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  final statsMap = await repository.getFavoritesStats();
  
  return FavoritesStats(
    totalFavorites: statsMap['total_count'] as int,
    totalRestaurants: statsMap['total_restaurants'] as int? ?? 0,
    averageRating: statsMap['average_rating'] as double? ?? 0.0,
    recentFavorites: statsMap['recent_count'] as int? ?? 0,
    mostFavoriteCategory: statsMap['top_category'] as String? ?? 'Geral',
  );
});

/// Provider para favoritos por categoria
final favoritesByCategoryProvider = Provider.family<List<FavoriteModel>, String?>((ref, category) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.when(
    data: (favorites) {
      if (category == null || category == 'Todos') {
        return favorites;
      }
      return favorites.where((fav) => fav.restaurant?.categoryId == category).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Notifier para gerenciar o estado dos favoritos
class FavoritesNotifier extends StateNotifier<AsyncValue<List<FavoriteModel>>> {
  final domain_favorites.FavoritesRepository _repository;
  static const String _localFavoritesKey = 'local_favorites';
  
  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadFromLocalFirst();
  }
  
  /// Carrega todos os favoritos do usuário
  Future<void> loadFavorites() async {
    try {
      state = const AsyncValue.loading();
      final result = await _repository.getFavoriteRestaurants();
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (restaurants) {
          // Converter Restaurant para FavoriteModel
          final favorites = restaurants.map((restaurant) => FavoriteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'current_user',
            restaurantId: restaurant.id,
            createdAt: DateTime.now(),
            restaurant: restaurant,
          )).toList();
          state = AsyncValue.data(favorites);
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Adiciona um restaurante aos favoritos
  Future<bool> addFavorite(RestaurantModel restaurant) async {
    try {
      final result = await _repository.addToFavorites(restaurant.id);
      return result.fold(
        (failure) => false,
        (_) {
          // Atualiza o estado local imediatamente
          final currentFavorites = state.value ?? [];
          final newFavorite = FavoriteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: AuthService.instance.userId ?? 'anonymous',
            restaurantId: restaurant.id,
            createdAt: DateTime.now(),
            restaurant: restaurant.toEntity(),
          );
          
          // Verificar se já existe para evitar duplicatas
          final exists = currentFavorites.any((fav) => fav.restaurantId == restaurant.id);
          if (!exists) {
            state = AsyncValue.data([...currentFavorites, newFavorite]);
            _saveFavoritesToLocal();
          }
          
          // Recarregar favoritos do servidor para garantir sincronização
          loadFavorites();
          
          return true;
        },
      );
    } catch (error) {
      return false;
    }
  }
  
  /// Remove um restaurante dos favoritos
  Future<bool> removeFavorite(String restaurantId) async {
    try {
      final result = await _repository.removeFavorite(restaurantId);
      return result.fold(
        (failure) => false,
        (success) {
          if (success) {
            // Atualiza o estado local imediatamente
            final currentFavorites = state.value ?? [];
            final updatedFavorites = currentFavorites
                .where((fav) => fav.restaurantId != restaurantId)
                .toList();
            state = AsyncValue.data(updatedFavorites);
            _saveFavoritesToLocal();
            
            // Recarregar favoritos do servidor para garantir sincronização
            loadFavorites();
          }
          return success;
        },
      );
    } catch (error) {
      return false;
    }
  }
  
  /// Alterna o status de favorito de um restaurante
  Future<bool> toggleFavorite(RestaurantModel restaurant) async {
    final currentFavorites = state.value ?? [];
    final isFavorite = currentFavorites.any((fav) => fav.restaurantId == restaurant.id);
    
    if (isFavorite) {
      return await removeFavorite(restaurant.id);
    } else {
      return await addFavorite(restaurant);
    }
  }
  
  /// Verifica se um restaurante é favorito
  bool isFavorite(String restaurantId) {
    final favorites = state.value ?? [];
    return favorites.any((fav) => fav.restaurantId == restaurantId);
  }
  
  /// Busca favoritos por categoria
  Future<void> loadFavoritesByCategory(String category) async {
    try {
      state = const AsyncValue.loading();
      // Por enquanto, carrega todos e filtra localmente
      await loadFavorites();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Busca favoritos próximos
  Future<void> loadNearbyFavorites(double latitude, double longitude, {double radiusKm = 10.0}) async {
    try {
      state = const AsyncValue.loading();
      final result = await _repository.getNearbyFavorites(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (restaurants) {
          // Converter Restaurant para FavoriteModel
          final favorites = restaurants.map((restaurant) => FavoriteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'current_user',
            restaurantId: restaurant.id,
            createdAt: DateTime.now(),
            restaurant: restaurant,
          )).toList();
          state = AsyncValue.data(favorites);
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Sincroniza favoritos com o servidor
  Future<void> syncFavorites() async {
    try {
      // Recarregar favoritos
      await loadFavorites();
      await loadFavorites(); // Recarrega após sincronização
    } catch (error) {
      // Falha silenciosa na sincronização
    }
  }
  
  /// Limpa todos os favoritos
  Future<bool> clearAllFavorites() async {
    try {
      final favorites = state.value ?? [];
      bool allSuccess = true;
      
      for (final favorite in favorites) {
        final result = await _repository.removeFavorite(favorite.restaurantId);
        final success = result.fold(
          (failure) => false,
          (success) => success,
        );
        if (!success) allSuccess = false;
      }
      
      if (allSuccess) {
        state = const AsyncValue.data([]);
      }
      
      return allSuccess;
    } catch (error) {
      return false;
    }
  }
  
  /// Exporta favoritos
  Future<Map<String, dynamic>?> exportFavorites() async {
    try {
      final result = await _repository.exportFavorites();
      return result.fold(
        (failure) => null,
        (data) => data,
      );
    } catch (error) {
      return null;
    }
  }
  
  /// Importa favoritos
  Future<bool> importFavorites(Map<String, dynamic> data) async {
    try {
      final result = await _repository.importFavorites(data: data);
      final success = result.fold(
        (failure) => false,
        (success) => success,
      );
      if (!success) return false;
      await loadFavorites(); // Recarrega após importação
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Carrega favoritos do armazenamento local primeiro
  Future<void> _loadFromLocalFirst() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString(_localFavoritesKey);
      
      if (localData != null) {
        final List<dynamic> favoritesJson = jsonDecode(localData);
        final favorites = favoritesJson
            .map((json) => FavoriteModel.fromJson(json))
            .toList();
        state = AsyncValue.data(favorites);
      }
    } catch (e) {
      debugPrint('Erro ao carregar favoritos locais: $e');
    }
    
    // Depois tenta carregar do servidor
    loadFavorites();
  }

  /// Salva favoritos no armazenamento local
  Future<void> _saveFavoritesToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = state.value ?? [];
      final favoritesJson = favorites.map((fav) => fav.toJson()).toList();
      await prefs.setString(_localFavoritesKey, jsonEncode(favoritesJson));
    } catch (e) {
      debugPrint('Erro ao salvar favoritos localmente: $e');
    }
  }
}

/// Provider para contagem de favoritos
final favoritesCountProvider = Provider<int>((ref) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.when(
    data: (favorites) => favorites.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para categorias de favoritos
final favoritesCategoriesProvider = Provider<List<String>>((ref) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.when(
    data: (favorites) {
      final categories = favorites
          .map((fav) => fav.restaurant?.categoryId ?? 'Outros')
          .toSet()
          .toList();
      categories.sort();
      return ['Todos', ...categories];
    },
    loading: () => ['Todos'],
    error: (_, __) => ['Todos'],
  );
});

/// Provider para favoritos recentes (últimos 5)
final recentFavoritesProvider = Provider<List<FavoriteModel>>((ref) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.when(
    data: (favorites) {
      final sortedFavorites = List<FavoriteModel>.from(favorites)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sortedFavorites.take(5).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
