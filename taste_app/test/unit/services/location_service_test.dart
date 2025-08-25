import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taste_app/data/services/location/location_service.dart' as app_location;
import 'package:taste_app/data/models/location_model.dart';

void main() {
  group('LocationSettings Tests', () {
    test('should create LocationSettings with default values', () {
      // Act
      const settings = app_location.LocationSettings();

      // Assert
      expect(settings.accuracy, equals(LocationAccuracy.high));
      expect(settings.timeout, equals(const Duration(seconds: 15)));
      expect(settings.distanceFilter, equals(10));
      expect(settings.enableBackgroundLocation, isFalse);
      expect(settings.enableHighAccuracy, isTrue);
    });

    test('should create LocationSettings with custom values', () {
      // Act
      const settings = app_location.LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeout: Duration(seconds: 30),
        distanceFilter: 20,
        enableBackgroundLocation: true,
        enableHighAccuracy: false,
      );

      // Assert
      expect(settings.accuracy, equals(LocationAccuracy.medium));
      expect(settings.timeout, equals(const Duration(seconds: 30)));
      expect(settings.distanceFilter, equals(20));
      expect(settings.enableBackgroundLocation, isTrue);
      expect(settings.enableHighAccuracy, isFalse);
    });
  });

  group('GeocodingResult Tests', () {
    test('should create GeocodingResult with required values', () {
      // Act
      const result = app_location.GeocodingResult(
        address: 'Test Address',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      // Assert
      expect(result.address, equals('Test Address'));
      expect(result.latitude, equals(-23.5505));
      expect(result.longitude, equals(-46.6333));
      expect(result.street, isNull);
      expect(result.city, isNull);
      expect(result.state, isNull);
      expect(result.country, isNull);
      expect(result.postalCode, isNull);
    });

    test('should create GeocodingResult with all values', () {
      // Act
      const result = app_location.GeocodingResult(
        address: 'Rua Augusta, 123',
        street: 'Rua Augusta',
        city: 'São Paulo',
        state: 'SP',
        country: 'Brasil',
        postalCode: '01305-000',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      // Assert
      expect(result.address, equals('Rua Augusta, 123'));
      expect(result.street, equals('Rua Augusta'));
      expect(result.city, equals('São Paulo'));
      expect(result.state, equals('SP'));
      expect(result.country, equals('Brasil'));
      expect(result.postalCode, equals('01305-000'));
      expect(result.latitude, equals(-23.5505));
      expect(result.longitude, equals(-46.6333));
    });
  });

  group('LocationService Tests', () {
    late app_location.LocationService locationService;

    setUp(() {
      locationService = app_location.LocationService.instance;
      // Limpa dados antes de cada teste
      locationService.clearLocationData();
    });

    tearDown(() {
      locationService.dispose();
    });

    group('Singleton Pattern', () {
      test('should return the same instance', () {
        // Act
        final instance1 = app_location.LocationService.instance;
        final instance2 = app_location.LocationService.instance;

        // Assert
        expect(instance1, same(instance2));
      });
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        // Assert
        expect(locationService.currentPosition, isNull);
        expect(locationService.cachedLocation, isNull);
        expect(locationService.isLocationEnabled, isFalse);
        expect(locationService.permissionStatus, equals(PermissionStatus.denied));
        expect(locationService.isCacheValid, isFalse);
      });
    });

    group('Distance Calculations', () {
      test('should calculate distance between two coordinates in meters', () {
        // Arrange
        const lat1 = -23.5505; // São Paulo
        const lng1 = -46.6333;
        const lat2 = -22.9068; // Rio de Janeiro
        const lng2 = -43.1729;

        // Act
        final distance = locationService.calculateDistance(lat1, lng1, lat2, lng2);

        // Assert
        expect(distance, greaterThan(350000)); // Aproximadamente 357km
        expect(distance, lessThan(400000));
      });

      test('should calculate distance between two coordinates in kilometers', () {
        // Arrange
        const lat1 = -23.5505; // São Paulo
        const lng1 = -46.6333;
        const lat2 = -22.9068; // Rio de Janeiro
        const lng2 = -43.1729;

        // Act
        final distance = locationService.calculateDistanceInKm(lat1, lng1, lat2, lng2);

        // Assert
        expect(distance, greaterThan(350)); // Aproximadamente 357km
        expect(distance, lessThan(400));
      });

      test('should return zero distance for same coordinates', () {
        // Arrange
        const lat = -23.5505;
        const lng = -46.6333;

        // Act
        final distance = locationService.calculateDistance(lat, lng, lat, lng);

        // Assert
        expect(distance, equals(0.0));
      });
    });

    group('Location Bounds', () {
      test('should correctly identify location within bounds', () {
        // Arrange
        const latitude = -23.5505;
        const longitude = -46.6333;
        const northEastLat = -23.0;
        const northEastLng = -46.0;
        const southWestLat = -24.0;
        const southWestLng = -47.0;

        // Act
        final isInBounds = locationService.isLocationInBounds(
          latitude,
          longitude,
          northEastLat,
          northEastLng,
          southWestLat,
          southWestLng,
        );

        // Assert
        expect(isInBounds, isTrue);
      });

      test('should correctly identify location outside bounds', () {
        // Arrange
        const latitude = -25.0; // Fora dos limites
        const longitude = -46.6333;
        const northEastLat = -23.0;
        const northEastLng = -46.0;
        const southWestLat = -24.0;
        const southWestLng = -47.0;

        // Act
        final isInBounds = locationService.isLocationInBounds(
          latitude,
          longitude,
          northEastLat,
          northEastLng,
          southWestLat,
          southWestLng,
        );

        // Assert
        expect(isInBounds, isFalse);
      });
    });

    group('Location Utilities', () {
      test('should find nearest location from a list', () {
        // Arrange
        const userLocation = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );
        
        final locations = [
          const LocationModel(latitude: -23.5600, longitude: -46.6400), // Próximo
          const LocationModel(latitude: -22.9068, longitude: -43.1729), // Rio - Longe
          const LocationModel(latitude: -23.5510, longitude: -46.6340), // Muito próximo
        ];

        // Act
        final nearest = locationService.findNearestLocation(userLocation, locations);

        // Assert
        expect(nearest, isNotNull);
        expect(nearest!.latitude, equals(-23.5510));
        expect(nearest.longitude, equals(-46.6340));
      });

      test('should filter locations by radius', () {
        // Arrange
        const center = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );
        
        final locations = [
          const LocationModel(latitude: -23.5510, longitude: -46.6340), // ~1km
          const LocationModel(latitude: -22.9068, longitude: -43.1729), // ~357km
          const LocationModel(latitude: -23.5500, longitude: -46.6330), // ~500m
        ];
        
        const radiusInMeters = 2000.0; // 2km

        // Act
        final filtered = locationService.filterLocationsByRadius(
          center,
          locations,
          radiusInMeters,
        );

        // Assert
        expect(filtered.length, equals(2)); // Apenas as duas primeiras
        expect(filtered.any((loc) => loc.latitude == -22.9068), isFalse);
      });

      test('should calculate bearing between two coordinates', () {
        // Arrange
        const startLat = -23.5505;
        const startLng = -46.6333;
        const endLat = -22.9068;
        const endLng = -43.1729;

        // Act
        final bearing = locationService.calculateBearing(
          startLat,
          startLng,
          endLat,
          endLng,
        );

        // Assert
        expect(bearing, isA<double>());
        expect(bearing, greaterThanOrEqualTo(0));
        expect(bearing, lessThanOrEqualTo(360));
      });
    });

    group('Settings Management', () {
      test('should update location settings', () {
        // Arrange
        const newSettings = app_location.LocationSettings(
          accuracy: LocationAccuracy.low,
          timeout: Duration(seconds: 10),
          distanceFilter: 5,
        );

        // Act
        locationService.updateSettings(newSettings);

        // Assert
        // Como não temos acesso direto às configurações privadas,
        // verificamos se o método executa sem erro
        expect(() => locationService.updateSettings(newSettings), returnsNormally);
      });
    });

    group('Data Management', () {
      test('should clear location data', () {
        // Act
        locationService.clearLocationData();

        // Assert
        expect(locationService.currentPosition, isNull);
        expect(locationService.cachedLocation, isNull);
        expect(locationService.isLocationEnabled, isFalse);
        expect(locationService.permissionStatus, equals(PermissionStatus.denied));
        expect(locationService.isCacheValid, isFalse);
      });

      test('should dispose resources', () {
        // Act & Assert
        expect(() => locationService.dispose(), returnsNormally);
      });
    });
  });

  group('Location Exceptions Tests', () {
    test('should create LocationException with message', () {
      // Arrange
      const message = 'Test error message';
      
      // Act
      final exception = app_location.LocationException(message);
      
      // Assert
      expect(exception.message, equals(message));
      expect(exception.toString(), equals('LocationException: $message'));
    });

    test('should create LocationServiceDisabledException', () {
      // Arrange
      const message = 'Service disabled';
      
      // Act
      final exception = app_location.LocationServiceDisabledException(message);
      
      // Assert
      expect(exception, isA<app_location.LocationException>());
      expect(exception.message, equals(message));
    });

    test('should create LocationPermissionDeniedException', () {
      // Arrange
      const message = 'Permission denied';
      
      // Act
      final exception = app_location.LocationPermissionDeniedException(message);
      
      // Assert
      expect(exception, isA<app_location.LocationException>());
      expect(exception.message, equals(message));
    });

    test('should create LocationTimeoutException', () {
      // Arrange
      const message = 'Timeout occurred';
      
      // Act
      final exception = app_location.LocationTimeoutException(message);
      
      // Assert
      expect(exception, isA<app_location.LocationException>());
      expect(exception.message, equals(message));
    });
  });
}
