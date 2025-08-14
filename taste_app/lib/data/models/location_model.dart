import 'package:equatable/equatable.dart';

/// Modelo para representar uma localização geográfica
class LocationModel extends Equatable {
  /// Latitude da localização
  final double latitude;
  
  /// Longitude da localização
  final double longitude;
  
  /// Precisão da localização em metros
  final double? accuracy;
  
  /// Timestamp de quando a localização foi obtida
  final DateTime? timestamp;
  
  /// Nome ou descrição da localização (opcional)
  final String? name;
  
  /// Endereço formatado (opcional)
  final String? address;
  
  /// Cidade (opcional)
  final String? city;
  
  /// Estado/Província (opcional)
  final String? state;
  
  /// País (opcional)
  final String? country;
  
  /// CEP/Código postal (opcional)
  final String? postalCode;
  
  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
    this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });
  
  /// Cria uma instância a partir de um Map (JSON)
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      name: json['name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
    );
  }
  
  /// Converte para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postal_code': postalCode,
    };
  }
  
  /// Cria uma cópia com alguns campos alterados
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
    String? name,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }
  
  /// Retorna uma representação em string das coordenadas
  String get coordinates => '$latitude,$longitude';
  
  /// Retorna o endereço completo formatado
  String get fullAddress {
    final parts = <String>[];
    
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (country != null) parts.add(country!);
    if (postalCode != null) parts.add(postalCode!);
    
    return parts.join(', ');
  }
  
  /// Verifica se a localização é válida
  bool get isValid {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }
  
  /// Verifica se a localização tem informações de endereço
  bool get hasAddressInfo {
    return address != null || 
           city != null || 
           state != null || 
           country != null;
  }
  
  /// Verifica se a localização é recente (últimos 5 minutos)
  bool get isRecent {
    if (timestamp == null) return false;
    final now = DateTime.now();
    final difference = now.difference(timestamp!);
    return difference.inMinutes <= 5;
  }
  
  /// Verifica se a localização tem boa precisão (menos de 50 metros)
  bool get hasGoodAccuracy {
    return accuracy != null && accuracy! <= 50.0;
  }
  
  @override
  List<Object?> get props => [
    latitude,
    longitude,
    accuracy,
    timestamp,
    name,
    address,
    city,
    state,
    country,
    postalCode,
  ];
  
  @override
  String toString() {
    return 'LocationModel(lat: $latitude, lng: $longitude, name: $name)';
  }
}

/// Extensões úteis para LocationModel
extension LocationModelExtensions on LocationModel {
  /// Converte para formato Google Maps URL
  String toGoogleMapsUrl() {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }
  
  /// Converte para formato Apple Maps URL
  String toAppleMapsUrl() {
    return 'http://maps.apple.com/?q=$latitude,$longitude';
  }
  
  /// Converte para formato Waze URL
  String toWazeUrl() {
    return 'https://waze.com/ul?ll=$latitude,$longitude';
  }
}

/// Constantes para localizações especiais
class LocationConstants {
  /// Localização padrão (São Paulo, Brasil)
  static const LocationModel defaultLocation = LocationModel(
    latitude: -23.5505,
    longitude: -46.6333,
    name: 'São Paulo',
    city: 'São Paulo',
    state: 'SP',
    country: 'Brasil',
  );
  
  /// Raio padrão para busca de restaurantes (5km)
  static const double defaultSearchRadius = 5000.0;
  
  /// Raio máximo para busca de restaurantes (50km)
  static const double maxSearchRadius = 50000.0;
  
  /// Precisão mínima aceitável (100 metros)
  static const double minAcceptableAccuracy = 100.0;
}