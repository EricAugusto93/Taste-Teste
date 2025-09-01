import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/environment_config.dart';

/// Service to handle geocoding operations using Google Geocoding API
class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  /// Get coordinates from an address string
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final apiKey = EnvironmentConfig.googleMapsApiKey;
      if (apiKey.isEmpty) {
        debugPrint('❌ GeocodingService: Google Maps API key não configurada');
        return null;
      }

      final encodedAddress = Uri.encodeComponent(address);
      final url = '$_baseUrl?address=$encodedAddress&key=$apiKey';
      
      debugPrint('🌍 GeocodingService: Geocoding "$address"...');
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final lat = location['lat']?.toDouble();
          final lng = location['lng']?.toDouble();
          
          if (lat != null && lng != null) {
            debugPrint('✅ GeocodingService: Coordenadas obtidas: $lat, $lng');
            return {'latitude': lat, 'longitude': lng};
          }
        } else {
          debugPrint('⚠️ GeocodingService: Status ${data['status']} para "$address"');
        }
      } else {
        debugPrint('❌ GeocodingService: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ GeocodingService: Erro ao geocodificar "$address": $e');
    }
    
    return null;
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final apiKey = EnvironmentConfig.googleMapsApiKey;
      if (apiKey.isEmpty) {
        debugPrint('❌ GeocodingService: Google Maps API key não configurada');
        return null;
      }

      final url = '$_baseUrl?latlng=$latitude,$longitude&key=$apiKey';
      
      debugPrint('🏠 GeocodingService: Reverse geocoding $latitude, $longitude...');
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          final formattedAddress = data['results'][0]['formatted_address'];
          debugPrint('✅ GeocodingService: Endereço obtido: $formattedAddress');
          return formattedAddress;
        } else {
          debugPrint('⚠️ GeocodingService: Status ${data['status']} para coordenadas $latitude, $longitude');
        }
      } else {
        debugPrint('❌ GeocodingService: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ GeocodingService: Erro ao fazer reverse geocoding: $e');
    }
    
    return null;
  }
}