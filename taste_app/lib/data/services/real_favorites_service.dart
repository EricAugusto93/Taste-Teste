import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant_model.dart';
import '../../domain/entities/restaurant.dart';

/// Serviço para gerenciar favoritos reais usando CORS proxy
class RealFavoritesService {
  static const String _proxyBaseUrl = 'http://localhost:3000/api/proxy/supabase';
  
  /// Buscar todos os restaurantes disponíveis
  static Future<List<Restaurant>> getAllRestaurants() async {
    try {
      debugPrint('🔍 RealFavoritesService: Buscando todos os restaurantes...');
      
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': 'restaurants',
          'select': 'id,name,description,category_id,image_url,rating,review_count,delivery_time,delivery_fee,min_order_value,distance,has_promotion,price_range,latitude,longitude,address,phone,is_open,is_featured,emoji,created_at,updated_at',
          'order': 'name.asc.nullslast',
        },
      );

      debugPrint('📡 RealFavoritesService: URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'Content-Type',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('✅ RealFavoritesService: ${data.length} restaurantes encontrados');
        
        return data.map((json) {
          try {
            final restaurantModel = RestaurantModel.fromJson(json);
            return restaurantModel.toEntity();
          } catch (e) {
            debugPrint('⚠️ Erro ao processar restaurante: $e');
            debugPrint('📋 JSON problemático: $json');
            return null;
          }
        }).whereType<Restaurant>().toList();
      } else {
        debugPrint('❌ RealFavoritesService: Erro HTTP ${response.statusCode}');
        debugPrint('📋 Response body: ${response.body}');
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ RealFavoritesService: Erro ao buscar restaurantes: $e');
      rethrow;
    }
  }

  /// Buscar favoritos por usuário
  static Future<List<Restaurant>> getFavoritesByUser(String userId) async {
    try {
      debugPrint('🔍 RealFavoritesService: Buscando favoritos do usuário $userId...');
      
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': 'favorites',
          'select': '''*,
            restaurants!inner(
              id,
              name,
              description,
              image_url,
              rating,
              price_range,
              category_id,
              address,
              latitude,
              longitude,
              phone,
              website,
              is_open,
              is_featured,
              emoji,
              created_at,
              updated_at
            )''',
          'user_id': 'eq.$userId',
          'order': 'created_at.desc',
        },
      );

      debugPrint('📡 RealFavoritesService: URL favoritos: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'Content-Type',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('✅ RealFavoritesService: ${data.length} favoritos encontrados para usuário $userId');
        
        return data.map((item) {
          try {
            final restaurantData = item['restaurants'] as Map<String, dynamic>;
            final restaurantModel = RestaurantModel.fromJson(restaurantData);
            return restaurantModel.toEntity();
          } catch (e) {
            debugPrint('⚠️ Erro ao processar favorito: $e');
            debugPrint('📋 JSON problemático: $item');
            return null;
          }
        }).whereType<Restaurant>().toList();
      } else {
        debugPrint('❌ RealFavoritesService: Erro HTTP ${response.statusCode} ao buscar favoritos');
        debugPrint('📋 Response body: ${response.body}');
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ RealFavoritesService: Erro ao buscar favoritos: $e');
      rethrow;
    }
  }

  /// Adicionar favorito
  static Future<bool> addToFavorites(String userId, String restaurantId) async {
    try {
      debugPrint('🔍 RealFavoritesService: Adicionando restaurante $restaurantId aos favoritos do usuário $userId...');
      
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': 'favorites',
        },
      );

      final body = {
        'user_id': userId,
        'restaurant_id': restaurantId,
      };

      debugPrint('📡 RealFavoritesService: URL adicionar: $uri');
      debugPrint('📋 Body: $body');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ RealFavoritesService: Favorito adicionado com sucesso');
        return true;
      } else {
        debugPrint('❌ RealFavoritesService: Erro HTTP ${response.statusCode} ao adicionar favorito');
        debugPrint('📋 Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ RealFavoritesService: Erro ao adicionar favorito: $e');
      return false;
    }
  }

  /// Remover favorito
  static Future<bool> removeFromFavorites(String userId, String restaurantId) async {
    try {
      debugPrint('🔍 RealFavoritesService: Removendo restaurante $restaurantId dos favoritos do usuário $userId...');
      
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': 'favorites',
          'user_id': 'eq.$userId',
          'restaurant_id': 'eq.$restaurantId',
        },
      );

      debugPrint('📡 RealFavoritesService: URL remover: $uri');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ RealFavoritesService: Favorito removido com sucesso');
        return true;
      } else {
        debugPrint('❌ RealFavoritesService: Erro HTTP ${response.statusCode} ao remover favorito');
        debugPrint('📋 Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ RealFavoritesService: Erro ao remover favorito: $e');
      return false;
    }
  }

  /// Verificar se é favorito
  static Future<bool> isFavorite(String userId, String restaurantId) async {
    try {
      debugPrint('🔍 RealFavoritesService: Verificando se restaurante $restaurantId é favorito do usuário $userId...');
      
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': 'favorites',
          'select': 'id',
          'user_id': 'eq.$userId',
          'restaurant_id': 'eq.$restaurantId',
          'limit': '1',
        },
      );

      debugPrint('📡 RealFavoritesService: URL verificar: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'Content-Type',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final isFav = data.isNotEmpty;
        debugPrint('✅ RealFavoritesService: É favorito? $isFav');
        return isFav;
      } else {
        debugPrint('❌ RealFavoritesService: Erro HTTP ${response.statusCode} ao verificar favorito');
        debugPrint('📋 Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ RealFavoritesService: Erro ao verificar favorito: $e');
      return false;
    }
  }

  /// Buscar amostra de restaurantes para demonstração
  static Future<List<Restaurant>> getSampleRestaurants({int limit = 5}) async {
    try {
      debugPrint('🔍 RealFavoritesService: Buscando amostra de restaurantes (limite: $limit)...');
      
      final uri = Uri.parse(_proxyBaseUrl).replace(
        queryParameters: {
          'path': 'restaurants',
          'select': 'id,name,description,category_id,image_url,rating,review_count,delivery_time,delivery_fee,min_order_value,distance,has_promotion,price_range,latitude,longitude,address,phone,is_open,is_featured,emoji,created_at,updated_at',
          'order': 'rating.desc.nullslast',
          'limit': limit.toString(),
        },
      );

      debugPrint('📡 RealFavoritesService: URL amostra: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'Content-Type',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('✅ RealFavoritesService: ${data.length} restaurantes de amostra encontrados');
        
        return data.map((json) {
          try {
            final restaurantModel = RestaurantModel.fromJson(json);
            return restaurantModel.toEntity();
          } catch (e) {
            debugPrint('⚠️ Erro ao processar amostra: $e');
            return null;
          }
        }).whereType<Restaurant>().toList();
      } else {
        debugPrint('❌ RealFavoritesService: Erro HTTP ${response.statusCode} ao buscar amostra');
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ RealFavoritesService: Erro ao buscar amostra: $e');
      rethrow;
    }
  }
}