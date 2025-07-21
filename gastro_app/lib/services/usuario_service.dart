import '../models/usuario.dart';
import '../models/restaurante.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class UsuarioService {
  static final _supabase = SupabaseService.client;

  // Obter favoritos do usuário atual (método simplificado)
  static Future<Set<String>> obterFavoritos() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return <String>{};
      
      final favoritos = await obterIdsFavoritos(user.id);
      return favoritos.toSet();
    } catch (e) {
      return <String>{};
    }
  }

  // Buscar usuário atual (já criado automaticamente via trigger)
  static Future<Usuario?> obterUsuarioAtual() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response != null ? Usuario.fromJson(response) : null;
    } catch (e) {
      throw Exception('Erro ao obter usuário atual: $e');
    }
  }

  // Sincronizar dados do usuário (caso necessário atualizar)
  static Future<Usuario> sincronizarUsuario() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from('usuarios')
          .upsert({
            'id': user.id,
            'email': user.email!,
          })
          .select()
          .single();

      return Usuario.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao sincronizar usuário: $e');
    }
  }

  // Adicionar restaurante aos favoritos
  static Future<void> adicionarFavorito(String usuarioId, String restauranteId) async {
    try {
      final usuario = await _supabase
          .from('usuarios')
          .select('favoritos')
          .eq('id', usuarioId)
          .single();

      final favoritos = List<String>.from(usuario['favoritos'] ?? []);
      if (!favoritos.contains(restauranteId)) {
        favoritos.add(restauranteId);
        
        await _supabase
            .from('usuarios')
            .update({'favoritos': favoritos})
            .eq('id', usuarioId);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar favorito: $e');
    }
  }

  // Remover restaurante dos favoritos
  static Future<void> removerFavorito(String usuarioId, String restauranteId) async {
    try {
      final usuario = await _supabase
          .from('usuarios')
          .select('favoritos')
          .eq('id', usuarioId)
          .single();

      final favoritos = List<String>.from(usuario['favoritos'] ?? []);
      favoritos.remove(restauranteId);
      
      await _supabase
          .from('usuarios')
          .update({'favoritos': favoritos})
          .eq('id', usuarioId);
    } catch (e) {
      throw Exception('Erro ao remover favorito: $e');
    }
  }

  // Toggle favorito (adiciona se não existir, remove se existir)
  static Future<bool> toggleFavorito(String usuarioId, String restauranteId) async {
    try {
      final usuario = await _supabase
          .from('usuarios')
          .select('favoritos')
          .eq('id', usuarioId)
          .single();

      final favoritos = List<String>.from(usuario['favoritos'] ?? []);
      final jaEstaFavoritado = favoritos.contains(restauranteId);
      
      if (jaEstaFavoritado) {
        favoritos.remove(restauranteId);
      } else {
        favoritos.add(restauranteId);
      }
      
      await _supabase
          .from('usuarios')
          .update({'favoritos': favoritos})
          .eq('id', usuarioId);

      return !jaEstaFavoritado; // Retorna true se foi adicionado, false se foi removido
    } catch (e) {
      throw Exception('Erro ao alternar favorito: $e');
    }
  }

  // Verificar se um restaurante está nos favoritos
  static Future<bool> ehFavorito(String usuarioId, String restauranteId) async {
    try {
      final usuario = await _supabase
          .from('usuarios')
          .select('favoritos')
          .eq('id', usuarioId)
          .single();

      final favoritos = List<String>.from(usuario['favoritos'] ?? []);
      return favoritos.contains(restauranteId);
    } catch (e) {
      throw Exception('Erro ao verificar favorito: $e');
    }
  }

  // Buscar lista de restaurantes favoritos com detalhes
  static Future<List<Restaurante>> buscarRestaurantesFavoritos(String usuarioId) async {
    try {
      final usuario = await _supabase
          .from('usuarios')
          .select('favoritos')
          .eq('id', usuarioId)
          .single();

      final favoritos = List<String>.from(usuario['favoritos'] ?? []);
      
      if (favoritos.isEmpty) {
        return [];
      }

      final response = await _supabase
          .from('restaurantes')
          .select()
          .inFilter('id', favoritos);

      return (response as List<dynamic>)
          .map((data) => Restaurante.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar restaurantes favoritos: $e');
    }
  }

  // Obter lista de IDs dos favoritos
  static Future<List<String>> obterIdsFavoritos(String usuarioId) async {
    try {
      final usuario = await _supabase
          .from('usuarios')
          .select('favoritos')
          .eq('id', usuarioId)
          .single();

      return List<String>.from(usuario['favoritos'] ?? []);
    } catch (e) {
      throw Exception('Erro ao obter favoritos: $e');
    }
  }

  // Limpar todos os favoritos
  static Future<void> limparFavoritos(String usuarioId) async {
    try {
      await _supabase
          .from('usuarios')
          .update({'favoritos': []})
          .eq('id', usuarioId);
    } catch (e) {
      throw Exception('Erro ao limpar favoritos: $e');
    }
  }
} 