import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';
import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

class GetCategoryByIdParams extends Equatable {
  final String id;

  const GetCategoryByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}

class GetCategoryByIdUseCase implements UseCase<Category, GetCategoryByIdParams> {
  final CategoryRepository repository;

  GetCategoryByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(GetCategoryByIdParams params) async {
    return await repository.getCategoryById(params.id);
  }
}