import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/restaurant.dart';
import '../../entities/location.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';

/// Parâmetros para buscar restaurantes próximos
class GetNearbyRestaurantsParams extends Equatable {
  final Location location;
  final double radius; // em metros
  final int limit;

  const GetNearbyRestaurantsParams({
    required this.location,
    this.radius = 5000, // 5km default
    this.limit = 20,
  });

  @override
  List<Object> get props => [location, radius, limit];
}

/// Caso de uso para obter restaurantes próximos
class GetNearbyRestaurantsUseCase implements UseCase<List<Restaurant>, GetNearbyRestaurantsParams> {
  final RestaurantRepository repository;

  GetNearbyRestaurantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(GetNearbyRestaurantsParams params) async {
    try {
      final restaurantModels = await repository.getNearbyRestaurants(
        latitude: params.location.latitude,
        longitude: params.location.longitude,
        radiusKm: params.radius / 1000, // Convert meters to kilometers
        limit: params.limit,
      );
      
      // Convert RestaurantModel to Restaurant entity
      final restaurants = restaurantModels.map((model) => Restaurant.fromModel(model)).toList();
      return Right(restaurants);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}