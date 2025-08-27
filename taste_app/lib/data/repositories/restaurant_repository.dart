import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/restaurant_model.dart';
import '../datasources/restaurant_remote_datasource.dart';
import '../../core/config/supabase_config.dart';
import '../../core/services/cache_service.dart';
import '../../core/models/cache_item.dart';
import '../../core/utils/logger.dart';

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
  final RestaurantRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  RestaurantRepository(this._remoteDataSource, this._cacheService);

  /// Busca restaurantes com filtros opcionais
  /// [category] - Categoria dos restaurantes
  /// [limit] - Limite de resultados
  /// [offset] - Offset para paginação
  Future<List<RestaurantModel>> getRestaurants({
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      debugPrint('🔍 RestaurantRepository: Buscando restaurantes - categoria: $category');
      List<RestaurantModel> restaurants;
      
      if (category != null && category.isNotEmpty) {
        // Busca por categoria específica
        debugPrint('📂 RestaurantRepository: Buscando por categoria específica: $category');
        restaurants = await _remoteDataSource.getRestaurantsByCategory(category);
      } else {
        // Busca todos os restaurantes
        debugPrint('📋 RestaurantRepository: Buscando TODOS os restaurantes');
        restaurants = await _remoteDataSource.getAllRestaurants();
      }
      
      debugPrint('✅ RestaurantRepository: ${restaurants.length} restaurantes encontrados');
      
      // Aplica limit e offset se especificados
      if (offset != null && offset > 0) {
        restaurants = restaurants.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        restaurants = restaurants.take(limit).toList();
      }

      // Salva no cache se há dados
      if (restaurants.isNotEmpty) {
        await _cacheService.set(
          'restaurants_${category ?? 'all'}_${limit ?? 'unlimited'}_${offset ?? 0}',
          restaurants.map((r) => r.toJson()).toList(),
        );
      }

      return restaurants;
    } catch (e) {
      // Em caso de erro, retorna lista vazia
      return [];
    }
  }

  /// Busca restaurantes em destaque
  Future<List<RestaurantModel>> getFeaturedRestaurants({int limit = 10}) async {
    try {
      final allRestaurants = await _remoteDataSource.getAllRestaurants();
      
      // Filtra restaurantes em destaque
      final featuredRestaurants = allRestaurants
          .where((restaurant) => restaurant.isFeatured)
          .take(limit)
          .toList();
      
      // Salva no cache se há resultados
      if (featuredRestaurants.isNotEmpty) {
        await _cacheService.set('featured_restaurants', featuredRestaurants);
      }
      
      return featuredRestaurants;
    } catch (e) {
      Logger.error('Erro ao buscar restaurantes em destaque', {'error': e.toString()});
      
      // Tenta buscar do cache em caso de erro
      final cachedData = await _cacheService.get<List<Map<String, dynamic>>>('featured_restaurants');
      if (cachedData != null) {
        return cachedData.map((data) => RestaurantModel.fromSupabase(data)).toList();
      }
      
      return [];
    }
  }

  /// Busca restaurantes próximos
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 10,
  }) async {
    try {
      final restaurants = await _remoteDataSource.getNearbyRestaurants(
        latitude,
        longitude,
        radiusKm,
      );
      
      // Filtra por distância e aplica limite
      final nearbyRestaurants = restaurants
          .where((restaurant) {
            if (restaurant.latitude == null || restaurant.longitude == null) {
              return false;
            }
            final distance = _calculateDistance(
              latitude,
              longitude,
              restaurant.latitude!,
              restaurant.longitude!,
            );
            return distance <= radiusKm;
          })
          .take(limit)
          .toList();
      
      // Salva no cache se há dados
      if (nearbyRestaurants.isNotEmpty) {
        await _cacheService.set(
          'nearby_restaurants_${latitude}_${longitude}_${radiusKm}',
          nearbyRestaurants.map((r) => r.toJson()).toList(),
        );
      }
      
      return nearbyRestaurants;
    } catch (e) {
      return [];
    }
  }

  /// Busca um restaurante por ID
  Future<RestaurantModel?> getRestaurantById(String id) async {
    try {
      final restaurant = await _remoteDataSource.getRestaurantById(id);
      
      // Salva no cache se encontrado
      await _cacheService.set(
        'restaurant_$id',
        restaurant.toJson(),
      );
      
      return restaurant;
    } catch (e) {
      return null;
    }
  }

  /// Busca restaurantes por termo de pesquisa
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final restaurants = await _remoteDataSource.searchRestaurants(query);
      
      // Salva no cache se há resultados
      if (restaurants.isNotEmpty) {
        await _cacheService.set(
          'search_restaurants_$query',
          restaurants.map((r) => r.toJson()).toList(),
        );
      }
      
      return restaurants;
    } catch (e) {
      return [];
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

      final restaurants = (response)
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

      final allRestaurants = (response)
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

      final allRestaurants = (response)
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
