import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/location_model.dart';

/// Configuration settings for location service
class LocationSettings {
  final LocationAccuracy accuracy;
  final Duration timeout;
  final int distanceFilter;
  final bool enableBackgroundLocation;
  final bool enableHighAccuracy;

  const LocationSettings({
    this.accuracy = LocationAccuracy.high,
    this.timeout = const Duration(seconds: 15),
    this.distanceFilter = 10,
    this.enableBackgroundLocation = false,
    this.enableHighAccuracy = true,
  });
}

/// Base class for location-related exceptions
class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}

/// Exception thrown when location permission is denied
class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException(super.message);
}

/// Exception thrown when location request times out
class LocationTimeoutException extends LocationException {
  const LocationTimeoutException(super.message);
}

/// Exception thrown when location service is disabled
class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException(super.message);
}

/// Geocoding result containing address information
class GeocodingResult {
  final String address;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double latitude;
  final double longitude;

  const GeocodingResult({
    required this.address,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    required this.latitude,
    required this.longitude,
  });
}

@singleton
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService();
  
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  
  Position? _cachedLocation;
  Position? get cachedLocation => _cachedLocation;
  
  bool _isLocationEnabled = false;
  bool get isLocationEnabled => _isLocationEnabled;
  
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  PermissionStatus get permissionStatus => _permissionStatus;
  
  DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  
  bool get isCacheValid {
    if (_lastCacheTime == null || _cachedLocation == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidDuration;
  }
  /// Verifica se as permissões de localização estão concedidas
  Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission == PermissionStatus.granted;
  }

  /// Solicita permissões de localização
  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }

  /// Verifica se o serviço de localização está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtém a posição atual do usuário
  Future<Position?> getCurrentPosition() async {
    try {
      debugPrint('📍 LocationService: Tentando obter localização atual...');
      
      // Verifica se o serviço está habilitado
      if (!await isLocationServiceEnabled()) {
        debugPrint('❌ LocationService: Serviço de localização desabilitado');
        throw const LocationServiceDisabledException('Serviço de localização desabilitado');
      }

      // Verifica permissões
      if (!await hasLocationPermission()) {
        debugPrint('⚠️ LocationService: Sem permissão, solicitando...');
        final granted = await requestLocationPermission();
        if (!granted) {
          debugPrint('❌ LocationService: Permissão negada pelo usuário');
          throw const LocationPermissionDeniedException('Permissão de localização negada');
        }
      }

      debugPrint('🎯 LocationService: Obtendo posição com alta precisão...');
      
      Position? position;
      
      // Primeira tentativa: getCurrentPosition com configurações otimizadas para web
      try {
        if (kIsWeb) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 30),
          );
        } else {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: const Duration(seconds: 15),
          );
        }
      } catch (e) {
        debugPrint('⚠️ LocationService: getCurrentPosition falhou, tentando getLastKnownPosition: $e');
        
        // Segunda tentativa: getLastKnownPosition
        try {
          position = await Geolocator.getLastKnownPosition();
          if (position != null) {
            debugPrint('📱 LocationService: Usando última localização conhecida');
          }
        } catch (e2) {
          debugPrint('❌ LocationService: getLastKnownPosition também falhou: $e2');
        }
      }
      
      if (position == null) {
        throw Exception('Não foi possível obter localização');
      }
      
      debugPrint('✅ LocationService: Localização obtida: ${position.latitude}, ${position.longitude}');
      debugPrint('📊 LocationService: Precisão: ${position.accuracy}m, Timestamp: ${position.timestamp}');
      
      // Fazer geocodificação reversa para descobrir o endereço real
      await _performReverseGeocoding(position.latitude, position.longitude);
      
      // Cache da localização obtida
      _currentPosition = position;
      _cachedLocation = position;
      _lastCacheTime = DateTime.now();
      
      return position;
    } catch (e) {
      debugPrint('❌ LocationService: Erro ao obter localização: $e');
      return null;
    }
  }

  /// Calcula a distância entre duas coordenadas em metros
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Verifica se um ponto está dentro do raio especificado (em metros)
  bool isWithinRadius(
    double userLat,
    double userLng,
    double targetLat,
    double targetLng,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(userLat, userLng, targetLat, targetLng);
    return distance <= radiusInMeters;
  }

  /// Converte metros para quilômetros
  double metersToKilometers(double meters) {
    return meters / 1000;
  }

  /// Converte quilômetros para metros
  double kilometersToMeters(double kilometers) {
    return kilometers * 1000;
  }
  
  /// Abre as configurações do aplicativo
  Future<bool> openAppSettings() async {
    return await Permission.location.request().isGranted;
  }
  
  /// Limpa os dados de localização
  void clearLocationData() {
    _currentPosition = null;
    _cachedLocation = null;
    _isLocationEnabled = false;
    _permissionStatus = PermissionStatus.denied;
    _lastCacheTime = null;
  }
  
  /// Check if a location is within specified bounds
  bool isLocationInBounds(
    double latitude,
    double longitude,
    double northEastLat,
    double northEastLng,
    double southWestLat,
    double southWestLng,
  ) {
    return latitude >= southWestLat &&
           latitude <= northEastLat &&
           longitude >= southWestLng &&
           longitude <= northEastLng;
  }

  /// Find the nearest location from a list
  LocationModel? findNearestLocation(LocationModel userLocation, List<LocationModel> locations) {
    if (locations.isEmpty) return null;

    LocationModel? nearest;
    double minDistance = double.infinity;

    for (final location in locations) {
      final distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        location.latitude,
        location.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }

    return nearest;
  }

  /// Filter locations within a specific radius
  List<LocationModel> filterLocationsByRadius(
    LocationModel center,
    List<LocationModel> locations,
    double radiusInMeters,
  ) {
    return locations.where((location) {
      final distance = calculateDistance(
        center.latitude,
        center.longitude,
        location.latitude,
        location.longitude,
      );
      return distance <= radiusInMeters;
    }).toList();
  }

  /// Calculate bearing between two coordinates
  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const double degreesToRadians = 0.017453292519943295;
    const double radiansToDegrees = 57.29577951308232;

    final double dLng = (endLng - startLng) * degreesToRadians;
    final double sLat = startLat * degreesToRadians;
    final double eLat = endLat * degreesToRadians;

    final double y = sin(dLng) * cos(eLat);
    final double x = cos(sLat) * sin(eLat) - sin(sLat) * cos(eLat) * cos(dLng);

    final double bearing = atan2(y, x) * radiansToDegrees;
    return (bearing + 360) % 360;
  }

  /// Update location settings
  void updateSettings(LocationSettings settings) {
    // In a real implementation, these settings would be stored and used
    // for subsequent location requests
    debugPrint('📍 LocationService: Settings updated');
  }

  /// Libera recursos
  void dispose() {
    clearLocationData();
  }
  
  /// Calcula distância em quilômetros
  double calculateDistanceInKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final distanceInMeters = calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return metersToKilometers(distanceInMeters);
  }

  /// Realizar geocodificação reversa para descobrir endereço exato
  Future<void> _performReverseGeocoding(double latitude, double longitude) async {
    try {
      debugPrint('🔍 LocationService: Fazendo geocodificação reversa...');
      
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        debugPrint('🏠 ENDEREÇO DETECTADO:');
        debugPrint('   Rua: ${placemark.street ?? 'N/A'}');
        debugPrint('   Bairro: ${placemark.subLocality ?? 'N/A'}');
        debugPrint('   Cidade: ${placemark.locality ?? 'N/A'}');
        debugPrint('   Estado: ${placemark.administrativeArea ?? 'N/A'}');
        debugPrint('   País: ${placemark.country ?? 'N/A'}');
        debugPrint('   CEP: ${placemark.postalCode ?? 'N/A'}');
        debugPrint('   Área Admin: ${placemark.subAdministrativeArea ?? 'N/A'}');
        
        // Verificação específica para Pinhais
        final cidade = placemark.locality?.toLowerCase();
        final subArea = placemark.subAdministrativeArea?.toLowerCase(); 
        
        if (cidade?.contains('pinhais') == true) {
          debugPrint('✅ CONFIRMADO: Você está em PINHAIS/PR!');
        } else if (cidade?.contains('curitiba') == true) {
          debugPrint('📍 Detectado: Curitiba/PR');
        } else {
          debugPrint('🤔 Cidade detectada: ${placemark.locality}');
        }
        
        if (subArea?.contains('pinhais') == true) {
          debugPrint('✅ CONFIRMADO pela subárea: PINHAIS/PR!');
        }
        
        // Verificar coordenadas específicas
        debugPrint('🎯 ANÁLISE DAS COORDENADAS:');
        debugPrint('   Suas coordenadas: $latitude, $longitude');
        debugPrint('   Centro Pinhais: -25.4448, -49.1924');
        debugPrint('   Centro Curitiba: -25.4284, -49.2733');
        
        // Calcular distância para Pinhais e Curitiba
        final distToPinhais = calculateDistanceInKm(latitude, longitude, -25.4448, -49.1924);
        final distToCuritiba = calculateDistanceInKm(latitude, longitude, -25.4284, -49.2733);
        
        debugPrint('   Distância até Pinhais: ${distToPinhais.toStringAsFixed(2)} km');
        debugPrint('   Distância até Curitiba: ${distToCuritiba.toStringAsFixed(2)} km');
        
        if (distToPinhais < distToCuritiba) {
          debugPrint('✅ CONFIRMADO: Você está mais próximo de PINHAIS que de Curitiba!');
        } else {
          debugPrint('🤔 Você está mais próximo de Curitiba que de Pinhais...');
        }
      } else {
        debugPrint('⚠️ LocationService: Geocodificação reversa não retornou resultados');
      }
    } catch (e) {
      debugPrint('❌ LocationService: Erro na geocodificação reversa: $e');
    }
  }
}
