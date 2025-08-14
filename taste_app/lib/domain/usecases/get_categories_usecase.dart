import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';
import '../../core/error/failures.dart';
import 'usecase.dart';

/// Caso de uso para obter todas as categorias
class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getAllCategories();
  }
}