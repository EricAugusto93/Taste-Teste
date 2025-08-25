import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/favorites_repository.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';

/// Parâmetros para adicionar favorito
class AddFavoriteParams extends Equatable {
  final String restaurantId;

  const AddFavoriteParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}

/// Caso de uso para adicionar restaurante aos favoritos
class AddFavoriteUseCase implements UseCase<void, AddFavoriteParams> {
  final FavoritesRepository repository;

  AddFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddFavoriteParams params) async {
    return await repository.addToFavorites(params.restaurantId);
  }
}