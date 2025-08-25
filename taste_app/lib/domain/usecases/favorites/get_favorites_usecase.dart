import 'package:dartz/dartz.dart';
import '../../entities/restaurant.dart';
import '../../repositories/favorites_repository.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';

/// Caso de uso para obter restaurantes favoritos
class GetFavoritesUseCase implements UseCase<List<Restaurant>, NoParams> {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(NoParams params) async {
    return await repository.getFavorites();
  }
}