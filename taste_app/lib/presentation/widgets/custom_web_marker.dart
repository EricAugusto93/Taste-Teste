import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// Conditional imports
import 'custom_web_marker_stub.dart'
    if (dart.library.html) 'custom_web_marker_web.dart';

/// Custom marker wrapper que usa AdvancedMarkerElement no Web e gmaps.Marker no mobile
class CustomWebMarker {
  final String markerId;
  final gmaps.LatLng position;
  final String? title;
  final String? snippet;
  final gmaps.BitmapDescriptor? icon;
  final VoidCallback? onTap;
  final gmaps.InfoWindow? infoWindow;
  final bool draggable;
  final bool visible;
  final double zIndex;
  final Offset anchor;
  final double alpha;

  const CustomWebMarker({
    required this.markerId,
    required this.position,
    this.title,
    this.snippet,
    this.icon,
    this.onTap,
    this.infoWindow,
    this.draggable = false,
    this.visible = true,
    this.zIndex = 0.0,
    this.anchor = const Offset(0.5, 1.0),
    this.alpha = 1.0,
  });

  /// Converte para gmaps.Marker tradicional (usado no mobile)
  gmaps.Marker toGoogleMapsMarker() {
    return gmaps.Marker(
      markerId: gmaps.MarkerId(markerId),
      position: position,
      infoWindow: infoWindow ?? gmaps.InfoWindow(
        title: title ?? '',
        snippet: snippet ?? '',
      ),
      icon: icon ?? gmaps.BitmapDescriptor.defaultMarker,
      onTap: onTap,
      draggable: draggable,
      visible: visible,
      zIndex: zIndex,
      anchor: anchor,
      alpha: alpha,
    );
  }

  /// Cria marker usando AdvancedMarkerElement no web, gmaps.Marker no mobile
  static dynamic createPlatformMarker(CustomWebMarker marker, {dynamic map}) {
    if (kIsWeb) {
      // No web, usar AdvancedMarkerElement via JavaScript
      return CustomWebMarkerWeb.createAdvancedMarker(marker, map: map);
    } else {
      // No mobile, usar gmaps.Marker tradicional (não deprecated)
      return marker.toGoogleMapsMarker();
    }
  }

  /// Remove marker da plataforma específica
  static void removePlatformMarker(String markerId) {
    if (kIsWeb) {
      CustomWebMarkerWeb.removeMarker(markerId);
    }
    // No mobile, o marker é removido automaticamente pelo widget
  }

  /// Atualiza posição do marker
  static void updateMarkerPosition(String markerId, gmaps.LatLng position) {
    if (kIsWeb) {
      CustomWebMarkerWeb.updateMarkerPosition(markerId, position);
    }
    // No mobile, isso é feito recriando o Set<Marker> no widget
  }

  /// Verifica se AdvancedMarkerElement está disponível
  static bool get isAdvancedMarkerAvailable {
    if (!kIsWeb) return false;
    return CustomWebMarkerWeb.isAdvancedMarkerAvailable();
  }

  /// Inicializa o sistema de markers (necessário para web)
  static void initialize(dynamic map) {
    if (kIsWeb) {
      CustomWebMarkerWeb.initialize(map);
    }
  }

  /// Limpa todos os markers
  static void clearAllMarkers() {
    if (kIsWeb) {
      CustomWebMarkerWeb.clearAllMarkers();
    }
  }
}

/// Resultado de conversão para uso em widgets Flutter
class MarkerConversionResult {
  final Set<gmaps.Marker> markers;
  final List<String> webMarkerIds;

  const MarkerConversionResult({
    required this.markers,
    required this.webMarkerIds,
  });
}

/// Utilidades para conversão em lote de markers
class CustomWebMarkerUtils {
  /// Converte lista de CustomWebMarker para Set<gmaps.Marker>
  /// No web, também cria AdvancedMarkerElements via JavaScript
  static MarkerConversionResult convertMarkersForPlatform(
    List<CustomWebMarker> customMarkers, {
    dynamic map,
  }) {
    final Set<gmaps.Marker> flutterMarkers = {};
    final List<String> webMarkerIds = [];

    for (final customMarker in customMarkers) {
      if (kIsWeb && CustomWebMarkerWeb.isAdvancedMarkerAvailable()) {
        // No web, tentar criar AdvancedMarkerElement via JavaScript
        try {
          CustomWebMarkerWeb.createAdvancedMarker(customMarker, map: map);
          webMarkerIds.add(customMarker.markerId);
          
          if (kDebugMode) {
            debugPrint('🚀 CustomWebMarker criado via AdvancedMarkerElement: ${customMarker.markerId}');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Fallback para gmaps.Marker para ${customMarker.markerId}: $e');
          }
          // Fallback para gmaps.Marker se AdvancedMarkerElement falhar
          flutterMarkers.add(customMarker.toGoogleMapsMarker());
        }
      } else {
        // No mobile ou quando AdvancedMarkerElement não está disponível
        flutterMarkers.add(customMarker.toGoogleMapsMarker());
        
        if (kDebugMode) {
          debugPrint('📱 CustomWebMarker criado via gmaps.Marker: ${customMarker.markerId}');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('📊 Conversão completa: ${webMarkerIds.length} AdvancedMarkers, ${flutterMarkers.length} gmaps.Markers');
    }

    return MarkerConversionResult(
      markers: flutterMarkers,
      webMarkerIds: webMarkerIds,
    );
  }

  /// Cria CustomWebMarker a partir de dados básicos
  static CustomWebMarker createRestaurantMarker({
    required String id,
    required double lat,
    required double lng,
    required String name,
    String? emoji,
    String? rating,
    String? deliveryTime,
    gmaps.BitmapDescriptor? customIcon,
    VoidCallback? onTap,
  }) {
    final title = emoji != null ? '$emoji $name' : name;
    final snippet = rating != null && deliveryTime != null
        ? '⭐ $rating • $deliveryTime'
        : null;

    return CustomWebMarker(
      markerId: id,
      position: gmaps.LatLng(lat, lng),
      title: title,
      snippet: snippet,
      icon: customIcon,
      onTap: onTap,
      infoWindow: gmaps.InfoWindow(
        title: title,
        snippet: snippet ?? '',
      ),
    );
  }

  /// Cria CustomWebMarker para localização do usuário
  static CustomWebMarker createUserLocationMarker({
    required double lat,
    required double lng,
    gmaps.BitmapDescriptor? customIcon,
    VoidCallback? onTap,
  }) {
    return CustomWebMarker(
      markerId: 'user_location',
      position: gmaps.LatLng(lat, lng),
      title: '📍 Você está aqui',
      snippet: 'Sua localização atual',
      icon: customIcon,
      onTap: onTap,
      infoWindow: const gmaps.InfoWindow(
        title: '📍 Você está aqui',
        snippet: 'Sua localização atual',
      ),
    );
  }

  /// Cria CustomWebMarker para cluster
  static CustomWebMarker createClusterMarker({
    required String id,
    required double lat,
    required double lng,
    required int count,
    gmaps.BitmapDescriptor? customIcon,
    VoidCallback? onTap,
  }) {
    return CustomWebMarker(
      markerId: 'cluster_$id',
      position: gmaps.LatLng(lat, lng),
      title: '$count restaurantes',
      snippet: 'Clique para expandir',
      icon: customIcon,
      onTap: onTap,
      infoWindow: gmaps.InfoWindow(
        title: '$count restaurantes',
        snippet: 'Clique para expandir',
      ),
    );
  }

  /// Creates cluster balloon marker with custom styling
  /// This method should be called from map_page.dart where BalloonMarkerService is imported
  static CustomWebMarker createBalloonClusterMarker({
    required String id,
    required double lat,
    required double lng,
    required int count,
    required gmaps.BitmapDescriptor clusterIcon,
    VoidCallback? onTap,
  }) {
    return createClusterMarker(
      id: id,
      lat: lat,
      lng: lng,
      count: count,
      customIcon: clusterIcon,
      onTap: onTap,
    );
  }
}