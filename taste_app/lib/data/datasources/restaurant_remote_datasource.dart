import '../models/restaurant_model.dart';
import '../../core/config/supabase_config.dart';
import '../../core/error/exceptions.dart';

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
    try {
      final response = await SupabaseDatabase.restaurants
          .select()
          .order('created_at', ascending: false);

      return (response as List<Map<String, dynamic>>)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar restaurantes: $e');
    }
  }

  @override
  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('id', id)
          .single();

      return RestaurantModel.fromJson(response as Map<String, dynamic>);
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

      return (response as List<Map<String, dynamic>>)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar restaurantes: $e');
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurantsByCategory(String categoryId) async {
    try {
      final response = await SupabaseDatabase.restaurants
          .select()
          .eq('category_id', categoryId)
          .order('rating', ascending: false);

      return (response as List<Map<String, dynamic>>)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();
    } catch (e) {
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

      return (response as List<Map<String, dynamic>>)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar restaurantes próximos: $e');
    }
  }
}