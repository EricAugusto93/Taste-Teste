import 'package:flutter/foundation.dart';
import '../models/favorite_model.dart';
import '../../core/config/supabase_config.dart';

/// Repositório para operações com favoritos
class FavoriteRepository {
  /// Busca todos os favoritos de um usuário
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    try {
      final response = await SupabaseDatabase.favorites
          .select('*, restaurants(*)')
          .eq('user_id', userId)
          .order('favorited_at', ascending: false);

      return (response as List<Map<String, dynamic>>)
          .map((json) => FavoriteModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar favoritos: $e');
      return [];
    }
  }

  /// Adiciona um restaurante aos favoritos
  Future<bool> addToFavorites(String userId, String restaurantId) async {
    try {
      await SupabaseDatabase.favorites.insert({
        'user_id': userId,
        'restaurant_id': restaurantId,
        'favorited_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar favorito: $e');
      return false;
    }
  }

  /// Remove um restaurante dos favoritos
  Future<bool> removeFromFavorites(String userId, String restaurantId) async {
    try {
      await SupabaseDatabase.favorites
          .delete()
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId);
      return true;
    } catch (e) {
      debugPrint('Erro ao remover favorito: $e');
      return false;
    }
  }

  /// Verifica se um restaurante está nos favoritos
  Future<bool> isFavorite(String userId, String restaurantId) async {
    try {
      final response = await SupabaseDatabase.favorites
          .select('id')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
      return false;
    }
  }

  /// Alterna o status de favorito de um restaurante
  Future<bool> toggleFavorite(String userId, String restaurantId) async {
    try {
      final isFav = await isFavorite(userId, restaurantId);
      
      if (isFav) {
        return await removeFromFavorites(userId, restaurantId);
      } else {
        return await addToFavorites(userId, restaurantId);
      }
    } catch (e) {
      debugPrint('Erro ao alternar favorito: $e');
      return false;
    }
  }

  /// Busca favoritos com informações completas dos restaurantes
  Future<List<FavoriteModel>> getFavoritesWithRestaurants(String userId) async {
    try {
      final response = await SupabaseDatabase.favorites
          .select('''
            id,
            user_id,
            restaurant_id,
            favorited_at,
            restaurants (
              id,
              name,
              description,
              image_url,
              rating,
              price_range,
              cuisine_type,
              address,
              phone,
              website,
              opening_hours,
              latitude,
              longitude,
              is_open,
              is_featured,
              category_id,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', userId)
          .order('favorited_at', ascending: false);

      return (response as List<Map<String, dynamic>>)
          .map((json) => FavoriteModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar favoritos com restaurantes: $e');
      return [];
    }
  }
}