import 'package:dartz/dartz.dart';
import '../entities/restaurant.dart';
import '../../core/error/failures.dart';

/// Interface do repositório de restaurantes
abstract class RestaurantRepository {
  /// Obtém todos os restaurantes
  Future<Either<Failure, List<Restaurant>>> getAllRestaurants();

  /// Obtém um restaurante por ID
  Future<Either<Failure, Restaurant>> getRestaurantById(String id);

  /// Busca restaurantes por termo de pesquisa
  Future<Either<Failure, List<Restaurant>>> searchRestaurants(String query);

  /// Obtém restaurantes por categoria
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByCategory(String categoryId);

  /// Obtém restaurantes próximos
  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double? radiusKm,
  });
}