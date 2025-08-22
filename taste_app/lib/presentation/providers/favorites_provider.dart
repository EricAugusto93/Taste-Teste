import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/favorite_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/services/favorites_sync_service.dart';
import '../../data/services/favorites_service.dart';
import '../../data/services/offline_favorites_service.dart';
import '../../data/services/auth_service.dart';

/// Provider para o repositório de favoritos
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final supabaseClient = Supabase.instance.client;
  final favoritesService = FavoritesService.instance;
  final offlineService = OfflineFavoritesService();
  final syncService = FavoritesSyncService(
    favoritesService: favoritesService,
    offlineService: offlineService,
  );
  
  return FavoritesRepositoryImpl(
    supabaseClient,
    syncService: syncService,
  );
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
    recentFavorites: statsMap['recent_count'] as int? ?? 0,
    mostFavoritedCategory: statsMap['top_category'] as String?,
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
  final FavoritesRepository _repository;
  
  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFavorites();
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
      final result = await _repository.addToFavorites(restaurantId: restaurant.id);
      return result.fold(
        (failure) => false,
        (success) {
          if (success) {
            // Atualiza o estado local
            state.whenData((favorites) {
              final newFavorite = FavoriteModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: AuthService.instance.userId ?? 'anonymous', // TODO: Obter do auth
                restaurantId: restaurant.id,
                createdAt: DateTime.now(),
                restaurant: restaurant.toEntity(),
              );
              state = AsyncValue.data([...favorites, newFavorite]);
            });
          }
          return success;
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
            // Atualiza o estado local
            state.whenData((favorites) {
              final updatedFavorites = favorites
                  .where((fav) => fav.restaurantId != restaurantId)
                  .toList();
              state = AsyncValue.data(updatedFavorites);
            });
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
      // Usar o serviço de sincronização do repositório
      if (_repository is FavoritesRepositoryImpl) {
        final repo = _repository as FavoritesRepositoryImpl;
        final userId = AuthService.instance.userId;
        if (userId != null) {
          await repo.syncService.performFullSync(userId);
        }
      }
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