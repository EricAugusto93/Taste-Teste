import 'package:dartz/dartz.dart';
import '../entities/restaurant.dart';
import '../../core/error/failures.dart';

/// Interface do repositório de favoritos
abstract class FavoriteRepository {
  /// Obtém os restaurantes favoritos do usuário
  Future<Either<Failure, List<Restaurant>>> getUserFavorites(String userId);

  /// Adiciona um restaurante aos favoritos
  Future<Either<Failure, void>> addFavorite(String userId, String restaurantId);

  /// Remove um restaurante dos favoritos
  Future<Either<Failure, void>> removeFavorite(String userId, String restaurantId);

  /// Verifica se um restaurante é favorito
  Future<Either<Failure, bool>> isFavorite(String userId, String restaurantId);

  /// Alterna o status de favorito de um restaurante
  Future<Either<Failure, bool>> toggleFavorite(String userId, String restaurantId);
}