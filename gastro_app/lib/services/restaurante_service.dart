import '../models/restaurante.dart';
import 'supabase_service.dart';
import 'dart:math' as math;

class RestauranteService {
  static final _supabase = SupabaseService.client;

  // Buscar todos os restaurantes (método simplificado)
  static Future<List<Restaurante>> obterTodos() async {
    try {
      print('🔍 [RestauranteService] Iniciando busca de todos os restaurantes...');
      
      final response = await _supabase
          .from('restaurantes')
          .select()
          .order('nome', ascending: true);
      
      print('🔍 [RestauranteService] Response do Supabase: ${response.length} registros');
      
      final restaurantes = (response as List<dynamic>)
          .map((data) => Restaurante.fromJson(data))
          .toList();
      
      print('🔍 [RestauranteService] Restaurantes mapeados: ${restaurantes.length}');
      if (restaurantes.isNotEmpty) {
        print('🔍 [RestauranteService] Primeiro restaurante: ${restaurantes.first.nome}');
      }
      
      return restaurantes;
    } catch (e) {
      print('🔍 [RestauranteService] Erro ao obter restaurantes: $e');
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
        // ✅ Usar busca mais flexível
        query = query.or('tipo.ilike.%$tipoOuCategoria%,tipo.eq.$tipoOuCategoria');
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

  // Método para inserir restaurantes de teste próximos a Curitiba
  static Future<void> inserirRestaurantesTeste() async {
    try {
      print('🔧 [RestauranteService] Inserindo restaurantes de teste...');
      
      final restaurantesTeste = [
        {
          'nome': 'Churrascaria Gaúcha',
          'tipo': 'churrascaria',
          'descricao': 'Tradicional churrascaria com carnes nobres e buffet completo.',
          'endereco': 'Rua XV de Novembro, 100 - Centro, Curitiba',
          'latitude': -25.4284,
          'longitude': -49.2733,
          'telefone': '(41) 99999-1111',
          'preco_medio': 65.00,
          'imagem_url': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
          'tags': ['churrasco', 'carne', 'buffet', 'tradicional'],
          'ativo': true,
        },
        {
          'nome': 'Bistrô do Batel',
          'tipo': 'contemporâneo',
          'descricao': 'Culinária contemporânea em ambiente sofisticado no coração do Batel.',
          'endereco': 'Av. Batel, 200 - Batel, Curitiba',
          'latitude': -25.4372,
          'longitude': -49.2844,
          'telefone': '(41) 99999-2222',
          'preco_medio': 85.00,
          'imagem_url': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500',
          'tags': ['contemporâneo', 'sofisticado', 'batel', 'jantar'],
          'ativo': true,
        },
        {
          'nome': 'Pizzaria Curitibana',
          'tipo': 'italiano',
          'descricao': 'Pizza artesanal com ingredientes locais e massa fermentada naturalmente.',
          'endereco': 'Rua Comendador Araújo, 300 - Centro, Curitiba',
          'latitude': -25.4195,
          'longitude': -49.2646,
          'telefone': '(41) 99999-3333',
          'preco_medio': 40.00,
          'imagem_url': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
          'tags': ['pizza', 'artesanal', 'massa natural', 'local'],
          'ativo': true,
        },
        {
          'nome': 'Café Central',
          'tipo': 'café',
          'descricao': 'Café especial com torrefação própria no centro histórico de Curitiba.',
          'endereco': 'Largo da Ordem, 50 - Centro Histórico, Curitiba',
          'latitude': -25.4284,
          'longitude': -49.2733,
          'telefone': '(41) 99999-4444',
          'preco_medio': 20.00,
          'imagem_url': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
          'tags': ['café especial', 'torrefação', 'centro histórico', 'wifi'],
          'ativo': true,
        },
        {
          'nome': 'Sushi Curitiba',
          'tipo': 'japonês',
          'descricao': 'Sushi bar moderno com peixes frescos e ambiente descontraído.',
          'endereco': 'Rua Marechal Deodoro, 400 - Centro, Curitiba',
          'latitude': -25.4284,
          'longitude': -49.2733,
          'telefone': '(41) 99999-5555',
          'preco_medio': 70.00,
          'imagem_url': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
          'tags': ['sushi', 'peixe fresco', 'moderno', 'descontraído'],
          'ativo': true,
        },
      ];
      
      for (final restaurante in restaurantesTeste) {
        try {
          // Verificar se já existe
           final existente = await _supabase
               .from('restaurantes')
               .select('id')
               .eq('nome', restaurante['nome'] as String)
               .maybeSingle();
          
          if (existente == null) {
            await _supabase.from('restaurantes').insert(restaurante);
            print('✅ [RestauranteService] Inserido: ${restaurante['nome']}');
          } else {
            print('ℹ️ [RestauranteService] Já existe: ${restaurante['nome']}');
          }
        } catch (e) {
          print('❌ [RestauranteService] Erro ao inserir ${restaurante['nome']}: $e');
        }
      }
      
      print('🔧 [RestauranteService] Inserção de restaurantes de teste concluída!');
    } catch (e) {
      print('❌ [RestauranteService] Erro geral ao inserir restaurantes de teste: $e');
    }
  }
}