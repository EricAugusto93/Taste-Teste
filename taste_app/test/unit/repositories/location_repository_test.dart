import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import 'package:taste_app/data/repositories/location_repository.dart';
import 'package:taste_app/data/models/location_model.dart';
import 'package:taste_app/data/services/location/location_service.dart';

import 'location_repository_test.mocks.dart';

@GenerateMocks([LocationService])
void main() {
  group('LocationRepository', () {
    late LocationRepository repository;
    late MockLocationService mockLocationService;

    setUp(() {
      mockLocationService = MockLocationService();
      repository = LocationRepository.withService(mockLocationService);
    });

    group('getCurrentLocation', () {
      test('should return LocationModel when position is obtained successfully',
          () async {
        // Arrange
        final mockPosition = Position(
          latitude: -23.5505,
          longitude: -46.6333,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(mockLocationService.getCurrentLocation(forceRefresh: false))
            .thenAnswer((_) async => mockPosition);
        when(mockLocationService.isCacheValid).thenReturn(true);

        // Act
        final result = await repository.getCurrentLocation();

        // Assert
        expect(result, isNotNull);
        expect(result!.latitude, equals(-23.5505));
        expect(result.longitude, equals(-46.6333));
        expect(result.accuracy, equals(10.0));
      });

      test('should return null when position cannot be obtained', () async {
        // Arrange
        when(mockLocationService.getCurrentLocation(forceRefresh: false))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentLocation();

        // Assert
        expect(result, isNull);
      });

      test('should return null when exception occurs', () async {
        // Arrange
        when(mockLocationService.getCurrentLocation(forceRefresh: false))
            .thenThrow(Exception('Location error'));

        // Act
        final result = await repository.getCurrentLocation();

        // Assert
        expect(result, isNull);
      });

      test('should force refresh when forceRefresh is true', () async {
        // Arrange
        final mockPosition = Position(
          latitude: -23.5505,
          longitude: -46.6333,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(mockLocationService.getCurrentLocation(forceRefresh: true))
            .thenAnswer((_) async => mockPosition);

        // Act
        final result = await repository.getCurrentLocation(forceRefresh: true);

        // Assert
        expect(result, isNotNull);
        verify(mockLocationService.getCurrentLocation(forceRefresh: true))
            .called(1);
      });
    });

    group('isLocationServiceEnabled', () {
      test('should return true when location service is enabled', () async {
        // Arrange
        when(mockLocationService.checkLocationService())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.isLocationServiceEnabled();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when location service is disabled', () async {
        // Arrange
        when(mockLocationService.checkLocationService())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.isLocationServiceEnabled();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when exception occurs', () async {
        // Arrange
        when(mockLocationService.checkLocationService())
            .thenThrow(Exception('Service error'));

        // Act
        final result = await repository.isLocationServiceEnabled();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getLocationPermissionStatus', () {
      test('should return granted when permission is granted', () async {
        // Arrange
        when(mockLocationService.checkLocationPermission())
            .thenAnswer((_) async => PermissionStatus.granted);

        // Act
        final result = await repository.getLocationPermissionStatus();

        // Assert
        expect(result, equals(PermissionStatus.granted));
      });

      test('should return denied when permission is denied', () async {
        // Arrange
        when(mockLocationService.checkLocationPermission())
            .thenAnswer((_) async => PermissionStatus.denied);

        // Act
        final result = await repository.getLocationPermissionStatus();

        // Assert
        expect(result, equals(PermissionStatus.denied));
      });

      test('should return denied when exception occurs', () async {
        // Arrange
        when(mockLocationService.checkLocationPermission())
            .thenThrow(Exception('Permission error'));

        // Act
        final result = await repository.getLocationPermissionStatus();

        // Assert
        expect(result, equals(PermissionStatus.denied));
      });
    });

    group('requestLocationPermission', () {
      test('should return granted when permission is granted', () async {
        // Arrange
        when(mockLocationService.requestLocationPermission())
            .thenAnswer((_) async => PermissionStatus.granted);

        // Act
        final result = await repository.requestLocationPermission();

        // Assert
        expect(result, equals(PermissionStatus.granted));
      });

      test('should return denied when permission is denied', () async {
        // Arrange
        when(mockLocationService.requestLocationPermission())
            .thenAnswer((_) async => PermissionStatus.denied);

        // Act
        final result = await repository.requestLocationPermission();

        // Assert
        expect(result, equals(PermissionStatus.denied));
      });

      test('should return denied when exception occurs', () async {
        // Arrange
        when(mockLocationService.requestLocationPermission())
            .thenThrow(Exception('Request error'));

        // Act
        final result = await repository.requestLocationPermission();

        // Assert
        expect(result, equals(PermissionStatus.denied));
      });
    });

    group('hasAllRequiredPermissions', () {
      test('should return true when all permissions are granted', () async {
        // Arrange
        when(mockLocationService.hasAllPermissions())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.hasAllRequiredPermissions();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when permissions are missing', () async {
        // Arrange
        when(mockLocationService.hasAllPermissions())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.hasAllRequiredPermissions();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when exception occurs', () async {
        // Arrange
        when(mockLocationService.hasAllPermissions())
            .thenThrow(Exception('Permissions error'));

        // Act
        final result = await repository.hasAllRequiredPermissions();

        // Assert
        expect(result, isFalse);
      });
    });

    group('calculateDistanceInMeters', () {
      test('should calculate distance correctly', () {
        // Arrange
        const from = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );
        const to = LocationModel(
          latitude: -23.5506,
          longitude: -46.6334,
        );
        const expectedDistance = 100.0;

        when(mockLocationService.calculateDistance(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        )).thenReturn(expectedDistance);

        // Act
        final result = repository.calculateDistanceInMeters(from, to);

        // Assert
        expect(result, equals(expectedDistance));
      });

      test('should return 0.0 when exception occurs', () {
        // Arrange
        const from = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );
        const to = LocationModel(
          latitude: -23.5506,
          longitude: -46.6334,
        );

        when(mockLocationService.calculateDistance(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        )).thenThrow(Exception('Distance error'));

        // Act
        final result = repository.calculateDistanceInMeters(from, to);

        // Assert
        expect(result, equals(0.0));
      });
    });

    group('calculateDistanceInKilometers', () {
      test('should calculate distance in km correctly', () {
        // Arrange
        const from = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );
        const to = LocationModel(
          latitude: -23.5506,
          longitude: -46.6334,
        );
        const expectedDistance = 0.1;

        when(mockLocationService.calculateDistanceInKm(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        )).thenReturn(expectedDistance);

        // Act
        final result = repository.calculateDistanceInKilometers(from, to);

        // Assert
        expect(result, equals(expectedDistance));
      });

      test('should return 0.0 when exception occurs', () {
        // Arrange
        const from = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );
        const to = LocationModel(
          latitude: -23.5506,
          longitude: -46.6334,
        );

        when(mockLocationService.calculateDistanceInKm(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        )).thenThrow(Exception('Distance error'));

        // Act
        final result = repository.calculateDistanceInKilometers(from, to);

        // Assert
        expect(result, equals(0.0));
      });
    });

    group('formatDistanceForDisplay', () {
      test('should format distance correctly', () {
        // Arrange
        const distance = 1500.0;
        const expectedFormat = '1.5 km';

        when(mockLocationService.formatDistance(distance))
            .thenReturn(expectedFormat);

        // Act
        final result = repository.formatDistanceForDisplay(distance);

        // Assert
        expect(result, equals(expectedFormat));
      });

      test('should return N/A when exception occurs', () {
        // Arrange
        const distance = 1500.0;

        when(mockLocationService.formatDistance(distance))
            .thenThrow(Exception('Format error'));

        // Act
        final result = repository.formatDistanceForDisplay(distance);

        // Assert
        expect(result, equals('N/A'));
      });
    });

    group('getCachedLocation', () {
      test('should return cached location when cache is valid', () {
        // Arrange
        const cachedLocation = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );

        when(mockLocationService.cachedLocation).thenReturn(cachedLocation);
        when(mockLocationService.isCacheValid).thenReturn(true);

        // Act
        final result = repository.getCachedLocation();

        // Assert
        expect(result, equals(cachedLocation));
      });

      test('should return null when cache is invalid', () {
        // Arrange
        const cachedLocation = LocationModel(
          latitude: -23.5505,
          longitude: -46.6333,
        );

        when(mockLocationService.cachedLocation).thenReturn(cachedLocation);
        when(mockLocationService.isCacheValid).thenReturn(false);

        // Act
        final result = repository.getCachedLocation();

        // Assert
        expect(result, isNull);
      });

      test('should return null when cache is empty', () {
        // Arrange
        when(mockLocationService.cachedLocation).thenReturn(null);
        when(mockLocationService.isCacheValid).thenReturn(true);

        // Act
        final result = repository.getCachedLocation();

        // Assert
        expect(result, isNull);
      });

      test('should return null when exception occurs', () {
        // Arrange
        when(mockLocationService.cachedLocation)
            .thenThrow(Exception('Cache error'));

        // Act
        final result = repository.getCachedLocation();

        // Assert
        expect(result, isNull);
      });
    });

    group('isCacheValid', () {
      test('should return true when cache is valid', () {
        // Arrange
        when(mockLocationService.isCacheValid).thenReturn(true);

        // Act
        final result = repository.isCacheValid();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when cache is invalid', () {
        // Arrange
        when(mockLocationService.isCacheValid).thenReturn(false);

        // Act
        final result = repository.isCacheValid();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when exception occurs', () {
        // Arrange
        when(mockLocationService.isCacheValid)
            .thenThrow(Exception('Cache error'));

        // Act
        final result = repository.isCacheValid();

        // Assert
        expect(result, isFalse);
      });
    });

    group('openAppSettings', () {
      test('should return true when settings are opened successfully',
          () async {
        // Arrange
        when(mockLocationService.openAppSettings())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.openAppSettings();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when settings cannot be opened', () async {
        // Arrange
        when(mockLocationService.openAppSettings())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.openAppSettings();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when exception occurs', () async {
        // Arrange
        when(mockLocationService.openAppSettings())
            .thenThrow(Exception('Settings error'));

        // Act
        final result = await repository.openAppSettings();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
