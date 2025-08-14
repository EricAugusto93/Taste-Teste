import 'package:dartz/dartz.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/category_remote_data_source.dart';

/// Implementação do repositório de categorias
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final categoryModels = await remoteDataSource.getAllCategories();
      final categories = categoryModels
          .where((model) => model.isActive)
          .map((model) => model.toEntity())
          .toList();
      
      // Ordenar por sortOrder
      categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final categoryModels = await remoteDataSource.getAllCategories();
      final categoryModel = categoryModels.firstWhere(
        (model) => model.id == id,
        orElse: () => throw const NotFoundException('Category not found'),
      );
      return Right(categoryModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getActiveCategories() async {
    try {
      final categoryModels = await remoteDataSource.getAllCategories();
      final activeCategories = categoryModels
          .where((model) => model.isActive)
          .map((model) => model.toEntity())
          .toList();
      
      // Ordenar por sortOrder
      activeCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      return Right(activeCategories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }
}