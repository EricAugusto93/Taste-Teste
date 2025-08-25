import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';
import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

class GetActiveCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;

  GetActiveCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getActiveCategories();
  }
}