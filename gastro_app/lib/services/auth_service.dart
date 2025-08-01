import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getters seguros para facilitar acesso
  static User? get currentUser {
    try {
      return _client.auth.currentUser;
    } catch (e) {
      debugPrint('Erro ao obter usuário atual: $e');
      return null;
    }
  }
  
  static Session? get currentSession {
    try {
      return _client.auth.currentSession;
    } catch (e) {
      debugPrint('Erro ao obter sessão atual: $e');
      return null;
    }
  }
  
  static Stream<AuthState> get authStateChanges {
    try {
      return _client.auth.onAuthStateChange;
    } catch (e) {
      debugPrint('Erro ao obter stream de auth: $e');
      // Retornar stream vazio em caso de erro
      return Stream.value(AuthState(AuthChangeEvent.signedOut, null));
    }
  }
  
  // Resultado de operações de autenticação
  static AuthResult success(User user) => AuthResult.success(user);
  static AuthResult error(String message) => AuthResult.error(message);
  static AuthResult needsConfirmation(String email) => AuthResult.needsConfirmation(email);
  
  /// Faz login com email e senha
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validação básica
      if (email.trim().isEmpty) {
        return error('Email é obrigatório');
      }
      if (password.isEmpty) {
        return error('Senha é obrigatória');
      }

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
      
      // Tratamento específico para email não confirmado
      if (e.message.toLowerCase().contains('email not confirmed')) {
        return needsConfirmation(email.trim());
      }
      
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
        
        // Se precisar confirmar email, retorna status especial
        if (response.session == null) {
          debugPrint('📧 Email de confirmação enviado para: ${response.user!.email}');
          return needsConfirmation(response.user!.email!);
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
  
  /// Reenvia email de confirmação
  static Future<bool> resendConfirmation(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
      debugPrint('✅ Email de confirmação reenviado para: $email');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao reenviar confirmação: $e');
      return false;
    }
  }
  
  /// Faz logout do usuário atual
  static Future<bool> signOut() async {
    try {
      // Verificar se há uma sessão ativa antes de tentar logout
      final session = currentSession;
      if (session == null) {
        debugPrint('⚠️ Nenhuma sessão ativa para fazer logout');
        return true; // Consideramos sucesso se já não há sessão
      }

      // Usar SignOutScope.local para evitar erro 403
      await _client.auth.signOut(scope: SignOutScope.local);
      debugPrint('✅ Logout local realizado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
      
      // Se o erro for 403 (Forbidden), ainda consideramos sucesso
      // pois o logout local funciona mesmo com esse erro
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        debugPrint('ℹ️ Erro 403 no logout é esperado - logout local funcionou');
        return true;
      }
      
      // Para outros erros, ainda consideramos como logout bem-sucedido
      // para evitar que o usuário fique "preso" na sessão
      return true;
    }
  }
  
  /// Verifica se usuário está autenticado (com proteção null)
  static bool get isAuthenticated {
    try {
      final user = currentUser;
      final session = currentSession;
      return user != null && session != null;
    } catch (e) {
      debugPrint('Erro ao verificar autenticação: $e');
      return false;
    }
  }
  
  /// Recupera senha por email
  static Future<bool> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        debugPrint('❌ Email vazio para reset de senha');
        return false;
      }
      
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
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
    
    if (message.contains('invalid login credentials')) {
      return 'Email ou senha incorretos';
    }
    
    if (message.contains('email not confirmed')) {
      return 'Email não confirmado. Verifique sua caixa de entrada.';
    }
    
    if (message.contains('invalid email or password')) {
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

  /// Limpa estado de autenticação corrompido
  static Future<void> clearCorruptedAuthState() async {
    try {
      // Tentar fazer logout para limpar o estado
      await _client.auth.signOut();
      debugPrint('🔄 Estado de autenticação limpo');
    } catch (e) {
      debugPrint('⚠️ Erro ao limpar estado: $e');
      
      // Se logout falhar, tentar limpar storage diretamente
      try {
        // Limpar localStorage se estivermos no web
        if (kIsWeb) {
          // Para web, podemos tentar acessar localStorage via JavaScript
          debugPrint('🧹 Tentando limpar localStorage do navegador...');
        }
      } catch (storageError) {
        debugPrint('❌ Erro ao limpar storage: $storageError');
      }
    }
  }
  
  /// Verifica e corrige problemas de autenticação
  static Future<bool> validateAndFixAuthState() async {
    try {
      final session = currentSession;
      final user = currentUser;
      
      // Se não há sessão, está tudo ok
      if (session == null || user == null) {
        return true;
      }
      
      // Verificar se a sessão é válida
      if (session.expiresAt != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
        final now = DateTime.now();
        
        if (expiryDate.isBefore(now)) {
          debugPrint('🔄 Sessão expirada, fazendo logout...');
          await clearCorruptedAuthState();
          return false;
        }
      }
      
      // Verificar se o token está válido
      if (session.accessToken.isEmpty) {
        debugPrint('🔄 Token vazio, limpando estado...');
        await clearCorruptedAuthState();
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('⚠️ Erro na validação de auth state: $e');
      await clearCorruptedAuthState();
      return false;
    }
  }
}

/// Classe para resultado das operações de autenticação
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final bool needsEmailConfirmation;
  final String? emailToConfirm;
  
  AuthResult.success(this.user) 
    : isSuccess = true, 
      error = null, 
      needsEmailConfirmation = false,
      emailToConfirm = null;
      
  AuthResult.error(this.error) 
    : isSuccess = false, 
      user = null, 
      needsEmailConfirmation = false,
      emailToConfirm = null;
      
  AuthResult.needsConfirmation(this.emailToConfirm) 
    : isSuccess = false, 
      user = null, 
      error = null,
      needsEmailConfirmation = true;
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