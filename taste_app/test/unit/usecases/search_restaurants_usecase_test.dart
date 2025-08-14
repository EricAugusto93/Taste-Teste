import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:taste_app/domain/usecases/search_restaurants_usecase.dart';
import 'package:taste_app/domain/repositories/restaurant_repository.dart';
import 'package:taste_app/domain/entities/restaurant.dart';
import 'package:taste_app/core/error/failures.dart';
import '../../test_helpers.dart';

// Generate mocks
@GenerateMocks([RestaurantRepository])
import 'search_restaurants_usecase_test.mocks.dart';

void main() {
  group('SearchRestaurantsUseCase Tests', () {
    late SearchRestaurantsUseCase usecase;
    late MockRestaurantRepository mockRepository;
    late List<Restaurant> mockRestaurants;

    setUp(() {
      mockRepository = MockRestaurantRepository();
      usecase = SearchRestaurantsUseCase(mockRepository);
      // Convert models to entities for testing
      final mockModels = TestHelpers.createMockRestaurantList(5);
      mockRestaurants = mockModels.map((model) => model.toEntity()).toList();
    });

    test('should search restaurants successfully when query is valid', () async {
      // Arrange
      const searchQuery = 'pizza';
      final expectedRestaurants = [mockRestaurants.first];
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => Right(expectedRestaurants));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, Right(expectedRestaurants));
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no restaurants match search query', () async {
      // Arrange
      const searchQuery = 'nonexistent';
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, const Right(<Restaurant>[]));
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // Arrange
      const searchQuery = 'pizza';
      const failure = ServerFailure('Server error');
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      const searchQuery = 'pizza';
      const failure = NetworkFailure('Network error');
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle empty search query', () async {
      // Arrange
      const searchQuery = '';
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => Right(mockRestaurants));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, Right(mockRestaurants));
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
    });

    test('should handle search query with special characters', () async {
      // Arrange
      const searchQuery = 'café & restaurant!';
      final expectedRestaurants = [mockRestaurants.first];
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => Right(expectedRestaurants));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, Right(expectedRestaurants));
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
    });

    test('should handle very long search query', () async {
      // Arrange
      const searchQuery = 'this is a very long search query that might cause issues if not handled properly by the system';
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, const Right(<Restaurant>[]));
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
    });

    test('should trim whitespace from search query', () async {
      // Arrange
      const searchQuery = '  pizza  ';
      const trimmedQuery = 'pizza';
      final expectedRestaurants = [mockRestaurants.first];
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => Right(expectedRestaurants));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, Right(expectedRestaurants));
      // Verify that the trimmed query is passed to repository
      verify(mockRepository.searchRestaurants(trimmedQuery)).called(1);
    });

    test('should handle case-insensitive search', () async {
      // Arrange
      const searchQuery = 'PIZZA';
      final expectedRestaurants = [mockRestaurants.first];
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => Right(expectedRestaurants));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      expect(result, Right(expectedRestaurants));
      verify(mockRepository.searchRestaurants(searchQuery.toLowerCase())).called(1);
    });

    test('should return multiple restaurants when multiple matches exist', () async {
      // Arrange
      const searchQuery = 'restaurant';
      when(mockRepository.searchRestaurants(any))
          .thenAnswer((_) async => Right(mockRestaurants));

      // Act
      final result = await usecase(const SearchRestaurantsParams(query: searchQuery));

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (restaurants) {
          expect(restaurants.length, mockRestaurants.length);
          expect(restaurants, equals(mockRestaurants));
        },
      );
      verify(mockRepository.searchRestaurants(searchQuery)).called(1);
    });
  });
}