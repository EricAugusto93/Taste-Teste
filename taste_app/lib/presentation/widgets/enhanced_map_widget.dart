import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../data/models/restaurant_model.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';
import 'reusable_map_view.dart';

/// Widget de mapa melhorado com marcadores customizados
/// Agora usa o ReusableMapView como base para maior reutilização
class EnhancedMapWidget extends StatelessWidget {
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

  const EnhancedMapWidget({
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
    this.enableClustering = true,
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
  Widget build(BuildContext context) {
    return ReusableMapView(
      userLocation: userLocation,
      restaurants: restaurants,
      onRestaurantTap: onRestaurantTap,
      onMapTap: onMapTap,
      onRestaurantFavorite: onRestaurantFavorite,
      onRestaurantDirections: onRestaurantDirections,
      height: height,
      showUserLocation: showUserLocation,
      enableInteraction: enableInteraction,
      initialPosition: initialPosition,
      zoom: zoom,
      showInfoWindows: showInfoWindows,
      selectedRestaurantId: selectedRestaurantId,
      locationRepository: locationRepository,
      enableClustering: enableClustering,
      showAdvancedMarkers: showAdvancedMarkers,
      showAdvancedInfoWindow: showAdvancedInfoWindow,
      compactInfoWindow: compactInfoWindow,
      animationDuration: animationDuration,
      showMapControls: showMapControls,
      showMyLocationButton: showMyLocationButton,
      showZoomControls: showZoomControls,
      mapType: mapType,
      polygons: polygons,
      polylines: polylines,
      circles: circles,
      padding: padding,
    );
  }
}