import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../data/models/restaurant_model.dart';
import '../../data/models/location_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/logger.dart';

/// Classe para representar um cluster de restaurantes
class RestaurantCluster {
  final String id;
  final LocationModel center;
  final List<RestaurantModel> restaurants;
  final double radius;

  RestaurantCluster({
    required this.id,
    required this.center,
    required this.restaurants,
    required this.radius,
  });

  /// Verificar se um restaurante está dentro do cluster
  bool containsRestaurant(RestaurantModel restaurant) {
    if (restaurant.latitude == null || restaurant.longitude == null) {
      return false;
    }
    
    final distance = _calculateDistance(
      center.latitude,
      center.longitude,
      restaurant.latitude!,
      restaurant.longitude!,
    );
    
    return distance <= radius;
  }

  /// Adicionar restaurante ao cluster
  void addRestaurant(RestaurantModel restaurant) {
    if (!restaurants.contains(restaurant)) {
      restaurants.add(restaurant);
    }
  }

  /// Calcular distância entre dois pontos em metros
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // metros
    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLon = (lon2 - lon1) * (math.pi / 180);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
}

/// Gerenciador de clustering para marcadores do mapa
class MapClusterManager {
  static const double _defaultClusterRadius = 100.0; // metros
  static const int _minClusterSize = 2;
  static const int _maxClusterSize = 99;
  
  // Cache para otimização
  static final Map<String, List<RestaurantCluster>> _clusterCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Criar clusters a partir de uma lista de restaurantes com cache
  static List<RestaurantCluster> createClusters(
    List<RestaurantModel> restaurants, {
    double clusterRadius = _defaultClusterRadius,
    int minClusterSize = _minClusterSize,
    double zoomLevel = 15.0,
  }) {
    if (restaurants.isEmpty) return [];

    // Ajustar raio do cluster baseado no zoom
    final adjustedRadius = _getAdjustedRadius(clusterRadius, zoomLevel);
    
    // Gerar chave do cache
    final cacheKey = _generateCacheKey(restaurants, adjustedRadius, minClusterSize);
    
    // Verificar cache
    if (_isValidCache(cacheKey)) {
      return _clusterCache[cacheKey]!;
    }

    final clusters = <RestaurantCluster>[];
    final processedRestaurants = <String>{};
    
    // Ordenar restaurantes por latitude para otimização
    final sortedRestaurants = List<RestaurantModel>.from(restaurants)
      ..sort((a, b) => (a.latitude ?? 0).compareTo(b.latitude ?? 0));

    for (final restaurant in sortedRestaurants) {
      if (processedRestaurants.contains(restaurant.id) ||
          restaurant.latitude == null ||
          restaurant.longitude == null) {
        continue;
      }

      final nearbyRestaurants = _findNearbyRestaurants(
        restaurant,
        sortedRestaurants,
        adjustedRadius,
        processedRestaurants,
      );

      if (nearbyRestaurants.length >= minClusterSize) {
        final center = _calculateClusterCenter(nearbyRestaurants);
        final cluster = RestaurantCluster(
          id: 'cluster_${clusters.length}_${DateTime.now().millisecondsSinceEpoch}',
          center: center,
          restaurants: nearbyRestaurants,
          radius: adjustedRadius,
        );

        clusters.add(cluster);
        
        // Marcar restaurantes como processados
        for (final r in nearbyRestaurants) {
          processedRestaurants.add(r.id);
        }
      } else {
        // Restaurante isolado, marcar como processado
        processedRestaurants.add(restaurant.id);
      }
    }
    
    // Salvar no cache
    _clusterCache[cacheKey] = clusters;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    // Limpar cache antigo
    _cleanExpiredCache();

    return clusters;
  }

  /// Encontrar restaurantes próximos com otimização
  static List<RestaurantModel> _findNearbyRestaurants(
    RestaurantModel centerRestaurant,
    List<RestaurantModel> sortedRestaurants,
    double radius,
    Set<String> processedRestaurants,
  ) {
    final nearby = <RestaurantModel>[centerRestaurant];
    final radiusInDegrees = radius / 111000; // Aproximação: 1 grau ≈ 111km
    final centerIndex = sortedRestaurants.indexOf(centerRestaurant);

    // Buscar para trás
    for (int i = centerIndex - 1; i >= 0; i--) {
      final restaurant = sortedRestaurants[i];
      
      // Otimização: se a diferença de latitude for muito grande, parar
      if ((centerRestaurant.latitude! - restaurant.latitude!).abs() > radiusInDegrees) {
        break;
      }
      
      if (restaurant.id == centerRestaurant.id ||
          processedRestaurants.contains(restaurant.id) ||
          restaurant.latitude == null ||
          restaurant.longitude == null) {
        continue;
      }

      final distance = _calculateDistanceFast(
        centerRestaurant.latitude!,
        centerRestaurant.longitude!,
        restaurant.latitude!,
        restaurant.longitude!,
      );

      if (distance <= radius) {
        nearby.add(restaurant);
      }
    }
    
    // Buscar para frente
    for (int i = centerIndex + 1; i < sortedRestaurants.length; i++) {
      final restaurant = sortedRestaurants[i];
      
      // Otimização: se a diferença de latitude for muito grande, parar
      if ((restaurant.latitude! - centerRestaurant.latitude!).abs() > radiusInDegrees) {
        break;
      }
      
      if (processedRestaurants.contains(restaurant.id) ||
          restaurant.latitude == null ||
          restaurant.longitude == null) {
        continue;
      }

      final distance = _calculateDistanceFast(
        centerRestaurant.latitude!,
        centerRestaurant.longitude!,
        restaurant.latitude!,
        restaurant.longitude!,
      );

      if (distance <= radius) {
        nearby.add(restaurant);
      }
    }

    return nearby;
  }

  /// Calcular distância rápida entre dois pontos em metros
  static double _calculateDistanceFast(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Fórmula simplificada para distâncias pequenas (mais rápida)
    const double earthRadius = 6371000; // metros
    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLon = (lon2 - lon1) * (math.pi / 180);
    final double avgLat = (lat1 + lat2) / 2 * (math.pi / 180);
    
    final double x = dLon * math.cos(avgLat);
    final double y = dLat;
    
    return math.sqrt(x * x + y * y) * earthRadius;
  }

  /// Calcular centro geográfico do cluster
  static LocationModel _calculateClusterCenter(List<RestaurantModel> restaurants) {
    double totalLat = 0;
    double totalLng = 0;
    int count = 0;

    for (final restaurant in restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        totalLat += restaurant.latitude!;
        totalLng += restaurant.longitude!;
        count++;
      }
    }

    return LocationModel(
      latitude: totalLat / count,
      longitude: totalLng / count,
    );
  }

  /// Obter restaurantes não clusterizados
  static List<RestaurantModel> getUnclusteredRestaurants(
    List<RestaurantModel> allRestaurants,
    List<RestaurantCluster> clusters,
  ) {
    final clusteredIds = <String>{};
    
    for (final cluster in clusters) {
      for (final restaurant in cluster.restaurants) {
        clusteredIds.add(restaurant.id);
      }
    }

    return allRestaurants
        .where((restaurant) => !clusteredIds.contains(restaurant.id))
        .toList();
  }
  
  /// Gerar chave do cache
  static String _generateCacheKey(
    List<RestaurantModel> restaurants,
    double radius,
    int minClusterSize,
  ) {
    final ids = restaurants.map((r) => r.id).join(',');
    return '${ids.hashCode}_${radius}_$minClusterSize';
  }
  
  /// Verificar se o cache é válido
  static bool _isValidCache(String cacheKey) {
    if (!_clusterCache.containsKey(cacheKey) || 
        !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }
  
  /// Limpar cache expirado
  static void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiration) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _clusterCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
  
  /// Ajustar raio do cluster baseado no nível de zoom
  static double _getAdjustedRadius(double baseRadius, double zoomLevel) {
    // Quanto maior o zoom, menor o raio do cluster
    if (zoomLevel >= 18) return baseRadius * 0.5;
    if (zoomLevel >= 16) return baseRadius * 0.7;
    if (zoomLevel >= 14) return baseRadius * 1.0;
    if (zoomLevel >= 12) return baseRadius * 1.5;
    return baseRadius * 2.0;
  }
  
  /// Limpar todo o cache
  static void clearCache() {
    _clusterCache.clear();
    _cacheTimestamps.clear();
  }
}

/// Widget para criar marcador de cluster
class ClusterMarkerWidget {
  /// Criar marcador visual para cluster
  static Future<Uint8List> createClusterMarker({
    required int count,
    double size = 80,
    Color backgroundColor = AppColors.primary,
    Color textColor = Colors.white,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size);
    final radius = size / 2;
    final center = Offset(markerSize.width / 2, markerSize.height / 2);

    // Desenhar círculo de pulso externo
    final pulsePaint = Paint()
      ..color = backgroundColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius + 8, pulsePaint);

    // Desenhar sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    canvas.drawCircle(
      Offset(center.dx + 3, center.dy + 3),
      radius,
      shadowPaint,
    );

    // Desenhar círculo principal com gradiente
    final mainPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [backgroundColor, backgroundColor.withOpacity(0.8)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, mainPaint);

    // Desenhar borda com gradiente
    final borderPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - radius, center.dy - radius),
        Offset(center.dx + radius, center.dy + radius),
        [Colors.white, Colors.white.withOpacity(0.8)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, radius, borderPaint);

    // Desenhar círculo interno
    final innerPaint = Paint()
      ..color = backgroundColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      center,
      size / 3,
      innerPaint,
    );

    // Desenhar texto do contador com sombra
    final textPainter = TextPainter(
      text: TextSpan(
        text: count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.25,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Converter para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      markerSize.width.toInt(),
      markerSize.height.toInt(),
    );
    
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Obter cor do cluster baseado no número de restaurantes
  static Color getClusterColor(int count) {
    if (count < 5) {
      return AppColors.primary;
    } else if (count < 10) {
      return const Color(0xFFFF9800); // Laranja
    } else if (count < 20) {
      return const Color(0xFFE91E63); // Rosa
    } else if (count < 50) {
      return const Color(0xFF9C27B0); // Roxo
    } else {
      return const Color(0xFF673AB7); // Roxo escuro
    }
  }

  /// Obter tamanho do cluster baseado no número de restaurantes
  static double getClusterSize(int count) {
    if (count < 5) {
      return 65;
    } else if (count < 10) {
      return 75;
    } else if (count < 20) {
      return 85;
    } else if (count < 50) {
      return 95;
    } else {
      return 105;
    }
  }

  /// Criar marcador animado para cluster
  static Future<Uint8List> createAnimatedClusterMarker({
    required int count,
    required double animationValue, // 0.0 a 1.0
    double baseSize = 80,
    Color? backgroundColor,
  }) async {
    final animatedSize = baseSize + (animationValue * 15);
    final color = backgroundColor ?? getClusterColor(count);
    
    return createClusterMarker(
      count: count,
      size: animatedSize,
      backgroundColor: color,
    );
  }
}

/// Extensão para facilitar o uso de clustering no EnhancedMapWidget
extension ClusteringExtension on List<RestaurantModel> {
  /// Criar clusters automaticamente
  List<RestaurantCluster> createClusters({
    double clusterRadius = 100.0,
    int minClusterSize = 2,
  }) {
    return MapClusterManager.createClusters(
      this,
      clusterRadius: clusterRadius,
      minClusterSize: minClusterSize,
    );
  }

  /// Obter restaurantes não clusterizados
  List<RestaurantModel> getUnclusteredRestaurants(
    List<RestaurantCluster> clusters,
  ) {
    return MapClusterManager.getUnclusteredRestaurants(this, clusters);
  }
}