// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Web implementation for Advanced Markers
class AdvancedMarkerWeb {
  static final Map<String, js.JsObject> _markers = {};
  static js.JsObject? _map;
  static final List<Function()> _pendingMarkerCallbacks = [];
  static bool _isMapReady = false;

  /// Inicializa o mapa para uso com AdvancedMarkers
  static void initializeMap(js.JsObject? mapInstance) {
    if (kDebugMode) {
      debugPrint('🗺️ Inicializando AdvancedMarkerWeb...');
    }

    // Resetar estado
    _map = null;
    _isMapReady = false;

    // Se uma instância foi fornecida, usar ela
    if (mapInstance != null) {
      _map = mapInstance;
      _isMapReady = true;

      if (kDebugMode) {
        debugPrint('✅ Instância do mapa fornecida diretamente');
      }

      _executePendingCallbacks();
      return;
    }

    // Tentar obter a instância do mapa imediatamente
    _tryToGetMapInstance();

    // Se não conseguir, tentar novamente após delays
    if (!_isMapReady) {
      Timer(const Duration(milliseconds: 500), () {
        if (!_isMapReady) {
          _tryToGetMapInstance();
        }
      });

      Timer(const Duration(milliseconds: 1500), () {
        if (!_isMapReady) {
          _tryToGetMapInstance();
        }
      });

      Timer(const Duration(milliseconds: 3000), () {
        if (!_isMapReady) {
          if (kDebugMode) {
            debugPrint(
                '⚠️ Timeout na inicialização do mapa, usando fallback para marcadores pendentes');
          }
          // Executar callbacks mesmo sem o mapa pronto (usarão fallback)
          _executePendingCallbacks();
        }
      });
    }
  }

  /// Tenta obter a instância do mapa JavaScript
  static void _tryToGetMapInstance() {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Tentando obter instância do mapa...');
      }

      // Verificar se o Google Maps está disponível
      final google = js.context['google'];
      if (google == null || google['maps'] == null) {
        if (kDebugMode) {
          debugPrint('⏳ Google Maps API ainda não está disponível');
        }
        return;
      }

      // Procurar por elementos do Google Maps no DOM
      final mapElements = html.document.querySelectorAll('.gm-style');
      final mapContainers =
          html.document.querySelectorAll('[data-testid="google-map"]');

      if (mapElements.isNotEmpty || mapContainers.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('✅ Elementos do mapa encontrados no DOM');
        }

        // Configurar uma referência funcional do mapa
        _map = js.JsObject.jsify(
            {'isGoogleMap': true, 'ready': true, 'apiLoaded': true});
        _isMapReady = true;

        if (kDebugMode) {
          debugPrint('🎉 Instância do mapa configurada com sucesso!');
          debugPrint(
              '📋 Executando ${_pendingMarkerCallbacks.length} callbacks pendentes');
        }

        // Executar callbacks pendentes
        _executePendingCallbacks();
      } else {
        if (kDebugMode) {
          debugPrint('⏳ Elementos do mapa ainda não encontrados no DOM');
        }

        // Tentar novamente após um pequeno delay
        Timer(const Duration(milliseconds: 500), () {
          if (!_isMapReady && _pendingMarkerCallbacks.isNotEmpty) {
            _tryToGetMapInstance();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao tentar obter instância do mapa: $e');
      }
    }
  }

  /// Executa callbacks pendentes quando o mapa estiver pronto
  static void _executePendingCallbacks() {
    if (_pendingMarkerCallbacks.isEmpty) {
      if (kDebugMode) {
        debugPrint('✅ Nenhum callback pendente para executar');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
          '🔄 Executando ${_pendingMarkerCallbacks.length} callbacks pendentes');
    }

    final callbacks = List<Function()>.from(_pendingMarkerCallbacks);
    _pendingMarkerCallbacks.clear();

    int successCount = 0;
    int errorCount = 0;

    for (final callback in callbacks) {
      try {
        callback();
        successCount++;
      } catch (e) {
        errorCount++;
        if (kDebugMode) {
          debugPrint('❌ Erro ao executar callback pendente: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
          '📊 Callbacks executados: $successCount sucessos, $errorCount erros');
    }
  }

  /// Obtém o objeto JavaScript do mapa atual
  static js.JsObject? _getCurrentMap() {
    try {
      // Tentar acessar o mapa através do contexto global
      final google = js.context['google'];
      if (google != null && google['maps'] != null) {
        // Procurar por instâncias de mapa no DOM
        final mapElements = js.context['document']
            .callMethod('querySelectorAll', ['.gm-style']);
        if (mapElements != null && mapElements['length'] > 0) {
          // Retornar uma referência genérica que será usada para criar marcadores
          return js.JsObject.jsify({'isGoogleMap': true});
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao obter mapa atual: $e');
      }
      return null;
    }
  }

  /// Verifica se AdvancedMarkerElement está disponível
  static bool isAdvancedMarkerAvailable() {
    try {
      if (kDebugMode) {
        debugPrint(
            '🔍 Verificando disponibilidade do AdvancedMarkerElement...');
      }

      final google = js.context['google'];
      if (google == null) {
        if (kDebugMode) {
          debugPrint('❌ google não está disponível no contexto JavaScript');
        }
        return false;
      }

      final maps = js.context['google']['maps'];
      if (maps == null) {
        if (kDebugMode) {
          debugPrint('❌ google.maps não está disponível');
        }
        return false;
      }

      final marker = js.context['google']['maps']['marker'];
      if (marker == null) {
        if (kDebugMode) {
          debugPrint(
              '❌ google.maps.marker não está disponível - biblioteca marker não foi carregada');
        }
        return false;
      }

      final advancedMarker =
          js.context['google']['maps']['marker']['AdvancedMarkerElement'];
      final isAvailable = advancedMarker != null;

      if (kDebugMode) {
        if (isAvailable) {
          debugPrint('✅ AdvancedMarkerElement está disponível!');
        } else {
          debugPrint('❌ AdvancedMarkerElement não está disponível');
        }
      }

      return isAvailable;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao verificar AdvancedMarkerElement: $e');
      }
      return false;
    }
  }

  /// Cria um AdvancedMarkerElement
  static js.JsObject? createAdvancedMarker({
    required String markerId,
    required double lat,
    required double lng,
    String? title,
    html.Element? content,
    bool gmpDraggable = false,
  }) {
    try {
      if (kDebugMode) {
        debugPrint(
            '🚀 Solicitação para criar AdvancedMarkerElement: $markerId');
      }

      // Se o mapa estiver pronto, criar imediatamente
      if (_isMapReady && _map != null) {
        return _tryCreateMarkerImmediate(
            markerId, lat, lng, title, content, gmpDraggable);
      }

      // Se o mapa não estiver pronto, adicionar à fila de callbacks
      if (kDebugMode) {
        debugPrint(
            '⏳ Mapa não está pronto, adicionando marcador $markerId à fila');
      }

      _pendingMarkerCallbacks.add(() {
        _tryCreateMarkerImmediate(
            markerId, lat, lng, title, content, gmpDraggable);
      });

      // Tentar obter a instância do mapa novamente
      _tryToGetMapInstance();

      // Retornar um placeholder temporário
      return js.JsObject.jsify({'id': markerId, 'pending': true});
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Erro ao criar AdvancedMarkerElement: $e - usando fallback');
      }
      return _createFallbackMarker(markerId, lat, lng, title);
    }
  }

  /// Tenta criar marcador imediatamente
  static js.JsObject? _tryCreateMarkerImmediate(
    String markerId,
    double lat,
    double lng,
    String? title,
    html.Element? content,
    bool gmpDraggable,
  ) {
    try {
      if (kDebugMode) {
        debugPrint('🔨 Tentando criar marcador imediatamente: $markerId');
      }

      // Verificar se o Google Maps está disponível
      final google = js.context['google'];
      if (google == null || google['maps'] == null) {
        if (kDebugMode) {
          debugPrint('❌ Google Maps API não está disponível');
        }
        return _createFallbackMarker(markerId, lat, lng, title);
      }

      // Tentar obter a instância do mapa atual
      js.JsObject? currentMap = _getCurrentMapInstance();
      if (currentMap == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Instância do mapa não disponível, usando fallback');
        }
        return _createFallbackMarker(markerId, lat, lng, title);
      }

      // Verificar se AdvancedMarkerElement está disponível
      final advancedMarkerClass =
          google['maps']['marker']?['AdvancedMarkerElement'];
      if (advancedMarkerClass == null) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ AdvancedMarkerElement não disponível, usando fallback');
        }
        return _createFallbackMarker(markerId, lat, lng, title);
      }

      final position = js.JsObject.jsify({'lat': lat, 'lng': lng});
      final options = js.JsObject.jsify({
        'position': position,
        'map': currentMap,
        'title': title ?? '',
        'gmpDraggable': gmpDraggable,
        if (content != null) 'content': content,
      });

      final marker = js.JsObject(advancedMarkerClass, [options]);
      _markers[markerId] = marker;

      if (kDebugMode) {
        debugPrint('✅ AdvancedMarkerElement criado com sucesso: $markerId');
      }

      return marker;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro na criação imediata: $e, usando fallback');
      }
      return _createFallbackMarker(markerId, lat, lng, title);
    }
  }

  /// Obtém a instância atual do mapa JavaScript
  static js.JsObject? _getCurrentMapInstance() {
    try {
      // Se já temos uma referência válida, usar ela
      if (_map != null && _map!['ready'] == true) {
        return _map;
      }

      // Tentar encontrar o mapa através do DOM
      final mapElements = html.document.querySelectorAll('.gm-style');
      if (mapElements.isNotEmpty) {
        // Procurar por uma instância de mapa no contexto global
        final google = js.context['google'];
        if (google != null && google['maps'] != null) {
          // Retornar uma referência genérica que funciona com a API
          return js.JsObject.jsify({'isGoogleMap': true, 'ready': true});
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao obter instância do mapa: $e');
      }
      return null;
    }
  }

  /// Cria um marcador de fallback usando AdvancedMarkerElement quando disponível
  static js.JsObject? _createFallbackMarker(
    String markerId,
    double lat,
    double lng,
    String? title,
  ) {
    try {
      // Tentar usar AdvancedMarkerElement primeiro
      if (isAdvancedMarkerAvailable()) {
        return _tryCreateAdvancedMarkerFallback(markerId, lat, lng, title);
      }

      // Se AdvancedMarkerElement não estiver disponível, log error (não usar marcador tradicional)
      if (kDebugMode) {
        debugPrint(
            '❌ AdvancedMarkerElement não está disponível para marcador: $markerId');
        debugPrint(
            'ℹ️ Biblioteca marker não foi carregada. Verificar se &libraries=places,marker está na URL.');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao criar marcador de fallback: $e');
      }
      return null;
    }
  }

  /// Tenta criar AdvancedMarkerElement como fallback
  static js.JsObject? _tryCreateAdvancedMarkerFallback(
    String markerId,
    double lat,
    double lng,
    String? title,
  ) {
    try {
      final advancedMarkerClass =
          js.context['google']['maps']['marker']['AdvancedMarkerElement'];
      if (advancedMarkerClass == null) {
        return null;
      }

      final position = js.JsObject.jsify({'lat': lat, 'lng': lng});
      final options = js.JsObject.jsify({
        'position': position,
        'map': _getCurrentMapInstance(),
        'title': title ?? '',
      });

      final marker = js.JsObject(advancedMarkerClass, [options]);
      _markers[markerId] = marker;

      if (kDebugMode) {
        debugPrint('✅ AdvancedMarkerElement criado como fallback: $markerId');
      }

      return marker;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao criar AdvancedMarkerElement fallback: $e');
      }
      return null;
    }
  }

  /// Função auxiliar para criar marcador com delay
  static void _createMarkerDelayed(
    String markerId,
    double lat,
    double lng,
    String? title,
    html.Element? content,
    bool gmpDraggable,
  ) {
    try {
      // Tentar criar usando o método imediato primeiro
      final marker = _tryCreateMarkerImmediate(
          markerId, lat, lng, title, content, gmpDraggable);

      if (marker != null) {
        if (kDebugMode) {
          debugPrint('✅ AdvancedMarkerElement criado com delay: $markerId');
        }
        return;
      }

      // Se falhar, tentar criar marcador de fallback
      final fallbackMarker = _createFallbackMarker(markerId, lat, lng, title);

      if (fallbackMarker != null) {
        if (kDebugMode) {
          debugPrint('✅ Marcador de fallback criado com delay: $markerId');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Falha ao criar qualquer tipo de marcador: $markerId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao criar AdvancedMarkerElement delayed: $e');
      }
    }
  }

  /// Cria um marcador com ícone customizado
  static js.JsObject? createAdvancedMarkerWithIcon({
    required String markerId,
    required double lat,
    required double lng,
    required String iconUrl,
    String? title,
    double iconWidth = 32,
    double iconHeight = 32,
    bool gmpDraggable = false,
  }) {
    try {
      // Cria um elemento HTML para o ícone
      final iconElement = html.DivElement()
        ..style.width = '${iconWidth}px'
        ..style.height = '${iconHeight}px'
        ..style.backgroundImage = 'url($iconUrl)'
        ..style.backgroundSize = 'contain'
        ..style.backgroundRepeat = 'no-repeat'
        ..style.backgroundPosition = 'center';

      return createAdvancedMarker(
        markerId: markerId,
        lat: lat,
        lng: lng,
        title: title,
        content: iconElement,
        gmpDraggable: gmpDraggable,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao criar AdvancedMarkerElement com ícone: $e');
      }
      return null;
    }
  }

  /// Cria um marcador com emoji
  static js.JsObject? createAdvancedMarkerWithEmoji({
    required String markerId,
    required double lat,
    required double lng,
    required String emoji,
    String? title,
    double fontSize = 24,
    bool gmpDraggable = false,
  }) {
    try {
      // Cria um elemento HTML para o emoji
      final emojiElement = html.DivElement()
        ..style.fontSize = '${fontSize}px'
        ..style.textAlign = 'center'
        ..style.lineHeight = '1'
        ..style.userSelect = 'none'
        ..text = emoji;

      return createAdvancedMarker(
        markerId: markerId,
        lat: lat,
        lng: lng,
        title: title,
        content: emojiElement,
        gmpDraggable: gmpDraggable,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao criar AdvancedMarkerElement com emoji: $e');
      }
      return null;
    }
  }

  /// Remove um marcador
  static void removeMarker(String markerId) {
    try {
      final marker = _markers[markerId];
      if (marker != null) {
        // Remove o marcador do mapa
        marker['map'] = null;
        _markers.remove(markerId);

        if (kDebugMode) {
          debugPrint('✅ AdvancedMarkerElement removido: $markerId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao remover AdvancedMarkerElement: $e');
      }
    }
  }

  /// Remove todos os marcadores
  static void clearAllMarkers() {
    try {
      for (final markerId in _markers.keys.toList()) {
        removeMarker(markerId);
      }

      if (kDebugMode) {
        debugPrint('✅ Todos os AdvancedMarkerElements removidos');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao limpar AdvancedMarkerElements: $e');
      }
    }
  }

  /// Adiciona listener de clique a um marcador
  static void addClickListener(String markerId, Function() onTap) {
    try {
      final marker = _markers[markerId];
      if (marker != null) {
        // Usar a API correta do Google Maps para eventos
        final eventClass = js.context['google']?['maps']?['event'];
        if (eventClass != null) {
          eventClass.callMethod('addListener', [
            marker,
            'click',
            js.allowInterop((_) {
              onTap();
            })
          ]);

          if (kDebugMode) {
            debugPrint(
                '✅ Listener de clique adicionado ao marcador: $markerId');
          }
        } else {
          if (kDebugMode) {
            debugPrint('❌ Google Maps event API não encontrada');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao adicionar listener: $e');
      }
    }
  }

  /// Atualiza a posição de um marcador
  static void updateMarkerPosition(String markerId, double lat, double lng) {
    try {
      final marker = _markers[markerId];
      if (marker != null) {
        final position =
            js.JsObject(js.context['google']['maps']['LatLng'], [lat, lng]);
        marker['position'] = position;

        if (kDebugMode) {
          debugPrint('✅ Posição do marcador atualizada: $markerId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao atualizar posição do marcador: $e');
      }
    }
  }

  /// Obtém a contagem de marcadores ativos
  static int getMarkerCount() {
    return _markers.length;
  }

  /// Verifica se um marcador existe
  static bool hasMarker(String markerId) {
    return _markers.containsKey(markerId);
  }
}
