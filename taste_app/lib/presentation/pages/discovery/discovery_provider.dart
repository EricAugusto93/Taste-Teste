import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/services/location/location_service.dart';
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
        debugPrint('📍 Discovery: Localização real obtida: ${position.latitude}, ${position.longitude}');
        state = state.copyWith(
          userLocation: position,
          hasLocationPermission: true,
        );
      } else {
        debugPrint('⚠️ Discovery: Não foi possível obter localização real do usuário');
        // Não usa localização falsa - deixa null para indicar que localização é necessária
        state = state.copyWith(
          userLocation: null,
          hasLocationPermission: false, // Indica que não tem permissão ou falha
        );
      }
    } catch (e) {
      debugPrint('❌ Discovery: Erro ao obter localização: $e');
      // Não usa fallback falso - deixa null para indicar que localização é necessária
      state = state.copyWith(
        userLocation: null,
        hasLocationPermission: false,
      );
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      debugPrint('🔍 Discovery: Carregando restaurantes para categoria: $categoryId');
      
      // Carrega todos os restaurantes com retry
      final allRestaurants = await _restaurantRepository.getRestaurants();
      debugPrint('📊 Discovery: ${allRestaurants.length} restaurantes carregados do banco');
      
      // Se não conseguiu carregar restaurantes, tenta novamente uma vez
      if (allRestaurants.isEmpty) {
        debugPrint('⚠️ Discovery: Lista vazia, tentando novamente em 2 segundos...');
        await Future.delayed(const Duration(seconds: 2));
        final retryRestaurants = await _restaurantRepository.getRestaurants();
        debugPrint('🔄 Discovery: Segunda tentativa: ${retryRestaurants.length} restaurantes');
        
        if (retryRestaurants.isEmpty) {
          debugPrint('❌ Discovery: Ainda sem restaurantes, mas continuando sem erro');
          state = state.copyWith(
            restaurants: [],
            isLoading: false,
          );
          return;
        }
      }
      
      // Debug: mostra alguns restaurantes com coordenadas
      if (allRestaurants.isNotEmpty) {
        for (int i = 0; i < (allRestaurants.length > 3 ? 3 : allRestaurants.length); i++) {
          final r = allRestaurants[i];
          debugPrint('🏪 Restaurante ${i + 1}: ${r.name} - categoryId: ${r.categoryId} - Coords: ${r.latitude}, ${r.longitude}');
        }
      }
      
      // Filtra restaurantes por categoria específica
      List<RestaurantModel> categoryRestaurants;
      
      if (categoryId == 'todos') {
        categoryRestaurants = allRestaurants;
        debugPrint('📋 Discovery: Mostrando TODOS os restaurantes (${categoryRestaurants.length})');
      } else {
        categoryRestaurants = allRestaurants
            .where((restaurant) => restaurant.categoryId == categoryId)
            .toList();
        debugPrint('📋 Discovery: Filtrando por categoria $categoryId: ${categoryRestaurants.length} restaurantes encontrados');
      }

      // Se temos localização do usuário, filtra por raio (com aumento progressivo)
      List<RestaurantModel> filteredRestaurants = categoryRestaurants;
      
      if (state.userLocation != null) {
        final userLat = state.userLocation!.latitude;
        final userLng = state.userLocation!.longitude;
        
        // Tenta diferentes raios até encontrar restaurantes
        const radiusOptions = [5000.0, 10000.0, 15000.0, 20000.0, 50000.0]; // 5km, 10km, 15km, 20km, 50km
        
        for (final radiusInMeters in radiusOptions) {
          filteredRestaurants = categoryRestaurants.where((restaurant) {
            return _locationService.isWithinRadius(
              userLat,
              userLng,
              restaurant.latitude ?? 0.0,
              restaurant.longitude ?? 0.0,
              radiusInMeters,
            );
          }).toList();
          
          debugPrint('📍 Discovery: Localização real do usuário: $userLat, $userLng (raio: ${(radiusInMeters/1000).toInt()}km)');
          debugPrint('🗺️ Discovery: Com raio de ${(radiusInMeters/1000).toInt()}km: ${filteredRestaurants.length} restaurantes');
          
          // Se encontrou restaurantes, para de procurar
          if (filteredRestaurants.isNotEmpty) break;
        }
        
        // Se ainda não encontrou nada, mostra todos os restaurantes da categoria
        if (filteredRestaurants.isEmpty) {
          debugPrint('⚠️ Discovery: Nenhum restaurante próximo encontrado, mostrando todos da categoria');
          filteredRestaurants = categoryRestaurants;
        }

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
      } else {
        debugPrint('⚠️ Discovery: Sem localização real do usuário, mostrando todos os restaurantes da categoria ordenados por nome');
        // Ordena por nome quando não há localização
        filteredRestaurants.sort((a, b) => a.name.compareTo(b.name));
      }

      debugPrint('✅ Discovery: Total final de restaurantes: ${filteredRestaurants.length}');
      
      state = state.copyWith(
        restaurants: filteredRestaurants,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Discovery: Erro ao carregar restaurantes: $e');
      debugPrint('❌ Discovery: Stack trace: ${StackTrace.current}');
      
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
