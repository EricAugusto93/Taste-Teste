import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../core/utils/logger.dart';
import 'location_provider.dart';

/// Estado dos restaurantes
class RestaurantState {
  final List<RestaurantModel> restaurants;
  final List<RestaurantModel> nearbyRestaurants;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const RestaurantState({
    this.restaurants = const [],
    this.nearbyRestaurants = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  bool get hasError => error != null;

  RestaurantState copyWith({
    List<RestaurantModel>? restaurants,
    List<RestaurantModel>? nearbyRestaurants,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return RestaurantState(
      restaurants: restaurants ?? this.restaurants,
      nearbyRestaurants: nearbyRestaurants ?? this.nearbyRestaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// Notifier para gerenciar o estado dos restaurantes
class RestaurantNotifier extends StateNotifier<RestaurantState> {
  final RestaurantRepository _repository;
  final Ref _ref;

  RestaurantNotifier(this._repository, this._ref) : super(const RestaurantState()) {
    loadRestaurants();
  }

  /// Carrega todos os restaurantes
  Future<void> loadRestaurants() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      Logger.info('RestaurantProvider: Carregando restaurantes');
      final restaurants = await _repository.getRestaurants();
      
      Logger.info('RestaurantProvider: ${restaurants.length} restaurantes carregados');
      state = state.copyWith(
        restaurants: restaurants,
        isLoading: false,
      );

      // Atualiza restaurantes próximos se tiver localização
      await _updateNearbyRestaurants();
    } catch (e) {
      Logger.error('RestaurantProvider: Erro ao carregar restaurantes: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar restaurantes: $e',
      );
    }
  }

  /// Carrega restaurantes por categoria
  Future<void> loadRestaurantsByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, error: null, selectedCategory: categoryId);

    try {
      Logger.info('RestaurantProvider: Carregando restaurantes da categoria: $categoryId');
      final restaurants = await _repository.getRestaurants(category: categoryId);
      
      Logger.info('RestaurantProvider: ${restaurants.length} restaurantes carregados para categoria');
      state = state.copyWith(
        restaurants: restaurants,
        isLoading: false,
      );
    } catch (e) {
      Logger.error('RestaurantProvider: Erro ao carregar restaurantes por categoria: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar restaurantes por categoria: $e',
      );
    }
  }

  /// Atualiza restaurantes próximos baseado na localização atual
  Future<void> _updateNearbyRestaurants() async {
    final locationState = _ref.read(locationProvider);
    
    if (locationState.currentLocation == null) {
      Logger.info('RestaurantProvider: Sem localização disponível para calcular proximidade');
      return;
    }

    try {
      final userLocation = locationState.currentLocation!;
      final restaurantsWithDistance = await _repository.getNearbyRestaurants(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        radiusKm: 10, // 10km de raio
      );

      Logger.info('RestaurantProvider: ${restaurantsWithDistance.length} restaurantes próximos encontrados');
      state = state.copyWith(nearbyRestaurants: restaurantsWithDistance);
    } catch (e) {
      Logger.error('RestaurantProvider: Erro ao calcular restaurantes próximos: $e');
    }
  }

  /// Busca restaurante por ID
  RestaurantModel? getRestaurantById(String id) {
    try {
      return state.restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Busca restaurantes por nome
  List<RestaurantModel> searchRestaurants(String query) {
    if (query.isEmpty) return state.restaurants;
    
    return state.restaurants
        .where((restaurant) => 
          restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
          restaurant.description?.toLowerCase().contains(query.toLowerCase()) == true)
        .toList();
  }

  /// Filtra restaurantes por rating
  List<RestaurantModel> filterByRating(double minRating) {
    return state.restaurants
        .where((restaurant) => restaurant.rating >= minRating)
        .toList();
  }

  /// Filtra restaurantes abertos
  List<RestaurantModel> getOpenRestaurants() {
    return state.restaurants
        .where((restaurant) => restaurant.isOpen)
        .toList();
  }

  /// Filtra restaurantes em destaque
  List<RestaurantModel> getFeaturedRestaurants() {
    return state.restaurants
        .where((restaurant) => restaurant.isFeatured)
        .toList();
  }

  /// Atualiza localização e recalcula proximidade
  Future<void> updateLocation(LocationModel location) async {
    await _updateNearbyRestaurants();
  }

  /// Recarrega os restaurantes
  Future<void> refresh() async {
    if (state.selectedCategory != null) {
      await loadRestaurantsByCategory(state.selectedCategory!);
    } else {
      await loadRestaurants();
    }
  }

  /// Limpa o filtro de categoria
  Future<void> clearCategoryFilter() async {
    state = state.copyWith(selectedCategory: null);
    await loadRestaurants();
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider para o repositório de restaurantes
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return getIt<RestaurantRepository>();
});

/// Provider para o estado dos restaurantes
final restaurantProvider = StateNotifierProvider<RestaurantNotifier, RestaurantState>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  return RestaurantNotifier(repository, ref);
});

/// Provider para restaurantes próximos (baseado na localização)
final nearbyRestaurantsProvider = Provider<List<RestaurantModel>>((ref) {
  final restaurantState = ref.watch(restaurantProvider);
  return restaurantState.nearbyRestaurants;
});

/// Provider para restaurantes abertos
final openRestaurantsProvider = Provider<List<RestaurantModel>>((ref) {
  final restaurantState = ref.watch(restaurantProvider);
  return restaurantState.restaurants.where((r) => r.isOpen).toList();
});

/// Provider para restaurantes em destaque
final featuredRestaurantsProvider = Provider<List<RestaurantModel>>((ref) {
  final restaurantState = ref.watch(restaurantProvider);
  return restaurantState.restaurants.where((r) => r.isFeatured).toList();
});

/// Provider para buscar restaurante por ID
final restaurantByIdProvider = Provider.family<RestaurantModel?, String>((ref, id) {
  final restaurantState = ref.watch(restaurantProvider);
  try {
    return restaurantState.restaurants.firstWhere((restaurant) => restaurant.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider para busca de restaurantes
final searchRestaurantsProvider = Provider.family<List<RestaurantModel>, String>((ref, query) {
  final restaurantState = ref.watch(restaurantProvider);
  if (query.isEmpty) return restaurantState.restaurants;
  
  return restaurantState.restaurants
      .where((restaurant) => 
        restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
        restaurant.description?.toLowerCase().contains(query.toLowerCase()) == true)
      .toList();
});

/// Provider para filtrar por rating
final restaurantsByRatingProvider = Provider.family<List<RestaurantModel>, double>((ref, minRating) {
  final restaurantState = ref.watch(restaurantProvider);
  return restaurantState.restaurants
      .where((restaurant) => restaurant.rating >= minRating)
      .toList();
});
