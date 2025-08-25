import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/restaurant.dart';

/// Interface do repositório de favoritos
abstract class FavoritesRepository {
  /// Adicionar restaurante aos favoritos (simplificado para Use Case)
  Future<Either<Failure, void>> addToFavorites(String restaurantId);

  /// Remover restaurante dos favoritos (simplificado para Use Case)
  Future<Either<Failure, void>> removeFromFavorites(String restaurantId);

  /// Verificar se restaurante é favorito
  Future<Either<Failure, bool>> isFavorite(String restaurantId);

  /// Obter lista de restaurantes favoritos (simplificado para Use Case)
  Future<Either<Failure, List<Restaurant>>> getFavorites();

  /// Adicionar restaurante aos favoritos (método legado com parâmetros completos)
  Future<Either<Failure, bool>> addToFavoritesLegacy({
    required String restaurantId,
    String? userId,
    double? rating,
    String? comment,
  });

  /// Remover restaurante dos favoritos (método legado)
  Future<Either<Failure, bool>> removeFromFavoritesLegacy({
    required String restaurantId,
    String? userId,
  });

  /// Obter lista de restaurantes favoritos (método legado)
  Future<Either<Failure, List<Restaurant>>> getFavoriteRestaurants({
    String? userId,
    int? limit,
    int? offset,
  });

  /// Adicionar avaliação rápida (automaticamente adiciona aos favoritos)
  Future<Either<Failure, bool>> addQuickReview({
    required String restaurantId,
    required double rating,
    String? comment,
    String? userId,
  });

  /// Obter contagem de favoritos
  Future<Either<Failure, int>> getFavoritesCount({String? userId});

  /// Obter apenas os IDs dos favoritos (para cache)
  Future<Either<Failure, List<String>>> getFavoriteIds({String? userId});

  /// Sincronizar favoritos (útil após login)
  Future<Either<Failure, bool>> syncFavorites({String? userId});

  /// Limpar cache local
  void clearCache();

  /// Obter favoritos próximos por localização
  Future<Either<Failure, List<Restaurant>>> getNearbyFavorites({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? userId,
  });

  /// Remover favorito (método simplificado)
  Future<Either<Failure, bool>> removeFavorite(String restaurantId);

  /// Exportar favoritos
  Future<Either<Failure, Map<String, dynamic>>> exportFavorites({String? userId});

  /// Importar favoritos
  Future<Either<Failure, bool>> importFavorites({
    required Map<String, dynamic> data,
    String? userId,
  });

  /// Obter estatísticas de favoritos
  Future<Map<String, dynamic>> getFavoritesStats({String? userId});
}