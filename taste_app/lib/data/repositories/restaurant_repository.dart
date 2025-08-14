import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/restaurant_model.dart';
import '../../core/config/supabase_config.dart';
import '../../core/services/cache_service.dart';
import '../../core/models/cache_item.dart';
import '../../core/di/injection_container.dart';

/// Extensão para conversão de graus para radianos
extension on double {
  double degreesToRadians() => this * (math.pi / 180);
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}

/// Repositório para operações com restaurantes
class RestaurantRepository {
  final CacheService _cacheService = InjectionContainer.get<CacheService>();

  /// Dados mock de restaurantes para demonstração
  List<RestaurantModel> get _mockRestaurants => [
    RestaurantModel(
      id: 'mock_1',
      name: 'Pizzaria Bella Napoli',
      description: 'Autêntica pizza italiana com massa artesanal e ingredientes frescos importados diretamente da Itália.',
      categoryId: 'pizza',
      category: 'Pizza',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
      rating: 4.8,
      reviewCount: 342,
      deliveryTime: '25-35 min',
      deliveryFee: 4.99,
      minOrderValue: 25.0,
      hasPromotion: true,
      priceRange: '\$\$',
      latitude: -23.5505,
      longitude: -46.6333,
      address: 'Rua Augusta, 1234 - Consolação, São Paulo - SP',
      phone: '(11) 3456-7890',
      isOpen: true,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_2',
      name: 'Burger House Premium',
      description: 'Os melhores hambúrguers artesanais da cidade com carne angus e pães brioche fresquinhos.',
      categoryId: 'burger',
      category: 'Hambúrguer',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      rating: 4.6,
      reviewCount: 198,
      deliveryTime: '30-40 min',
      deliveryFee: 5.99,
      minOrderValue: 20.0,
      hasPromotion: false,
      priceRange: '\$\$\$',
      latitude: -23.5489,
      longitude: -46.6388,
      address: 'Av. Paulista, 567 - Bela Vista, São Paulo - SP',
      phone: '(11) 2345-6789',
      isOpen: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_3',
      name: 'Sushi Zen',
      description: 'Culinária japonesa tradicional com peixes frescos e técnicas milenares dos mestres sushimen.',
      categoryId: 'japanese',
      category: 'Japonesa',
      imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
      rating: 4.9,
      reviewCount: 456,
      deliveryTime: '35-45 min',
      deliveryFee: 6.99,
      minOrderValue: 35.0,
      hasPromotion: true,
      priceRange: '\$\$\$\$',
      latitude: -23.5558,
      longitude: -46.6396,
      address: 'Rua Oscar Freire, 890 - Jardins, São Paulo - SP',
      phone: '(11) 3789-0123',
      isOpen: true,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_4',
      name: 'Café Central',
      description: 'Café especial com grãos selecionados, doces artesanais e ambiente aconchegante para relaxar.',
      categoryId: 'coffee',
      category: 'Café',
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
      rating: 4.4,
      reviewCount: 89,
      deliveryTime: '15-25 min',
      deliveryFee: 3.99,
      minOrderValue: 15.0,
      hasPromotion: false,
      priceRange: '\$\$',
      latitude: -23.5475,
      longitude: -46.6361,
      address: 'Rua da Consolação, 456 - Centro, São Paulo - SP',
      phone: '(11) 4567-8901',
      isOpen: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_5',
      name: 'Doce Tentação',
      description: 'Sobremesas irresistíveis, bolos artesanais e doces gourmet para adoçar seu dia.',
      categoryId: 'dessert',
      category: 'Sobremesa',
      imageUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400',
      rating: 4.7,
      reviewCount: 234,
      deliveryTime: '20-30 min',
      deliveryFee: 4.50,
      minOrderValue: 18.0,
      hasPromotion: true,
      priceRange: '\$\$',
      latitude: -23.5520,
      longitude: -46.6344,
      address: 'Rua Haddock Lobo, 321 - Cerqueira César, São Paulo - SP',
      phone: '(11) 5678-9012',
      isOpen: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_6',
      name: 'Green Life',
      description: 'Alimentação saudável e natural com pratos veganos, vegetarianos e opções sem glúten.',
      categoryId: 'healthy',
      category: 'Saudável',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      rating: 4.5,
      reviewCount: 167,
      deliveryTime: '25-35 min',
      deliveryFee: 5.50,
      minOrderValue: 22.0,
      hasPromotion: false,
      priceRange: '\$\$\$',
      latitude: -23.5543,
      longitude: -46.6407,
      address: 'Av. Rebouças, 789 - Pinheiros, São Paulo - SP',
      phone: '(11) 6789-0123',
      isOpen: true,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_7',
      name: 'Pizzaria Margherita',
      description: 'Pizza napoletana tradicional com forno a lenha e ingredientes selecionados.',
      categoryId: 'pizza',
      category: 'Pizza',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
      rating: 4.6,
      reviewCount: 278,
      deliveryTime: '20-30 min',
      deliveryFee: 3.99,
      minOrderValue: 20.0,
      hasPromotion: false,
      priceRange: '\$\$',
      latitude: -23.5612,
      longitude: -46.6556,
      address: 'Rua Teodoro Sampaio, 1122 - Pinheiros, São Paulo - SP',
      phone: '(11) 7890-1234',
      isOpen: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_8',
      name: 'Smash Burger Co.',
      description: 'Hambúrguers smash com blend especial e batatas rústicas crocantes.',
      categoryId: 'burger',
      category: 'Hambúrguer',
      imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
      rating: 4.4,
      reviewCount: 156,
      deliveryTime: '25-35 min',
      deliveryFee: 4.50,
      minOrderValue: 18.0,
      hasPromotion: true,
      priceRange: '\$\$',
      latitude: -23.5634,
      longitude: -46.6527,
      address: 'Av. Faria Lima, 2233 - Itaim Bibi, São Paulo - SP',
      phone: '(11) 8901-2345',
      isOpen: true,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_9',
      name: 'Ramen House',
      description: 'Autêntico ramen japonês com caldo preparado por 24 horas e ingredientes frescos.',
      categoryId: 'japanese',
      category: 'Japonesa',
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
      rating: 4.7,
      reviewCount: 312,
      deliveryTime: '30-40 min',
      deliveryFee: 5.99,
      minOrderValue: 28.0,
      hasPromotion: false,
      priceRange: '\$\$\$',
      latitude: -23.5467,
      longitude: -46.6445,
      address: 'Rua da Liberdade, 567 - Liberdade, São Paulo - SP',
      phone: '(11) 9012-3456',
      isOpen: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_10',
      name: 'Café Bourbon',
      description: 'Café especial com grãos premium, torrados artesanalmente e doces franceses.',
      categoryId: 'coffee',
      category: 'Café',
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
      rating: 4.5,
      reviewCount: 145,
      deliveryTime: '10-20 min',
      deliveryFee: 2.99,
      minOrderValue: 12.0,
      hasPromotion: true,
      priceRange: '\$\$',
      latitude: -23.5578,
      longitude: -46.6589,
      address: 'Rua Bela Cintra, 789 - Consolação, São Paulo - SP',
      phone: '(11) 0123-4567',
      isOpen: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_11',
      name: 'Açaí & Cia',
      description: 'Açaí natural com frutas frescas, granola caseira e opções veganas.',
      categoryId: 'healthy',
      category: 'Saudável',
      imageUrl: 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400',
      rating: 4.3,
      reviewCount: 98,
      deliveryTime: '15-25 min',
      deliveryFee: 3.50,
      minOrderValue: 15.0,
      hasPromotion: false,
      priceRange: '\$\$',
      latitude: -23.5523,
      longitude: -46.6378,
      address: 'Av. Ipiranga, 1456 - República, São Paulo - SP',
      phone: '(11) 1234-5678',
      isOpen: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    RestaurantModel(
      id: 'mock_12',
      name: 'Gelato Italiano',
      description: 'Gelatos artesanais com receitas tradicionais italianas e sabores únicos.',
      categoryId: 'dessert',
      category: 'Sobremesa',
      imageUrl: 'https://images.unsplash.com/photo-1488900128323-21503983a07e?w=400',
      rating: 4.8,
      reviewCount: 189,
      deliveryTime: '20-30 min',
      deliveryFee: 4.99,
      minOrderValue: 16.0,
      hasPromotion: true,
      priceRange: '\$\$',
      latitude: -23.5445,
      longitude: -46.6412,
      address: 'Rua Augusta, 2567 - Jardins, São Paulo - SP',
      phone: '(11) 2345-6789',
      isOpen: true,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now(),
    ),
  ];

  /// Busca restaurantes com filtros opcionais
  Future<List<RestaurantModel>> getRestaurants({
    String? categoryId,
    bool? isFeatured,
    bool? isOpen,
    int? limit,
  }) async {
    try {
      // Gerar chave de cache baseada nos parâmetros
      final cacheKey = 'restaurants_${categoryId ?? 'all'}_${isFeatured ?? 'any'}_${isOpen ?? 'any'}_${limit ?? 50}';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        return cachedData.map((json) => RestaurantModel.fromJson(json)).toList();
      }

      var query = SupabaseDatabase.restaurants.select();

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }
      if (isOpen != null) {
        query = query.eq('is_open', isOpen);
      }
      
      final response = await query
          .order('rating', ascending: false)
          .limit(limit ?? 50);
          
      final restaurants = (response as List<Map<String, dynamic>>)
          .map((data) => RestaurantModel.fromSupabase(data))
          .toList();
      
      // Se não há dados reais, usar dados mock
      if (restaurants.isEmpty) {
        var mockData = _mockRestaurants;
        
        // Aplicar filtros aos dados mock
        if (categoryId != null) {
          mockData = mockData.where((r) => r.categoryId == categoryId).toList();
        }
        if (isFeatured != null) {
          mockData = mockData.where((r) => r.isFeatured == isFeatured).toList();
        }
        if (isOpen != null) {
          mockData = mockData.where((r) => r.isOpen == isOpen).toList();
        }
        
        // Aplicar limite
        if (limit != null && mockData.length > limit) {
          mockData = mockData.take(limit).toList();
        }
        
        return mockData;
      }
      
      // Salvar no cache
      final rawData = restaurants.map((r) => r.toJson()).toList();
      await _cacheService.set(cacheKey, rawData, dataType: CacheDataType.restaurant);
      
      return restaurants;
    } catch (e) {
      debugPrint('Erro ao buscar restaurantes: $e');
      // Em caso de erro, retornar dados mock
      var mockData = _mockRestaurants;
      
      // Aplicar filtros aos dados mock
      if (categoryId != null) {
        mockData = mockData.where((r) => r.categoryId == categoryId).toList();
      }
      if (isFeatured != null) {
        mockData = mockData.where((r) => r.isFeatured == isFeatured).toList();
      }
      if (isOpen != null) {
        mockData = mockData.where((r) => r.isOpen == isOpen).toList();
      }
      
      // Aplicar limite
      if (limit != null && mockData.length > limit) {
        mockData = mockData.take(limit).toList();
      }
      
      return mockData;
    }
  }

  /// Busca restaurantes em destaque
  Future<List<RestaurantModel>> getFeaturedRestaurants({int limit = 10}) async {
    return getRestaurants(isFeatured: true, limit: limit);
  }

  /// Busca restaurantes próximos com geolocalização real
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      // Buscar todos os restaurantes abertos
      final restaurants = await getRestaurants(isOpen: true, limit: 100);
      
      // Filtrar por distância e calcular distância real
      final nearbyRestaurants = <RestaurantModel>[];
      
      for (final restaurant in restaurants) {
        if (restaurant.latitude != null && restaurant.longitude != null) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            restaurant.latitude!,
            restaurant.longitude!,
          );
          
          if (distance <= radiusKm) {
            nearbyRestaurants.add(restaurant.copyWith(distance: distance));
          }
        }
      }
      
      // Ordenar por distância
      nearbyRestaurants.sort((a, b) {
        final distanceA = a.distance ?? 0;
        final distanceB = b.distance ?? 0;
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyRestaurants.take(limit).toList();
    } catch (e) {
      debugPrint('Erro ao buscar restaurantes próximos: $e');
      // Em caso de erro, usar dados mock próximos
      final nearbyRestaurants = <RestaurantModel>[];
      
      for (final restaurant in _mockRestaurants) {
        if (restaurant.latitude != null && restaurant.longitude != null && restaurant.isOpen) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            restaurant.latitude!,
            restaurant.longitude!,
          );
          
          if (distance <= radiusKm) {
            nearbyRestaurants.add(restaurant.copyWith(distance: distance));
          }
        }
      }
      
      // Ordenar por distância
      nearbyRestaurants.sort((a, b) {
        final distanceA = a.distance ?? 0;
        final distanceB = b.distance ?? 0;
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyRestaurants.take(limit).toList();
    }
  }

  /// Busca um restaurante por ID
  Future<RestaurantModel?> getRestaurantById(String id) async {
    try {
      // Tentar buscar do cache primeiro
      final cacheKey = 'restaurant_$id';
      final cachedData = await _cacheService.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        return RestaurantModel.fromJson(cachedData);
      }

      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('id', id)
          .single();

      final restaurant = RestaurantModel.fromSupabase(response);
      
      // Salvar no cache
      await _cacheService.set(cacheKey, restaurant.toJson(), dataType: CacheDataType.restaurant);
      
      return restaurant;
    } catch (e) {
      return null;
    }
  }

  /// Busca restaurantes por termo de pesquisa
  Future<List<RestaurantModel>> searchRestaurants(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return getRestaurants(isOpen: true, limit: 20);
      }

      // Gerar chave de cache para a busca
      final cacheKey = 'search_${searchTerm.toLowerCase().trim()}';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        return cachedData.map((json) => RestaurantModel.fromJson(json)).toList();
      }

      // Busca em múltiplos campos: nome, descrição e tags
      final response = await SupabaseDatabase.restaurants
          .select()
          .or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%,tags.ilike.%$searchTerm%')
          .eq('is_open', true)
          .order('rating', ascending: false)
          .limit(50);

      final restaurants = (response as List<Map<String, dynamic>>)
          .map((data) => RestaurantModel.fromSupabase(data))
          .toList();
      
      // Se não há dados reais, buscar nos dados mock
      if (restaurants.isEmpty) {
        final searchTermLower = searchTerm.toLowerCase();
        final mockResults = _mockRestaurants.where((restaurant) {
          return restaurant.isOpen &&
              (restaurant.name.toLowerCase().contains(searchTermLower) ||
               (restaurant.description?.toLowerCase().contains(searchTermLower) ?? false) ||
               restaurant.category.toLowerCase().contains(searchTermLower));
        }).toList();
        
        // Ordenar por rating
        mockResults.sort((a, b) => b.rating.compareTo(a.rating));
        
        return mockResults;
      }
      
      // Salvar no cache com TTL menor para buscas
      final rawData = restaurants.map((r) => r.toJson()).toList();
      await _cacheService.set(cacheKey, rawData, dataType: CacheDataType.search);
      
      return restaurants;
    } catch (e) {
      debugPrint('Erro ao buscar restaurantes: $e');
      // Em caso de erro, buscar nos dados mock
      if (searchTerm.trim().isEmpty) {
        return _mockRestaurants.where((r) => r.isOpen).take(20).toList();
      }
      
      final searchTermLower = searchTerm.toLowerCase();
      final mockResults = _mockRestaurants.where((restaurant) {
        return restaurant.isOpen &&
            (restaurant.name.toLowerCase().contains(searchTermLower) ||
             (restaurant.description?.toLowerCase().contains(searchTermLower) ?? false) ||
             restaurant.category.toLowerCase().contains(searchTermLower));
      }).toList();
      
      // Ordenar por rating
      mockResults.sort((a, b) => b.rating.compareTo(a.rating));
      
      return mockResults;
    }
  }

  /// Busca restaurantes por categoria específica
  Future<List<RestaurantModel>> getRestaurantsByCategory(String categoryId, {int limit = 20}) async {
    try {
      // Gerar chave de cache
      final cacheKey = 'category_${categoryId}_$limit';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        return cachedData.map((json) => RestaurantModel.fromJson(json)).toList();
      }

      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('category_id', categoryId)
          .eq('is_open', true)
          .order('rating', ascending: false)
          .limit(limit);

      final restaurants = (response as List<Map<String, dynamic>>)
          .map((data) => RestaurantModel.fromSupabase(data))
          .toList();
      
      // Salvar no cache
      final rawData = restaurants.map((r) => r.toJson()).toList();
      await _cacheService.set(cacheKey, rawData, dataType: CacheDataType.category);
      
      return restaurants;
    } catch (e) {
      debugPrint('Erro ao buscar restaurantes por categoria: $e');
      return [];
    }
  }

  /// Busca restaurantes próximos por localização e categoria
  Future<List<RestaurantModel>> getRestaurantsByLocation({
    required double latitude,
    required double longitude,
    required String categoryId,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      // Gerar chave de cache
      final cacheKey = 'location_${latitude}_${longitude}_${categoryId}_${radiusKm}_$limit';

      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        return cachedData.map((json) => RestaurantModel.fromJson(json)).toList();
      }

      // Buscar restaurantes da categoria específica
      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('category_id', categoryId)
          .eq('is_open', true)
          .order('rating', ascending: false);

      final allRestaurants = (response as List<Map<String, dynamic>>)
          .map((data) => RestaurantModel.fromSupabase(data))
          .toList();

      // Filtrar por distância
      final nearbyRestaurants = <RestaurantModel>[];

      for (final restaurant in allRestaurants) {
        if (restaurant.latitude != null && restaurant.longitude != null) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            restaurant.latitude!,
            restaurant.longitude!,
          );

          if (distance <= radiusKm) {
            nearbyRestaurants.add(restaurant);
          }
        }
      }

      // Ordenar por distância
      nearbyRestaurants.sort((a, b) {
        final distanceA = _calculateDistance(latitude, longitude, a.latitude!, a.longitude!);
        final distanceB = _calculateDistance(latitude, longitude, b.latitude!, b.longitude!);
        return distanceA.compareTo(distanceB);
      });

      final result = nearbyRestaurants.take(limit).toList();

      // Salvar no cache
      final rawData = result.map((r) => r.toJson()).toList();
      await _cacheService.set(cacheKey, rawData, dataType: CacheDataType.restaurant);

      return result;
    } catch (e) {
      debugPrint('Erro ao buscar restaurantes por localização e categoria: $e');
      return [];
    }
  }

  /// Busca restaurantes com filtros avançados
  Future<List<RestaurantModel>> searchWithFilters({
    String? searchTerm,
    String? categoryId,
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    double? minRating,
    double? maxPrice,
    bool? isOpen,
    int limit = 20,
  }) async {
    try {
      // Gerar chave de cache
      final cacheKey = 'search_filters_${searchTerm ?? ''}_${categoryId ?? ''}_${latitude ?? 0}_${longitude ?? 0}_${radiusKm}_${minRating ?? 0}_${maxPrice ?? 0}_${isOpen ?? true}_$limit';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        return cachedData.map((json) => RestaurantModel.fromJson(json)).toList();
      }

      // Construir query base
      var query = SupabaseDatabase.restaurants.select();
      
      // Aplicar filtros
      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        query = query.or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%,tags.ilike.%$searchTerm%');
      }
      
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      if (isOpen != null) {
        query = query.eq('is_open', isOpen);
      }
      
      if (minRating != null) {
        query = query.gte('rating', minRating);
      }
      
      if (maxPrice != null) {
        query = query.lte('price_range', maxPrice);
      }
      
      final response = await query
          .order('rating', ascending: false)
          .limit(limit * 2); // Buscar mais para filtrar por distância

      final allRestaurants = (response as List<Map<String, dynamic>>)
          .map((data) => RestaurantModel.fromSupabase(data))
          .toList();

      List<RestaurantModel> filteredRestaurants = allRestaurants;

      // Filtrar por distância se localização fornecida
      if (latitude != null && longitude != null) {
        filteredRestaurants = [];
        
        for (final restaurant in allRestaurants) {
          if (restaurant.latitude != null && restaurant.longitude != null) {
            final distance = _calculateDistance(
              latitude,
              longitude,
              restaurant.latitude!,
              restaurant.longitude!,
            );

            if (distance <= radiusKm) {
              filteredRestaurants.add(restaurant);
            }
          }
        }

        // Ordenar por distância
        filteredRestaurants.sort((a, b) {
          final distanceA = _calculateDistance(latitude, longitude, a.latitude!, a.longitude!);
          final distanceB = _calculateDistance(latitude, longitude, b.latitude!, b.longitude!);
          return distanceA.compareTo(distanceB);
        });
      }

      final result = filteredRestaurants.take(limit).toList();
      
      // Salvar no cache
      final rawData = result.map((r) => r.toJson()).toList();
      await _cacheService.set(cacheKey, rawData, dataType: CacheDataType.search);
      
      return result;
    } catch (e) {
      debugPrint('Erro ao buscar restaurantes com filtros: $e');
      return [];
    }
  }

  /// Calcular distância entre dois pontos usando fórmula de Haversine
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Raio da Terra em km
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.degreesToRadians().cos() * lat2.degreesToRadians().cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
