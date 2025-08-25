import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taste_app/services/analytics_service.dart';

/// Tipos de deep link
enum DeepLinkType {
  restaurant,
  search,
  category,
  profile,
  favorites,
  review,
  map,
  settings,
  unknown,
}

/// Dados do deep link
class DeepLinkData {
  final DeepLinkType type;
  final String path;
  final Map<String, String> parameters;
  final Map<String, String> queryParameters;
  final String originalUrl;
  
  DeepLinkData({
    required this.type,
    required this.path,
    required this.parameters,
    required this.queryParameters,
    required this.originalUrl,
  });
  
  /// Obtém parâmetro por nome
  String? getParameter(String name) {
    return parameters[name] ?? queryParameters[name];
  }
  
  /// Verifica se tem parâmetro
  bool hasParameter(String name) {
    return parameters.containsKey(name) || queryParameters.containsKey(name);
  }
  
  @override
  String toString() {
    return 'DeepLinkData(type: $type, path: $path, params: $parameters, query: $queryParameters)';
  }
}

/// Resultado da navegação por deep link
class DeepLinkResult {
  final bool success;
  final String? error;
  final DeepLinkData? data;
  
  DeepLinkResult.success(this.data) : success = true, error = null;
  DeepLinkResult.error(this.error) : success = false, data = null;
}

/// Handler para deep links
abstract class DeepLinkHandler {
  DeepLinkType get type;
  Future<bool> canHandle(DeepLinkData data);
  Future<void> handle(BuildContext context, DeepLinkData data);
}

/// Handler para restaurantes
class RestaurantDeepLinkHandler extends DeepLinkHandler {
  @override
  DeepLinkType get type => DeepLinkType.restaurant;
  
  @override
  Future<bool> canHandle(DeepLinkData data) async {
    return data.type == DeepLinkType.restaurant && data.hasParameter('id');
  }
  
  @override
  Future<void> handle(BuildContext context, DeepLinkData data) async {
    final restaurantId = data.getParameter('id');
    if (restaurantId == null) return;
    
    // Navega para a tela de detalhes do restaurante
    Navigator.of(context).pushNamed(
      '/restaurant',
      arguments: {'id': restaurantId},
    );
    
    // Registra analytics
    AnalyticsService.instance.trackEvent(
      'deep_link_restaurant',
      parameters: {
        'restaurant_id': restaurantId,
        'source': 'deep_link',
      },
    );
  }
}

/// Handler para busca
class SearchDeepLinkHandler extends DeepLinkHandler {
  @override
  DeepLinkType get type => DeepLinkType.search;
  
  @override
  Future<bool> canHandle(DeepLinkData data) async {
    return data.type == DeepLinkType.search;
  }
  
  @override
  Future<void> handle(BuildContext context, DeepLinkData data) async {
    final query = data.getParameter('q') ?? data.getParameter('query');
    final category = data.getParameter('category');
    final location = data.getParameter('location');
    
    // Navega para a tela de busca
    Navigator.of(context).pushNamed(
      '/search',
      arguments: {
        'query': query,
        'category': category,
        'location': location,
      },
    );
    
    // Registra analytics
    AnalyticsService.instance.trackEvent(
      'deep_link_search',
      parameters: {
        'query': query ?? '',
        'category': category ?? '',
        'location': location ?? '',
        'source': 'deep_link',
      },
    );
  }
}

/// Handler para categorias
class CategoryDeepLinkHandler extends DeepLinkHandler {
  @override
  DeepLinkType get type => DeepLinkType.category;
  
  @override
  Future<bool> canHandle(DeepLinkData data) async {
    return data.type == DeepLinkType.category && data.hasParameter('name');
  }
  
  @override
  Future<void> handle(BuildContext context, DeepLinkData data) async {
    final categoryName = data.getParameter('name');
    if (categoryName == null) return;
    
    // Navega para a tela de categoria
    Navigator.of(context).pushNamed(
      '/category',
      arguments: {'category': categoryName},
    );
    
    // Registra analytics
    AnalyticsService.instance.trackEvent(
      'deep_link_category',
      parameters: {
        'category': categoryName,
        'source': 'deep_link',
      },
    );
  }
}

/// Handler para perfil
class ProfileDeepLinkHandler extends DeepLinkHandler {
  @override
  DeepLinkType get type => DeepLinkType.profile;
  
  @override
  Future<bool> canHandle(DeepLinkData data) async {
    return data.type == DeepLinkType.profile;
  }
  
  @override
  Future<void> handle(BuildContext context, DeepLinkData data) async {
    final userId = data.getParameter('id');
    
    // Navega para a tela de perfil
    Navigator.of(context).pushNamed(
      '/profile',
      arguments: {'userId': userId},
    );
    
    // Registra analytics
    AnalyticsService.instance.trackEvent(
      'deep_link_profile',
      parameters: {
        'user_id': userId ?? 'current',
        'source': 'deep_link',
      },
    );
  }
}

/// Handler para favoritos
class FavoritesDeepLinkHandler extends DeepLinkHandler {
  @override
  DeepLinkType get type => DeepLinkType.favorites;
  
  @override
  Future<bool> canHandle(DeepLinkData data) async {
    return data.type == DeepLinkType.favorites;
  }
  
  @override
  Future<void> handle(BuildContext context, DeepLinkData data) async {
    // Navega para a tela de favoritos
    Navigator.of(context).pushNamed('/favorites');
    
    // Registra analytics
    AnalyticsService.instance.trackEvent(
      'deep_link_favorites',
      parameters: {'source': 'deep_link'},
    );
  }
}

/// Handler para mapa
class MapDeepLinkHandler extends DeepLinkHandler {
  @override
  DeepLinkType get type => DeepLinkType.map;
  
  @override
  Future<bool> canHandle(DeepLinkData data) async {
    return data.type == DeepLinkType.map;
  }
  
  @override
  Future<void> handle(BuildContext context, DeepLinkData data) async {
    final lat = data.getParameter('lat');
    final lng = data.getParameter('lng');
    final zoom = data.getParameter('zoom');
    
    // Navega para a tela do mapa
    Navigator.of(context).pushNamed(
      '/map',
      arguments: {
        'lat': lat != null ? double.tryParse(lat) : null,
        'lng': lng != null ? double.tryParse(lng) : null,
        'zoom': zoom != null ? double.tryParse(zoom) : null,
      },
    );
    
    // Registra analytics
    AnalyticsService.instance.trackEvent(
      'deep_link_map',
      parameters: {
        'lat': lat ?? '',
        'lng': lng ?? '',
        'zoom': zoom ?? '',
        'source': 'deep_link',
      },
    );
  }
}

/// Serviço de deep linking
class DeepLinkService {
  static DeepLinkService? _instance;
  static DeepLinkService get instance => _instance ??= DeepLinkService._();
  
  DeepLinkService._();
  
  final List<DeepLinkHandler> _handlers = [];
  final StreamController<DeepLinkData> _linkController = StreamController<DeepLinkData>.broadcast();
  
  static const MethodChannel _channel = MethodChannel('taste_app/deep_links');
  
  /// Stream de deep links recebidos
  Stream<DeepLinkData> get linkStream => _linkController.stream;
  
  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      // Registra handlers padrão
      _registerDefaultHandlers();
      
      // Configura listener para deep links apenas se não for web
      if (!kIsWeb) {
        _channel.setMethodCallHandler(_handleMethodCall);
      }
      
      // Verifica se o app foi aberto por um deep link
      await _checkInitialLink();
      
      debugPrint('Deep link service initialized');
    } catch (e) {
      debugPrint('Error initializing deep link service: $e');
    }
  }
  
  /// Registra handlers padrão
  void _registerDefaultHandlers() {
    _handlers.addAll([
      RestaurantDeepLinkHandler(),
      SearchDeepLinkHandler(),
      CategoryDeepLinkHandler(),
      ProfileDeepLinkHandler(),
      FavoritesDeepLinkHandler(),
      MapDeepLinkHandler(),
    ]);
  }
  
  /// Manipula chamadas do método channel
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDeepLink':
        final url = call.arguments as String;
        await _processDeepLink(url);
        break;
      default:
        debugPrint('Unknown method call: ${call.method}');
    }
  }
  
  /// Verifica link inicial
  Future<void> _checkInitialLink() async {
    try {
      // No web, não há suporte nativo para deep links via MethodChannel
      if (kIsWeb) {
        debugPrint('Deep links not supported on web platform');
        return;
      }
      
      final initialLink = await _channel.invokeMethod<String>('getInitialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        await _processDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error checking initial link: $e');
    }
  }
  
  /// Processa deep link
  Future<void> _processDeepLink(String url) async {
    try {
      final linkData = _parseDeepLink(url);
      _linkController.add(linkData);
      
      debugPrint('Deep link processed: $linkData');
    } catch (e) {
      debugPrint('Error processing deep link: $e');
    }
  }
  
  /// Faz parse do deep link (público)
  DeepLinkData parseDeepLink(String url) {
    return _parseDeepLink(url);
  }

  /// Faz parse do deep link
  DeepLinkData _parseDeepLink(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final queryParams = uri.queryParameters;
    
    // Determina o tipo baseado no path
    DeepLinkType type = DeepLinkType.unknown;
    Map<String, String> parameters = {};
    
    if (pathSegments.isNotEmpty) {
      switch (pathSegments[0]) {
        case 'restaurant':
        case 'r':
          type = DeepLinkType.restaurant;
          if (pathSegments.length > 1) {
            parameters['id'] = pathSegments[1];
          }
          break;
          
        case 'search':
        case 's':
          type = DeepLinkType.search;
          break;
          
        case 'category':
        case 'c':
          type = DeepLinkType.category;
          if (pathSegments.length > 1) {
            parameters['name'] = pathSegments[1];
          }
          break;
          
        case 'profile':
        case 'p':
          type = DeepLinkType.profile;
          if (pathSegments.length > 1) {
            parameters['id'] = pathSegments[1];
          }
          break;
          
        case 'favorites':
        case 'f':
          type = DeepLinkType.favorites;
          break;
          
        case 'map':
        case 'm':
          type = DeepLinkType.map;
          break;
          
        case 'settings':
          type = DeepLinkType.settings;
          break;
      }
    }
    
    return DeepLinkData(
      type: type,
      path: uri.path,
      parameters: parameters,
      queryParameters: queryParams,
      originalUrl: url,
    );
  }
  
  /// Registra handler customizado
  void registerHandler(DeepLinkHandler handler) {
    _handlers.removeWhere((h) => h.type == handler.type);
    _handlers.add(handler);
    debugPrint('Deep link handler registered: ${handler.type}');
  }
  
  /// Remove handler
  void unregisterHandler(DeepLinkType type) {
    _handlers.removeWhere((h) => h.type == type);
    debugPrint('Deep link handler unregistered: $type');
  }
  
  /// Manipula deep link com contexto
  Future<DeepLinkResult> handleDeepLink(BuildContext context, String url) async {
    try {
      final linkData = _parseDeepLink(url);
      
      // Encontra handler apropriado
      final handler = _handlers.firstWhere(
        (h) => h.type == linkData.type,
        orElse: () => throw Exception('No handler found for type: ${linkData.type}'),
      );
      
      // Verifica se pode manipular
      if (!await handler.canHandle(linkData)) {
        return DeepLinkResult.error('Handler cannot process this link');
      }
      
      // Executa handler
      await handler.handle(context, linkData);
      
      // Registra analytics
      AnalyticsService.instance.trackEvent(
        'deep_link_handled',
        parameters: {
          'type': linkData.type.name,
          'path': linkData.path,
          'success': true,
        },
      );
      
      return DeepLinkResult.success(linkData);
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      
      // Registra erro no analytics
      AnalyticsService.instance.recordError(
        e,
        StackTrace.current,
        reason: 'deep_link_error',
        customKeys: {
          'url': url,
          'error': e.toString(),
        },
      );
      
      return DeepLinkResult.error(e.toString());
    }
  }
  
  /// Gera deep link para restaurante
  String generateRestaurantLink(String restaurantId, {Map<String, String>? extraParams}) {
    final uri = Uri(
      scheme: 'https',
      host: 'taste.app',
      path: '/restaurant/$restaurantId',
      queryParameters: extraParams,
    );
    return uri.toString();
  }
  
  /// Gera deep link para busca
  String generateSearchLink({
    String? query,
    String? category,
    String? location,
    Map<String, String>? extraParams,
  }) {
    final params = <String, String>{};
    if (query != null) params['q'] = query;
    if (category != null) params['category'] = category;
    if (location != null) params['location'] = location;
    if (extraParams != null) params.addAll(extraParams);
    
    final uri = Uri(
      scheme: 'https',
      host: 'taste.app',
      path: '/search',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return uri.toString();
  }
  
  /// Gera deep link para categoria
  String generateCategoryLink(String categoryName, {Map<String, String>? extraParams}) {
    final uri = Uri(
      scheme: 'https',
      host: 'taste.app',
      path: '/category/$categoryName',
      queryParameters: extraParams,
    );
    return uri.toString();
  }
  
  /// Gera deep link para mapa
  String generateMapLink({
    double? lat,
    double? lng,
    double? zoom,
    Map<String, String>? extraParams,
  }) {
    final params = <String, String>{};
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();
    if (zoom != null) params['zoom'] = zoom.toString();
    if (extraParams != null) params.addAll(extraParams);
    
    final uri = Uri(
      scheme: 'https',
      host: 'taste.app',
      path: '/map',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return uri.toString();
  }
  
  /// Compartilha deep link
  Future<void> shareDeepLink(String url, {String? subject}) async {
    try {
      if (kIsWeb) {
        // No web, copia para o clipboard como fallback
        await copyDeepLink(url);
        debugPrint('Deep link copied to clipboard (web fallback): $url');
      } else {
        await _channel.invokeMethod('shareLink', {
          'url': url,
          'subject': subject ?? 'Confira isso no Taste!',
        });
      }
      
      // Registra analytics
      AnalyticsService.instance.trackEvent(
        'deep_link_shared',
        parameters: {
          'url': url,
          'subject': subject ?? '',
        },
      );
    } catch (e) {
      debugPrint('Error sharing deep link: $e');
    }
  }
  
  /// Copia deep link para clipboard
  Future<void> copyDeepLink(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      
      // Registra analytics
      AnalyticsService.instance.trackEvent(
        'deep_link_copied',
        parameters: {'url': url},
      );
    } catch (e) {
      debugPrint('Error copying deep link: $e');
    }
  }
  
  /// Obtém estatísticas de deep links
  Map<String, dynamic> getDeepLinkStats() {
    return {
      'handlersCount': _handlers.length,
      'handlers': _handlers.map((h) => h.type.name).toList(),
      'supportedTypes': DeepLinkType.values.map((t) => t.name).toList(),
    };
  }
  
  /// Finaliza o serviço
  void dispose() {
    _linkController.close();
  }
}

/// Widget para manipular deep links automaticamente
class DeepLinkWidget extends StatefulWidget {
  final Widget child;
  final Function(DeepLinkData)? onDeepLink;
  
  const DeepLinkWidget({
    super.key,
    required this.child,
    this.onDeepLink,
  });
  
  @override
  State<DeepLinkWidget> createState() => _DeepLinkWidgetState();
}

class _DeepLinkWidgetState extends State<DeepLinkWidget> {
  StreamSubscription<DeepLinkData>? _linkSubscription;
  
  @override
  void initState() {
    super.initState();
    _setupDeepLinkListener();
  }
  
  void _setupDeepLinkListener() {
    _linkSubscription = DeepLinkService.instance.linkStream.listen(
      (linkData) {
        if (mounted) {
          widget.onDeepLink?.call(linkData);
          DeepLinkService.instance.handleDeepLink(context, linkData.originalUrl);
        }
      },
    );
  }
  
  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
