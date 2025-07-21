import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/experiencia.dart';
import '../models/restaurante.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ExperienciaService {
  static final _supabase = SupabaseService.client;

  /// Obter experiências do usuário atual (método simplificado)
  static Future<List<dynamic>> obterExperienciasUsuario() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        return [];
      }
      
      final experiencias = await buscarExperienciasDoUsuario(user.id);
      return experiencias;
    } catch (e) {
      print('ERRO em obterExperienciasUsuario: $e');
      return [];
    }
  }

  /// Obter experiência específica de restaurante (método simplificado)
  static Future<dynamic> obterExperienciaRestaurante(String restauranteId) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return null;
      
      final experiencia = await buscarExperienciaUsuarioRestaurante(user.id, restauranteId);
      return experiencia;
    } catch (e) {
      return null;
    }
  }

  /// Registra uma nova experiência do usuário
  static Future<Experiencia> registrarExperiencia({
    required String userId,
    required String restauranteId,
    required String emoji,
    required String comentario,
    DateTime? dataVisita,
  }) async {
    try {
      final dataVisitaFinal = dataVisita ?? DateTime.now();
      
      final response = await _supabase
          .from('experiencias')
          .insert({
            'user_id': userId,
            'restaurante_id': restauranteId,
            'emoji': emoji,
            'comentario': comentario,
            'data_visita': dataVisitaFinal.toIso8601String(),
          })
          .select()
          .single();

      return Experiencia.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao registrar experiência: $e');
    }
  }

  /// Busca todas as experiências de um usuário
  static Future<List<ExperienciaComRestaurante>> buscarExperienciasDoUsuario(
    String userId,
  ) async {
    try {
      // Buscar experiências sem JOIN para evitar problemas de URL
      final experienciasResponse = await _supabase
          .from('experiencias')
          .select('*')
          .eq('user_id', userId)
          .order('data_visita', ascending: false);

      if (experienciasResponse.isEmpty) {
        return [];
      }

      // Buscar restaurantes separadamente para evitar problemas com embedded resources
      List<ExperienciaComRestaurante> resultado = [];
      
      for (final expData in experienciasResponse) {
        try {
          final experiencia = Experiencia.fromJson(expData);
          
          // Buscar restaurante separadamente
          final restauranteResponse = await _supabase
              .from('restaurantes')
              .select('''
                id,
                nome,
                tipo,
                descricao,
                imagem_url,
                latitude,
                longitude,
                tags
              ''')
              .eq('id', experiencia.restauranteId)
              .maybeSingle();

          if (restauranteResponse != null) {
            final restaurante = Restaurante.fromJson(restauranteResponse);
            resultado.add(ExperienciaComRestaurante(
              experiencia: experiencia,
              restaurante: restaurante,
            ));
          }
        } catch (e) {
          // Continua processando outras experiências mesmo se uma falhar
          continue;
        }
      }

      return resultado;
    } catch (e) {
      throw Exception('Erro ao buscar experiências do usuário: $e');
    }
  }

  /// Busca experiência específica de um usuário para um restaurante
  static Future<Experiencia?> buscarExperienciaUsuarioRestaurante(
    String userId,
    String restauranteId,
  ) async {
    try {
      final response = await _supabase
          .from('experiencias')
          .select()
          .eq('user_id', userId)
          .eq('restaurante_id', restauranteId)
          .maybeSingle();

      return response != null ? Experiencia.fromJson(response) : null;
    } catch (e) {
      throw Exception('Erro ao buscar experiência: $e');
    }
  }

  /// Atualiza uma experiência existente
  static Future<Experiencia> atualizarExperiencia(
    String experienciaId, {
    String? emoji,
    String? comentario,
    DateTime? dataVisita,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (emoji != null) updateData['emoji'] = emoji;
      if (comentario != null) updateData['comentario'] = comentario;
      if (dataVisita != null) updateData['data_visita'] = dataVisita.toIso8601String();
      
      if (updateData.isEmpty) {
        throw Exception('Nenhum campo para atualizar foi fornecido');
      }

      final response = await _supabase
          .from('experiencias')
          .update(updateData)
          .eq('id', experienciaId)
          .select()
          .single();

      return Experiencia.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar experiência: $e');
    }
  }

  /// Exclui uma experiência
  static Future<void> excluirExperiencia(String experienciaId) async {
    try {
      await _supabase
          .from('experiencias')
          .delete()
          .eq('id', experienciaId);
    } catch (e) {
      throw Exception('Erro ao excluir experiência: $e');
    }
  }



  /// Busca experiências recentes de todos os usuários (últimas 10)
  static Future<List<ExperienciaComRestaurante>> buscarExperienciasRecentes() async {
    try {
      // Buscar experiências sem JOIN para evitar problemas de URL
      final experienciasResponse = await _supabase
          .from('experiencias')
          .select('*')
          .order('created_at', ascending: false)
          .limit(10);

      if (experienciasResponse.isEmpty) {
        return [];
      }

      // Buscar restaurantes separadamente
      List<ExperienciaComRestaurante> resultado = [];
      
      for (final expData in experienciasResponse) {
        try {
          final experiencia = Experiencia.fromJson(expData);
          
          // Buscar restaurante separadamente
          final restauranteResponse = await _supabase
              .from('restaurantes')
              .select('''
                id,
                nome,
                tipo,
                descricao,
                imagem_url,
                latitude,
                longitude,
                tags
              ''')
              .eq('id', experiencia.restauranteId)
              .maybeSingle();

          if (restauranteResponse != null) {
            final restaurante = Restaurante.fromJson(restauranteResponse);
            resultado.add(ExperienciaComRestaurante(
              experiencia: experiencia,
              restaurante: restaurante,
            ));
          }
        } catch (e) {
          // Continua processando outras experiências mesmo se uma falhar
          continue;
        }
      }

      return resultado;
    } catch (e) {
      throw Exception('Erro ao buscar experiências recentes: $e');
    }
  }
}

/// Classe para combinar experiência com dados do restaurante
class ExperienciaComRestaurante {
  final Experiencia experiencia;
  final Restaurante restaurante;

  const ExperienciaComRestaurante({
    required this.experiencia,
    required this.restaurante,
  });
}



/// Enum para facilitar o uso dos emojis de avaliação
enum EmojiAvaliacao {
  delicioso('😋', 'Delicioso'),
  amei('❤️', 'Amei'),
  ok('😐', 'Ok'),
  ruim('🤢', 'Ruim');

  const EmojiAvaliacao(this.emoji, this.descricao);

  final String emoji;
  final String descricao;

  static EmojiAvaliacao? fromEmoji(String emoji) {
    for (final avaliacao in EmojiAvaliacao.values) {
      if (avaliacao.emoji == emoji) return avaliacao;
    }
    return null;
  }
} 