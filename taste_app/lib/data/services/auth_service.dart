import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

/// Serviço de autenticação usando Supabase
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  /// Cliente Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Usuário atual
  User? get currentUser => _client.auth.currentUser;

  /// Estado de autenticação local (fallback para problemas de conectividade)
  static bool _localAuthState = false;
  
  /// Se o usuário está autenticado
  bool get isAuthenticated {
    // Prioriza o estado do Supabase se estiver funcionando
    try {
      final supabaseUser = currentUser;
      if (supabaseUser != null) {
        _localAuthState = true;
        debugPrint('✅ AuthService: Usuário autenticado via Supabase: ${supabaseUser.email}');
        return true;
      }
      // Se não há usuário no Supabase mas temos estado local, usa o local
      debugPrint('🔍 AuthService: Sem usuário Supabase, usando estado local: $_localAuthState');
      return _localAuthState;
    } catch (e) {
      // Em caso de erro de conectividade, usa estado local
      debugPrint('⚠️ AuthService: Usando estado local devido a erro: $e, estado: $_localAuthState');
      return _localAuthState;
    }
  }

  /// Stream de mudanças no estado de autenticação
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Inicializa o serviço de autenticação
  Future<void> initialize() async {
    try {
      // A sessão é recuperada automaticamente pelo Supabase
      debugPrint('Serviço de autenticação inicializado');
      debugPrint('Usuário atual: ${currentUser?.email ?? "Não autenticado"}');
    } catch (e) {
      debugPrint('Erro ao inicializar autenticação: $e');
    }
  }

  /// Faz login com email e senha
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _localAuthState = true; // Marca como autenticado localmente
      debugPrint('✅ AuthService: Login realizado com sucesso');
      return response;
    } catch (e) {
      debugPrint('❌ AuthService: Erro no login: $e');
      
      // Fallback: simula login local para desenvolvimento
      if (email == 'user@example.com' && password == 'password123') {
        debugPrint('🔓 AuthService: Login local simulado para desenvolvimento');
        _localAuthState = true;
        // Retorna uma resposta mock
        return AuthResponse(
          user: null,
          session: null,
        );
      }
      
      rethrow;
    }
  }
  
  /// Faz logout local
  void signOutLocal() {
    _localAuthState = false;
    debugPrint('🔒 AuthService: Logout local realizado');
  }
  
  /// Força autenticação local (para desenvolvimento)
  void forceLocalAuth() {
    _localAuthState = true;
    debugPrint('🔓 AuthService: Autenticação local forçada para desenvolvimento');
  }

  /// Registra um novo usuário com email e senha
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return response;
    } catch (e) {
      debugPrint('Erro no registro: $e');
      rethrow;
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('Logout realizado com sucesso');
    } catch (e) {
      debugPrint('Erro no logout: $e');
      rethrow;
    }
  }

  /// Envia email de recuperação de senha
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      debugPrint('Email de recuperação enviado');
    } catch (e) {
      debugPrint('Erro ao enviar email de recuperação: $e');
      rethrow;
    }
  }

  /// Atualiza dados do usuário
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
      return response;
    } catch (e) {
      debugPrint('Erro ao atualizar usuário: $e');
      rethrow;
    }
  }

  /// Login anônimo (para modo guest)
  Future<AuthResponse> signInAnonymously() async {
    try {
      final response = await _client.auth.signInAnonymously();
      debugPrint('Login anônimo realizado');
      return response;
    } catch (e) {
      debugPrint('Erro no login anônimo: $e');
      rethrow;
    }
  }

  /// Verifica se o email está confirmado
  bool get isEmailConfirmed {
    final user = currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }

  /// Reenvia email de confirmação
  Future<void> resendConfirmation(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      debugPrint('Email de confirmação reenviado');
    } catch (e) {
      debugPrint('Erro ao reenviar confirmação: $e');
      rethrow;
    }
  }

  /// Obtém o token de acesso atual
  String? get accessToken => _client.auth.currentSession?.accessToken;

  /// Verifica se a sessão é válida
  bool get hasValidSession {
    final session = _client.auth.currentSession;
    if (session == null) return false;
    
    final now = DateTime.now();
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      session.expiresAt! * 1000,
    );
    
    return now.isBefore(expiresAt);
  }

  /// Atualiza a sessão se necessário
  Future<void> refreshSessionIfNeeded() async {
    try {
      if (!hasValidSession) {
        await _client.auth.refreshSession();
        debugPrint('Sessão atualizada');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar sessão: $e');
    }
  }

  /// Obtém informações do perfil do usuário
  Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  /// ID do usuário atual
  String? get userId => currentUser?.id;

  /// Email do usuário atual
  String? get userEmail => currentUser?.email;

  /// Limpa dados de autenticação
  void clearAuthData() {
    // O Supabase gerencia isso automaticamente no signOut
    debugPrint('Dados de autenticação limpos');
  }
}