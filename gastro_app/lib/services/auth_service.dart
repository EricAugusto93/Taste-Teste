import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getters para facilitar acesso
  static User? get currentUser => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Resultado de operações de autenticação
  static AuthResult success(User user) => AuthResult.success(user);
  static AuthResult error(String message) => AuthResult.error(message);
  
  /// Faz login com email e senha
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user != null) {
        debugPrint('✅ Login realizado: ${response.user!.email}');
        return success(response.user!);
      } else {
        return error('Erro inesperado no login');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Erro de autenticação: ${e.message}');
      return error(_getAuthErrorMessage(e.message));
    } catch (e) {
      debugPrint('❌ Erro geral no login: $e');
      return error('Erro de conexão. Tente novamente.');
    }
  }
  
  /// Registra novo usuário com email e senha
  static Future<AuthResult> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: name != null ? {'name': name.trim()} : null,
      );
      
      if (response.user != null) {
        debugPrint('✅ Registro realizado: ${response.user!.email}');
        
        // Se precisar confirmar email, informar usuário
        if (response.session == null) {
          return error('Verifique seu email para confirmar a conta');
        }
        
        return success(response.user!);
      } else {
        return error('Erro inesperado no registro');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Erro no registro: ${e.message}');
      return error(_getAuthErrorMessage(e.message));
    } catch (e) {
      debugPrint('❌ Erro geral no registro: $e');
      return error('Erro de conexão. Tente novamente.');
    }
  }
  
  /// Faz logout do usuário atual
  static Future<bool> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('✅ Logout realizado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
      return false;
    }
  }
  
  /// Verifica se usuário está autenticado
  static bool get isAuthenticated => currentUser != null;
  
  /// Recupera senha por email
  static Future<bool> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'gastroapp://auth/reset-password', // Deep link para o app
      );
      debugPrint('✅ Email de recuperação enviado para: $email');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao enviar email de recuperação: $e');
      return false;
    }
  }
  
  /// Atualiza dados do usuário
  static Future<AuthResult> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: email?.trim(),
          password: password,
          data: data,
        ),
      );
      
      if (response.user != null) {
        debugPrint('✅ Usuário atualizado: ${response.user!.email}');
        return success(response.user!);
      } else {
        return error('Erro ao atualizar usuário');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Erro ao atualizar usuário: ${e.message}');
      return error(_getAuthErrorMessage(e.message));
    } catch (e) {
      debugPrint('❌ Erro geral ao atualizar: $e');
      return error('Erro de conexão. Tente novamente.');
    }
  }
  
  /// Converte mensagens de erro do Supabase para português
  static String _getAuthErrorMessage(String originalMessage) {
    final message = originalMessage.toLowerCase();
    
    if (message.contains('invalid login credentials') ||
        message.contains('email not confirmed') ||
        message.contains('invalid email or password')) {
      return 'Email ou senha incorretos';
    }
    
    if (message.contains('user already registered')) {
      return 'Este email já está cadastrado';
    }
    
    if (message.contains('password should be at least 6 characters')) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    if (message.contains('invalid email')) {
      return 'Email inválido';
    }
    
    if (message.contains('signup is disabled')) {
      return 'Cadastro temporariamente desabilitado';
    }
    
    if (message.contains('email rate limit exceeded')) {
      return 'Muitas tentativas. Aguarde alguns minutos.';
    }
    
    if (message.contains('invalid refresh token') ||
        message.contains('refresh token not found')) {
      return 'Sessão expirada. Faça login novamente.';
    }
    
    // Mensagem genérica para erros não mapeados
    return 'Erro de autenticação. Tente novamente.';
  }
}

/// Classe para resultado das operações de autenticação
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  
  AuthResult.success(this.user) : isSuccess = true, error = null;
  AuthResult.error(this.error) : isSuccess = false, user = null;
}

/// Extensão para facilitar validações
extension AuthValidation on String {
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }
  
  bool get isValidPassword {
    return length >= 6;
  }
} 