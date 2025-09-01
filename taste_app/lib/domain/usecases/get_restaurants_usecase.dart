import 'package:dartz/dartz.dart';
import '../entities/restaurant.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../core/error/failures.dart';
import 'usecase.dart';

/// Caso de uso para obter todos os restaurantes
class GetRestaurantsUseCase implements UseCase<List<Restaurant>, NoParams> {
  final RestaurantRepository repository;

  GetRestaurantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(NoParams params) async {
    try {
      final restaurantModels = await repository.getRestaurants();
      final restaurants = restaurantModels.map((model) => Restaurant.fromModel(model)).toList();
      return Right(restaurants);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
