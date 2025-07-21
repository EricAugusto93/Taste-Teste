import 'package:flutter/foundation.dart';

import '../models/estatisticas_restaurante.dart';
import '../services/supabase_service.dart';

class EstatisticasService {
  static final _supabase = SupabaseService.client;
  
  // Cache em memória para evitar queries desnecessárias
  static final Map<String, EstatisticasRestaurante> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Obtém estatísticas agregadas para um restaurante específico
  static Future<EstatisticasRestaurante> obterEstatisticas(String restauranteId) async {
    // Verificar cache
    if (_isCacheValid(restauranteId)) {
      return _cache[restauranteId]!;
    }

    try {
      final estatisticas = await _calcularEstatisticas(restauranteId);
      
      // Salvar no cache
      _cache[restauranteId] = estatisticas;
      _cacheTimestamps[restauranteId] = DateTime.now();
      
      return estatisticas;
    } catch (e) {
      debugPrint('Erro ao obter estatísticas do restaurante $restauranteId: $e');
      return EstatisticasRestaurante.vazia(restauranteId);
    }
  }

  /// Obtém estatísticas para múltiplos restaurantes
  static Future<Map<String, EstatisticasRestaurante>> obterEstatisticasMultiplas(
    List<String> restauranteIds,
  ) async {
    final Map<String, EstatisticasRestaurante> resultado = {};
    
    // Separar IDs que precisam ser buscados vs. que estão em cache
    final idsParaBuscar = <String>[];
    
    for (final id in restauranteIds) {
      if (_isCacheValid(id)) {
        resultado[id] = _cache[id]!;
      } else {
        idsParaBuscar.add(id);
      }
    }
    
    // Buscar os restantes em paralelo
    if (idsParaBuscar.isNotEmpty) {
      final futures = idsParaBuscar.map((id) => obterEstatisticas(id));
      final estatisticas = await Future.wait(futures);
      
      for (int i = 0; i < idsParaBuscar.length; i++) {
        resultado[idsParaBuscar[i]] = estatisticas[i];
      }
    }
    
    return resultado;
  }

  /// Calcula estatísticas agregadas para um restaurante
  static Future<EstatisticasRestaurante> _calcularEstatisticas(String restauranteId) async {
    // Buscar todas as experiências do restaurante
    final response = await _supabase
        .from('experiencias')
        .select('''
          id,
          emoji,
          comentario,
          data_visita,
          usuarios(nome)
        ''')
        .eq('restaurante_id', restauranteId)
        .order('data_visita', ascending: false);

    final experiencias = response as List<dynamic>;
    
    if (experiencias.isEmpty) {
      return EstatisticasRestaurante.vazia(restauranteId);
    }

    // Calcular estatísticas
    final Map<String, int> stats = {};
    final List<ComentarioRecente> comentariosRecentes = [];

    for (final exp in experiencias) {
      final emoji = exp['emoji'] as String;
      stats[emoji] = (stats[emoji] ?? 0) + 1;
      
      // Adicionar aos comentários recentes se tem comentário
      final comentario = exp['comentario'] as String?;
      if (comentario != null && comentario.trim().isNotEmpty && comentariosRecentes.length < 3) {
        final nomeUsuario = exp['usuarios']?['nome'] as String?;
        comentariosRecentes.add(
          ComentarioRecente(
            id: exp['id'] as String,
            comentario: comentario,
            emoji: emoji,
            nomeUsuario: nomeUsuario,
            dataVisita: DateTime.parse(exp['data_visita'] as String),
          ),
        );
      }
    }

    // Determinar emoji mais votado
    String topEmoji = '';
    int maxCount = 0;
    
    stats.forEach((emoji, count) {
      if (count > maxCount) {
        maxCount = count;
        topEmoji = emoji;
      }
    });

    return EstatisticasRestaurante(
      restauranteId: restauranteId,
      total: experiencias.length,
      stats: stats,
      topEmoji: topEmoji,
      comentariosRecentes: comentariosRecentes,
      ultimaAtualizacao: DateTime.now(),
    );
  }

  /// Invalida o cache para um restaurante específico
  static void invalidarCache(String restauranteId) {
    _cache.remove(restauranteId);
    _cacheTimestamps.remove(restauranteId);
  }

  /// Invalida todo o cache
  static void invalidarTodoCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Verifica se o cache é válido para um restaurante
  static bool _isCacheValid(String restauranteId) {
    final timestamp = _cacheTimestamps[restauranteId];
    if (timestamp == null || !_cache.containsKey(restauranteId)) {
      return false;
    }
    
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Atualiza estatísticas após nova experiência ser registrada
  static Future<void> atualizarAposNovaExperiencia(
    String restauranteId,
    String emoji,
    String? comentario,
  ) async {
    try {
      // Invalidar cache para forçar nova busca
      invalidarCache(restauranteId);
      
      // Buscar estatísticas atualizadas
      await obterEstatisticas(restauranteId);
      
      debugPrint('Estatísticas atualizadas para restaurante $restauranteId');
    } catch (e) {
      debugPrint('Erro ao atualizar estatísticas: $e');
    }
  }

  /// Obtém top restaurantes por avaliação
  static Future<List<String>> obterTopRestaurantesPorAvaliacao({
    int limite = 10,
    String? emojiFilter,
  }) async {
    try {
      var query = _supabase
          .from('experiencias')
          .select('restaurante_id, emoji');
      
      if (emojiFilter != null) {
        query = query.eq('emoji', emojiFilter);
      }
      
      final response = await query;
      final experiencias = response as List<dynamic>;
      
      // Agrupar por restaurante e contar
      final Map<String, int> contagemPorRestaurante = {};
      
      for (final exp in experiencias) {
        final restauranteId = exp['restaurante_id'] as String;
        contagemPorRestaurante[restauranteId] = 
            (contagemPorRestaurante[restauranteId] ?? 0) + 1;
      }
      
      // Ordenar por contagem e retornar top
      final sorted = contagemPorRestaurante.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sorted.take(limite).map((e) => e.key).toList();
    } catch (e) {
      debugPrint('Erro ao obter top restaurantes: $e');
      return [];
    }
  }

  /// Obtém estatísticas globais do app
  static Future<Map<String, dynamic>> obterEstatisticasGlobais() async {
    try {
      final response = await _supabase
          .from('experiencias')
          .select('emoji, restaurante_id');
      
      final experiencias = response as List<dynamic>;
      
      final Map<String, int> emojisGlobais = {};
      final Set<String> restaurantesUnicos = {};
      
      for (final exp in experiencias) {
        final emoji = exp['emoji'] as String;
        final restauranteId = exp['restaurante_id'] as String;
        
        emojisGlobais[emoji] = (emojisGlobais[emoji] ?? 0) + 1;
        restaurantesUnicos.add(restauranteId);
      }
      
      return {
        'total_experiencias': experiencias.length,
        'total_restaurantes_avaliados': restaurantesUnicos.length,
        'emojis_globais': emojisGlobais,
        'emoji_mais_usado': emojisGlobais.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key,
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas globais: $e');
      return {
        'total_experiencias': 0,
        'total_restaurantes_avaliados': 0,
        'emojis_globais': <String, int>{},
        'emoji_mais_usado': '',
      };
    }
  }

  /// Limpa cache antigo automaticamente
  static void limparCacheAntigo() {
    final agora = DateTime.now();
    final keysParaRemover = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (agora.difference(timestamp) > _cacheDuration) {
        keysParaRemover.add(key);
      }
    });
    
    for (final key in keysParaRemover) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
} 