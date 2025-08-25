import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth/auth_service.dart';

/// Estado da autenticação
class AppAuthState {
  final bool isAuthenticated;
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AppAuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AppAuthState copyWith({
    bool? isAuthenticated,
    AppUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AppAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier para gerenciar o estado da autenticação
class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AppAuthState()) {
    _initializeAuth();
  }

  /// Inicializa o estado da autenticação
  void _initializeAuth() {
    // Usa o método isAuthenticated que já inclui fallback local
    final isAuth = _authService.isAuthenticated;
    final user = _authService.currentUser;
    
    state = AppAuthState(
      isAuthenticated: isAuth,
      user: user,
    );

    // Escuta mudanças no estado de autenticação do Supabase
    try {
      _authService.authStateChanges.listen((appUser) {
        state = AppAuthState(
          isAuthenticated: _authService.isAuthenticated,
          user: appUser,
        );
      });
    } catch (e) {
      print('⚠️ AuthProvider: Erro ao escutar mudanças de auth, usando estado local: $e');
      // Se não conseguir escutar o Supabase, usa apenas estado local
    }
  }

  /// Faz login com email e senha
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _authService.signInWithEmail(email, password);
      
      if (response.user != null) {
        state = AppAuthState(
          isAuthenticated: true,
          user: response.user,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Falha no login',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Faz cadastro com email e senha (alias para signUpWithEmailAndPassword)
  Future<bool> signUp(String email, String password) async {
    return signUpWithEmailAndPassword(email, password);
  }

  /// Faz cadastro com email e senha
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _authService.signUpWithEmail(email, password);
      
      if (response.user != null) {
        state = AppAuthState(
          isAuthenticated: true,
          user: response.user,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Falha no cadastro',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AppAuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Força autenticação local (para desenvolvimento)
  void forceLocalAuth() {
    _authService.forceLocalAuth();
    state = AppAuthState(
      isAuthenticated: true,
      user: null, // Usuário mock para desenvolvimento
      isLoading: false,
    );
  }
}

/// Provider do serviço de autenticação
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Provider principal da autenticação
final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Provider para verificar se o usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Provider para obter o usuário atual
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});
