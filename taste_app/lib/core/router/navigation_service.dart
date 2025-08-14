import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../services/deep_link_service.dart';
import '../config/environment_config.dart';
import '../services/analytics_service.dart';

/// Serviço centralizado para navegação e deep linking
class NavigationService {
  static NavigationService? _instance;
  static NavigationService get instance => _instance ??= NavigationService._();
  NavigationService._();

  GoRouter? _router;
  final List<String> _navigationHistory = [];
  
  /// Define o router principal
  void setRouter(GoRouter router) {
    _router = router;
  }

  /// Router atual
  GoRouter? get router => _router;

  /// Histórico de navegação (apenas em desenvolvimento)
  List<String> get navigationHistory => 
      EnvironmentConfig.isDevelopment ? List.from(_navigationHistory) : [];

  /// Navega para uma rota específica
  void goTo(String route, {Map<String, String>? queryParameters}) {
    if (_router == null) {
      debugPrint('⚠️ Router não inicializado');
      return;
    }

    try {
      String finalRoute = route;
      
      // Adiciona query parameters se fornecidos
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final uri = Uri.parse(route);
        final newUri = uri.replace(
          queryParameters: {...uri.queryParameters, ...queryParameters},
        );
        finalRoute = newUri.toString();
      }

      _router!.go(finalRoute);
      _trackNavigation('go', finalRoute);
      
    } catch (e) {
      debugPrint('❌ Erro na navegação para $route: $e');
    }
  }

  /// Empurra uma nova rota na pilha
  void pushTo(String route, {Map<String, String>? queryParameters}) {
    if (_router == null) {
      debugPrint('⚠️ Router não inicializado');
      return;
    }

    try {
      String finalRoute = route;
      
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final uri = Uri.parse(route);
        final newUri = uri.replace(
          queryParameters: {...uri.queryParameters, ...queryParameters},
        );
        finalRoute = newUri.toString();
      }

      _router!.push(finalRoute);
      _trackNavigation('push', finalRoute);
      
    } catch (e) {
      debugPrint('❌ Erro ao empurrar rota $route: $e');
    }
  }

  /// Volta para a rota anterior
  void goBack() {
    if (_router == null) {
      debugPrint('⚠️ Router não inicializado');
      return;
    }

    try {
      if (_router!.canPop()) {
        _router!.pop();
        _trackNavigation('pop', 'back');
      } else {
        // Se não pode voltar, vai para home
        goTo('/home');
      }
    } catch (e) {
      debugPrint('❌ Erro ao voltar: $e');
    }
  }

  /// Navega usando um deep link
  void navigateFromDeepLink(String deepLink) {
    try {
      final linkData = DeepLinkService.instance.parseDeepLink(deepLink);
      String? route;
      
      switch (linkData.type) {
        case DeepLinkType.restaurant:
          final id = linkData.getParameter('id');
          if (id != null) route = '/restaurant/$id';
          break;
        case DeepLinkType.search:
          route = '/search';
          break;
        case DeepLinkType.category:
          final name = linkData.getParameter('name');
          if (name != null) route = '/category/$name';
          break;
        case DeepLinkType.profile:
          route = '/profile';
          break;
        case DeepLinkType.favorites:
          route = '/favorites';
          break;
        case DeepLinkType.map:
          route = '/map';
          break;
        case DeepLinkType.settings:
          route = '/settings';
          break;
        default:
          route = '/home';
      }
      
      if (route != null) {
        goTo(route);
        _trackNavigation('deep_link', route, metadata: {'original_link': deepLink});
      }
    } catch (e) {
      debugPrint('❌ Erro ao processar deep link: $e');
      goTo('/home');
    }
  }

  /// Navega para detalhes de um restaurante
  void goToRestaurant(String restaurantId) {
    goTo('/restaurant/$restaurantId');
  }

  /// Navega para busca com query opcional
  void goToSearch({String? query}) {
    if (query != null && query.isNotEmpty) {
      goTo('/search', queryParameters: {'q': query});
    } else {
      goTo('/search');
    }
  }

  /// Navega para categoria
  void goToCategory(String categoryId) {
    goTo('/category/$categoryId');
  }

  /// Navega para mapa com coordenadas opcionais
  void goToMap({double? lat, double? lng}) {
    if (lat != null && lng != null) {
      goTo('/map', queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
      });
    } else {
      goTo('/map');
    }
  }

  /// Navega para perfil de usuário
  void goToUserProfile(String userId) {
    goTo('/user/$userId');
  }

  /// Navega para favoritos
  void goToFavorites() {
    goTo('/favorites');
  }

  /// Navega para perfil do usuário atual
  void goToProfile() {
    goTo('/profile');
  }

  /// Navega para configurações
  void goToSettings() {
    goTo('/settings');
  }

  /// Navega para home
  void goToHome() {
    goTo('/home');
  }

  /// Gera e compartilha deep link
  String generateShareableLink(String route, {Map<String, String>? queryParameters}) {
    final uri = Uri(
      scheme: 'https',
      host: 'taste.app',
      path: route,
      queryParameters: queryParameters,
    );
    return uri.toString();
  }

  /// Rastreia navegação para analytics
  void _trackNavigation(String action, String route, {Map<String, dynamic>? metadata}) {
    // Adiciona ao histórico apenas em desenvolvimento
    if (EnvironmentConfig.isDevelopment) {
      _navigationHistory.add('$action: $route');
      
      // Mantém apenas os últimos 50 itens
      if (_navigationHistory.length > 50) {
        _navigationHistory.removeAt(0);
      }
      
      debugPrint('🧭 Navegação: $action -> $route');
    }

    // Envia para analytics se habilitado
    if (EnvironmentConfig.enableAnalytics) {
      AnalyticsService.instance.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'navigation',
        parameters: {
          'action': action,
          'route': route,
          ...?metadata,
        },
      );
    }
  }

  /// Obtém a rota atual
  String? getCurrentRoute() {
    return _router?.routerDelegate.currentConfiguration.uri.path;
  }

  /// Verifica se pode voltar
  bool canGoBack() {
    return _router?.canPop() ?? false;
  }

  /// Limpa o histórico de navegação
  void clearNavigationHistory() {
    if (EnvironmentConfig.isDevelopment) {
      _navigationHistory.clear();
      debugPrint('🧹 Histórico de navegação limpo');
    }
  }

  /// Obtém estatísticas de navegação (apenas desenvolvimento)
  Map<String, dynamic> getNavigationStats() {
    if (!EnvironmentConfig.isDevelopment) return {};
    
    final stats = <String, int>{};
    for (final entry in _navigationHistory) {
      final route = entry.split(': ').last;
      stats[route] = (stats[route] ?? 0) + 1;
    }
    
    return {
      'total_navigations': _navigationHistory.length,
      'unique_routes': stats.length,
      'most_visited': stats.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key,
      'route_counts': stats,
    };
  }
}

/// Extension para facilitar o uso do NavigationService
extension NavigationServiceExtension on NavigationService {
  /// Navega para uma rota com parâmetros nomeados
  void goToNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    if (_router == null) return;
    
    try {
      _router!.goNamed(
        name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
      );
      _trackNavigation('go_named', name);
    } catch (e) {
      debugPrint('❌ Erro na navegação nomeada para $name: $e');
    }
  }

  /// Empurra uma rota com parâmetros nomeados
  void pushNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    if (_router == null) return;
    
    try {
      _router!.pushNamed(
        name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
      );
      _trackNavigation('push_named', name);
    } catch (e) {
      debugPrint('❌ Erro ao empurrar rota nomeada $name: $e');
    }
  }
}