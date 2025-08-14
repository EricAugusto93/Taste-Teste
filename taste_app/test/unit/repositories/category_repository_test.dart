import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:taste_app/data/repositories/category_repository_impl.dart';
import 'package:taste_app/data/datasources/category_remote_data_source.dart';
import 'package:taste_app/data/models/category_model.dart';
import 'package:taste_app/domain/entities/category.dart';
import 'package:taste_app/core/error/failures.dart';
import 'package:taste_app/core/error/exceptions.dart';
import 'package:dartz/dartz.dart';
import '../../test_helpers.dart';

// Generate mocks
@GenerateMocks([CategoryRemoteDataSource])
import 'category_repository_test.mocks.dart';

void main() {
  group('CategoryRepository Tests', () {
    late CategoryRepositoryImpl repository;
    late MockCategoryRemoteDataSource mockRemoteDataSource;
    late List<CategoryModel> mockCategoryModels;
    late List<Category> expectedCategories;

    setUp(() {
      mockRemoteDataSource = MockCategoryRemoteDataSource();
      repository = CategoryRepositoryImpl(remoteDataSource: mockRemoteDataSource);
      mockCategoryModels = TestHelpers.createMockCategoryList(5);
      expectedCategories = mockCategoryModels.map((model) => model.toEntity()).toList();
    });

    group('getAllCategories', () {
      test('should return categories when remote data source call is successful', () async {
        // Arrange
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => mockCategoryModels);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (categories) => expect(categories.length, expectedCategories.length),
        );
        verify(mockRemoteDataSource.getAllCategories()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return empty list when no categories exist', () async {
        // Arrange
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (categories) => expect(categories, isEmpty),
        );
        verify(mockRemoteDataSource.getAllCategories()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return ServerFailure when remote data source throws ServerException', () async {
        // Arrange
        when(mockRemoteDataSource.getAllCategories())
            .thenThrow(const ServerException('Server error'));

        // Act
        final result = await repository.getAllCategories();

        // Assert
        expect(result, const Left(ServerFailure('Server error')));
        verify(mockRemoteDataSource.getAllCategories()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return NetworkFailure when remote data source throws NetworkException', () async {
        // Arrange
        when(mockRemoteDataSource.getAllCategories())
            .thenThrow(const NetworkException('Network error'));

        // Act
        final result = await repository.getAllCategories();

        // Assert
        expect(result, const Left(NetworkFailure('Network error')));
        verify(mockRemoteDataSource.getAllCategories()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return ServerFailure when remote data source throws unexpected exception', () async {
        // Arrange
        when(mockRemoteDataSource.getAllCategories())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getAllCategories();

        // Assert
        expect(result, const Left(ServerFailure('Unexpected error occurred')));
        verify(mockRemoteDataSource.getAllCategories()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return categories sorted by sortOrder', () async {
        // Arrange
        final unsortedModels = [
          TestHelpers.createMockCategory(id: '3', name: 'Category C', sortOrder: 3),
          TestHelpers.createMockCategory(id: '1', name: 'Category A', sortOrder: 1),
          TestHelpers.createMockCategory(id: '2', name: 'Category B', sortOrder: 2),
        ];
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => unsortedModels);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (categories) {
            expect(categories.length, 3);
            expect(categories[0].name, 'Category A');
            expect(categories[1].name, 'Category B');
            expect(categories[2].name, 'Category C');
          },
        );
        verify(mockRemoteDataSource.getAllCategories()).called(1);
      });

      test('should filter out inactive categories', () async {
        // Arrange
        final mixedModels = [
          TestHelpers.createMockCategory(id: '1', name: 'Active Category', isActive: true),
          TestHelpers.createMockCategory(id: '2', name: 'Inactive Category', isActive: false),
          TestHelpers.createMockCategory(id: '3', name: 'Another Active', isActive: true),
        ];
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => mixedModels);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (categories) {
            expect(categories.length, 2);
            expect(categories.every((cat) => cat.isActive), isTrue);
            expect(categories.map((cat) => cat.name), containsAll(['Active Category', 'Another Active']));
          },
        );
        verify(mockRemoteDataSource.getAllCategories()).called(1);
      });

      test('should handle categories with null descriptions', () async {
        // Arrange
        final categoriesWithNullDesc = [
          TestHelpers.createMockCategory(id: '1', name: 'Category 1', description: null),
          TestHelpers.createMockCategory(id: '2', name: 'Category 2', description: 'Valid description'),
        ];
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => categoriesWithNullDesc);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (categories) {
            expect(categories.length, 2);
            expect(categories[0].description, isNull);
            expect(categories[1].description, 'Valid description');
          },
        );
        verify(mockRemoteDataSource.getAllCategories()).called(1);
      });

      test('should handle large number of categories efficiently', () async {
        // Arrange
        final largeCategoryList = List.generate(100, (index) => 
          TestHelpers.createMockCategory(
            id: 'category_$index',
            name: 'Category $index',
            sortOrder: index,
          )
        );
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => largeCategoryList);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (categories) {
            expect(categories.length, 100);
            // Verify sorting is maintained
            for (int i = 0; i < categories.length - 1; i++) {
              expect(categories[i].sortOrder, lessThanOrEqualTo(categories[i + 1].sortOrder));
            }
          },
        );
        verify(mockRemoteDataSource.getAllCategories()).called(1);
      });

      test('should handle concurrent calls correctly', () async {
        // Arrange
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => mockCategoryModels);

        // Act
        final futures = List<Future<Either<Failure, List<Category>>>>.generate(
          5, (_) => repository.getAllCategories()
        );
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          result.fold(
            (failure) => fail('Expected Right but got Left'),
            (categories) => expect(categories.length, expectedCategories.length),
          );
        }
        verify(mockRemoteDataSource.getAllCategories()).called(5);
      });

      test('should properly convert CategoryModel to Category entity', () async {
        // Arrange
        final testModel = TestHelpers.createMockCategory(
          id: 'test_id',
          name: 'Test Category',
          description: 'Test Description',
          icon: 'test_icon',
          color: '#FF0000',
          isActive: true,
          sortOrder: 1,
        );
        when(mockRemoteDataSource.getAllCategories())
            .thenAnswer((_) async => [testModel]);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (categories) {
            final category = categories.first;
            expect(category.id, testModel.id);
            expect(category.name, testModel.name);
            expect(category.description, testModel.description);
            expect(category.icon, testModel.icon);
            expect(category.color, testModel.color);
            expect(category.isActive, testModel.isActive);
            expect(category.sortOrder, testModel.sortOrder);
            expect(category.createdAt, testModel.createdAt);
            expect(category.updatedAt, testModel.updatedAt);
          },
        );
        verify(mockRemoteDataSource.getAllCategories()).called(1);
      });
    });
  });
}