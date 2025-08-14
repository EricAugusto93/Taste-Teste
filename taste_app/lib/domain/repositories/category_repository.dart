import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../../core/error/failures.dart';

/// Interface do repositório de categorias
abstract class CategoryRepository {
  /// Obtém todas as categorias
  Future<Either<Failure, List<Category>>> getAllCategories();

  /// Obtém uma categoria por ID
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Obtém categorias ativas ordenadas por sortOrder
  Future<Either<Failure, List<Category>>> getActiveCategories();
}