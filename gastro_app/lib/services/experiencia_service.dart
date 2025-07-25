import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/experiencia.dart';
import '../models/restaurante.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ExperienciaService {
  static final _supabase = SupabaseService.client;

  /// Obter experiências do usuário (método simplificado)
  static Future<List<dynamic>> obterExperienciasUsuario() async {
    try {
      print('🔄 [obterExperienciasUsuario] Iniciando...');
      final user = AuthService.currentUser;
      print('👤 [obterExperienciasUsuario] Usuário atual: ${user?.id}');
      
      if (user == null) {
        print('❌ [obterExperienciasUsuario] Usuário não encontrado');
        return [];
      }
      
      print('🔍 [obterExperienciasUsuario] Buscando experiências para usuário: ${user.id}');
      final experiencias = await buscarExperienciasDoUsuario(user.id);
      print('✅ [obterExperienciasUsuario] Experiências encontradas: ${experiencias.length}');
      
      for (int i = 0; i < experiencias.length; i++) {
        final exp = experiencias[i];
        print('📊 [obterExperienciasUsuario] Experiência $i: ${exp.experiencia.emoji} - ${exp.restaurante.nome}');
      }
      
      return experiencias;
    } catch (e) {
      print('❌ [obterExperienciasUsuario] ERRO: $e');
      print('🔍 [obterExperienciasUsuario] Stack trace: ${StackTrace.current}');
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
    String? comentario,
    DateTime? dataVisita,
  }) async {
    try {
      print('🔄 [ExperienciaService] Iniciando registro de experiência');
      print('📊 [ExperienciaService] Dados: userId=$userId, restauranteId=$restauranteId, emoji=$emoji');
      
      final dataVisitaFinal = dataVisita ?? DateTime.now();
      
      // Verificar se já existe uma experiência para este restaurante hoje
      print('🔍 [ExperienciaService] Verificando experiência existente...');
      final experienciaExistente = await buscarExperienciaUsuarioRestaurante(
        userId, 
        restauranteId
      );
      
      if (experienciaExistente != null) {
        print('🔄 [ExperienciaService] Experiência existente encontrada, atualizando...');
        // Se já existe uma experiência, atualizar ao invés de criar nova
        final resultado = await atualizarExperiencia(
          experienciaExistente.id,
          emoji: emoji,
          comentario: comentario,
          dataVisita: dataVisitaFinal,
        );
        print('✅ [ExperienciaService] Experiência atualizada com sucesso');
        return resultado;
      }
      
      print('➕ [ExperienciaService] Criando nova experiência...');
      final dadosInsert = {
        'user_id': userId,
        'restaurante_id': restauranteId,
        'emoji': emoji,
        'comentario': comentario?.isNotEmpty == true ? comentario : null,
        'data_visita': dataVisitaFinal.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      print('📤 [ExperienciaService] Enviando dados para Supabase: $dadosInsert');
      
      final response = await _supabase
          .from('experiencias')
          .insert(dadosInsert)
          .select()
          .single();

      print('📥 [ExperienciaService] Resposta do Supabase: $response');
      
      final experiencia = Experiencia.fromJson(response);
      print('✅ [ExperienciaService] Experiência criada com sucesso: ${experiencia.id}');
      
      return experiencia;
    } catch (e) {
      print('❌ [ExperienciaService] Erro ao registrar experiência: $e');
      print('🔍 [ExperienciaService] Stack trace: ${StackTrace.current}');
      throw Exception('Erro ao registrar experiência: $e');
    }
  }

  /// Busca todas as experiências de um usuário
  static Future<List<ExperienciaComRestaurante>> buscarExperienciasDoUsuario(
    String userId,
  ) async {
    try {
      print('🔍 [buscarExperienciasDoUsuario] Buscando experiências para userId: $userId');
      
      // Buscar experiências sem JOIN para evitar problemas de URL
      final experienciasResponse = await _supabase
          .from('experiencias')
          .select('*')
          .eq('user_id', userId)
          .order('data_visita', ascending: false);

      print('📥 [buscarExperienciasDoUsuario] Resposta do Supabase: ${experienciasResponse.length} experiências');
      
      if (experienciasResponse.isEmpty) {
        print('❌ [buscarExperienciasDoUsuario] Nenhuma experiência encontrada');
        return [];
      }

      // Buscar restaurantes separadamente para evitar problemas com embedded resources
      List<ExperienciaComRestaurante> resultado = [];
      
      for (int i = 0; i < experienciasResponse.length; i++) {
        final expData = experienciasResponse[i];
        try {
          print('🔄 [buscarExperienciasDoUsuario] Processando experiência $i: ${expData['id']}');
          final experiencia = Experiencia.fromJson(expData);
          print('✅ [buscarExperienciasDoUsuario] Experiência criada: ${experiencia.emoji}');
          
          // Buscar restaurante separadamente
          print('🔍 [buscarExperienciasDoUsuario] Buscando restaurante: ${experiencia.restauranteId}');
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
                tags,
                created_at,
                updated_at
              ''')
              .eq('id', experiencia.restauranteId)
              .maybeSingle();

          if (restauranteResponse != null) {
            print('✅ [buscarExperienciasDoUsuario] Restaurante encontrado: ${restauranteResponse['nome']}');
            final restaurante = Restaurante.fromJson(restauranteResponse);
            resultado.add(ExperienciaComRestaurante(
              experiencia: experiencia,
              restaurante: restaurante,
            ));
            print('✅ [buscarExperienciasDoUsuario] ExperienciaComRestaurante adicionada');
          } else {
            print('❌ [buscarExperienciasDoUsuario] Restaurante não encontrado para ID: ${experiencia.restauranteId}');
          }
        } catch (e) {
          print('❌ [buscarExperienciasDoUsuario] Erro ao processar experiência $i: $e');
          // Continua processando outras experiências mesmo se uma falhar
          continue;
        }
      }

      print('✅ [buscarExperienciasDoUsuario] Total de experiências processadas: ${resultado.length}');
      return resultado;
    } catch (e) {
      print('❌ [buscarExperienciasDoUsuario] Erro geral: $e');
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
      print('🔄 [ExperienciaService] Atualizando experiência: $experienciaId');
      
      final updateData = <String, dynamic>{};
      
      if (emoji != null) updateData['emoji'] = emoji;
      if (comentario != null) updateData['comentario'] = comentario.isNotEmpty ? comentario : null;
      if (dataVisita != null) updateData['data_visita'] = dataVisita.toIso8601String();
      
      // Sempre atualizar o timestamp
      updateData['updated_at'] = DateTime.now().toIso8601String();
      
      if (updateData.isEmpty) {
        throw Exception('Nenhum campo para atualizar foi fornecido');
      }
      
      print('📤 [ExperienciaService] Dados de atualização: $updateData');
      
      final response = await _supabase
          .from('experiencias')
          .update(updateData)
          .eq('id', experienciaId)
          .select()
          .single();

      print('📥 [ExperienciaService] Resposta da atualização: $response');
      
      final experiencia = Experiencia.fromJson(response);
      print('✅ [ExperienciaService] Experiência atualizada com sucesso');
      
      return experiencia;
    } catch (e) {
      print('❌ [ExperienciaService] Erro ao atualizar experiência: $e');
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
                tags,
                created_at,
                updated_at
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