import 'dart:math';
import '../../../data/models/restaurant_model.dart';
import '../../../data/repositories/location_repository.dart';
import '../../utils/logger.dart';
import '../../../services/analytics_service.dart';

/// Serviço para cálculo de distâncias e funcionalidades relacionadas
class DistanceService {
  static DistanceService? _instance;
  static DistanceService get instance => _instance ??= DistanceService._();
  DistanceService._();

  final LocationRepository _locationRepository = LocationRepository.instance;
  
  /// Calcula a distância entre duas coordenadas usando a fórmula de Haversine
  /// 
  /// Retorna a distância em metros
  double calculateHaversineDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371000; // Raio da Terra em metros
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Converte graus para radianos
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
  
  /// Calcula a distância entre o usuário e um restaurante
  /// 
  /// Retorna a distância em metros ou null se não conseguir obter a localização
  Future<double?> calculateDistanceToRestaurant(
    RestaurantModel restaurant, {
    bool forceRefresh = false,
  }) async {
    try {
      Logger.debug('DistanceService: Calculando distância para restaurante', {
        'restaurant_id': restaurant.id,
        'restaurant_name': restaurant.name,
      });
      
      final userLocation = await _locationRepository.getCurrentLocation(
        forceRefresh: forceRefresh,
      );
      
      if (userLocation == null) {
        Logger.warning('DistanceService: Localização do usuário não disponível');
        return null;
      }
      
      // Verifica se o restaurante tem coordenadas válidas
      if (restaurant.latitude == null || restaurant.longitude == null) {
        Logger.warning('DistanceService: Restaurante sem coordenadas válidas', {
          'restaurant_id': restaurant.id,
        });
        return null;
      }
      
      final distance = calculateHaversineDistance(
        userLocation.latitude,
        userLocation.longitude,
        restaurant.latitude!,
        restaurant.longitude!,
      );
      
      Logger.debug('DistanceService: Distância calculada', {
        'restaurant_id': restaurant.id,
        'distance_meters': distance,
      });
      
      AnalyticsService.instance.trackEvent('distance_calculated', parameters: {
        'restaurant_id': restaurant.id,
        'distance_meters': distance,
        'method': 'haversine',
      });
      
      return distance;
      
    } catch (e, stackTrace) {
      Logger.error('DistanceService: Erro ao calcular distância', e, stackTrace);
      
      AnalyticsService.instance.trackEvent('distance_calculation_error', parameters: {
        'restaurant_id': restaurant.id,
        'error': e.toString(),
      });
      
      return null;
    }
  }
  
  /// Calcula distâncias para uma lista de restaurantes
  /// 
  /// Retorna um Map com o ID do restaurante como chave e a distância como valor
  Future<Map<String, double>> calculateDistancesToRestaurants(
    List<RestaurantModel> restaurants, {
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('DistanceService: Calculando distâncias para múltiplos restaurantes', {
        'count': restaurants.length,
      });
      
      final userLocation = await _locationRepository.getCurrentLocation(
        forceRefresh: forceRefresh,
      );
      
      if (userLocation == null) {
        Logger.warning('DistanceService: Localização do usuário não disponível');
        return {};
      }
      
      final Map<String, double> distances = {};
      
      for (final restaurant in restaurants) {
        try {
          // Verifica se o restaurante tem coordenadas válidas
          if (restaurant.latitude == null || restaurant.longitude == null) {
            Logger.warning('DistanceService: Restaurante sem coordenadas válidas', {
              'restaurant_id': restaurant.id,
            });
            continue;
          }
          
          final distance = calculateHaversineDistance(
            userLocation.latitude,
            userLocation.longitude,
            restaurant.latitude!,
            restaurant.longitude!,
          );
          
          distances[restaurant.id] = distance;
        } catch (e) {
          Logger.warning('DistanceService: Erro ao calcular distância para restaurante', {
            'restaurant_id': restaurant.id,
            'error': e.toString(),
          });
        }
      }
      
      Logger.info('DistanceService: Distâncias calculadas', {
        'successful': distances.length,
        'total': restaurants.length,
      });
      
      AnalyticsService.instance.trackEvent('bulk_distance_calculated', parameters: {
        'restaurant_count': restaurants.length,
        'successful_calculations': distances.length,
      });
      
      return distances;
      
    } catch (e, stackTrace) {
      Logger.error('DistanceService: Erro ao calcular distâncias em lote', e, stackTrace);
      return {};
    }
  }
  
  /// Ordena restaurantes por distância
  /// 
  /// Retorna uma lista ordenada dos restaurantes mais próximos primeiro
  Future<List<RestaurantModel>> sortRestaurantsByDistance(
    List<RestaurantModel> restaurants, {
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('DistanceService: Ordenando restaurantes por distância', {
        'count': restaurants.length,
      });
      
      final distances = await calculateDistancesToRestaurants(
        restaurants,
        forceRefresh: forceRefresh,
      );
      
      if (distances.isEmpty) {
        Logger.warning('DistanceService: Nenhuma distância calculada, retornando lista original');
        return restaurants;
      }
      
      // Ordena os restaurantes por distância
      final sortedRestaurants = List<RestaurantModel>.from(restaurants);
      sortedRestaurants.sort((a, b) {
        final distanceA = distances[a.id] ?? double.infinity;
        final distanceB = distances[b.id] ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });
      
      Logger.info('DistanceService: Restaurantes ordenados por distância');
      
      AnalyticsService.instance.trackEvent('restaurants_sorted_by_distance', parameters: {
        'restaurant_count': sortedRestaurants.length,
        'closest_distance': distances.values.isNotEmpty ? distances.values.reduce(min) : null,
        'farthest_distance': distances.values.isNotEmpty ? distances.values.reduce(max) : null,
      });
      
      return sortedRestaurants;
      
    } catch (e, stackTrace) {
      Logger.error('DistanceService: Erro ao ordenar restaurantes', e, stackTrace);
      return restaurants;
    }
  }
  
  /// Filtra restaurantes dentro de um raio específico
  /// 
  /// [radiusInMeters] - Raio em metros
  /// Retorna lista de restaurantes dentro do raio especificado
  Future<List<RestaurantModel>> filterRestaurantsWithinRadius(
    List<RestaurantModel> restaurants,
    double radiusInMeters, {
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('DistanceService: Filtrando restaurantes por raio', {
        'count': restaurants.length,
        'radius_meters': radiusInMeters,
      });
      
      final distances = await calculateDistancesToRestaurants(
        restaurants,
        forceRefresh: forceRefresh,
      );
      
      if (distances.isEmpty) {
        Logger.warning('DistanceService: Nenhuma distância calculada, retornando lista vazia');
        return [];
      }
      
      final filteredRestaurants = restaurants.where((restaurant) {
        final distance = distances[restaurant.id];
        return distance != null && distance <= radiusInMeters;
      }).toList();
      
      Logger.info('DistanceService: Restaurantes filtrados por raio', {
        'original_count': restaurants.length,
        'filtered_count': filteredRestaurants.length,
        'radius_meters': radiusInMeters,
      });
      
      AnalyticsService.instance.trackEvent('restaurants_filtered_by_radius', parameters: {
        'original_count': restaurants.length,
        'filtered_count': filteredRestaurants.length,
        'radius_meters': radiusInMeters,
      });
      
      return filteredRestaurants;
      
    } catch (e, stackTrace) {
      Logger.error('DistanceService: Erro ao filtrar restaurantes por raio', e, stackTrace);
      return [];
    }
  }
  
  /// Formata a distância para exibição amigável
  String formatDistance(double distanceInMeters) {
    try {
      if (distanceInMeters < 1000) {
        return '${distanceInMeters.round()}m';
      } else {
        final km = distanceInMeters / 1000;
        if (km < 10) {
          return '${km.toStringAsFixed(1)}km';
        } else {
          return '${km.round()}km';
        }
      }
    } catch (e) {
      Logger.error('DistanceService: Erro ao formatar distância', e);
      return 'N/A';
    }
  }
  
  /// Calcula o tempo estimado de caminhada
  /// 
  /// Assume velocidade média de caminhada de 5 km/h
  String calculateWalkingTime(double distanceInMeters) {
    try {
      const double walkingSpeedKmh = 5.0; // 5 km/h
      const double walkingSpeedMs = walkingSpeedKmh * 1000 / 3600; // m/s
      
      final timeInSeconds = distanceInMeters / walkingSpeedMs;
      final timeInMinutes = timeInSeconds / 60;
      
      if (timeInMinutes < 1) {
        return '< 1 min';
      } else if (timeInMinutes < 60) {
        return '${timeInMinutes.round()} min';
      } else {
        final hours = timeInMinutes / 60;
        return '${hours.toStringAsFixed(1)}h';
      }
    } catch (e) {
      Logger.error('DistanceService: Erro ao calcular tempo de caminhada', e);
      return 'N/A';
    }
  }
  
  /// Calcula o tempo estimado de carro
  /// 
  /// Assume velocidade média urbana de 30 km/h
  String calculateDrivingTime(double distanceInMeters) {
    try {
      const double drivingSpeedKmh = 30.0; // 30 km/h (velocidade urbana)
      const double drivingSpeedMs = drivingSpeedKmh * 1000 / 3600; // m/s
      
      final timeInSeconds = distanceInMeters / drivingSpeedMs;
      final timeInMinutes = timeInSeconds / 60;
      
      if (timeInMinutes < 1) {
        return '< 1 min';
      } else if (timeInMinutes < 60) {
        return '${timeInMinutes.round()} min';
      } else {
        final hours = timeInMinutes / 60;
        return '${hours.toStringAsFixed(1)}h';
      }
    } catch (e) {
      Logger.error('DistanceService: Erro ao calcular tempo de carro', e);
      return 'N/A';
    }
  }
  
  /// Obtém estatísticas de distância para uma lista de restaurantes
  Future<DistanceStats?> getDistanceStats(
    List<RestaurantModel> restaurants, {
    bool forceRefresh = false,
  }) async {
    try {
      final distances = await calculateDistancesToRestaurants(
        restaurants,
        forceRefresh: forceRefresh,
      );
      
      if (distances.isEmpty) {
        return null;
      }
      
      final distanceValues = distances.values.toList();
      distanceValues.sort();
      
      final stats = DistanceStats(
        minDistance: distanceValues.first,
        maxDistance: distanceValues.last,
        averageDistance: distanceValues.reduce((a, b) => a + b) / distanceValues.length,
        medianDistance: distanceValues[distanceValues.length ~/ 2],
        totalRestaurants: restaurants.length,
        restaurantsWithDistance: distances.length,
      );
      
      Logger.info('DistanceService: Estatísticas de distância calculadas', {
        'min_distance': stats.minDistance,
        'max_distance': stats.maxDistance,
        'average_distance': stats.averageDistance,
        'median_distance': stats.medianDistance,
      });
      
      return stats;
      
    } catch (e, stackTrace) {
      Logger.error('DistanceService: Erro ao calcular estatísticas', e, stackTrace);
      return null;
    }
  }
}

/// Classe para estatísticas de distância
class DistanceStats {
  final double minDistance;
  final double maxDistance;
  final double averageDistance;
  final double medianDistance;
  final int totalRestaurants;
  final int restaurantsWithDistance;
  
  const DistanceStats({
    required this.minDistance,
    required this.maxDistance,
    required this.averageDistance,
    required this.medianDistance,
    required this.totalRestaurants,
    required this.restaurantsWithDistance,
  });
  
  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'min_distance': minDistance,
      'max_distance': maxDistance,
      'average_distance': averageDistance,
      'median_distance': medianDistance,
      'total_restaurants': totalRestaurants,
      'restaurants_with_distance': restaurantsWithDistance,
    };
  }
}