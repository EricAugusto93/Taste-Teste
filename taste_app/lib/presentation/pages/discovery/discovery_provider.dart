import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../core/di/injection_container.dart';

// Estados da página de descoberta
class DiscoveryState {
  final bool isLoading;
  final List<RestaurantModel> restaurants;
  final CategoryModel? category;
  final Position? userLocation;
  final String? error;
  final bool hasLocationPermission;

  const DiscoveryState({
    this.isLoading = false,
    this.restaurants = const [],
    this.category,
    this.userLocation,
    this.error,
    this.hasLocationPermission = false,
  });

  DiscoveryState copyWith({
    bool? isLoading,
    List<RestaurantModel>? restaurants,
    CategoryModel? category,
    Position? userLocation,
    String? error,
    bool? hasLocationPermission,
  }) {
    return DiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      category: category ?? this.category,
      userLocation: userLocation ?? this.userLocation,
      error: error ?? this.error,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}

// Provider para o estado da descoberta
class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final RestaurantRepository _restaurantRepository;
  final CategoryRepository _categoryRepository;
  final LocationService _locationService;
  final String categoryId;

  DiscoveryNotifier(
    this._restaurantRepository,
    this._categoryRepository,
    this._locationService,
    this.categoryId,
  ) : super(const DiscoveryState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Carrega a categoria
      final category = await _categoryRepository.getCategoryById(categoryId);
      
      // Verifica permissões de localização
      final hasPermission = await _locationService.hasLocationPermission();
      
      state = state.copyWith(
        category: category,
        hasLocationPermission: hasPermission,
      );

      // Obtém localização do usuário
      await _getUserLocation();
      
      // Carrega restaurantes
      await _loadRestaurants();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados: $e',
      );
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        state = state.copyWith(
          userLocation: position,
          hasLocationPermission: true,
        );
      } else {
        state = state.copyWith(
          error: 'Não foi possível obter sua localização',
          hasLocationPermission: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao obter localização: $e',
        hasLocationPermission: false,
      );
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      // Carrega todos os restaurantes
      final allRestaurants = await _restaurantRepository.getRestaurants();
      
      // Filtra por categoria (exceto para 'todos')
      List<RestaurantModel> categoryRestaurants;
      if (categoryId == 'todos') {
        // Para 'todos', mostra restaurantes de todas as categorias
        categoryRestaurants = allRestaurants;
      } else {
        // Para categoria específica, filtra por categoryId
        categoryRestaurants = allRestaurants
            .where((restaurant) => restaurant.categoryId == categoryId)
            .toList();
      }

      // Se temos localização do usuário, filtra por raio de 10km
      List<RestaurantModel> filteredRestaurants = categoryRestaurants;
      
      if (state.userLocation != null) {
        final userLat = state.userLocation!.latitude;
        final userLng = state.userLocation!.longitude;
        const radiusInMeters = 10000.0; // 10km

        filteredRestaurants = categoryRestaurants.where((restaurant) {
          return _locationService.isWithinRadius(
            userLat,
            userLng,
            restaurant.latitude ?? 0.0,
            restaurant.longitude ?? 0.0,
            radiusInMeters,
          );
        }).toList();

        // Ordena por distância (mais próximos primeiro)
        filteredRestaurants.sort((a, b) {
          final distanceA = _locationService.calculateDistance(
            userLat, userLng, a.latitude ?? 0.0, a.longitude ?? 0.0,
          );
          final distanceB = _locationService.calculateDistance(
            userLat, userLng, b.latitude ?? 0.0, b.longitude ?? 0.0,
          );
          return distanceA.compareTo(distanceB);
        });
      }

      state = state.copyWith(
        restaurants: filteredRestaurants,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar restaurantes: $e',
      );
    }
  }

  Future<void> requestLocationPermission() async {
    final granted = await _locationService.requestLocationPermission();
    if (granted) {
      await _getUserLocation();
      await _loadRestaurants();
    } else {
      state = state.copyWith(
        error: 'Permissão de localização é necessária para encontrar restaurantes próximos',
        hasLocationPermission: false,
      );
    }
  }

  Future<void> retry() async {
    await _initialize();
  }

  double? getDistanceToRestaurant(RestaurantModel restaurant) {
    if (state.userLocation == null) return null;
    
    final distance = _locationService.calculateDistance(
      state.userLocation!.latitude,
      state.userLocation!.longitude,
      restaurant.latitude ?? 0.0,
      restaurant.longitude ?? 0.0,
    );
    
    return _locationService.metersToKilometers(distance);
  }
}

// Provider factory
final discoveryProvider = StateNotifierProvider.family<DiscoveryNotifier, DiscoveryState, String>(
  (ref, categoryId) {
    return DiscoveryNotifier(
      getIt<RestaurantRepository>(),
      getIt<CategoryRepository>(),
      getIt<LocationService>(),
      categoryId,
    );
  },
);
