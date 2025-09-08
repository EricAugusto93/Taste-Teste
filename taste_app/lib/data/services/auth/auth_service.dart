import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

/// Modelo básico de usuário baseado no Supabase User
class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
    this.metadata,
  });

  /// Cria AppUser a partir do Supabase User
  factory AppUser.fromSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String? ??
          user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt),
      metadata: user.userMetadata,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia com modificações
  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Resposta de autenticação
class AuthResponse {
  final AppUser? user;
  final String? error;
  final Session? session;
  final bool success;

  const AuthResponse({
    this.user,
    this.error,
    this.session,
    this.success = false,
  });

  /// Factory para sucesso
  factory AuthResponse.success({required AppUser user, Session? session}) {
    return AuthResponse(
      user: user,
      session: session,
      success: true,
    );
  }

  /// Factory para erro
  factory AuthResponse.error(String error) {
    return AuthResponse(error: error, success: false);
  }
}

/// Serviço de autenticação integrado com Supabase
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  // Cliente Supabase
  SupabaseClient get _supabase => SupabaseConfig.client;

  // Estado atual
  AppUser? _currentUser;
  Session? _currentSession;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;

  /// ID do usuário atual
  String? get userId => _currentUser?.id;

  /// Email do usuário atual
  String? get userEmail => _currentUser?.email;

  /// Usuário atual
  AppUser? get currentUser => _currentUser;

  /// Sessão atual
  Session? get currentSession => _currentSession;

  /// Stream de mudanças no estado de autenticação
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => _currentUser != null && _currentSession != null;

  /// Verifica se tem uma sessão válida
  bool get hasValidSession => _currentSession != null && !_isSessionExpired();

  /// Verifica se a sessão expirou
  bool _isSessionExpired() {
    if (_currentSession?.expiresAt == null) return true;
    return DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
        _currentSession!.expiresAt! * 1000));
  }

  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      debugPrint('🔐 AuthService: Inicializando com Supabase');

      // Verificar se há uma sessão existente
      final session = _supabase.auth.currentSession;
      if (session?.user != null) {
        debugPrint(
            '🔐 AuthService: Sessão existente encontrada para ${session!.user.email}');
        _updateAuthState(session);
      }

      // Escutar mudanças de auth state
      _authSubscription = _supabase.auth.onAuthStateChange.listen(
        (data) {
          debugPrint('🔐 AuthService: Mudança de estado: ${data.event}');
          _updateAuthState(data.session);
        },
        onError: (error) {
          debugPrint('❌ AuthService: Erro no listener: $error');
        },
      );

      debugPrint('✅ AuthService: Inicialização concluída');
    } catch (e) {
      debugPrint('❌ AuthService: Erro na inicialização: $e');
      // Em caso de erro, continua sem sessão
    }
  }

  /// Atualiza o estado de autenticação
  void _updateAuthState(Session? session) {
    _currentSession = session;
    if (session?.user != null) {
      _currentUser = AppUser.fromSupabaseUser(session!.user);
      debugPrint('✅ AuthService: Usuário logado: ${_currentUser!.email}');
    } else {
      _currentUser = null;
      debugPrint('🔐 AuthService: Usuário deslogado');
    }
    _authStateController.add(_currentUser);
  }

  /// Faz login com email e senha
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      debugPrint('🔐 AuthService: Tentando login para $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null && response.session != null) {
        debugPrint(
            '✅ AuthService: Login bem-sucedido para ${response.user!.email}');
        final appUser = AppUser.fromSupabaseUser(response.user!);

        // O estado será atualizado automaticamente pelo listener
        return AuthResponse.success(
          user: appUser,
          session: response.session,
        );
      } else {
        debugPrint('❌ AuthService: Login falhou - sem usuário ou sessão');
        return AuthResponse.error('Login falhou');
      }
    } on AuthException catch (e) {
      debugPrint('❌ AuthService: Erro de autenticação: ${e.message}');
      return AuthResponse.error(_getLocalizedError(e.message));
    } catch (e) {
      debugPrint('❌ AuthService: Erro geral no login: $e');
      return AuthResponse.error('Erro interno. Tente novamente.');
    }
  }

  /// Registra usuário com email e senha
  Future<AuthResponse> signUpWithEmail(String email, String password,
      {String? name}) async {
    try {
      debugPrint('🔐 AuthService: Tentando registro para $email');

      final metadata = name != null ? {'full_name': name} : <String, dynamic>{};

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
      );

      if (response.user != null) {
        debugPrint(
            '✅ AuthService: Registro bem-sucedido para ${response.user!.email}');
        final appUser = AppUser.fromSupabaseUser(response.user!);

        // Criar perfil do usuário na tabela user_profiles se necessário
        await _createUserProfile(response.user!);

        return AuthResponse.success(
          user: appUser,
          session: response.session,
        );
      } else {
        debugPrint('❌ AuthService: Registro falhou - sem usuário');
        return AuthResponse.error('Registro falhou');
      }
    } on AuthException catch (e) {
      debugPrint(
          '❌ AuthService: Erro de autenticação no registro: ${e.message}');
      return AuthResponse.error(_getLocalizedError(e.message));
    } catch (e) {
      debugPrint('❌ AuthService: Erro geral no registro: $e');
      return AuthResponse.error('Erro interno. Tente novamente.');
    }
  }

  /// Cria perfil do usuário na tabela user_profiles
  Future<void> _createUserProfile(User user) async {
    try {
      await _supabase.from('user_profiles').upsert({
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['full_name'],
        'avatar_url': user.userMetadata?['avatar_url'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ AuthService: Perfil do usuário criado/atualizado');
    } catch (e) {
      debugPrint('⚠️ AuthService: Erro ao criar perfil: $e (continuando...)');
    }
  }

  /// Faz login básico (compatibilidade)
  Future<void> login(String email, String password) async {
    final result = await signInWithEmail(email, password);
    if (!result.success) {
      throw Exception(result.error);
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      debugPrint('🔐 AuthService: Fazendo logout');
      await _supabase.auth.signOut();
      debugPrint('✅ AuthService: Logout realizado');
      // O estado será atualizado automaticamente pelo listener
    } catch (e) {
      debugPrint('❌ AuthService: Erro no logout: $e');
      // Limpa estado local mesmo com erro
      _updateAuthState(null);
    }
  }

  /// Faz logout (compatibilidade)
  Future<void> logout() async {
    await signOut();
  }

  /// Login anônimo (não suportado no Supabase por padrão)
  Future<void> signInAnonymously() async {
    debugPrint('⚠️ AuthService: Login anônimo não implementado com Supabase');
    // Por enquanto, não faz nada - usuário fica sem login
    _updateAuthState(null);
  }

  /// Reset de senha
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('🔐 AuthService: Reset de senha para $email');

      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: kIsWeb ? '${Uri.base.origin}/reset-password' : null,
      );

      debugPrint('✅ AuthService: Email de reset enviado');
    } on AuthException catch (e) {
      debugPrint('❌ AuthService: Erro no reset: ${e.message}');
      throw Exception(_getLocalizedError(e.message));
    } catch (e) {
      debugPrint('❌ AuthService: Erro geral no reset: $e');
      throw Exception('Erro interno. Tente novamente.');
    }
  }

  /// Atualiza sessão se necessário
  Future<void> refreshSessionIfNeeded() async {
    try {
      if (_isSessionExpired()) {
        debugPrint('🔄 AuthService: Renovando sessão expirada');
        final response = await _supabase.auth.refreshSession();
        if (response.session != null) {
          debugPrint('✅ AuthService: Sessão renovada');
        } else {
          debugPrint('❌ AuthService: Falha ao renovar sessão');
          await signOut();
        }
      }
    } catch (e) {
      debugPrint('❌ AuthService: Erro ao renovar sessão: $e');
      await signOut();
    }
  }

  /// Força autenticação local para desenvolvimento
  void forceLocalAuth() {
    if (!kDebugMode) {
      debugPrint('⚠️ AuthService: forceLocalAuth só funciona em modo debug');
      return;
    }

    debugPrint('🔓 AuthService: Criando usuário dev mock para desenvolvimento');

    try {
      // Criar usuário mock para desenvolvimento
      _currentUser = const AppUser(
        id: '00000000-0000-0000-0000-000000000001',
        email: 'dev@taste.app',
        name: 'Desenvolvedor Taste',
        avatarUrl: null,
        createdAt: null,
        metadata: {'dev_mode': true},
      );

      // Criar uma sessão mock mínima (sem usar construtor Session real)
      // Isso permite que isAuthenticated retorne true
      final mockSessionData = {
        'access_token': 'dev_token_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': 'dev_user_001',
        'expires_at': DateTime.now()
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch,
      };

      // Para simular uma sessão, vamos definir _currentSession como uma instância mock
      // mas sem usar o construtor real para evitar erros
      debugPrint('✅ AuthService: Usuário dev criado - ${_currentUser!.email}');
      debugPrint(
          '📝 AuthService: hasValidSession simulado para desenvolvimento');

      // Simular que temos uma sessão válida criando um objeto mock simples
      _currentSession = _createMockSession();

      debugPrint('🎯 AuthService: isAuthenticated = $isAuthenticated');
    } catch (e) {
      debugPrint('❌ AuthService: Erro ao criar usuário dev: $e');
    }
  }

  /// Cria uma sessão mock para desenvolvimento
  Session? _createMockSession() {
    if (!kDebugMode) return null;

    try {
      final now = DateTime.now();
      return Session(
        accessToken: 'dev_access_token',
        refreshToken: 'dev_refresh_token',
        expiresIn: 86400, // 24 horas
        tokenType: 'bearer',
        user: User(
          id: '00000000-0000-0000-0000-000000000001',
          aud: 'authenticated',
          email: 'dev@taste.app',
          createdAt: now.toIso8601String(),
          emailConfirmedAt: now.toIso8601String(),
          appMetadata: const {'provider': 'dev'},
          userMetadata: const {'name': 'Desenvolvedor Taste'},
        ),
      );
    } catch (e) {
      debugPrint('⚠️ AuthService: Erro ao criar sessão mock: $e');
      // Se não conseguir criar Session, pelo menos garante que _currentUser existe
      return null;
    }
  }

  /// Converte mensagens de erro para português
  String _getLocalizedError(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials')) {
      return 'Email ou senha incorretos';
    }
    if (lowerMessage.contains('user not found')) {
      return 'Usuário não encontrado';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return 'Confirme seu email antes de fazer login';
    }
    if (lowerMessage.contains('password')) {
      return 'Problema com a senha fornecida';
    }
    if (lowerMessage.contains('email')) {
      return 'Problema com o email fornecido';
    }
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection')) {
      return 'Problema de conexão. Verifique sua internet.';
    }

    return message; // Retorna original se não encontrou tradução
  }

  /// Dispose dos resources
  void dispose() {
    debugPrint('🔐 AuthService: Fazendo dispose');
    _authSubscription?.cancel();
    _authStateController.close();
  }
}
