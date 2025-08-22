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
        print('📍 Discovery: Localização obtida: ${position.latitude}, ${position.longitude}');
        state = state.copyWith(
          userLocation: position,
          hasLocationPermission: true,
        );
      } else {
        print('⚠️ Discovery: Não foi possível obter localização, usando Curitiba como padrão');
        // Usa Curitiba como localização padrão se não conseguir obter GPS
        final defaultPosition = Position(
          latitude: -25.4372, // Curitiba
          longitude: -49.2695, // Curitiba
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        state = state.copyWith(
          userLocation: defaultPosition,
          hasLocationPermission: true, // Considera como tendo permissão para não bloquear
        );
      }
    } catch (e) {
      print('❌ Discovery: Erro ao obter localização, usando Curitiba: $e');
      // Em caso de erro, usa Curitiba como fallback
      final defaultPosition = Position(
        latitude: -25.4372, // Curitiba
        longitude: -49.2695, // Curitiba
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      state = state.copyWith(
        userLocation: defaultPosition,
        hasLocationPermission: true,
      );
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      print('🔍 Discovery: Carregando restaurantes para categoria: $categoryId');
      
      // Carrega todos os restaurantes com retry
      final allRestaurants = await _restaurantRepository.getRestaurants();
      print('📊 Discovery: ${allRestaurants.length} restaurantes carregados do banco');
      
      // Se não conseguiu carregar restaurantes, tenta novamente uma vez
      if (allRestaurants.isEmpty) {
        print('⚠️ Discovery: Lista vazia, tentando novamente em 2 segundos...');
        await Future.delayed(const Duration(seconds: 2));
        final retryRestaurants = await _restaurantRepository.getRestaurants();
        print('🔄 Discovery: Segunda tentativa: ${retryRestaurants.length} restaurantes');
        
        if (retryRestaurants.isEmpty) {
          print('❌ Discovery: Ainda sem restaurantes, mas continuando sem erro');
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
          print('🏪 Restaurante ${i + 1}: ${r.name} - categoryId: ${r.categoryId} - Coords: ${r.latitude}, ${r.longitude}');
        }
      }
      
      // Filtra restaurantes por categoria específica
      List<RestaurantModel> categoryRestaurants;
      
      if (categoryId == 'todos') {
        categoryRestaurants = allRestaurants;
        print('📋 Discovery: Mostrando TODOS os restaurantes (${categoryRestaurants.length})');
      } else {
        categoryRestaurants = allRestaurants
            .where((restaurant) => restaurant.categoryId == categoryId)
            .toList();
        print('📋 Discovery: Filtrando por categoria $categoryId: ${categoryRestaurants.length} restaurantes encontrados');
      }

      // Se temos localização do usuário, filtra por raio (com aumento progressivo)
      List<RestaurantModel> filteredRestaurants = categoryRestaurants;
      
      if (state.userLocation != null) {
        final userLat = state.userLocation!.latitude;
        final userLng = state.userLocation!.longitude;
        
        // Tenta diferentes raios até encontrar restaurantes - ajustado para Pinhais
        const radiusOptions = [5000.0, 10000.0, 15000.0, 20000.0]; // 5km, 10km, 15km, 20km
        
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
          
          print('📍 Discovery: Localização do usuário: $userLat, $userLng (raio: ${(radiusInMeters/1000).toInt()}km)');
          print('🗺️ Discovery: Com raio de ${(radiusInMeters/1000).toInt()}km: ${filteredRestaurants.length} restaurantes');
          
          // Se encontrou restaurantes, para de procurar
          if (filteredRestaurants.isNotEmpty) break;
        }
        
        // Se ainda não encontrou nada, mostra todos os restaurantes da categoria
        if (filteredRestaurants.isEmpty) {
          print('⚠️ Discovery: Nenhum restaurante próximo encontrado, mostrando todos da categoria');
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
        print('❌ Discovery: Sem localização do usuário, mostrando todos os restaurantes da categoria');
      }

      print('✅ Discovery: Total final de restaurantes: ${filteredRestaurants.length}');
      
      state = state.copyWith(
        restaurants: filteredRestaurants,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Discovery: Erro ao carregar restaurantes: $e');
      print('❌ Discovery: Stack trace: ${StackTrace.current}');
      
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
