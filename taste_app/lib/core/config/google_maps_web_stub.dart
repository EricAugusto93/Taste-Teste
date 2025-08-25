import 'package:flutter/foundation.dart';

/// Stub implementation for non-web platforms
Future<void> initializeGoogleMaps(String apiKey) async {
  if (kDebugMode) {
    debugPrint('Google Maps initialization skipped (non-web platform)');
  }
}

bool isGoogleMapsAvailable() {
  return true; // Assume available on mobile platforms
}