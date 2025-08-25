import 'package:equatable/equatable.dart';

/// Entidade Location do domínio
class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final double? accuracy;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.accuracy,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        city,
        state,
        country,
        accuracy,
      ];

  Location copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    double? accuracy,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  String toString() {
    return 'Location(lat: $latitude, lng: $longitude, address: $address)';
  }
}