import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../data/models/restaurant_model.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/logger.dart';
import 'advanced_map_marker.dart';
import 'custom_web_marker.dart';
// import 'advanced_info_window.dart';
import 'map_cluster_widget.dart';

/// Componente de mapa reutilizável com recursos avançados
class ReusableMapView extends StatefulWidget {
  final LocationModel? userLocation;
  final List<RestaurantModel> restaurants;
  final Function(RestaurantModel)? onRestaurantTap;
  final Function(gmaps.LatLng)? onMapTap;
  final Function(RestaurantModel)? onRestaurantFavorite;
  final Function(RestaurantModel)? onRestaurantDirections;
  final double height;
  final bool showUserLocation;
  final bool enableInteraction;
  final gmaps.CameraPosition? initialPosition;
  final double zoom;
  final bool showInfoWindows;
  final String? selectedRestaurantId;
  final LocationRepository? locationRepository;
  final bool enableClustering;
  final bool showAdvancedMarkers;
  final bool showAdvancedInfoWindow;
  final bool compactInfoWindow;
  final Duration animationDuration;
  final bool showMapControls;
  final bool showMyLocationButton;
  final bool showZoomControls;
  final gmaps.MapType mapType;
  final Set<gmaps.Polygon>? polygons;
  final Set<gmaps.Polyline>? polylines;
  final Set<gmaps.Circle>? circles;
  final EdgeInsets padding;

  const ReusableMapView({
    super.key,
    this.userLocation,
    this.restaurants = const [],
    this.onRestaurantTap,
    this.onMapTap,
    this.onRestaurantFavorite,
    this.onRestaurantDirections,
    this.height = 300,
    this.showUserLocation = true,
    this.enableInteraction = true,
    this.initialPosition,
    this.zoom = 14.0,
    this.showInfoWindows = true,
    this.selectedRestaurantId,
    this.locationRepository,
    this.enableClustering = false,
    this.showAdvancedMarkers = true,
    this.showAdvancedInfoWindow = true,
    this.compactInfoWindow = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showMapControls = true,
    this.showMyLocationButton = true,
    this.showZoomControls = true,
    this.mapType = gmaps.MapType.normal,
    this.polygons,
    this.polylines,
    this.circles,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<ReusableMapView> createState() => _ReusableMapViewState();
}

class _ReusableMapViewState extends State<ReusableMapView>
    with TickerProviderStateMixin {
  gmaps.GoogleMapController? _controller;
  Set<gmaps.Marker> _markers = {};
  bool _isLoading = true;
  String? _selectedMarkerId;
  // InfoWindowOverlay? _activeInfoWindow;
  final GlobalKey _mapKey = GlobalKey();
  late AnimationController _markerAnimationController;
  late AnimationController _userLocationAnimationController;
  Map<String, String> _restaurantDistances = {};
  Timer? _distanceUpdateTimer;
  Timer? _debounceTimer;
  Timer? _animationTimer;
  List<RestaurantCluster> _clusters = [];
  List<RestaurantModel> _unclusteredRestaurants = [];
  double _currentZoom = 14.0;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _selectedMarkerId = widget.selectedRestaurantId;
    _setupAnimations();
    // NÃO criar marcadores no initState - aguardar o mapa estar pronto
    _startDistanceUpdates();
    _startAnimationLoop();
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    _userLocationAnimationController.dispose();
    _distanceUpdateTimer?.cancel();
    _debounceTimer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }

  void _setupAnimations() {
    _markerAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _userLocationAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  void _startAnimationLoop() {
    // Removido loop infinito de animação que consumia recursos desnecessariamente
    // As animações agora são executadas apenas quando necessário
    if (mounted) {
      _userLocationAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(ReusableMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurants != widget.restaurants ||
        oldWidget.userLocation != widget.userLocation ||
        oldWidget.selectedRestaurantId != widget.selectedRestaurantId) {
      _selectedMarkerId = widget.selectedRestaurantId;
      _hideInfoWindow();
      _createMarkers();
    }
  }

  /// Iniciar atualizações periódicas de distância
  void _startDistanceUpdates() {
    // Otimizado: apenas atualiza distâncias uma vez na inicialização
    // Timer periódico removido para melhor performance
    if (widget.locationRepository == null || widget.userLocation == null) return;
    
    _updateDistances();
  }

  /// Atualizar distâncias dos restaurantes
  Future<void> _updateDistances() async {
    if (widget.locationRepository == null || widget.userLocation == null) {
      return;
    }

    try {
      final distances = <String, String>{};
      
      for (final restaurant in widget.restaurants) {
        if (restaurant.latitude != null && restaurant.longitude != null) {
          final distance = widget.locationRepository!.calculateDistanceInMeters(
            widget.userLocation!,
            LocationModel(
              latitude: restaurant.latitude!,
              longitude: restaurant.longitude!,
            ),
          );
          
          distances[restaurant.id] = widget.locationRepository!
              .formatDistanceForDisplay(distance);
        }
      }
      
      if (mounted) {
        setState(() {
          _restaurantDistances = distances;
        });
      }
    } catch (e) {
      Logger.error('Erro ao calcular distâncias: $e');
    }
  }

  /// Mostrar InfoWindow avançada
  void _showAdvancedInfoWindow(RestaurantModel restaurant, Offset position) {
    if (!widget.showAdvancedInfoWindow) return;
    
    _hideInfoWindow();
    
    // Comentado temporariamente até implementar InfoWindowOverlay
    // setState(() {
    //   _activeInfoWindow = InfoWindowOverlay(
    //     restaurant: restaurant,
    //     distance: _restaurantDistances[restaurant.id],
    //     position: position,
    //     compact: widget.compactInfoWindow,
    //     onTap: () {
    //       _hideInfoWindow();
    //       widget.onRestaurantTap?.call(restaurant);
    //     },
    //     onClose: _hideInfoWindow,
    //     onFavorite: () {
    //       widget.onRestaurantFavorite?.call(restaurant);
    //     },
    //     onDirections: () {
    //       widget.onRestaurantDirections?.call(restaurant);
    //     },
    //   );
    // });
  }

  /// Esconder InfoWindow
  void _hideInfoWindow() {
    // Comentado temporariamente até implementar InfoWindowOverlay
    // if (_activeInfoWindow != null) {
    //   setState(() {
    //     _activeInfoWindow = null;
    //   });
    // }
  }

  /// Converter coordenadas do mapa para posição na tela
  Future<Offset?> _getScreenPosition(gmaps.LatLng latLng) async {
    if (_controller == null || !_isMapReady) return null;
    
    try {
      final screenCoordinate = await _controller!.getScreenCoordinate(latLng);
      return Offset(screenCoordinate.x.toDouble(), screenCoordinate.y.toDouble());
    } catch (e) {
      Logger.error('Erro ao obter posição na tela: $e');
      return null;
    }
  }

  Future<void> _createMarkers() async {
    // Verificar se o mapa está pronto antes de tentar criar marcadores
    if (!_isMapReady || _controller == null || !mounted) {
      Logger.warning('Mapa não está pronto para criar marcadores');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    final customMarkers = <CustomWebMarker>[];

    try {
      // Criar marcador do usuário (otimizado para web)
      if (widget.showUserLocation && widget.userLocation != null) {
        // Usa marcador sem animação para melhor performance na web
        final userMarkerIcon = await AdvancedMapMarker.createAnimatedUserMarker(
          size: 60,  // Tamanho menor para melhor performance
          animationValue: 0.0,  // Sem animação
        );
        
        final userMarker = CustomWebMarkerUtils.createUserLocationMarker(
          lat: widget.userLocation!.latitude,
          lng: widget.userLocation!.longitude,
          customIcon: gmaps.BitmapDescriptor.fromBytes(userMarkerIcon),
        );
        
        customMarkers.add(userMarker);
      }

      // Processar clustering se habilitado
      if (widget.enableClustering && widget.restaurants.length > 5) {
        await _createClusteredMarkers(customMarkers);
      } else {
        await _createIndividualMarkers(customMarkers);
      }

      // Converter CustomWebMarkers para platform-specific markers
      final result = CustomWebMarkerUtils.convertMarkersForPlatform(customMarkers);

      if (mounted) {
        setState(() {
          _markers = result.markers;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Erro ao criar marcadores: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Criar marcadores com clustering
  Future<void> _createClusteredMarkers(List<CustomWebMarker> markers) async {
    _clusters = MapClusterManager.createClusters(
      widget.restaurants,
      clusterRadius: 120.0,
      minClusterSize: 2,
      zoomLevel: _currentZoom,
    );
    
    _unclusteredRestaurants = widget.restaurants
        .where((restaurant) => !_clusters.any(
            (cluster) => cluster.restaurants.contains(restaurant)))
        .toList();

    // Criar marcadores de cluster
    for (final cluster in _clusters) {
      final clusterIcon = await AdvancedMapMarker.createPremiumClusterMarker(
        count: cluster.restaurants.length,
        size: _getClusterSize(cluster.restaurants.length),
        animationValue: _markerAnimationController.value,
      );

      final clusterMarker = CustomWebMarkerUtils.createClusterMarker(
        id: cluster.id,
        lat: cluster.center.latitude,
        lng: cluster.center.longitude,
        count: cluster.restaurants.length,
        customIcon: gmaps.BitmapDescriptor.fromBytes(clusterIcon),
        onTap: () => _onClusterTap(cluster),
      );
      
      markers.add(clusterMarker);
    }

    // Criar marcadores individuais
    for (final restaurant in _unclusteredRestaurants) {
      await _createRestaurantMarker(restaurant, markers);
    }
  }

  /// Criar marcadores individuais
  Future<void> _createIndividualMarkers(List<CustomWebMarker> markers) async {
    for (final restaurant in widget.restaurants) {
      await _createRestaurantMarker(restaurant, markers);
    }
  }

  /// Criar marcador individual de restaurante
  Future<void> _createRestaurantMarker(
    RestaurantModel restaurant,
    List<CustomWebMarker> markers,
  ) async {
    if (restaurant.latitude == null || restaurant.longitude == null) return;

    final isSelected = _selectedMarkerId == restaurant.id;
    
    final markerIcon = widget.showAdvancedMarkers
        ? await AdvancedMapMarker.createEmojiMarker(
            emoji: restaurant.emoji ?? '🍽️',
            isSelected: isSelected,
            size: isSelected ? 95 : 85,
            animationValue: isSelected ? _markerAnimationController.value : 0.0,
            showRating: true,
            rating: restaurant.rating,
          )
        : await AdvancedMapMarker.createEmojiMarker(
            emoji: restaurant.emoji ?? '🍽️',
            isSelected: isSelected,
            size: 80,
            showRating: true,
            rating: restaurant.rating,
          );

    final restaurantMarker = CustomWebMarkerUtils.createRestaurantMarker(
      id: restaurant.id,
      lat: restaurant.latitude!,
      lng: restaurant.longitude!,
      name: restaurant.name,
      emoji: restaurant.emoji,
      rating: restaurant.rating.toStringAsFixed(1),
      deliveryTime: '${restaurant.deliveryTime} min',
      customIcon: gmaps.BitmapDescriptor.fromBytes(markerIcon),
      onTap: () async => await _onMarkerTap(restaurant),
    );
    
    markers.add(restaurantMarker);
  }

  /// Lidar com toque em marcador
  Future<void> _onMarkerTap(RestaurantModel restaurant) async {
    if (!mounted || !_isMapReady) return;
    
    _markerAnimationController.forward();
    
    setState(() {
      _selectedMarkerId = restaurant.id;
    });

    // Mostrar InfoWindow avançada se habilitada
    if (widget.showAdvancedInfoWindow) {
      final position = await _getScreenPosition(
        gmaps.LatLng(restaurant.latitude!, restaurant.longitude!),
      );
      
      if (position != null) {
        _showAdvancedInfoWindow(restaurant, position);
      }
    }

    // Animar câmera para o marcador com animação suave
    if (_controller != null && mounted) {
      await _animateCameraToPosition(
        gmaps.LatLng(restaurant.latitude!, restaurant.longitude!),
        _currentZoom + 1.5,
        duration: const Duration(milliseconds: 800),
      );
    }
  }

  /// Lidar com toque em cluster
  Future<void> _onClusterTap(RestaurantCluster cluster) async {
    if (_controller == null || !_isMapReady || !mounted) return;

    final bounds = _calculateClusterBounds(cluster);
    if (bounds != null) {
      await _animateCameraToBounds(
        bounds,
        padding: 120.0,
        duration: const Duration(milliseconds: 1000),
      );
    }
  }

  /// Calcular bounds de um cluster
  gmaps.LatLngBounds? _calculateClusterBounds(RestaurantCluster cluster) {
    final locations = <gmaps.LatLng>[];

    for (final restaurant in cluster.restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        locations.add(
          gmaps.LatLng(restaurant.latitude!, restaurant.longitude!),
        );
      }
    }

    if (locations.isEmpty) return null;
    if (locations.length == 1) {
      final point = locations.first;
      return gmaps.LatLngBounds(
        southwest: gmaps.LatLng(point.latitude - 0.005, point.longitude - 0.005),
        northeast: gmaps.LatLng(point.latitude + 0.005, point.longitude + 0.005),
      );
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final location in locations) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }

    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(minLat, minLng),
      northeast: gmaps.LatLng(maxLat, maxLng),
    );
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    _controller = controller;
    
    // Aguarda mais tempo para garantir que o mapa esteja completamente inicializado
    // especialmente importante no Flutter Web
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _controller != null) {
        setState(() {
          _isMapReady = true;
        });
        
        // Aguarda mais um pouco antes de criar marcadores
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _isMapReady) {
            _createMarkers();
            
            // Ajustar câmera para mostrar todos os marcadores
            if (widget.restaurants.isNotEmpty || widget.userLocation != null) {
              _fitMarkersInView();
            }
          }
        });
      }
    });
  }

  /// Ajustar câmera para mostrar todos os marcadores com animação suave
  Future<void> _fitMarkersInView() async {
    if (_controller == null || !_isMapReady || !mounted) return;

    final bounds = _calculateBounds();
    if (bounds != null) {
      await _animateCameraToBounds(
        bounds,
        padding: 120.0,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  gmaps.LatLngBounds? _calculateBounds() {
    final locations = <gmaps.LatLng>[];

    // Adicionar localização do usuário
    if (widget.userLocation != null) {
      locations.add(
        gmaps.LatLng(
          widget.userLocation!.latitude,
          widget.userLocation!.longitude,
        ),
      );
    }

    // Adicionar restaurantes
    for (final restaurant in widget.restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        locations.add(
          gmaps.LatLng(restaurant.latitude!, restaurant.longitude!),
        );
      }
    }

    if (locations.isEmpty) return null;
    if (locations.length == 1) {
      final point = locations.first;
      return gmaps.LatLngBounds(
        southwest: gmaps.LatLng(point.latitude - 0.01, point.longitude - 0.01),
        northeast: gmaps.LatLng(point.latitude + 0.01, point.longitude + 0.01),
      );
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final location in locations) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }

    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(minLat, minLng),
      northeast: gmaps.LatLng(maxLat, maxLng),
    );
  }

  void _onCameraMove(gmaps.CameraPosition position) {
    _currentZoom = position.zoom;
    
    // Debounce para evitar muitas atualizações
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (widget.enableClustering) {
        _createMarkers();
      }
    });
  }

  void _onCameraIdle() {
    // Comentado temporariamente até implementar InfoWindowOverlay
    // // Atualizar InfoWindow se necessário
    // if (_activeInfoWindow != null && _selectedMarkerId != null) {
    //   final restaurant = widget.restaurants.firstWhere(
    //     (r) => r.id == _selectedMarkerId,
    //     orElse: () => widget.restaurants.first,
    //   );
    //   
    //   if (restaurant.latitude != null && restaurant.longitude != null) {
    //     _getScreenPosition(
    //       gmaps.LatLng(restaurant.latitude!, restaurant.longitude!),
    //     ).then((position) {
    //       if (position != null && mounted) {
    //         setState(() {
    //           _activeInfoWindow = InfoWindowOverlay(
    //             restaurant: restaurant,
    //             distance: _restaurantDistances[restaurant.id],
    //             position: position,
    //             compact: widget.compactInfoWindow,
    //             onTap: () {
    //               _hideInfoWindow();
    //               widget.onRestaurantTap?.call(restaurant);
    //             },
    //             onClose: _hideInfoWindow,
    //             onFavorite: () {
    //               widget.onRestaurantFavorite?.call(restaurant);
    //             },
    //             onDirections: () {
    //               widget.onRestaurantDirections?.call(restaurant);
    //             },
    //           );
    //         });
    //       }
    //     });
    //   }
    // }
  }

  double _getClusterSize(int count) {
    if (count >= 50) return 100;
    if (count >= 20) return 90;
    if (count >= 10) return 80;
    return 70;
  }

  gmaps.CameraPosition get _initialCameraPosition {
    if (widget.initialPosition != null) {
      return widget.initialPosition!;
    }

    if (widget.userLocation != null) {
      return gmaps.CameraPosition(
        target: gmaps.LatLng(
          widget.userLocation!.latitude,
          widget.userLocation!.longitude,
        ),
        zoom: widget.zoom,
      );
    }

    // Posição padrão (São Paulo)
    return gmaps.CameraPosition(
      target: const gmaps.LatLng(-23.5505, -46.6333),
      zoom: widget.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Stack(
          children: [
            // Mapa principal (sempre visível)
            gmaps.GoogleMap(
              key: _mapKey,
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              polygons: widget.polygons ?? {},
              polylines: widget.polylines ?? {},
              circles: widget.circles ?? {},
              onMapCreated: _onMapCreated,
              onTap: (latLng) {
                _hideInfoWindow();
                widget.onMapTap?.call(latLng);
              },
              myLocationEnabled: false, // Usamos marcador customizado
              myLocationButtonEnabled: false,
              zoomControlsEnabled: widget.showZoomControls,
              mapToolbarEnabled: widget.showMapControls,
              compassEnabled: widget.showMapControls,
              rotateGesturesEnabled: widget.enableInteraction,
              scrollGesturesEnabled: widget.enableInteraction,
              tiltGesturesEnabled: widget.enableInteraction,
              zoomGesturesEnabled: widget.enableInteraction,
              mapType: widget.mapType,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              padding: widget.padding,
            ),
            
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            
            // InfoWindow personalizada - comentado temporariamente
            // if (_activeInfoWindow != null)
            //   _activeInfoWindow!.build(context),
            
            // Botão de localização personalizado
            if (widget.showMyLocationButton)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  onPressed: _goToUserLocation,
                  child: Icon(Icons.my_location),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Ir para localização do usuário com animação suave
  Future<void> _goToUserLocation() async {
    if (widget.userLocation != null && _controller != null) {
      await _animateCameraToPosition(
        gmaps.LatLng(
          widget.userLocation!.latitude,
          widget.userLocation!.longitude,
        ),
        16.0,
        duration: const Duration(milliseconds: 1200),
      );
    }
  }

  /// Animar câmera para uma posição específica com ease-in-out
  Future<void> _animateCameraToPosition(
    gmaps.LatLng target,
    double zoom, {
    Duration duration = const Duration(milliseconds: 800),
  }) async {
    // Verificações robustas para evitar erro do Google Maps
    if (_controller == null || !_isMapReady || !mounted) {
      Logger.warning('⚠️ Mapa não está pronto para animação de posição');
      return;
    }

    try {
      // Aguardar um pequeno delay para garantir estabilidade
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Verificar novamente se ainda está válido
      if (_controller == null || !mounted) return;

      // Usar animação customizada com múltiplos steps para efeito ease-in-out
      final currentPosition = await _controller!.getVisibleRegion();
      final currentCenter = gmaps.LatLng(
        (currentPosition.northeast.latitude + currentPosition.southwest.latitude) / 2,
        (currentPosition.northeast.longitude + currentPosition.southwest.longitude) / 2,
      );
      
      final steps = 20;
      final stepDuration = Duration(milliseconds: duration.inMilliseconds ~/ steps);
      
      for (int i = 1; i <= steps; i++) {
        // Verificar se ainda está montado a cada step
        if (!mounted || _controller == null) break;
        
        final progress = i / steps;
        // Aplicar ease-in-out usando função cúbica
        final easedProgress = _easeInOutCubic(progress);
        
        final interpolatedLat = currentCenter.latitude + 
            (target.latitude - currentCenter.latitude) * easedProgress;
        final interpolatedLng = currentCenter.longitude + 
            (target.longitude - currentCenter.longitude) * easedProgress;
        final interpolatedZoom = _currentZoom + 
            (zoom - _currentZoom) * easedProgress;
        
        try {
          await _controller!.animateCamera(
            gmaps.CameraUpdate.newLatLngZoom(
              gmaps.LatLng(interpolatedLat, interpolatedLng),
              interpolatedZoom,
            ),
          );
        } catch (stepError) {
          Logger.warning('Erro em step de animação: $stepError');
          break; // Parar a animação em caso de erro
        }
        
        if (i < steps) {
          await Future.delayed(stepDuration);
        }
      }
    } catch (e) {
      Logger.error('Erro na animação da câmera: $e');
      
      try {
        // Fallback mais seguro
        if (_controller != null && mounted) {
          await _controller!.animateCamera(
            gmaps.CameraUpdate.newLatLngZoom(target, zoom),
          );
        }
      } catch (fallbackError) {
        Logger.error('Erro também no fallback de posição: $fallbackError');
        // Ignorar silenciosamente
      }
    }
  }

  /// Animar câmera para bounds com ease-in-out
  Future<void> _animateCameraToBounds(
    gmaps.LatLngBounds bounds, {
    double padding = 100.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) async {
    // Verificações mais robustas para evitar erro do Google Maps
    if (_controller == null || !_isMapReady || !mounted) {
      Logger.warning('⚠️ Mapa não está pronto para animação de câmera');
      return;
    }

    try {
      // Aguardar um frame adicional para garantir que o mapa está totalmente inicializado
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verificar novamente se o controller ainda está válido
      if (_controller == null || !mounted) return;

      // Para Flutter Web, usar newLatLngBounds é mais estável que animação customizada
      await _controller!.animateCamera(
        gmaps.CameraUpdate.newLatLngBounds(bounds, padding),
      );
    } catch (e) {
      Logger.error('Erro na animação para bounds: $e');
      
      // Fallback: calcular centro e zoom manualmente
      try {
        if (_controller != null && mounted) {
          final center = gmaps.LatLng(
            (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
          );
          
          // Estimar zoom baseado na distância dos bounds
          final latDiff = (bounds.northeast.latitude - bounds.southwest.latitude).abs();
          final lngDiff = (bounds.northeast.longitude - bounds.southwest.longitude).abs();
          final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
          
          double targetZoom;
          if (maxDiff > 0.1) {
            targetZoom = 10.0;
          } else if (maxDiff > 0.05) {
            targetZoom = 12.0;
          } else if (maxDiff > 0.01) {
            targetZoom = 14.0;
          } else {
            targetZoom = 16.0;
          }
          
          // Usar newLatLngZoom como fallback mais seguro
          await _controller!.animateCamera(
            gmaps.CameraUpdate.newLatLngZoom(center, targetZoom),
          );
        }
      } catch (fallbackError) {
        Logger.error('Erro também no fallback de animação: $fallbackError');
        // Ignorar silenciosamente - o mapa ficará na posição atual
      }
    }
  }

  /// Função ease-in-out cúbica para animações suaves
  double _easeInOutCubic(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      final f = 2 * t - 2;
      return 1 + f * f * f / 2;
    }
  }
}