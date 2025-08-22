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
    int retryCount = 0;
    const maxRetries = 3; // Reduzido para 3 tentativas mais rápidas
    
    while (retryCount < maxRetries) {
      try {
        print('🌐 RestaurantDataSource: Carregando TODOS os restaurantes do Supabase (tentativa ${retryCount + 1}/$maxRetries)');
        
        // Buscar todos os restaurantes com todas as informações
        final response = await SupabaseDatabase.restaurants
            .select('id, name, description, category_id, image_url, rating, review_count, delivery_time, delivery_fee, min_order_value, distance, has_promotion, price_range, latitude, longitude, address, phone, is_open, is_featured, emoji, created_at, updated_at')
            .order('name', ascending: true)
            .timeout(const Duration(seconds: 10));

        print('📡 RestaurantDataSource: Resposta recebida do Supabase');
        
        if (response == null || (response as List).isEmpty) {
          print('⚠️ RestaurantDataSource: Resposta vazia do Supabase');
          throw Exception('Resposta vazia do servidor');
        }
        
        final restaurants = (response as List<Map<String, dynamic>>)
            .map((json) => RestaurantModel.fromSupabase(json))
            .toList();
        
        print('✅ RestaurantDataSource: ${restaurants.length} restaurantes carregados com sucesso do banco real');
        
        // Log dos primeiros restaurantes para debug
        if (restaurants.isNotEmpty) {
          for (int i = 0; i < (restaurants.length > 5 ? 5 : restaurants.length); i++) {
            final r = restaurants[i];
            print('🏪 RestaurantDataSource: ${r.name} (${r.id}) - Lat: ${r.latitude}, Lng: ${r.longitude}');
          }
        }
        
        return restaurants;
      } catch (e) {
        retryCount++;
        print('❌ RestaurantDataSource: Erro na tentativa $retryCount: $e');
        
        // Identificar tipos de erro
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('xmlhttprequest') || 
            errorString.contains('cors') ||
            errorString.contains('networkerror')) {
          print('🚫 RestaurantDataSource: Erro de CORS/Rede detectado');
        } else if (errorString.contains('401') || 
                   errorString.contains('403') ||
                   errorString.contains('unauthorized') ||
                   errorString.contains('forbidden')) {
          print('🔐 RestaurantDataSource: Erro de autenticação detectado');
        } else if (errorString.contains('timeout')) {
          print('⏰ RestaurantDataSource: Timeout na conexão');
        } else {
          print('🔧 RestaurantDataSource: Erro técnico: ${e.runtimeType}');
        }
        
        if (retryCount >= maxRetries) {
          print('❌ RestaurantDataSource: Todas as tentativas de conexão falharam');
          print('🚨 RestaurantDataSource: Não foi possível carregar dados do banco - verifique configuração do Supabase');
          
          // Não usar fallback - forçar que a conexão funcione
          return <RestaurantModel>[];
        }
        
        // Aguarda antes de tentar novamente (backoff mais simples)
        final delayMs = 1000 + (retryCount * 1000); // 1s, 2s, 3s
        print('⏳ RestaurantDataSource: Aguardando ${delayMs}ms antes da próxima tentativa...');
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    
    return <RestaurantModel>[];
  }

  /// Método de fallback mínimo - apenas em casos extremos
  Future<List<RestaurantModel>> _getFallbackData() async {
    print('🚨 RestaurantDataSource: Usando fallback mínimo - conexão falhou completamente');
    
    // Fallback mínimo apenas se TODA a conexão falhar
    return [];  // Retorna lista vazia para forçar retry ou mostrar erro
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

      return (response as List<Map<String, dynamic>>)
          .map((json) => RestaurantModel.fromSupabase(json))
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
          .map((json) => RestaurantModel.fromSupabase(json))
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
          .map((json) => RestaurantModel.fromSupabase(json))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar restaurantes próximos: $e');
    }
  }
}