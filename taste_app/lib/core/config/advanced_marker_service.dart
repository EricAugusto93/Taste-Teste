import 'package:flutter/foundation.dart';

// Conditional imports para diferentes plataformas
import 'advanced_marker_web_stub.dart'
    if (dart.library.html) 'advanced_marker_web.dart';

/// Service para gerenciar AdvancedMarkerElement de forma cross-platform
class AdvancedMarkerService {
  static bool _isInitialized = false;
  
  /// Inicializa o serviço de marcadores avançados
  static void initialize(dynamic map) {
    if (kIsWeb) {
      AdvancedMarkerWeb.initializeMap(map);
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ AdvancedMarkerService inicializado para Web');
      }
    } else {
      if (kDebugMode) {
        debugPrint('ℹ️ AdvancedMarkerService: Plataforma não-web, usando marcadores tradicionais');
      }
    }
  }
  
  /// Verifica se AdvancedMarkerElement está disponível
  static bool isAvailable() {
    if (!kIsWeb) return false;
    return AdvancedMarkerWeb.isAdvancedMarkerAvailable();
  }
  
  /// Cria um marcador avançado
  static dynamic createMarker({
    required String markerId,
    required double lat,
    required double lng,
    String? title,
    dynamic content,
    bool draggable = false,
  }) {
    if (!kIsWeb || !_isInitialized) return null;
    
    return AdvancedMarkerWeb.createAdvancedMarker(
      markerId: markerId,
      lat: lat,
      lng: lng,
      title: title,
      content: content,
      gmpDraggable: draggable,
    );
  }
  
  /// Cria um marcador com ícone customizado
  static dynamic createMarkerWithIcon({
    required String markerId,
    required double lat,
    required double lng,
    required String iconUrl,
    String? title,
    double iconWidth = 32,
    double iconHeight = 32,
    bool draggable = false,
  }) {
    if (!kIsWeb || !_isInitialized) return null;
    
    return AdvancedMarkerWeb.createAdvancedMarkerWithIcon(
      markerId: markerId,
      lat: lat,
      lng: lng,
      iconUrl: iconUrl,
      title: title,
      iconWidth: iconWidth,
      iconHeight: iconHeight,
      gmpDraggable: draggable,
    );
  }
  
  /// Cria um marcador com emoji
  static dynamic createMarkerWithEmoji({
    required String markerId,
    required double lat,
    required double lng,
    required String emoji,
    String? title,
    double fontSize = 24,
    bool draggable = false,
  }) {
    if (!kIsWeb || !_isInitialized) return null;
    
    return AdvancedMarkerWeb.createAdvancedMarkerWithEmoji(
      markerId: markerId,
      lat: lat,
      lng: lng,
      emoji: emoji,
      title: title,
      fontSize: fontSize,
      gmpDraggable: draggable,
    );
  }
  
  /// Remove um marcador
  static void removeMarker(String markerId) {
    if (!kIsWeb || !_isInitialized) return;
    AdvancedMarkerWeb.removeMarker(markerId);
  }
  
  /// Remove todos os marcadores
  static void clearAllMarkers() {
    if (!kIsWeb || !_isInitialized) return;
    AdvancedMarkerWeb.clearAllMarkers();
  }
  
  /// Adiciona listener de clique
  static void addClickListener(String markerId, Function() onTap) {
    if (!kIsWeb || !_isInitialized) return;
    AdvancedMarkerWeb.addClickListener(markerId, onTap);
  }
  
  /// Atualiza a posição de um marcador
  static void updateMarkerPosition(String markerId, double lat, double lng) {
    if (!kIsWeb || !_isInitialized) return;
    AdvancedMarkerWeb.updateMarkerPosition(markerId, lat, lng);
  }
  
  /// Obtém a contagem de marcadores ativos
  static int getMarkerCount() {
    if (!kIsWeb || !_isInitialized) return 0;
    return AdvancedMarkerWeb.getMarkerCount();
  }
  
  /// Verifica se um marcador existe
  static bool hasMarker(String markerId) {
    if (!kIsWeb || !_isInitialized) return false;
    return AdvancedMarkerWeb.hasMarker(markerId);
  }
  
  /// Verifica se o serviço foi inicializado
  static bool get isInitialized => _isInitialized;
}