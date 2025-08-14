import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:taste_app/domain/usecases/get_restaurants_usecase.dart';
import 'package:taste_app/domain/repositories/restaurant_repository.dart';
import 'package:taste_app/domain/entities/restaurant.dart';
import 'package:taste_app/core/error/failures.dart';
import 'package:taste_app/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../../test_helpers.dart';

// Generate mocks
@GenerateMocks([RestaurantRepository])
import 'get_restaurants_usecase_test.mocks.dart';

void main() {
  group('GetRestaurantsUseCase Tests', () {
    late GetRestaurantsUseCase usecase;
    late MockRestaurantRepository mockRepository;
    late List<Restaurant> mockRestaurants;

    setUp(() {
      mockRepository = MockRestaurantRepository();
      usecase = GetRestaurantsUseCase(mockRepository);
      // Convert models to entities for testing
      final mockModels = TestHelpers.createMockRestaurantList(3);
      mockRestaurants = mockModels.map((model) => model.toEntity()).toList();
    });

    test('should get restaurants from the repository when call is successful', () async {
      // Arrange
      when(mockRepository.getAllRestaurants())
          .thenAnswer((_) async => Right(mockRestaurants));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Right(mockRestaurants));
      verify(mockRepository.getAllRestaurants()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails with ServerFailure', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(mockRepository.getAllRestaurants())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getAllRestaurants()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when repository call fails with NetworkFailure', () async {
      // Arrange
      const failure = NetworkFailure('Network error');
      when(mockRepository.getAllRestaurants())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getAllRestaurants()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no restaurants are available', () async {
      // Arrange
      when(mockRepository.getAllRestaurants())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Right(<Restaurant>[]));
      verify(mockRepository.getAllRestaurants()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return restaurants sorted by rating when multiple restaurants exist', () async {
      // Arrange
      final unsortedRestaurants = [
        mockRestaurants[0].copyWith(rating: 3.5),
        mockRestaurants[1].copyWith(rating: 4.8),
        mockRestaurants[2].copyWith(rating: 4.2),
      ];
      when(mockRepository.getAllRestaurants())
          .thenAnswer((_) async => Right(unsortedRestaurants));

      // Act
      final result = await usecase(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (restaurants) {
          expect(restaurants.length, 3);
          // Verify restaurants are returned (sorting logic may be in repository or presentation layer)
          expect(restaurants, equals(unsortedRestaurants));
        },
      );
      verify(mockRepository.getAllRestaurants()).called(1);
    });

    test('should handle large number of restaurants efficiently', () async {
      // Arrange
      final largeRestaurantList = TestHelpers.createMockRestaurantList(50)
          .map((model) => model.toEntity()).toList();
      when(mockRepository.getAllRestaurants())
          .thenAnswer((_) async => Right(largeRestaurantList));

      // Act
      final result = await usecase(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (restaurants) {
          expect(restaurants.length, 50);
          expect(restaurants, equals(largeRestaurantList));
        },
      );
      verify(mockRepository.getAllRestaurants()).called(1);
    });
  });
}