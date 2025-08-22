import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

/// Guard de autenticação para proteger rotas
class AuthGuard {
  static final AuthService _authService = AuthService.instance;

  /// Verifica se o usuário pode acessar uma rota específica
  static bool canAccess(String route) {
    // Rotas que requerem autenticação
    final protectedRoutes = [
      '/profile',
      '/edit-profile',
      '/favorites',
      '/settings',
    ];

    // Rotas que só podem ser acessadas por usuários não autenticados
    final guestOnlyRoutes = [
      '/login',
      '/register',
      '/forgot-password',
    ];

    // Obtém estado de autenticação incluindo fallback local
    final isAuthenticated = _authService.isAuthenticated;
    debugPrint('🔍 AuthGuard: Verificando rota $route - isAuthenticated: $isAuthenticated');

    // Se a rota requer autenticação e o usuário não está autenticado
    if (protectedRoutes.any((protectedRoute) => route.startsWith(protectedRoute))) {
      return isAuthenticated;
    }

    // Se a rota é apenas para visitantes e o usuário está autenticado
    if (guestOnlyRoutes.any((guestRoute) => route.startsWith(guestRoute))) {
      return !isAuthenticated;
    }

    // Rotas públicas podem ser acessadas por qualquer um
    return true;
  }

  /// Obtém a rota de redirecionamento baseada no estado de autenticação
  static String getRedirectRoute(String attemptedRoute) {
    final isAuthenticated = _authService.isAuthenticated;
    debugPrint('🔍 AuthGuard: getRedirectRoute - attemptedRoute: $attemptedRoute, isAuthenticated: $isAuthenticated');

    // Rotas que requerem autenticação
    final protectedRoutes = [
      '/profile',
      '/edit-profile',
      '/favorites',
      '/settings',
    ];

    // Rotas que só podem ser acessadas por usuários não autenticados
    final guestOnlyRoutes = [
      '/login',
      '/register',
      '/forgot-password',
    ];

    // Se tentou acessar rota protegida sem estar autenticado
    if (protectedRoutes.any((route) => attemptedRoute.startsWith(route)) && !isAuthenticated) {
      debugPrint('🚫 AuthGuard: Rota protegida sem autenticação, redirecionando para /login');
      return '/login';
    }

    // Se tentou acessar rota de visitante estando autenticado
    if (guestOnlyRoutes.any((route) => attemptedRoute.startsWith(route)) && isAuthenticated) {
      debugPrint('🔄 AuthGuard: Rota de visitante com usuário autenticado, redirecionando para /main');
      return '/main';
    }

    // Se não há redirecionamento necessário, retorna a rota original
    debugPrint('✅ AuthGuard: Acesso permitido à rota $attemptedRoute');
    return attemptedRoute;
  }

  /// Middleware para GoRouter
  static String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.toString();
    
    // Em modo de desenvolvimento, força autenticação local para rotas protegidas
    if (kDebugMode && _shouldForceAuthInDev(location)) {
      debugPrint('🔓 AuthGuard: Modo desenvolvimento - forçando autenticação local para $location');
      _authService.forceLocalAuth();
    }
    
    // Verifica se pode acessar a rota
    if (!canAccess(location)) {
      final redirectRoute = getRedirectRoute(location);
      
      // Se a rota de redirecionamento é diferente da atual, redireciona
      if (redirectRoute != location) {
        debugPrint('🔒 AuthGuard: Redirecionando de $location para $redirectRoute');
        return redirectRoute;
      }
    }

    return null; // Não redireciona
  }
  
  /// Verifica se deve forçar autenticação local em desenvolvimento
  static bool _shouldForceAuthInDev(String location) {
    final protectedRoutes = ['/profile', '/edit-profile', '/favorites', '/settings'];
    return protectedRoutes.any((route) => location.startsWith(route));
  }

  /// Verifica se uma rota específica é protegida
  static bool isProtectedRoute(String route) {
    final protectedRoutes = [
      '/profile',
      '/edit-profile',
      '/favorites',
      '/settings',
    ];

    return protectedRoutes.any((protectedRoute) => route.startsWith(protectedRoute));
  }

  /// Verifica se uma rota é apenas para visitantes
  static bool isGuestOnlyRoute(String route) {
    final guestOnlyRoutes = [
      '/login',
      '/register',
      '/forgot-password',
    ];

    return guestOnlyRoutes.any((guestRoute) => route.startsWith(guestRoute));
  }

  /// Verifica se uma rota é pública
  static bool isPublicRoute(String route) {
    return !isProtectedRoute(route) && !isGuestOnlyRoute(route);
  }

  /// Obtém o status de acesso para uma rota
  static RouteAccessStatus getRouteAccessStatus(String route) {
    if (isProtectedRoute(route)) {
      return RouteAccessStatus.requiresAuth;
    } else if (isGuestOnlyRoute(route)) {
      return RouteAccessStatus.guestOnly;
    } else {
      return RouteAccessStatus.public;
    }
  }
}

/// Enum para status de acesso de rotas
enum RouteAccessStatus {
  /// Rota requer autenticação
  requiresAuth,
  
  /// Rota apenas para visitantes (não autenticados)
  guestOnly,
  
  /// Rota pública (acessível por todos)
  public,
}

/// Extension para facilitar o uso do RouteAccessStatus
extension RouteAccessStatusExtension on RouteAccessStatus {
  /// Descrição legível do status
  String get description {
    switch (this) {
      case RouteAccessStatus.requiresAuth:
        return 'Requer autenticação';
      case RouteAccessStatus.guestOnly:
        return 'Apenas para visitantes';
      case RouteAccessStatus.public:
        return 'Rota pública';
    }
  }

  /// Ícone representativo do status
  IconData get icon {
    switch (this) {
      case RouteAccessStatus.requiresAuth:
        return Icons.lock;
      case RouteAccessStatus.guestOnly:
        return Icons.person_off;
      case RouteAccessStatus.public:
        return Icons.public;
    }
  }
}