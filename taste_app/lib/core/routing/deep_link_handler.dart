import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_app/domain/entities/restaurant.dart';

/// Handler para deep links do aplicativo
class DeepLinkHandler {
  static const String _baseUrl = 'https://taste.app';
  static const String _scheme = 'taste';
  
  // ==========================================
  // ROTAS DISPONÍVEIS
  // ==========================================
  
  /// Rota para página inicial
  static const String home = '/';
  
  /// Rota para busca
  static const String search = '/search';
  
  /// Rota para favoritos
  static const String favorites = '/favorites';
  
  /// Rota para perfil
  static const String profile = '/profile';
  
  /// Rota para detalhes do restaurante
  static const String restaurantDetails = '/restaurant/:id';
  
  /// Rota para avaliações do restaurante
  static const String restaurantReviews = '/restaurant/:id/reviews';
  
  /// Rota para mapa
  static const String map = '/map';
  
  /// Rota para configurações
  static const String settings = '/settings';
  
  /// Rota para autenticação
  static const String auth = '/auth';
  
  /// Rota para login
  static const String login = '/auth/login';
  
  /// Rota para registro
  static const String register = '/auth/register';
  
  /// Rota para recuperação de senha
  static const String forgotPassword = '/auth/forgot-password';
  
  // ==========================================
  // MÉTODOS DE GERAÇÃO DE LINKS
  // ==========================================
  
  /// Gera link para detalhes do restaurante
  static String generateRestaurantLink(String restaurantId) {
    return '$_baseUrl/restaurant/$restaurantId';
  }
  
  /// Gera link para avaliações do restaurante
  static String generateRestaurantReviewsLink(String restaurantId) {
    return '$_baseUrl/restaurant/$restaurantId/reviews';
  }
  
  /// Gera link para busca com query
  static String generateSearchLink({String? query, String? category}) {
    final uri = Uri.parse('$_baseUrl/search');
    final params = <String, String>{};
    
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    
    return uri.replace(queryParameters: params.isNotEmpty ? params : null).toString();
  }
  
  /// Gera link para mapa com localização
  static String generateMapLink({double? lat, double? lng, String? restaurantId}) {
    final uri = Uri.parse('$_baseUrl/map');
    final params = <String, String>{};
    
    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lng'] = lng.toString();
    }
    
    if (restaurantId != null) {
      params['restaurant'] = restaurantId;
    }
    
    return uri.replace(queryParameters: params.isNotEmpty ? params : null).toString();
  }
  
  /// Gera link para compartilhamento de restaurante
  static String generateShareLink(Restaurant restaurant) {
    final link = generateRestaurantLink(restaurant.id);
    return '$link?utm_source=share&utm_medium=app&utm_campaign=restaurant_share';
  }
  
  // ==========================================
  // MÉTODOS DE PARSING
  // ==========================================
  
  /// Extrai ID do restaurante da URL
  static String? extractRestaurantId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'restaurant') {
      return segments[1];
    }
    
    return null;
  }
  
  /// Extrai parâmetros de busca da URL
  static Map<String, String> extractSearchParams(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return {};
    
    return uri.queryParameters;
  }
  
  /// Extrai coordenadas do mapa da URL
  static Map<String, double>? extractMapCoordinates(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    
    final params = uri.queryParameters;
    final latStr = params['lat'];
    final lngStr = params['lng'];
    
    if (latStr != null && lngStr != null) {
      final lat = double.tryParse(latStr);
      final lng = double.tryParse(lngStr);
      
      if (lat != null && lng != null) {
        return {'lat': lat, 'lng': lng};
      }
    }
    
    return null;
  }
  
  // ==========================================
  // VALIDAÇÃO DE LINKS
  // ==========================================
  
  /// Verifica se a URL é um deep link válido do app
  static bool isValidDeepLink(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    // Verifica scheme personalizado
    if (uri.scheme == _scheme) {
      return true;
    }
    
    // Verifica URL web
    if (uri.scheme == 'https' && uri.host == Uri.parse(_baseUrl).host) {
      return true;
    }
    
    return false;
  }
  
  /// Verifica se a rota existe
  static bool isValidRoute(String path) {
    final validRoutes = [
      home,
      search,
      favorites,
      profile,
      map,
      settings,
      auth,
      login,
      register,
      forgotPassword,
    ];
    
    // Verifica rotas exatas
    if (validRoutes.contains(path)) {
      return true;
    }
    
    // Verifica rotas com parâmetros
    if (path.startsWith('/restaurant/')) {
      return true;
    }
    
    return false;
  }
  
  // ==========================================
  // CONVERSÃO DE URLS
  // ==========================================
  
  /// Converte URL web para rota interna
  static String? webUrlToRoute(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    
    // Remove base URL e retorna apenas o path
    if (uri.scheme == 'https' && uri.host == Uri.parse(_baseUrl).host) {
      return uri.path;
    }
    
    return null;
  }
  
  /// Converte scheme URL para rota interna
  static String? schemeUrlToRoute(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    
    if (uri.scheme == _scheme) {
      return uri.path.isEmpty ? '/' : uri.path;
    }
    
    return null;
  }
  
  // ==========================================
  // NAVEGAÇÃO
  // ==========================================
  
  /// Navega para uma URL usando GoRouter
  static void navigateToUrl(BuildContext context, String url) {
    String? route;
    
    // Tenta converter URL para rota
    if (url.startsWith(_scheme)) {
      route = schemeUrlToRoute(url);
    } else if (url.startsWith('https')) {
      route = webUrlToRoute(url);
    } else {
      route = url; // Assume que já é uma rota
    }
    
    if (route != null && isValidRoute(route)) {
      context.go(route);
    } else {
      // Log erro ou mostra mensagem
      debugPrint('Invalid deep link: $url');
    }
  }
  
  /// Navega para detalhes do restaurante
  static void navigateToRestaurant(BuildContext context, String restaurantId) {
    context.go('/restaurant/$restaurantId');
  }
  
  /// Navega para busca com parâmetros
  static void navigateToSearch(BuildContext context, {String? query, String? category}) {
    final uri = Uri(path: '/search');
    final params = <String, String>{};
    
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    
    final finalUri = uri.replace(queryParameters: params.isNotEmpty ? params : null);
    context.go(finalUri.toString());
  }
  
  /// Navega para mapa com coordenadas
  static void navigateToMap(BuildContext context, {double? lat, double? lng, String? restaurantId}) {
    final uri = Uri(path: '/map');
    final params = <String, String>{};
    
    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lng'] = lng.toString();
    }
    
    if (restaurantId != null) {
      params['restaurant'] = restaurantId;
    }
    
    final finalUri = uri.replace(queryParameters: params.isNotEmpty ? params : null);
    context.go(finalUri.toString());
  }
}

/// Classe para configuração de deep links
class DeepLinkConfig {
  /// Scheme personalizado do app
  static const String scheme = 'taste';
  
  /// Host para URLs web
  static const String webHost = 'taste.app';
  
  /// Prefixos de URL permitidos
  static const List<String> allowedPrefixes = [
    'https://taste.app',
    'taste://',
  ];
  
  /// Configuração para Android (android/app/src/main/AndroidManifest.xml)
  static const String androidManifestConfig = '''
<!-- Deep Link Configuration -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https"
          android:host="taste.app" />
</intent-filter>

<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="taste" />
</intent-filter>
''';
  
  /// Configuração para iOS (ios/Runner/Info.plist)
  static const String iosInfoPlistConfig = '''
<!-- Deep Link Configuration -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>taste.app.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>taste</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleURLName</key>
        <string>taste.app.universal</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>https</string>
        </array>
    </dict>
</array>

<!-- Associated Domains -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:taste.app</string>
</array>
''';
}

/// Widget para interceptar deep links
class DeepLinkInterceptor extends StatefulWidget {
  final Widget child;
  final Function(String)? onDeepLink;
  
  const DeepLinkInterceptor({
    super.key,
    required this.child,
    this.onDeepLink,
  });
  
  @override
  State<DeepLinkInterceptor> createState() => _DeepLinkInterceptorState();
}

class _DeepLinkInterceptorState extends State<DeepLinkInterceptor> {
  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _handleIncomingLinks();
  }
  
  void _handleInitialLink() async {
    // Implementar lógica para link inicial
    // Usar package como app_links ou uni_links
  }
  
  void _handleIncomingLinks() {
    // Implementar lógica para links recebidos enquanto app está aberto
    // Usar package como app_links ou uni_links
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}