import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:taste_app/domain/entities/category.dart';
import 'package:taste_app/domain/repositories/category_repository.dart';
import 'package:taste_app/presentation/providers/category_provider.dart';
import 'package:taste_app/core/error/failures.dart';

import 'category_provider_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  group('CategoryProvider', () {
    late MockCategoryRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockCategoryRepository();
      container = ProviderContainer(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('categoriesProvider', () {
      test('should return list of categories when repository call is successful', () async {
        // Arrange
        final categories = <Category>[
          Category(
            id: '1',
            name: 'Pizza',
            description: 'Delicious pizzas',
            icon: 'pizza',
            color: '#FF5722',
            isActive: true,
            sortOrder: 1,
            createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
            updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
          ),
          Category(
            id: '2',
            name: 'Burger',
            description: 'Tasty burgers',
            icon: 'burger',
            color: '#4CAF50',
            isActive: true,
            sortOrder: 2,
            createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
            updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
          ),
        ];

        when(mockRepository.getAllCategories())
            .thenAnswer((_) async => Right(categories));

        // Act
        final result = await container.read(categoriesProvider.future);

        // Assert
        expect(result, equals(categories));
        verify(mockRepository.getAllCategories()).called(1);
      });

      test('should throw exception when repository call fails', () async {
        // Arrange
        const failure = ServerFailure('Server error');
        when(mockRepository.getAllCategories())
            .thenAnswer((_) async => const Left(failure));

        // Act & Assert
        expect(
          () => container.read(categoriesProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('activeCategoriesProvider', () {
      test('should return list of active categories when repository call is successful', () async {
        // Arrange
        final activeCategories = <Category>[
          Category(
            id: '1',
            name: 'Pizza',
            description: 'Delicious pizzas',
            icon: 'pizza',
            color: '#FF5722',
            isActive: true,
            sortOrder: 1,
            createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
            updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
          ),
        ];

        when(mockRepository.getActiveCategories())
            .thenAnswer((_) async => Right(activeCategories));

        // Act
        final result = await container.read(activeCategoriesProvider.future);

        // Assert
        expect(result, equals(activeCategories));
        verify(mockRepository.getActiveCategories()).called(1);
      });

      test('should throw exception when repository call fails', () async {
        // Arrange
        const failure = ServerFailure('Server error');
        when(mockRepository.getActiveCategories())
            .thenAnswer((_) async => const Left(failure));

        // Act & Assert
        expect(
          () => container.read(activeCategoriesProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('categoryByIdProvider', () {
      test('should return category when repository call is successful', () async {
        // Arrange
        const categoryId = '1';
        final category = Category(
          id: '1',
          name: 'Pizza',
          description: 'Delicious pizzas',
          icon: 'pizza',
          color: '#FF5722',
          isActive: true,
          sortOrder: 1,
          createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
        );

        when(mockRepository.getCategoryById(categoryId))
            .thenAnswer((_) async => Right(category));

        // Act
        final result = await container.read(categoryByIdProvider(categoryId).future);

        // Assert
        expect(result, equals(category));
        verify(mockRepository.getCategoryById(categoryId)).called(1);
      });

      test('should throw exception when repository call fails', () async {
        // Arrange
        const categoryId = '1';
        const failure = ServerFailure('Category not found');
        when(mockRepository.getCategoryById(categoryId))
            .thenAnswer((_) async => const Left(failure));

        // Act & Assert
        expect(
          () => container.read(categoryByIdProvider(categoryId).future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('popularCategoriesProvider', () {
      test('should return first 6 active categories', () async {
        // Arrange
        final activeCategories = List<Category>.generate(10, (index) => Category(
          id: '${index + 1}',
          name: 'Category ${index + 1}',
          description: 'Description ${index + 1}',
          icon: 'category${index + 1}',
          color: '#FF5722',
          isActive: true,
          sortOrder: index + 1,
          createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
        ));

        when(mockRepository.getActiveCategories())
            .thenAnswer((_) async => Right(activeCategories));

        // Act
        final result = await container.read(popularCategoriesProvider.future);

        // Assert
        expect(result.length, equals(6));
        expect(result, equals(activeCategories.take(6).toList()));
      });

      test('should return all categories if less than 6 active categories exist', () async {
        // Arrange
        final activeCategories = List<Category>.generate(3, (index) => Category(
          id: '${index + 1}',
          name: 'Category ${index + 1}',
          description: 'Description ${index + 1}',
          icon: 'category${index + 1}',
          color: '#FF5722',
          isActive: true,
          sortOrder: index + 1,
          createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
        ));

        when(mockRepository.getActiveCategories())
            .thenAnswer((_) async => Right(activeCategories));

        // Act
        final result = await container.read(popularCategoriesProvider.future);

        // Assert
        expect(result.length, equals(3));
        expect(result, equals(activeCategories));
      });
    });

    group('categoryExistsProvider', () {
      test('should return true when category exists', () async {
        // Arrange
        const categoryId = '1';
        final category = Category(
          id: '1',
          name: 'Pizza',
          description: 'Delicious pizzas',
          icon: 'pizza',
          color: '#FF5722',
          isActive: true,
          sortOrder: 1,
          createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
        );

        when(mockRepository.getCategoryById(categoryId))
            .thenAnswer((_) async => Right(category));

        // Act
        final result = await container.read(categoryExistsProvider(categoryId).future);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when category does not exist', () async {
        // Arrange
        const categoryId = '999';
        const failure = ServerFailure('Category not found');
        when(mockRepository.getCategoryById(categoryId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await container.read(categoryExistsProvider(categoryId).future);

        // Assert
        expect(result, isFalse);
      });
    });
  });
}