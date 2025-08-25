import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/restaurant.dart';
import '../../entities/location.dart';
import '../../repositories/restaurant_repository.dart';
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
    return await repository.getNearbyRestaurants(
      location: params.location,
      radius: params.radius,
      limit: params.limit,
    );
  }
}