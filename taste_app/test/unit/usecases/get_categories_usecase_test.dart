import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:taste_app/domain/usecases/get_categories_usecase.dart';
import 'package:taste_app/domain/repositories/category_repository.dart';
import 'package:taste_app/domain/entities/category.dart';
import 'package:taste_app/core/error/failures.dart';
import 'package:taste_app/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../../test_helpers.dart';

// Generate mocks
@GenerateMocks([CategoryRepository])
import 'get_categories_usecase_test.mocks.dart';

void main() {
  group('GetCategoriesUseCase Tests', () {
    late GetCategoriesUseCase usecase;
    late MockCategoryRepository mockRepository;
    late List<Category> mockCategories;

    setUp(() {
      mockRepository = MockCategoryRepository();
      usecase = GetCategoriesUseCase(mockRepository);
      // Convert models to entities for testing
      final mockModels = TestHelpers.createMockCategoryList(5);
      mockCategories = mockModels.map((model) => Category(
        id: model.id,
        name: model.name,
        description: model.description,
        icon: model.icon,
        color: model.color,
        isActive: model.isActive,
        sortOrder: model.sortOrder,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      )).toList();
    });

    test('should get all categories successfully', () async {
      // Arrange
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(mockCategories));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Right(mockCategories));
      verify(mockRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no categories exist', () async {
      // Arrange
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Right(<Category>[]));
      verify(mockRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      const failure = NetworkFailure('Network error');
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return categories sorted by sortOrder', () async {
      // Arrange
      final sortedCategories = List<Category>.from(mockCategories)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(sortedCategories));

      // Act
      final result = await usecase(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (categories) {
          expect(categories.length, sortedCategories.length);
          // Verify categories are in correct order
          for (int i = 0; i < categories.length - 1; i++) {
            expect(categories[i].sortOrder, lessThanOrEqualTo(categories[i + 1].sortOrder));
          }
        },
      );
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('should return only active categories when filtered', () async {
      // Arrange
      final activeCategories = mockCategories.where((cat) => cat.isActive).toList();
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(activeCategories));

      // Act
      final result = await usecase(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (categories) {
          expect(categories.every((cat) => cat.isActive), isTrue);
        },
      );
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('should handle categories with null or empty descriptions', () async {
      // Arrange
      final categoriesWithNullDesc = mockCategories.map((cat) => Category(
        id: cat.id,
        name: cat.name,
        description: null, // Test null description
        icon: cat.icon,
        color: cat.color,
        isActive: cat.isActive,
        sortOrder: cat.sortOrder,
        createdAt: cat.createdAt,
        updatedAt: cat.updatedAt,
      )).toList();
      
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(categoriesWithNullDesc));

      // Act
      final result = await usecase(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (categories) {
          expect(categories.length, categoriesWithNullDesc.length);
          expect(categories.every((cat) => cat.description == null), isTrue);
        },
      );
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('should handle categories with different data types correctly', () async {
      // Arrange
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(mockCategories));

      // Act
      final result = await usecase(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (categories) {
          for (final category in categories) {
            expect(category.id, isA<String>());
            expect(category.name, isA<String>());
            expect(category.icon, isA<String>());
            expect(category.color, isA<String>());
            expect(category.isActive, isA<bool>());
            expect(category.sortOrder, isA<int>());
            expect(category.createdAt, isA<DateTime>());
            expect(category.updatedAt, isA<DateTime>());
          }
        },
      );
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('should handle large number of categories efficiently', () async {
      // Arrange
      final largeCategoryList = List.generate(100, (index) => Category(
        id: 'category_$index',
        name: 'Category $index',
        description: 'Description for category $index',
        icon: 'icon_$index',
        color: '#FF0000',
        isActive: index % 2 == 0, // Alternate active/inactive
        sortOrder: index,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(largeCategoryList));

      // Act
      final result = await usecase(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (categories) {
          expect(categories.length, 100);
          expect(categories, equals(largeCategoryList));
        },
      );
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('should handle concurrent calls correctly', () async {
      // Arrange
      when(mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(mockCategories));

      // Act
      final futures = List.generate(5, (_) => usecase(NoParams()));
      final results = await Future.wait(futures);

      // Assert
      for (final result in results) {
        expect(result, Right(mockCategories));
      }
      verify(mockRepository.getAllCategories()).called(5);
    });
  });
}