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
    
    try {
      // Primeiro tenta o método direto
      return await _getRestaurantsDirectly();
    } catch (e) {
      debugPrint('❌ Falha no método direto, tentando proxy: $e');
      
      // Em web development, usar proxy como fallback
      if (kIsWeb && kDebugMode) {
        try {
          return await _getRestaurantsViaProxy();
        } catch (proxyError) {
          debugPrint('❌ Proxy também falhou: $proxyError');
          return await _getFallbackData();
        }
      }
      
      // Se não é web ou proxy falhou, usar fallback
      return await _getFallbackData();
    }
  }
  
  /// Método para buscar via proxy (Web Development)
  Future<List<RestaurantModel>> _getRestaurantsViaProxy() async {
    try {
      debugPrint('🔄 RestaurantDataSource: Usando CORS proxy para web development');
      
      final response = await CorsProxyService.get(
        'restaurants',
        queryParams: {
          'select': 'id,name,description,category_id,image_url,rating,review_count,delivery_time,delivery_fee,min_order_value,distance,has_promotion,price_range,latitude,longitude,address,phone,opening_hours,is_open,is_featured,emoji,created_at,updated_at',
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
            .select('id, name, description, category_id, image_url, rating, review_count, delivery_time, delivery_fee, min_order_value, distance, has_promotion, price_range, latitude, longitude, address, phone, opening_hours, is_open, is_featured, emoji, created_at, updated_at')
            .order('name', ascending: true)
            .timeout(const Duration(seconds: 30));

        if (response.isEmpty) {
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

  /// Método de fallback - retorna dados de exemplo para desenvolvimento
  Future<List<RestaurantModel>> _getFallbackData() async {
    debugPrint('🚨 RestaurantDataSource: Usando dados de fallback para desenvolvimento');
    
    return [
      RestaurantModel(
        id: '1',
        name: 'Romanelli Cucina',
        description: 'Autêntica culinária italiana com pratos clássicos',
        categoryId: '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d', // Date Night
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
        rating: 4.8,
        reviewCount: 127,
        deliveryTime: '35 min',
        deliveryFee: 8.90,
        minOrderValue: 25.00,
        distance: 1.2,
        hasPromotion: true,
        priceRange: r'$$',
        latitude: -25.64096,
        longitude: -49.3256704,
        address: 'Rua das Flores, 123 - Centro',
        phone: '(41) 3333-4444',
        isOpen: true,
        isFeatured: true,
        emoji: '🇮🇹',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: '2',
        name: 'Sakura Sushi Bar',
        description: 'O melhor da culinária japonesa com ingredientes frescos',
        categoryId: '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d', // Date Night
        imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
        rating: 4.7,
        reviewCount: 89,
        deliveryTime: '40 min',
        deliveryFee: 12.00,
        minOrderValue: 40.00,
        distance: 2.1,
        hasPromotion: false,
        priceRange: r'$$$',
        latitude: -25.64496,
        longitude: -49.3206704,
        address: 'Av. Batel, 567 - Batel',
        phone: '(41) 2222-5555',
        isOpen: true,
        isFeatured: true,
        emoji: '🍣',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: '3',
        name: 'Bistrot du Coin',
        description: 'Bistrô francês aconchegante com vinhos selecionados',
        categoryId: '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d', // Date Night
        imageUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=500',
        rating: 4.9,
        reviewCount: 156,
        deliveryTime: '45 min',
        deliveryFee: 15.00,
        minOrderValue: 60.00,
        distance: 1.8,
        hasPromotion: false,
        priceRange: r'$$$$',
        latitude: -25.63596,
        longitude: -49.3176704,
        address: 'Rua França, 89 - Jardins',
        phone: '(41) 1111-6666',
        isOpen: true,
        isFeatured: true,
        emoji: '🇫🇷',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: '4',
        name: 'Burger House',
        description: 'Os melhores hambúrgueres artesanais da cidade',
        categoryId: 'burger', // Categoria diferente para outras seções
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        rating: 4.5,
        reviewCount: 203,
        deliveryTime: '25 min',
        deliveryFee: 6.50,
        minOrderValue: 20.00,
        distance: 0.8,
        hasPromotion: true,
        priceRange: r'$$',
        latitude: -25.63896,
        longitude: -49.3226704,
        address: 'Rua Augusta, 345 - Vila Madalena',
        phone: '(41) 9999-7777',
        isOpen: true,
        isFeatured: false,
        emoji: '🍔',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: '5',
        name: 'Casa do Bacalhau',
        description: 'Pratos tradicionais portugueses e frutos do mar',
        categoryId: '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d', // Date Night
        imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=500',
        rating: 4.6,
        reviewCount: 92,
        deliveryTime: '50 min',
        deliveryFee: 10.00,
        minOrderValue: 35.00,
        distance: 2.5,
        hasPromotion: false,
        priceRange: r'$$$',
        latitude: -25.64296,
        longitude: -49.3146704,
        address: 'Rua do Porto, 678 - Centro Histórico',
        phone: '(41) 8888-3333',
        isOpen: true,
        isFeatured: false,
        emoji: '🇵🇹',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('id', id)
          .single();

      return RestaurantModel.fromSupabase(response);
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
