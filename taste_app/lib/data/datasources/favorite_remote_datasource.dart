import 'package:supabase_flutter/supabase_flutter.dart';
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
  late final SupabaseClient _client;

  FavoriteRemoteDataSourceImpl() {
    _client = Supabase.instance.client;
  }

  @override
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    try {
      final response = await _client
          .from('favorites')
          .select('''
            id,
            user_id,
            restaurant_id,
            created_at,
            restaurants (
              id,
              name,
              description,
              image_url,
              rating,
              delivery_time,
              delivery_fee,
              min_order_value,
              price_range,
              latitude,
              longitude,
              address,
              phone,
              is_open,
              is_featured,
              category_id
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => FavoriteModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar favoritos: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar favoritos: $e');
    }
  }

  @override
  Future<FavoriteModel> addFavorite(String userId, String restaurantId) async {
    try {
      // Verificar se já existe
      final existing = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Restaurante já está nos favoritos');
      }

      // Inserir novo favorito
      final response = await _client
          .from('favorites')
          .insert({
            'user_id': userId,
            'restaurant_id': restaurantId,
          })
          .select('''
            id,
            user_id,
            restaurant_id,
            created_at,
            restaurants (
              id,
              name,
              description,
              image_url,
              rating,
              delivery_time,
              delivery_fee,
              min_order_value,
              price_range,
              latitude,
              longitude,
              address,
              phone,
              is_open,
              is_featured,
              category_id
            )
          ''')
          .single();

      return FavoriteModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Restaurante já está nos favoritos');
      }
      throw Exception('Erro ao adicionar favorito: ${e.message}');
    } catch (e) {
      if (e.toString().contains('já está nos favoritos')) rethrow;
      throw Exception('Erro inesperado ao adicionar favorito: $e');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String restaurantId) async {
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao remover favorito: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao remover favorito: $e');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String restaurantId) async {
    try {
      final response = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      print('Erro ao verificar favorito: ${e.message}');
      return false;
    } catch (e) {
      print('Erro inesperado ao verificar favorito: $e');
      return false;
    }
  }
}