import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:taste_app/data/repositories/favorite_repository.dart';
import 'package:taste_app/data/models/favorite_model.dart';
import '../../test_helpers.dart';

// Generate mocks
@GenerateMocks([FavoriteRepository])
import 'favorite_repository_test.mocks.dart';

void main() {
  group('FavoriteRepository Tests', () {
    late MockFavoriteRepository mockRepository;
    late FavoriteModel mockFavorite;

    setUp(() {
      mockRepository = MockFavoriteRepository();
      mockFavorite = TestHelpers.createMockFavorite();
    });

    group('getUserFavorites', () {
      test('should return user favorites when call is successful', () async {
        // Arrange
        const userId = 'test_user_1';
        final mockFavorites = [mockFavorite];
        when(mockRepository.getUserFavorites(any))
            .thenAnswer((_) async => mockFavorites);

        // Act
        final result = await mockRepository.getUserFavorites(userId);

        // Assert
        expect(result, equals(mockFavorites));
        verify(mockRepository.getUserFavorites(userId)).called(1);
      });

      test('should return empty list when user has no favorites', () async {
        // Arrange
        const userId = 'test_user_1';
        when(mockRepository.getUserFavorites(any))
            .thenAnswer((_) async => []);

        // Act
        final result = await mockRepository.getUserFavorites(userId);

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getUserFavorites(userId)).called(1);
      });
    });

    group('addToFavorites', () {
      test('should add favorite successfully', () async {
        // Arrange
        const userId = 'test_user_1';
        const restaurantId = 'test_restaurant_1';
        when(mockRepository.addToFavorites(any, any))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockRepository.addToFavorites(userId, restaurantId);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.addToFavorites(userId, restaurantId)).called(1);
      });

      test('should return false when adding favorite fails', () async {
        // Arrange
        const userId = 'test_user_1';
        const restaurantId = 'test_restaurant_1';
        when(mockRepository.addToFavorites(any, any))
            .thenAnswer((_) async => false);

        // Act
        final result = await mockRepository.addToFavorites(userId, restaurantId);

        // Assert
        expect(result, isFalse);
        verify(mockRepository.addToFavorites(userId, restaurantId)).called(1);
      });
    });

    group('removeFromFavorites', () {
      test('should remove favorite successfully', () async {
        // Arrange
        const userId = 'test_user_1';
        const restaurantId = 'test_restaurant_1';
        when(mockRepository.removeFromFavorites(any, any))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockRepository.removeFromFavorites(userId, restaurantId);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.removeFromFavorites(userId, restaurantId)).called(1);
      });

      test('should return false when removing favorite fails', () async {
        // Arrange
        const userId = 'test_user_1';
        const restaurantId = 'test_restaurant_1';
        when(mockRepository.removeFromFavorites(any, any))
            .thenAnswer((_) async => false);

        // Act
        final result = await mockRepository.removeFromFavorites(userId, restaurantId);

        // Assert
        expect(result, isFalse);
        verify(mockRepository.removeFromFavorites(userId, restaurantId)).called(1);
      });
    });

    group('isFavorite', () {
      test('should return true when restaurant is favorited by user', () async {
        // Arrange
        const userId = 'test_user_1';
        const restaurantId = 'test_restaurant_1';
        when(mockRepository.isFavorite(any, any))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockRepository.isFavorite(userId, restaurantId);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.isFavorite(userId, restaurantId)).called(1);
      });

      test('should return false when restaurant is not favorited by user', () async {
        // Arrange
        const userId = 'test_user_1';
        const restaurantId = 'test_restaurant_1';
        when(mockRepository.isFavorite(any, any))
            .thenAnswer((_) async => false);

        // Act
        final result = await mockRepository.isFavorite(userId, restaurantId);

        // Assert
        expect(result, isFalse);
        verify(mockRepository.isFavorite(userId, restaurantId)).called(1);
      });
    });

    group('toggleFavorite', () {
      test('should toggle favorite successfully', () async {
        // Arrange
        const userId = 'test_user_1';
        const restaurantId = 'test_restaurant_1';
        when(mockRepository.toggleFavorite(any, any))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockRepository.toggleFavorite(userId, restaurantId);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.toggleFavorite(userId, restaurantId)).called(1);
      });
    });

    group('getFavoritesWithRestaurants', () {
      test('should return favorites with restaurant details', () async {
        // Arrange
        const userId = 'test_user_1';
        final favoritesWithRestaurants = [mockFavorite];
        when(mockRepository.getFavoritesWithRestaurants(any))
            .thenAnswer((_) async => favoritesWithRestaurants);

        // Act
        final result = await mockRepository.getFavoritesWithRestaurants(userId);

        // Assert
        expect(result, equals(favoritesWithRestaurants));
        verify(mockRepository.getFavoritesWithRestaurants(userId)).called(1);
      });
    });
  });
}