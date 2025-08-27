import '../models/restaurant_model.dart';
import '../../core/config/supabase_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/cors_proxy_service.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Interface para operações remotas de restaurantes
abstract class RestaurantRemoteDataSource {
  /// Busca todos os restaurantes
  Future<List<RestaurantModel>> getAllRestaurants();
  
  /// Busca um restaurante por ID
  Future<RestaurantModel> getRestaurantById(String id);
  
  /// Busca restaurantes por texto
  Future<List<RestaurantModel>> searchRestaurants(String query);
  
  /// Busca restaurantes por categoria
  Future<List<RestaurantModel>> getRestaurantsByCategory(String categoryId);
  
  /// Busca restaurantes próximos
  Future<List<RestaurantModel>> getNearbyRestaurants(
    double latitude,
    double longitude,
    double radius,
  );
}

/// Implementação do RestaurantRemoteDataSource usando Supabase
class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  @override
  Future<List<RestaurantModel>> getAllRestaurants() async {
    debugPrint('🌐 RestaurantDataSource: Carregando TODOS os restaurantes');
    
    // Em web development, usar proxy para contornar CORS
    if (kIsWeb && kDebugMode) {
      return await _getRestaurantsViaProxy();
    }
    
    // Fallback para método original (mobile/produção)
    return await _getRestaurantsDirectly();
  }
  
  /// Método para buscar via proxy (Web Development)
  Future<List<RestaurantModel>> _getRestaurantsViaProxy() async {
    try {
      debugPrint('🔄 RestaurantDataSource: Usando CORS proxy para web development');
      
      final response = await CorsProxyService.get(
        'restaurants',
        queryParams: {
          'select': 'id,name,description,category_id,image_url,rating,review_count,delivery_time,delivery_fee,min_order_value,distance,has_promotion,price_range,latitude,longitude,address,phone,is_open,is_featured,emoji,created_at,updated_at',
          'order': 'name.asc.nullslast',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final restaurants = data
            .map((json) => RestaurantModel.fromSupabase(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('✅ RestaurantDataSource: ${restaurants.length} restaurantes carregados via proxy');
        
        // Log dos primeiros restaurantes
        if (restaurants.isNotEmpty) {
          for (int i = 0; i < (restaurants.length > 3 ? 3 : restaurants.length); i++) {
            final r = restaurants[i];
            debugPrint('🏪 RestaurantDataSource: ${r.name} (${r.categoryId})');
          }
        }
        
        return restaurants;
      } else {
        debugPrint('❌ RestaurantDataSource: Erro no proxy: ${response.statusCode}');
        throw Exception('Erro no proxy: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ RestaurantDataSource: Erro no proxy: $e');
      return await _getFallbackData();
    }
  }
  
  /// Método direto original (Mobile/Produção)
  Future<List<RestaurantModel>> _getRestaurantsDirectly() async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        debugPrint('🌐 RestaurantDataSource: Tentativa direta ${retryCount + 1}/$maxRetries');
        
        final response = await SupabaseDatabase.restaurants
            .select('id, name, description, category_id, image_url, rating, review_count, delivery_time, delivery_fee, min_order_value, distance, has_promotion, price_range, latitude, longitude, address, phone, is_open, is_featured, emoji, created_at, updated_at')
            .order('name', ascending: true)
            .timeout(const Duration(seconds: 30));

        if (response == null || response.isEmpty) {
          throw Exception('Resposta vazia do servidor');
        }
        
        final restaurants = response
            .map((json) => RestaurantModel.fromSupabase(json))
            .toList();
        
        debugPrint('✅ RestaurantDataSource: ${restaurants.length} restaurantes carregados diretamente');
        return restaurants;
        
      } catch (e) {
        retryCount++;
        debugPrint('❌ RestaurantDataSource: Erro na tentativa $retryCount: $e');
        
        if (retryCount >= maxRetries) {
          return await _getFallbackData();
        }
        
        await Future.delayed(Duration(milliseconds: 1000 * retryCount));
      }
    }
    
    return <RestaurantModel>[];
  }

  /// Método de fallback - retorna lista vazia para forçar conexão real
  Future<List<RestaurantModel>> _getFallbackData() async {
    debugPrint('🚨 RestaurantDataSource: FALLBACK REMOVIDO - Sem dados mockados');
    return []; // Sempre retorna vazio para forçar dados reais
  }

  @override
  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('id', id)
          .single();

      return RestaurantModel.fromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Erro ao buscar restaurante: $e');
    }
  }

  @override
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    try {
      final response = await SupabaseDatabase.restaurants
          .select()
          .ilike('name', '%$query%')
          .order('rating', ascending: false);

      return (response)
          .map((json) => RestaurantModel.fromSupabase(json))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar restaurantes: $e');
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurantsByCategory(String categoryId) async {
    try {
      debugPrint('🔍 RestaurantDataSource: Buscando restaurantes para categoria: $categoryId');
      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('category_id', categoryId)
          .order('rating', ascending: false);

      final restaurants = (response)
          .map((json) => RestaurantModel.fromSupabase(json))
          .toList();
          
      debugPrint('📊 RestaurantDataSource: Encontrados ${restaurants.length} restaurantes para categoria $categoryId');
      return restaurants;
    } catch (e) {
      debugPrint('❌ RestaurantDataSource: Erro ao buscar por categoria: $e');
      throw ServerException('Erro ao buscar restaurantes por categoria: $e');
    }
  }

  @override
  Future<List<RestaurantModel>> getNearbyRestaurants(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      // Implementação básica - busca todos os restaurantes com coordenadas
      final response = await SupabaseDatabase.restaurants
          .select()
          .not('latitude', 'is', null)
          .not('longitude', 'is', null)
          .order('rating', ascending: false);

      return (response)
          .map((json) => RestaurantModel.fromSupabase(json))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar restaurantes próximos: $e');
    }
  }
}
