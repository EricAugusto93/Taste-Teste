import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:taste_app/data/repositories/restaurant_repository.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import '../../test_helpers.dart';

// Generate mocks
@GenerateMocks([RestaurantRepository])
import 'restaurant_repository_test.mocks.dart';

void main() {
  group('RestaurantRepository Tests', () {
    late MockRestaurantRepository mockRepository;
    late List<RestaurantModel> mockRestaurants;

    setUp(() {
      mockRepository = MockRestaurantRepository();
      mockRestaurants = TestHelpers.createMockRestaurantList(3);
    });

    group('getRestaurants', () {
      test('should return restaurants when call is successful', () async {
        // Arrange
        when(mockRepository.getRestaurants())
            .thenAnswer((_) async => mockRestaurants);

        // Act
        final result = await mockRepository.getRestaurants();

        // Assert
        expect(result, equals(mockRestaurants));
        verify(mockRepository.getRestaurants()).called(1);
      });

      test('should return filtered restaurants by category', () async {
        // Arrange
        const categoryId = 'italian';
        final filteredRestaurants = [mockRestaurants.first];
        when(mockRepository.getRestaurants(categoryId: categoryId))
            .thenAnswer((_) async => filteredRestaurants);

        // Act
        final result =
            await mockRepository.getRestaurants(categoryId: categoryId);

        // Assert
        expect(result, equals(filteredRestaurants));
        verify(mockRepository.getRestaurants(categoryId: categoryId)).called(1);
      });

      test('should return featured restaurants only', () async {
        // Arrange
        final featuredRestaurants = [mockRestaurants.first];
        when(mockRepository.getRestaurants(isFeatured: true))
            .thenAnswer((_) async => featuredRestaurants);

        // Act
        final result = await mockRepository.getRestaurants(isFeatured: true);

        // Assert
        expect(result, equals(featuredRestaurants));
        verify(mockRepository.getRestaurants(isFeatured: true)).called(1);
      });
    });

    group('getRestaurantById', () {
      test('should return restaurant when found', () async {
        // Arrange
        final mockRestaurant = TestHelpers.createMockRestaurant();
        when(mockRepository.getRestaurantById(any))
            .thenAnswer((_) async => mockRestaurant);

        // Act
        final result = await mockRepository.getRestaurantById('test_id');

        // Assert
        expect(result, equals(mockRestaurant));
        verify(mockRepository.getRestaurantById('test_id')).called(1);
      });

      test('should return null when restaurant not found', () async {
        // Arrange
        when(mockRepository.getRestaurantById(any))
            .thenAnswer((_) async => null);

        // Act
        final result = await mockRepository.getRestaurantById('invalid_id');

        // Assert
        expect(result, isNull);
        verify(mockRepository.getRestaurantById('invalid_id')).called(1);
      });
    });

    group('searchRestaurants', () {
      test('should return filtered restaurants when search is successful',
          () async {
        // Arrange
        const searchQuery = 'pizza';
        final filteredRestaurants = [mockRestaurants.first];
        when(mockRepository.searchRestaurants(any))
            .thenAnswer((_) async => filteredRestaurants);

        // Act
        final result = await mockRepository.searchRestaurants(searchQuery);

        // Assert
        expect(result, equals(filteredRestaurants));
        verify(mockRepository.searchRestaurants(searchQuery)).called(1);
      });

      test('should return empty list when no restaurants match search',
          () async {
        // Arrange
        when(mockRepository.searchRestaurants(any)).thenAnswer((_) async => []);

        // Act
        final result = await mockRepository.searchRestaurants('nonexistent');

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.searchRestaurants('nonexistent')).called(1);
      });
    });

    group('getFeaturedRestaurants', () {
      test('should return featured restaurants with default limit', () async {
        // Arrange
        final featuredRestaurants = [mockRestaurants.first];
        when(mockRepository.getFeaturedRestaurants())
            .thenAnswer((_) async => featuredRestaurants);

        // Act
        final result = await mockRepository.getFeaturedRestaurants();

        // Assert
        expect(result, equals(featuredRestaurants));
        verify(mockRepository.getFeaturedRestaurants()).called(1);
      });

      test('should return featured restaurants with custom limit', () async {
        // Arrange
        final featuredRestaurants = mockRestaurants.take(2).toList();
        when(mockRepository.getFeaturedRestaurants(limit: 2))
            .thenAnswer((_) async => featuredRestaurants);

        // Act
        final result = await mockRepository.getFeaturedRestaurants(limit: 2);

        // Assert
        expect(result, equals(featuredRestaurants));
        verify(mockRepository.getFeaturedRestaurants(limit: 2)).called(1);
      });
    });

    group('getNearbyRestaurants', () {
      test('should return nearby restaurants when location is provided',
          () async {
        // Arrange
        const latitude = -23.5505;
        const longitude = -46.6333;
        const radiusKm = 5.0;
        when(mockRepository.getNearbyRestaurants(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        )).thenAnswer((_) async => mockRestaurants);

        // Act
        final result = await mockRepository.getNearbyRestaurants(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );

        // Assert
        expect(result, equals(mockRestaurants));
        verify(mockRepository.getNearbyRestaurants(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        )).called(1);
      });

      test('should return restaurants with default parameters', () async {
        // Arrange
        const latitude = -23.5505;
        const longitude = -46.6333;
        when(mockRepository.getNearbyRestaurants(
          latitude: latitude,
          longitude: longitude,
        )).thenAnswer((_) async => mockRestaurants);

        // Act
        final result = await mockRepository.getNearbyRestaurants(
          latitude: latitude,
          longitude: longitude,
        );

        // Assert
        expect(result, equals(mockRestaurants));
        verify(mockRepository.getNearbyRestaurants(
          latitude: latitude,
          longitude: longitude,
        )).called(1);
      });
    });
  });
}
