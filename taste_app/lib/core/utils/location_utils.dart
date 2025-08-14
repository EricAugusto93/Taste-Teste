import 'dart:math' as math;
import '../../data/models/location_model.dart';

/// Utilitários para cálculos de localização e distância
class LocationUtils {
  LocationUtils._();

  /// Raio da Terra em metros
  static const double earthRadiusInMeters = 6371000;

  /// Raio da Terra em quilômetros
  static const double earthRadiusInKm = 6371;

  /// Calcula a distância entre duas coordenadas usando a fórmula de Haversine
  /// Retorna a distância em metros
  static double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusInMeters * c;
  }

  /// Calcula a distância entre duas LocationModel usando Haversine
  static double calculateDistance(LocationModel from, LocationModel to) {
    return calculateHaversineDistance(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Calcula a distância em quilômetros
  static double calculateDistanceInKm(LocationModel from, LocationModel to) {
    return calculateDistance(from, to) / 1000;
  }

  /// Formata a distância para exibição amigável
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else if (distanceInMeters < 10000) {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.round()}km';
    }
  }

  /// Formata a distância com mais detalhes
  static String formatDetailedDistance(double distanceInMeters) {
    if (distanceInMeters < 100) {
      return '${distanceInMeters.round()} metros';
    } else if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)} km';
      } else {
        return '${km.round()} km';
      }
    }
  }

  /// Calcula o bearing (direção) entre duas coordenadas
  /// Retorna o ângulo em graus (0-360)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLon = _degreesToRadians(lon2 - lon1);
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  /// Converte bearing em direção cardinal (N, NE, E, SE, S, SW, W, NW)
  static String bearingToCardinal(double bearing) {
    const directions = [
      'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'
    ];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Converte bearing em direção cardinal em português
  static String bearingToCardinalPt(double bearing) {
    const directions = [
      'Norte', 'Nordeste', 'Leste', 'Sudeste', 
      'Sul', 'Sudoeste', 'Oeste', 'Noroeste'
    ];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Verifica se uma localização está dentro de um raio específico
  static bool isWithinRadius(
    LocationModel center,
    LocationModel target,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(center, target);
    return distance <= radiusInMeters;
  }

  /// Encontra a localização mais próxima de uma lista
  static LocationModel? findNearestLocation(
    LocationModel userLocation,
    List<LocationModel> locations,
  ) {
    if (locations.isEmpty) return null;

    LocationModel? nearest;
    double minDistance = double.infinity;

    for (final location in locations) {
      final distance = calculateDistance(userLocation, location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }

    return nearest;
  }

  /// Ordena localizações por distância (mais próximas primeiro)
  static List<LocationModel> sortLocationsByDistance(
    LocationModel userLocation,
    List<LocationModel> locations,
  ) {
    final locationsWithDistance = locations.map((location) {
      final distance = calculateDistance(userLocation, location);
      return _LocationWithDistance(location, distance);
    }).toList();

    locationsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    return locationsWithDistance.map((item) => item.location).toList();
  }

  /// Filtra localizações dentro de um raio específico
  static List<LocationModel> filterLocationsByRadius(
    LocationModel center,
    List<LocationModel> locations,
    double radiusInMeters,
  ) {
    return locations.where((location) {
      return isWithinRadius(center, location, radiusInMeters);
    }).toList();
  }

  /// Verifica se uma coordenada está dentro de limites específicos
  static bool isLocationInBounds(
    LocationModel location,
    LocationModel northEast,
    LocationModel southWest,
  ) {
    return location.latitude <= northEast.latitude &&
           location.latitude >= southWest.latitude &&
           location.longitude <= northEast.longitude &&
           location.longitude >= southWest.longitude;
  }

  /// Calcula o ponto médio entre duas coordenadas
  static LocationModel calculateMidpoint(
    LocationModel location1,
    LocationModel location2,
  ) {
    final lat1Rad = _degreesToRadians(location1.latitude);
    final lat2Rad = _degreesToRadians(location2.latitude);
    final dLon = _degreesToRadians(location2.longitude - location1.longitude);

    final bx = math.cos(lat2Rad) * math.cos(dLon);
    final by = math.cos(lat2Rad) * math.sin(dLon);

    final midLat = math.atan2(
      math.sin(lat1Rad) + math.sin(lat2Rad),
      math.sqrt((math.cos(lat1Rad) + bx) * (math.cos(lat1Rad) + bx) + by * by),
    );

    final midLon = _degreesToRadians(location1.longitude) + math.atan2(by, math.cos(lat1Rad) + bx);

    return LocationModel(
      latitude: _radiansToDegrees(midLat),
      longitude: _radiansToDegrees(midLon),
      accuracy: math.max(location1.accuracy ?? 0, location2.accuracy ?? 0),
      timestamp: DateTime.now(),
    );
  }

  /// Calcula os limites (bounds) para uma lista de localizações
  static LocationBounds calculateBounds(List<LocationModel> locations) {
    if (locations.isEmpty) {
      throw ArgumentError('Lista de localizações não pode estar vazia');
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLon = locations.first.longitude;
    double maxLon = locations.first.longitude;

    for (final location in locations) {
      minLat = math.min(minLat, location.latitude);
      maxLat = math.max(maxLat, location.latitude);
      minLon = math.min(minLon, location.longitude);
      maxLon = math.max(maxLon, location.longitude);
    }

    return LocationBounds(
      northEast: LocationModel(
        latitude: maxLat,
        longitude: maxLon,
        timestamp: DateTime.now(),
      ),
      southWest: LocationModel(
        latitude: minLat,
        longitude: minLon,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Expande os limites por uma margem em metros
  static LocationBounds expandBounds(
    LocationBounds bounds,
    double marginInMeters,
  ) {
    // Aproximação: 1 grau ≈ 111,320 metros
    final marginInDegrees = marginInMeters / 111320;

    return LocationBounds(
      northEast: LocationModel(
        latitude: bounds.northEast.latitude + marginInDegrees,
        longitude: bounds.northEast.longitude + marginInDegrees,
        timestamp: DateTime.now(),
      ),
      southWest: LocationModel(
        latitude: bounds.southWest.latitude - marginInDegrees,
        longitude: bounds.southWest.longitude - marginInDegrees,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Converte graus para radianos
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Converte radianos para graus
  static double _radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  /// Valida se as coordenadas são válidas
  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
           latitude <= 90 &&
           longitude >= -180 &&
           longitude <= 180;
  }

  /// Normaliza longitude para o intervalo [-180, 180]
  static double normalizeLongitude(double longitude) {
    while (longitude > 180) {
      longitude -= 360;
    }
    while (longitude < -180) {
      longitude += 360;
    }
    return longitude;
  }

  /// Normaliza latitude para o intervalo [-90, 90]
  static double normalizeLatitude(double latitude) {
    return math.max(-90, math.min(90, latitude));
  }

  /// Gera uma localização aleatória dentro de um raio
  static LocationModel generateRandomLocationInRadius(
    LocationModel center,
    double radiusInMeters,
  ) {
    final random = math.Random();
    final radiusInDegrees = radiusInMeters / 111320;
    
    final u = random.nextDouble();
    final v = random.nextDouble();
    
    final w = radiusInDegrees * math.sqrt(u);
    final t = 2 * math.pi * v;
    
    final x = w * math.cos(t);
    final y = w * math.sin(t);
    
    final newLat = center.latitude + y;
    final newLon = center.longitude + x / math.cos(_degreesToRadians(center.latitude));
    
    return LocationModel(
      latitude: normalizeLatitude(newLat),
      longitude: normalizeLongitude(newLon),
      timestamp: DateTime.now(),
    );
  }
}

/// Classe auxiliar para ordenação por distância
class _LocationWithDistance {
  final LocationModel location;
  final double distance;

  _LocationWithDistance(this.location, this.distance);
}

/// Classe para representar limites geográficos
class LocationBounds {
  final LocationModel northEast;
  final LocationModel southWest;

  const LocationBounds({
    required this.northEast,
    required this.southWest,
  });

  /// Verifica se uma localização está dentro dos limites
  bool contains(LocationModel location) {
    return LocationUtils.isLocationInBounds(location, northEast, southWest);
  }

  /// Calcula o centro dos limites
  LocationModel get center {
    return LocationUtils.calculateMidpoint(northEast, southWest);
  }

  /// Calcula a largura em metros
  double get widthInMeters {
    return LocationUtils.calculateDistance(
      LocationModel(
        latitude: southWest.latitude,
        longitude: southWest.longitude,
        timestamp: DateTime.now(),
      ),
      LocationModel(
        latitude: southWest.latitude,
        longitude: northEast.longitude,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Calcula a altura em metros
  double get heightInMeters {
    return LocationUtils.calculateDistance(
      LocationModel(
        latitude: southWest.latitude,
        longitude: southWest.longitude,
        timestamp: DateTime.now(),
      ),
      LocationModel(
        latitude: northEast.latitude,
        longitude: southWest.longitude,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  String toString() {
    return 'LocationBounds(northEast: $northEast, southWest: $southWest)';
  }
}