import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Helper class para facilitar navegação e deep linking
class DeepLinkHelper {
  /// Base URL para deep links (pode ser configurada para produção)
  static const String baseUrl = 'https://taste.app';
  
  /// Navegar para detalhes do restaurante
  static void goToRestaurant(BuildContext context, String restaurantId) {
    context.pushNamed('restaurant_details', pathParameters: {'id': restaurantId});
  }
  
  /// Navegar para categoria
  static void goToCategory(BuildContext context, String categoryId) {
    context.pushNamed('category_details', pathParameters: {'id': categoryId});
  }
  
  /// Navegar para busca com query
  static void goToSearch(BuildContext context, {String? query}) {
    if (query != null && query.isNotEmpty) {
      context.pushNamed('search', queryParameters: {'q': query});
    } else {
      context.pushNamed('search');
    }
  }
  
  /// Navegar para mapa com coordenadas
  static void goToMap(BuildContext context, {double? lat, double? lng}) {
    final queryParams = <String, String>{};
    if (lat != null) queryParams['lat'] = lat.toString();
    if (lng != null) queryParams['lng'] = lng.toString();
    
    context.pushNamed('map_view', queryParameters: queryParams);
  }
  
  /// Navegar para favoritos
  static void goToFavorites(BuildContext context) {
    context.pushNamed('favorites');
  }
  
  /// Navegar para configurações
  static void goToSettings(BuildContext context) {
    context.pushNamed('settings');
  }
  
  /// Navegar para perfil do usuário
  static void goToUserProfile(BuildContext context, String userId) {
    context.pushNamed('user_profile', pathParameters: {'userId': userId});
  }
  
  /// Navegar para menu do restaurante
  static void goToRestaurantMenu(BuildContext context, String restaurantId) {
    context.pushNamed('restaurant_menu', pathParameters: {'id': restaurantId});
  }
  
  /// Navegar para avaliações do restaurante
  static void goToRestaurantReviews(BuildContext context, String restaurantId) {
    context.pushNamed('restaurant_reviews', pathParameters: {'id': restaurantId});
  }
  
  /// Gerar URL para compartilhamento de restaurante
  static String generateRestaurantUrl(String restaurantId) {
    return '$baseUrl/restaurant/$restaurantId';
  }
  
  /// Gerar URL para compartilhamento de categoria
  static String generateCategoryUrl(String categoryId) {
    return '$baseUrl/category/$categoryId';
  }
  
  /// Gerar URL para compartilhamento de busca
  static String generateSearchUrl(String query) {
    return '$baseUrl/search?q=${Uri.encodeComponent(query)}';
  }
  
  /// Gerar URL para compartilhamento de localização
  static String generateMapUrl(double lat, double lng) {
    return '$baseUrl/map?lat=$lat&lng=$lng';
  }
  
  /// Compartilhar restaurante
  static Future<void> shareRestaurant(String restaurantId, String restaurantName) async {
    final url = generateRestaurantUrl(restaurantId);
    await Share.share(
      'Confira o restaurante $restaurantName no Taste! $url',
      subject: 'Restaurante no Taste',
    );
  }
  
  /// Compartilhar categoria
  static Future<void> shareCategory(String categoryId, String categoryName) async {
    final url = generateCategoryUrl(categoryId);
    await Share.share(
      'Veja os restaurantes de $categoryName no Taste! $url',
      subject: 'Categoria no Taste',
    );
  }
  
  /// Compartilhar busca
  static Future<void> shareSearch(String query) async {
    final url = generateSearchUrl(query);
    await Share.share(
      'Veja os resultados para "$query" no Taste! $url',
      subject: 'Busca no Taste',
    );
  }
  
  /// Compartilhar localização
  static Future<void> shareLocation(double lat, double lng, String locationName) async {
    final url = generateMapUrl(lat, lng);
    await Share.share(
      'Confira $locationName no mapa do Taste! $url',
      subject: 'Localização no Taste',
    );
  }
  
  /// Verificar se uma URL é um deep link válido do app
  static bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host == 'taste.app' || uri.host == 'www.taste.app';
    } catch (e) {
      return false;
    }
  }
  
  /// Extrair rota do deep link
  static String? extractRouteFromDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      if (isValidDeepLink(url)) {
        return uri.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Navegar usando deep link URL
  static void navigateFromDeepLink(BuildContext context, String url) {
    final route = extractRouteFromDeepLink(url);
    if (route != null) {
      context.go(route);
    }
  }
}

/// Extension para facilitar navegação
extension DeepLinkExtension on BuildContext {
  /// Navegar para restaurante
  void goToRestaurant(String restaurantId) {
    DeepLinkHelper.goToRestaurant(this, restaurantId);
  }
  
  /// Navegar para categoria
  void goToCategory(String categoryId) {
    DeepLinkHelper.goToCategory(this, categoryId);
  }
  
  /// Navegar para busca
  void goToSearch({String? query}) {
    DeepLinkHelper.goToSearch(this, query: query);
  }
  
  /// Navegar para mapa
  void goToMap({double? lat, double? lng}) {
    DeepLinkHelper.goToMap(this, lat: lat, lng: lng);
  }
  
  /// Navegar para favoritos
  void goToFavorites() {
    DeepLinkHelper.goToFavorites(this);
  }
  
  /// Navegar para configurações
  void goToSettings() {
    DeepLinkHelper.goToSettings(this);
  }
}