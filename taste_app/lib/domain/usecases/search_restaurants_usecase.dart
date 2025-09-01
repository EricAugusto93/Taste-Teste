import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/restaurant.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../core/error/failures.dart';
import 'usecase.dart';

/// Caso de uso para buscar restaurantes
class SearchRestaurantsUseCase implements UseCase<List<Restaurant>, SearchRestaurantsParams> {
  final RestaurantRepository repository;

  SearchRestaurantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(SearchRestaurantsParams params) async {
    try {
      // Normalizar a query: trim e lowercase
      final normalizedQuery = params.query.trim().toLowerCase();
      final restaurantModels = await repository.searchRestaurants(normalizedQuery);
      final restaurants = restaurantModels.map((model) => Restaurant.fromModel(model)).toList();
      return Right(restaurants);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Parâmetros para busca de restaurantes
class SearchRestaurantsParams extends Equatable {
  final String query;

  const SearchRestaurantsParams({required this.query});

  @override
  List<Object> get props => [query];
}
