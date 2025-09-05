// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'custom_web_marker.dart';

/// Web-specific implementation using AdvancedMarkerElement
class CustomWebMarkerWeb {
  static final Map<String, js.JsObject> _markers = {};
  static js.JsObject? _map;
  static bool _isInitialized = false;
  static final List<Function()> _pendingCreations = [];

  /// Initialize the web marker system
  static void initialize(dynamic map) {
    if (kDebugMode) {
      debugPrint('🚀 CustomWebMarkerWeb: Inicializando sistema de markers...');
    }
    
    _map = map as js.JsObject?;
    _isInitialized = true;

    // Execute any pending marker creations
    final pendingList = List<Function()>.from(_pendingCreations);
    _pendingCreations.clear();
    
    for (final creation in pendingList) {
      try {
        creation();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Erro ao executar criação pendente: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('✅ CustomWebMarkerWeb inicializado com ${pendingList.length} markers pendentes');
    }
  }

  /// Create AdvancedMarkerElement
  static dynamic createAdvancedMarker(CustomWebMarker marker, {dynamic map}) {
    if (!kIsWeb) return null;

    if (kDebugMode) {
      debugPrint('🎯 Criando AdvancedMarker: ${marker.markerId}');
    }

    // If not initialized, queue the creation
    if (!_isInitialized || _map == null) {
      if (kDebugMode) {
        debugPrint('⏳ Sistema não inicializado, enfileirando marker: ${marker.markerId}');
      }
      
      _pendingCreations.add(() {
        _createAdvancedMarkerImmediate(marker);
      });
      return null;
    }

    return _createAdvancedMarkerImmediate(marker);
  }

  /// Create AdvancedMarkerElement immediately
  static js.JsObject? _createAdvancedMarkerImmediate(CustomWebMarker marker) {
    try {
      // Check if Google Maps API is available
      final google = js.context['google'];
      if (google == null || google['maps'] == null) {
        if (kDebugMode) {
          debugPrint('❌ Google Maps API não disponível para ${marker.markerId}');
        }
        return null;
      }

      // Check if marker library and AdvancedMarkerElement are available
      final markerLib = google['maps']['marker'];
      if (markerLib == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Biblioteca marker não carregada, usando fallback para ${marker.markerId}');
        }
        return _createFallbackAdvancedMarker(marker);
      }

      final advancedMarkerClass = markerLib['AdvancedMarkerElement'];
      if (advancedMarkerClass == null) {
        if (kDebugMode) {
          debugPrint('⚠️ AdvancedMarkerElement não disponível, usando fallback para ${marker.markerId}');
        }
        return _createFallbackAdvancedMarker(marker);
      }

      // Get current map instance
      js.JsObject? currentMap = _getCurrentMapInstance();
      if (currentMap == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Instância do mapa não encontrada para ${marker.markerId}');
        }
        return null;
      }

      // Create position
      final position = js.JsObject.jsify({
        'lat': marker.position.latitude,
        'lng': marker.position.longitude,
      });

      // Create content element if needed
      html.Element? contentElement;
      if (marker.title != null && marker.title!.isNotEmpty) {
        // Extract emoji from title for balloon marker
        final emoji = _extractEmojiFromTitle(marker.title!);
        if (emoji != null) {
          // Use new balloon-style marker
          contentElement = createBalloonMarkerContent(
            emoji: emoji,
            isSelected: false, // Can be enhanced to track selected state
            isCluster: marker.markerId.startsWith('cluster_'),
            clusterCount: marker.markerId.startsWith('cluster_') 
                ? _extractClusterCount(marker.title!) 
                : null,
          );
        }
      }

      // Create marker options
      final options = js.JsObject.jsify({
        'position': position,
        'map': currentMap,
        'title': marker.title ?? '',
        'gmpDraggable': marker.draggable,
        if (contentElement != null) 'content': contentElement,
      });

      // Create the AdvancedMarkerElement
      final jsMarker = js.JsObject(advancedMarkerClass, [options]);
      
      // Store the marker
      _markers[marker.markerId] = jsMarker;

      // Add click listener if provided
      if (marker.onTap != null) {
        _addClickListener(marker.markerId, marker.onTap!);
      }

      if (kDebugMode) {
        debugPrint('✅ AdvancedMarkerElement criado: ${marker.markerId}');
      }

      return jsMarker;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao criar AdvancedMarkerElement ${marker.markerId}: $e');
      }
      return _createFallbackAdvancedMarker(marker);
    }
  }

  /// Create fallback marker when AdvancedMarkerElement is not available
  static js.JsObject? _createFallbackAdvancedMarker(CustomWebMarker marker) {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Criando marker fallback para: ${marker.markerId}');
      }

      // Still avoid using google.maps.Marker - return null to let Flutter handle it
      // This is better than creating deprecated markers
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no fallback para ${marker.markerId}: $e');
      }
      return null;
    }
  }

  /// Get current map instance
  static js.JsObject? _getCurrentMapInstance() {
    try {
      // Try to use stored map instance
      if (_map != null) {
        return _map;
      }

      // Try to find map in DOM
      final mapElements = html.document.querySelectorAll('.gm-style');
      if (mapElements.isNotEmpty) {
        // Return a generic map reference
        return js.JsObject.jsify({'isGoogleMap': true});
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao obter instância do mapa: $e');
      }
      return null;
    }
  }

  /// Extract emoji from title string
  static String? _extractEmojiFromTitle(String title) {
    if (title.isEmpty) return null;
    
    // Check if first character is an emoji
    final firstChar = title.isNotEmpty ? title[0] : '';
    if (_isEmoji(firstChar)) {
      return firstChar;
    }
    
    return null;
  }

  /// Extract cluster count from title string
  static String? _extractClusterCount(String title) {
    final regex = RegExp(r'(\d+)\s*restaurantes?');
    final match = regex.firstMatch(title);
    return match?.group(1);
  }

  /// Check if character is an emoji
  static bool _isEmoji(String char) {
    final codeUnit = char.codeUnits.first;
    return (codeUnit >= 0x1F600 && codeUnit <= 0x1F64F) || // Emoticons
           (codeUnit >= 0x1F300 && codeUnit <= 0x1F5FF) || // Misc Symbols
           (codeUnit >= 0x1F680 && codeUnit <= 0x1F6FF) || // Transport
           (codeUnit >= 0x1F1E6 && codeUnit <= 0x1F1FF) || // Regional indicators
           (codeUnit >= 0x2600 && codeUnit <= 0x26FF) ||   // Misc symbols
           (codeUnit >= 0x2700 && codeUnit <= 0x27BF);     // Dingbats
  }

  /// Create emoji content element
  static html.DivElement _createEmojiContent(String emoji) {
    final div = html.DivElement()
      ..style.fontSize = '24px'
      ..style.textAlign = 'center'
      ..style.lineHeight = '1'
      ..style.userSelect = 'none'
      ..style.cursor = 'pointer'
      ..text = emoji;
    
    return div;
  }

  /// Create balloon-style marker content element
  static html.DivElement createBalloonMarkerContent({
    required String emoji,
    bool isSelected = false,
    bool isCluster = false,
    String? clusterCount,
  }) {
    final container = html.DivElement();
    
    // Balloon container with positioning
    container.style
      ..position = 'relative'
      ..width = '40px'
      ..height = '48px' // 40px circle + 8px tail
      ..display = 'flex'
      ..alignItems = 'center'
      ..justifyContent = 'center'
      ..cursor = 'pointer'
      ..userSelect = 'none';

    // Create balloon circle
    final balloon = html.DivElement();
    balloon.style
      ..width = '40px'
      ..height = '40px'
      ..backgroundColor = isCluster ? '#6B73D9' : 'white'
      ..border = isSelected ? '2px solid #6B73D9' : '2px solid #E5E7EB'
      ..borderRadius = '50%'
      ..display = 'flex'
      ..alignItems = 'center'
      ..justifyContent = 'center'
      ..boxShadow = '0 2px 4px rgba(0, 0, 0, 0.2)'
      ..position = 'relative'
      ..zIndex = '2'
      ..fontSize = '20px'
      ..lineHeight = '1'
      ..transition = 'transform 0.2s ease, box-shadow 0.2s ease';

    // Add content (emoji or cluster count)
    if (isCluster && clusterCount != null) {
      balloon.text = clusterCount;
      balloon.style
        ..color = 'white'
        ..fontWeight = 'bold'
        ..fontSize = '14px';
    } else {
      balloon.text = emoji;
    }

    // Create tail
    final tail = html.DivElement();
    tail.style
      ..position = 'absolute'
      ..bottom = '8px'
      ..left = '50%'
      ..width = '0'
      ..height = '0'
      ..borderLeft = '6px solid transparent'
      ..borderRight = '6px solid transparent'
      ..borderTop = isCluster ? '8px solid #6B73D9' : '8px solid white'
      ..transform = 'translateX(-50%)'
      ..zIndex = '2';

    // Create tail border
    final tailBorder = html.DivElement();
    tailBorder.style
      ..position = 'absolute'
      ..bottom = '7px'
      ..left = '50%'
      ..width = '0'
      ..height = '0'
      ..borderLeft = '7px solid transparent'
      ..borderRight = '7px solid transparent'
      ..borderTop = isSelected ? '9px solid #6B73D9' : '9px solid #E5E7EB'
      ..transform = 'translateX(-50%)'
      ..zIndex = '1';

    // Add hover effects
    balloon.onMouseEnter.listen((_) {
      balloon.style.transform = 'scale(1.05)';
      balloon.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.3)';
    });

    balloon.onMouseLeave.listen((_) {
      if (!isSelected) {
        balloon.style.transform = 'scale(1.0)';
        balloon.style.boxShadow = '0 2px 4px rgba(0, 0, 0, 0.2)';
      }
    });

    // Apply selected state styling
    if (isSelected) {
      balloon.style.transform = 'scale(1.05)';
      balloon.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.3)';
    }

    // Assemble the marker
    container.children.addAll([tailBorder, tail, balloon]);
    
    return container;
  }

  /// Add click listener to marker
  static void _addClickListener(String markerId, VoidCallback onTap) {
    try {
      final marker = _markers[markerId];
      if (marker != null) {
        final eventClass = js.context['google']?['maps']?['event'];
        if (eventClass != null) {
          eventClass.callMethod('addListener', [marker, 'click', js.allowInterop((_) {
            onTap();
          })]);
          
          if (kDebugMode) {
            debugPrint('✅ Click listener adicionado para: $markerId');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao adicionar click listener para $markerId: $e');
      }
    }
  }

  /// Remove marker
  static void removeMarker(String markerId) {
    try {
      final marker = _markers[markerId];
      if (marker != null) {
        // Remove from map
        marker['map'] = null;
        _markers.remove(markerId);
        
        if (kDebugMode) {
          debugPrint('✅ Marker removido: $markerId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao remover marker $markerId: $e');
      }
    }
  }

  /// Update marker position
  static void updateMarkerPosition(String markerId, gmaps.LatLng position) {
    try {
      final marker = _markers[markerId];
      if (marker != null) {
        final newPosition = js.JsObject.jsify({
          'lat': position.latitude,
          'lng': position.longitude,
        });
        
        marker['position'] = newPosition;
        
        if (kDebugMode) {
          debugPrint('✅ Posição atualizada para $markerId: ${position.latitude}, ${position.longitude}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao atualizar posição do marker $markerId: $e');
      }
    }
  }

  /// Check if AdvancedMarkerElement is available
  static bool isAdvancedMarkerAvailable() {
    try {
      final google = js.context['google'];
      if (google == null) return false;
      
      final maps = google['maps'];
      if (maps == null) return false;
      
      final marker = maps['marker'];
      if (marker == null) return false;
      
      final advancedMarker = marker['AdvancedMarkerElement'];
      return advancedMarker != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao verificar AdvancedMarkerElement: $e');
      }
      return false;
    }
  }

  /// Clear all markers
  static void clearAllMarkers() {
    try {
      for (final markerId in _markers.keys.toList()) {
        removeMarker(markerId);
      }
      
      if (kDebugMode) {
        debugPrint('✅ Todos os markers removidos');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao limpar markers: $e');
      }
    }
  }

  /// Get marker count
  static int get markerCount => _markers.length;

  /// Check if marker exists
  static bool hasMarker(String markerId) => _markers.containsKey(markerId);

  /// Get all marker IDs
  static List<String> get markerIds => _markers.keys.toList();
}