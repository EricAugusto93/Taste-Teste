import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

/// Modelo básico de usuário
class AppUser {
  final String id;
  final String email;
  
  const AppUser({required this.id, required this.email});
}

/// Resposta de autenticação
class AuthResponse {
  final AppUser? user;
  final String? error;
  
  const AuthResponse({this.user, this.error});
}

/// Serviço básico de autenticação
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  String? _userId;
  String? _userEmail;
  AppUser? _currentUser;
  final StreamController<AppUser?> _authStateController = StreamController<AppUser?>.broadcast();

  /// ID do usuário atual
  String? get userId => _userId;

  /// Email do usuário atual
  String? get userEmail => _userEmail;

  /// Usuário atual
  AppUser? get currentUser => _currentUser;

  /// Stream de mudanças no estado de autenticação
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => _userId != null;

  /// Verifica se tem uma sessão válida
  bool get hasValidSession => _currentUser != null;

  /// Inicializa o serviço
  Future<void> initialize() async {
    debugPrint('🔐 Auth: Inicializando serviço de autenticação');
    // Por enquanto, inicia com usuário anônimo
    await signInAnonymously();
  }

  /// Faz login com email e senha
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      debugPrint('🔐 Auth: Login para $email');
      _userId = _generateUuid();
      _userEmail = email;
      _currentUser = AppUser(id: _userId!, email: email);
      _authStateController.add(_currentUser);
      return AuthResponse(user: _currentUser);
    } catch (e) {
      return AuthResponse(error: 'Erro no login: $e');
    }
  }

  /// Registra usuário com email e senha
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      debugPrint('🔐 Auth: Registrando usuário $email');
      _userId = _generateUuid();
      _userEmail = email;
      _currentUser = AppUser(id: _userId!, email: email);
      _authStateController.add(_currentUser);
      return AuthResponse(user: _currentUser);
    } catch (e) {
      return AuthResponse(error: 'Erro no registro: $e');
    }
  }

  /// Faz login básico (compatibilidade)
  Future<void> login(String email, String password) async {
    await signInWithEmail(email, password);
  }

  /// Faz logout
  Future<void> signOut() async {
    debugPrint('🔐 Auth: Logout');
    _userId = null;
    _userEmail = null;
    _currentUser = null;
    _authStateController.add(null);
  }

  /// Faz logout (compatibilidade)
  Future<void> logout() async {
    await signOut();
  }

  /// Login anônimo
  Future<void> signInAnonymously() async {
    debugPrint('🔐 Auth: Login anônimo');
    _userId = _generateUuid();
    _userEmail = 'anonimo@taste.app';
    _currentUser = AppUser(id: _userId!, email: _userEmail!);
    _authStateController.add(_currentUser);
  }

  /// Reset de senha
  Future<void> resetPassword(String email) async {
    debugPrint('🔐 Auth: Reset de senha para $email');
    // Mock - em produção enviaria email
  }

  /// Força autenticação local
  void forceLocalAuth() {
    debugPrint('🔐 Auth: Forçando autenticação local');
    if (_userId == null) {
      signInAnonymously();
    }
  }

  /// Atualiza sessão se necessário
  Future<void> refreshSessionIfNeeded() async {
    debugPrint('🔐 Auth: Verificando se precisa atualizar sessão');
    if (!hasValidSession) {
      await signInAnonymously();
    }
  }

  /// Gera um UUID v4 válido
  String _generateUuid() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    
    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Dispose dos resources
  void dispose() {
    _authStateController.close();
  }
}