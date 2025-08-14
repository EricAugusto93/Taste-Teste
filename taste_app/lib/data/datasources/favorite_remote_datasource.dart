import '../models/favorite_model.dart';

/// Interface para operações remotas de favoritos
abstract class FavoriteRemoteDataSource {
  /// Busca todos os favoritos de um usuário
  Future<List<FavoriteModel>> getUserFavorites(String userId);
  
  /// Adiciona um restaurante aos favoritos
  Future<FavoriteModel> addFavorite(String userId, String restaurantId);
  
  /// Remove um restaurante dos favoritos
  Future<void> removeFavorite(String userId, String restaurantId);
  
  /// Verifica se um restaurante é favorito do usuário
  Future<bool> isFavorite(String userId, String restaurantId);
}

/// Implementação do FavoriteRemoteDataSource usando Supabase
class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  @override
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    // TODO: Implementar busca de favoritos do usuário no Supabase
    throw UnimplementedError('getUserFavorites not implemented yet');
  }

  @override
  Future<FavoriteModel> addFavorite(String userId, String restaurantId) async {
    // TODO: Implementar adição de favorito no Supabase
    throw UnimplementedError('addFavorite not implemented yet');
  }

  @override
  Future<void> removeFavorite(String userId, String restaurantId) async {
    // TODO: Implementar remoção de favorito no Supabase
    throw UnimplementedError('removeFavorite not implemented yet');
  }

  @override
  Future<bool> isFavorite(String userId, String restaurantId) async {
    // TODO: Implementar verificação de favorito no Supabase
    throw UnimplementedError('isFavorite not implemented yet');
  }
}