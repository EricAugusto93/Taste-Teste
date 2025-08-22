import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../core/di/injection_container.dart';

/// Estado da HomePage
class HomeState {
  final bool isLoading;
  final Position? userLocation;
  final Map<String, List<RestaurantModel>> restaurantsByCategory;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.userLocation,
    this.restaurantsByCategory = const {},
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    Position? userLocation,
    Map<String, List<RestaurantModel>>? restaurantsByCategory,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      userLocation: userLocation ?? this.userLocation,
      restaurantsByCategory: restaurantsByCategory ?? this.restaurantsByCategory,
      error: error ?? this.error,
    );
  }
}

/// Notifier para a HomePage
class HomeNotifier extends StateNotifier<HomeState> {
  final RestaurantRepository _restaurantRepository;
  final LocationService _locationService;

  HomeNotifier(
    this._restaurantRepository,
    this._locationService,
  ) : super(const HomeState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Obtém localização do usuário
      await _getUserLocation();
      
      // Carrega restaurantes próximos
      await _loadNearbyRestaurants();
    } catch (e) {
      print('❌ HomePage: Erro na inicialização: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados',
      );
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        print('📍 HomePage: Localização obtida: ${position.latitude}, ${position.longitude}');
        state = state.copyWith(userLocation: position);
      } else {
        // Usa Curitiba como localização padrão
        final defaultPosition = Position(
          latitude: -25.4372,
          longitude: -49.2695,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        state = state.copyWith(userLocation: defaultPosition);
      }
    } catch (e) {
      print('❌ HomePage: Erro ao obter localização: $e');
      // Usa Curitiba como fallback
      final defaultPosition = Position(
        latitude: -25.4372,
        longitude: -49.2695,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      state = state.copyWith(userLocation: defaultPosition);
    }
  }

  Future<void> _loadNearbyRestaurants() async {
    try {
      print('🏠 HomePage: Carregando restaurantes próximos...');
      
      final allRestaurants = await _restaurantRepository.getRestaurants();
      print('📊 HomePage: ${allRestaurants.length} restaurantes carregados');
      
      if (state.userLocation == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Filtra restaurantes próximos (50km)
      final userLat = state.userLocation!.latitude;
      final userLng = state.userLocation!.longitude;
      const radiusInMeters = 50000.0; // 50km

      final nearbyRestaurants = allRestaurants.where((restaurant) {
        return _locationService.isWithinRadius(
          userLat,
          userLng,
          restaurant.latitude ?? 0.0,
          restaurant.longitude ?? 0.0,
          radiusInMeters,
        );
      }).toList();

      print('🗺️ HomePage: ${nearbyRestaurants.length} restaurantes próximos encontrados');

      // Agrupa por categoria
      final restaurantsByCategory = <String, List<RestaurantModel>>{};
      
      for (final restaurant in nearbyRestaurants) {
        final categoryId = restaurant.categoryId ?? 'outros';
        if (!restaurantsByCategory.containsKey(categoryId)) {
          restaurantsByCategory[categoryId] = [];
        }
        restaurantsByCategory[categoryId]!.add(restaurant);
      }

      // Ordena por distância dentro de cada categoria
      restaurantsByCategory.forEach((categoryId, restaurants) {
        restaurants.sort((a, b) {
          final distanceA = _locationService.calculateDistance(
            userLat, userLng, a.latitude ?? 0.0, a.longitude ?? 0.0,
          );
          final distanceB = _locationService.calculateDistance(
            userLat, userLng, b.latitude ?? 0.0, b.longitude ?? 0.0,
          );
          return distanceA.compareTo(distanceB);
        });
      });

      print('✅ HomePage: Restaurantes organizados por categoria');
      for (final entry in restaurantsByCategory.entries) {
        print('  ${entry.key}: ${entry.value.length} restaurantes');
      }

      state = state.copyWith(
        restaurantsByCategory: restaurantsByCategory,
        isLoading: false,
      );
    } catch (e) {
      print('❌ HomePage: Erro ao carregar restaurantes: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar restaurantes próximos',
      );
    }
  }

  /// Retorna o restaurante mais próximo de uma categoria específica
  RestaurantModel? getNearestRestaurantByCategory(String categoryId) {
    final restaurants = state.restaurantsByCategory[categoryId];
    return restaurants?.isNotEmpty == true ? restaurants!.first : null;
  }

  /// Retorna o nome do restaurante para exibir no container
  String getRestaurantNameForCategory(String categoryId, String fallbackText) {
    final restaurant = getNearestRestaurantByCategory(categoryId);
    return restaurant?.name ?? fallbackText;
  }
}

/// Provider da HomePage
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) {
    return HomeNotifier(
      getIt<RestaurantRepository>(),
      getIt<LocationService>(),
    );
  },
);