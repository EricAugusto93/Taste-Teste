import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper para navegação robusta que evita erros de pop
class NavigationHelper {
  /// Navega para trás de forma segura
  /// Se não conseguir fazer pop, navega para a home
  static void safeGoBack(BuildContext context, {String fallbackRoute = '/home'}) {
    try {
      // Verifica se o contexto ainda é válido
      if (!context.mounted) {
        return;
      }
      
      // Tenta fazer pop primeiro
      if (context.canPop()) {
        context.pop();
      } else {
        // Se não conseguir fazer pop, navega para fallback
        context.go(fallbackRoute);
      }
    } catch (e) {
      // Se houver qualquer erro, tenta navegar para a rota de fallback
      try {
        if (context.mounted) {
          context.go(fallbackRoute);
        }
      } catch (fallbackError) {
        // Se até o fallback falhar, não faz nada
        debugPrint('Erro crítico de navegação: $fallbackError');
      }
    }
  }

  /// Navega para uma rota específica de forma segura
  static void safeNavigateTo(BuildContext context, String route) {
    try {
      context.go(route);
    } catch (e) {
      // Se houver erro, tenta navegar para home
      context.go('/home');
    }
  }

  /// Push para uma rota de forma segura
  static void safePushTo(BuildContext context, String route) {
    try {
      context.push(route);
    } catch (e) {
      // Se houver erro no push, tenta go
      context.go(route);
    }
  }

  /// Verifica se é possível fazer pop de forma segura
  static bool canSafelyPop(BuildContext context) {
    try {
      return context.canPop();
    } catch (e) {
      return false;
    }
  }
}