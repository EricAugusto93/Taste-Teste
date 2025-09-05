/// Stub implementation for non-web platforms
class AdvancedMarkerWeb {
  static void initializeMap(dynamic map) {
    // Stub implementation - não faz nada em plataformas não-web
  }
  
  static bool isAdvancedMarkerAvailable() {
    return false; // AdvancedMarkerElement só está disponível na web
  }
  
  static dynamic createAdvancedMarker({
    required String markerId,
    required double lat,
    required double lng,
    String? title,
    dynamic content,
    bool gmpDraggable = false,
  }) {
    return null; // Stub implementation
  }
  
  static dynamic createAdvancedMarkerWithIcon({
    required String markerId,
    required double lat,
    required double lng,
    required String iconUrl,
    String? title,
    double iconWidth = 32,
    double iconHeight = 32,
    bool gmpDraggable = false,
  }) {
    return null; // Stub implementation
  }
  
  static dynamic createAdvancedMarkerWithEmoji({
    required String markerId,
    required double lat,
    required double lng,
    required String emoji,
    String? title,
    double fontSize = 24,
    bool gmpDraggable = false,
  }) {
    return null; // Stub implementation
  }
  
  static void removeMarker(String markerId) {
    // Stub implementation
  }
  
  static void clearAllMarkers() {
    // Stub implementation
  }
  
  static void addClickListener(String markerId, Function() onTap) {
    // Stub implementation
  }
  
  static void updateMarkerPosition(String markerId, double lat, double lng) {
    // Stub implementation
  }
  
  static int getMarkerCount() {
    return 0; // Stub implementation
  }
  
  static bool hasMarker(String markerId) {
    return false; // Stub implementation
  }
}