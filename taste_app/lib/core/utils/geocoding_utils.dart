import 'package:geocoding/geocoding.dart';
import '../../data/models/location_model.dart';
import '../../data/services/location_service.dart';
import 'logger.dart';

/// Utilitários para geocoding e geocoding reverso
class GeocodingUtils {
  GeocodingUtils._();

  /// Converte coordenadas em endereço (geocoding reverso)
  static Future<GeocodingResult?> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    String? localeIdentifier,
  }) async {
    try {
      Logger.info('Fazendo geocoding reverso', {
        'latitude': latitude,
        'longitude': longitude,
      });

      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: localeIdentifier,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        final result = GeocodingResult(
          address: _buildFullAddress(placemark),
          street: placemark.street,
          city: placemark.locality,
          state: placemark.administrativeArea,
          country: placemark.country,
          postalCode: placemark.postalCode,
          latitude: latitude,
          longitude: longitude,
        );

        Logger.info('Geocoding reverso concluído', {
          'address': result.address,
          'city': result.city,
        });

        return result;
      }

      Logger.warning('Nenhum resultado encontrado no geocoding reverso');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Erro no geocoding reverso', e, stackTrace);
      return null;
    }
  }

  /// Converte endereço em coordenadas (geocoding)
  static Future<List<GeocodingResult>> getCoordinatesFromAddress(
    String address, {
    String? localeIdentifier,
  }) async {
    try {
      Logger.info('Fazendo geocoding', {'address': address});

      final locations = await locationFromAddress(
        address,
        localeIdentifier: localeIdentifier,
      );

      final results = <GeocodingResult>[];

      for (final location in locations) {
        // Fazer geocoding reverso para obter detalhes do endereço
        final geocodingResult = await getAddressFromCoordinates(
          location.latitude,
          location.longitude,
          localeIdentifier: localeIdentifier,
        );

        if (geocodingResult != null) {
          results.add(geocodingResult);
        } else {
          // Fallback: criar resultado básico apenas com coordenadas
          results.add(GeocodingResult(
            address: address,
            latitude: location.latitude,
            longitude: location.longitude,
          ));
        }
      }

      Logger.info('Geocoding concluído', {'results': results.length});
      return results;
    } catch (e, stackTrace) {
      Logger.error('Erro no geocoding', e, stackTrace);
      return [];
    }
  }

  /// Busca endereços próximos a uma coordenada
  static Future<List<GeocodingResult>> findNearbyAddresses(
    double latitude,
    double longitude, {
    double radiusInMeters = 1000,
    int maxResults = 10,
  }) async {
    try {
      // Para buscar endereços próximos, fazemos geocoding reverso
      // em pontos ao redor da coordenada original
      final results = <GeocodingResult>[];
      
      // Ponto central
      final centerResult = await getAddressFromCoordinates(latitude, longitude);
      if (centerResult != null) {
        results.add(centerResult);
      }

      // Pontos ao redor (8 direções)
      final offsetInDegrees = radiusInMeters / 111320; // Aproximação
      final offsets = [
        [offsetInDegrees, 0], // Norte
        [offsetInDegrees, offsetInDegrees], // Nordeste
        [0, offsetInDegrees], // Leste
        [-offsetInDegrees, offsetInDegrees], // Sudeste
        [-offsetInDegrees, 0], // Sul
        [-offsetInDegrees, -offsetInDegrees], // Sudoeste
        [0, -offsetInDegrees], // Oeste
        [offsetInDegrees, -offsetInDegrees], // Noroeste
      ];

      for (final offset in offsets) {
        if (results.length >= maxResults) break;
        
        final nearbyResult = await getAddressFromCoordinates(
          latitude + offset[0],
          longitude + offset[1],
        );
        
        if (nearbyResult != null && 
            !results.any((r) => r.address == nearbyResult.address)) {
          results.add(nearbyResult);
        }
      }

      return results.take(maxResults).toList();
    } catch (e, stackTrace) {
      Logger.error('Erro ao buscar endereços próximos', e, stackTrace);
      return [];
    }
  }

  /// Valida se um endereço é válido fazendo geocoding
  static Future<bool> isValidAddress(String address) async {
    try {
      final results = await getCoordinatesFromAddress(address);
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Normaliza um endereço removendo caracteres especiais e formatando
  static String normalizeAddress(String address) {
    return address
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Remove espaços extras
        .replaceAll(RegExp(r'[^\w\s,.-]'), '') // Remove caracteres especiais
        .toLowerCase();
  }

  /// Extrai componentes do endereço de uma string
  static AddressComponents parseAddress(String address) {
    final normalized = normalizeAddress(address);
    final parts = normalized.split(',').map((e) => e.trim()).toList();
    
    String? street;
    String? city;
    String? state;
    String? country;
    String? postalCode;
    
    // Lógica simples de parsing (pode ser melhorada)
    if (parts.isNotEmpty) {
      street = parts[0];
    }
    if (parts.length > 1) {
      city = parts[1];
    }
    if (parts.length > 2) {
      state = parts[2];
    }
    if (parts.length > 3) {
      country = parts[3];
    }
    
    // Busca por CEP (formato brasileiro)
    final cepRegex = RegExp(r'\d{5}-?\d{3}');
    final cepMatch = cepRegex.firstMatch(address);
    if (cepMatch != null) {
      postalCode = cepMatch.group(0);
    }
    
    return AddressComponents(
      street: street,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
    );
  }

  /// Constrói endereço completo a partir de componentes
  static String buildAddress(AddressComponents components) {
    final parts = <String>[];
    
    if (components.street?.isNotEmpty == true) {
      parts.add(components.street!);
    }
    if (components.city?.isNotEmpty == true) {
      parts.add(components.city!);
    }
    if (components.state?.isNotEmpty == true) {
      parts.add(components.state!);
    }
    if (components.country?.isNotEmpty == true) {
      parts.add(components.country!);
    }
    
    return parts.join(', ');
  }

  /// Formata endereço para exibição brasileira
  static String formatBrazilianAddress(GeocodingResult result) {
    final parts = <String>[];
    
    if (result.street?.isNotEmpty == true) {
      parts.add(result.street!);
    }
    
    final cityState = <String>[];
    if (result.city?.isNotEmpty == true) {
      cityState.add(result.city!);
    }
    if (result.state?.isNotEmpty == true) {
      cityState.add(result.state!);
    }
    
    if (cityState.isNotEmpty) {
      parts.add(cityState.join(' - '));
    }
    
    if (result.postalCode?.isNotEmpty == true) {
      parts.add('CEP: ${result.postalCode}');
    }
    
    return parts.join('\n');
  }

  /// Calcula a qualidade/confiança de um resultado de geocoding
  static double calculateGeocodingQuality(GeocodingResult result) {
    double quality = 0.0;
    
    // Pontuação baseada na completude dos dados
    if (result.street?.isNotEmpty == true) quality += 0.3;
    if (result.city?.isNotEmpty == true) quality += 0.3;
    if (result.state?.isNotEmpty == true) quality += 0.2;
    if (result.country?.isNotEmpty == true) quality += 0.1;
    if (result.postalCode?.isNotEmpty == true) quality += 0.1;
    
    return quality;
  }

  /// Filtra resultados de geocoding por qualidade mínima
  static List<GeocodingResult> filterByQuality(
    List<GeocodingResult> results,
    double minQuality,
  ) {
    return results
        .where((result) => calculateGeocodingQuality(result) >= minQuality)
        .toList();
  }

  /// Constrói endereço completo a partir do placemark
  static String _buildFullAddress(Placemark placemark) {
    final parts = <String>[];

    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }
}

/// Classe para componentes de endereço
class AddressComponents {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  
  const AddressComponents({
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });
  
  @override
  String toString() {
    return 'AddressComponents(street: $street, city: $city, state: $state, country: $country, postalCode: $postalCode)';
  }
}

/// Extensões úteis para GeocodingResult
extension GeocodingResultExtensions on GeocodingResult {
  /// Converte para LocationModel
  LocationModel toLocationModel() {
    return LocationModel(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
    );
  }
  
  /// Verifica se o resultado é do Brasil
  bool get isBrazil {
    return country?.toLowerCase().contains('brasil') == true ||
           country?.toLowerCase().contains('brazil') == true;
  }
  
  /// Obtém endereço resumido (rua e cidade)
  String get shortAddress {
    final parts = <String>[];
    if (street?.isNotEmpty == true) parts.add(street!);
    if (city?.isNotEmpty == true) parts.add(city!);
    return parts.join(', ');
  }
  
  /// Obtém apenas a cidade e estado
  String get cityState {
    final parts = <String>[];
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
    return parts.join(', ');
  }
}