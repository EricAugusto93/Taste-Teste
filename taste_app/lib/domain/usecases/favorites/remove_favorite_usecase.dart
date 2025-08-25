import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/favorites_repository.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';

/// Parâmetros para remover favorito
class RemoveFavoriteParams extends Equatable {
  final String restaurantId;

  const RemoveFavoriteParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}

/// Caso de uso para remover restaurante dos favoritos
class RemoveFavoriteUseCase implements UseCase<void, RemoveFavoriteParams> {
  final FavoritesRepository repository;

  RemoveFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFavoriteParams params) async {
    return await repository.removeFromFavorites(params.restaurantId);
  }
}