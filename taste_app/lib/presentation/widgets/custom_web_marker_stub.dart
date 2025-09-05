import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'custom_web_marker.dart';

/// Stub implementation for non-web platforms
class CustomWebMarkerWeb {
  /// Initialize markers for non-web (no-op)
  static void initialize(dynamic map) {
    // No-op for non-web platforms
  }

  /// Create marker for non-web (returns null, uses regular gmaps.Marker)
  static dynamic createAdvancedMarker(CustomWebMarker marker, {dynamic map}) {
    return null; // Non-web platforms use regular gmaps.Marker
  }

  /// Remove marker for non-web (no-op)
  static void removeMarker(String markerId) {
    // No-op for non-web platforms
  }

  /// Update marker position for non-web (no-op)
  static void updateMarkerPosition(String markerId, gmaps.LatLng position) {
    // No-op for non-web platforms
  }

  /// Check if AdvancedMarkerElement is available (always false for non-web)
  static bool isAdvancedMarkerAvailable() {
    return false;
  }

  /// Clear all markers for non-web (no-op)
  static void clearAllMarkers() {
    // No-op for non-web platforms
  }
}