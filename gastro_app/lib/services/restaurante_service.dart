import '../models/restaurante.dart';
import 'supabase_service.dart';
import 'dart:math' as math;

class RestauranteService {
  static final _supabase = SupabaseService.client;

  // Buscar todos os restaurantes (método simplificado)
  static Future<List<Restaurante>> obterTodos() async {
    try {
      final response = await _supabase
          .from('restaurantes')
          .select()
          .order('nome', ascending: true);
      
      return (response as List<dynamic>)
          .map((data) => Restaurante.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter restaurantes: $e');
    }
  }

  // Buscar restaurantes próximos (método simplificado)
  static Future<List<Restaurante>> buscarProximos({
    required double latitude,
    required double longitude,
    required double raioKm,
  }) async {
    try {
      final response = await _supabase
          .from('restaurantes')
          .select()
          .order('nome', ascending: true);
      
      var restaurantes = (response as List<dynamic>)
          .map((data) => Restaurante.fromJson(data))
          .toList();

      // Filtrar por distância usando cálculo simples
      restaurantes = restaurantes.where((restaurante) {
        final distancia = _calcularDistancia(
          latitude,
          longitude,
          restaurante.latitude,
          restaurante.longitude,
        );
        return distancia <= raioKm;
      }).toList();

      return restaurantes;
    } catch (e) {
      throw Exception('Erro ao buscar restaurantes próximos: $e');
    }
  }

  // Buscar restaurantes por IDs
  static Future<List<Restaurante>> obterPorIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];
      
      final response = await _supabase
          .from('restaurantes')
          .select()
          .inFilter('id', ids);
      
      return (response as List<dynamic>)
          .map((data) => Restaurante.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar restaurantes por IDs: $e');
    }
  }

  // Buscar restaurantes com filtros múltiplos (simplificado)
  static Future<List<Restaurante>> buscarComFiltros({
    String? tipo,
    String? categoria,
    List<String>? tags,
    String? localizacao,
    double? latitude,
    double? longitude,
    double? distanciaMaxima,
    double? precoMin,
    double? precoMax,
    double? avaliacaoMinima,
  }) async {
    try {
      var query = _supabase.from('restaurantes').select();

      // Filtro por tipo ou categoria
      final tipoOuCategoria = categoria ?? tipo;
      if (tipoOuCategoria != null && tipoOuCategoria.isNotEmpty) {
        query = query.ilike('tipo', '%$tipoOuCategoria%');
      }

      // Filtro por tags
      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', [tags.first.toLowerCase()]);
      }

      // Filtro por localização
      if (localizacao != null && localizacao.isNotEmpty) {
        query = query.or('descricao.ilike.%$localizacao%,nome.ilike.%$localizacao%');
      }

      // Filtro por avaliação mínima
      if (avaliacaoMinima != null) {
        query = query.gte('avaliacao_media', avaliacaoMinima);
      }

      // Filtro por preço
      if (precoMin != null) {
        query = query.gte('preco_medio', precoMin);
      }
      if (precoMax != null) {
        query = query.lte('preco_medio', precoMax);
      }

      final response = await query.order('created_at', ascending: false);
      
      var restaurantes = (response as List<dynamic>)
          .map((data) => Restaurante.fromJson(data))
          .toList();

      // Filtro por distância (se coordenadas fornecidas)
      if (latitude != null && longitude != null && distanciaMaxima != null) {
        restaurantes = restaurantes.where((restaurante) {
          final distancia = _calcularDistancia(
            latitude,
            longitude,
            restaurante.latitude,
            restaurante.longitude,
          );
          return distancia <= distanciaMaxima;
        }).toList();
      }

      return restaurantes;
    } catch (e) {
      print('Erro ao buscar restaurantes com filtros: $e');
      return [];
    }
  }

  // Método auxiliar para calcular distância (fórmula de Haversine simplificada)
  static double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const double raioTerra = 6371; // raio da Terra em km
    
    final double dLat = _grausParaRadianos(lat2 - lat1);
    final double dLon = _grausParaRadianos(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_grausParaRadianos(lat1)) * math.cos(_grausParaRadianos(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return raioTerra * c;
  }

  static double _grausParaRadianos(double graus) {
    return graus * (math.pi / 180);
  }
} 