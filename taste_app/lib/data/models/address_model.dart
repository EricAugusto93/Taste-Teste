import 'package:equatable/equatable.dart';

/// Modelo de dados para endereços
class AddressModel extends Equatable {
  final String id;
  final String userId;
  final String label; // Casa, Trabalho, etc.
  final String type; // home, work, other
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String? reference;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.type,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.reference,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma cópia com novos valores
  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? type,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? reference,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      type: type ?? this.type,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      reference: reference ?? this.reference,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Cria um endereço vazio
  factory AddressModel.empty() {
    final now = DateTime.now();
    return AddressModel(
      id: '',
      userId: '',
      label: '',
      type: 'other',
      street: '',
      number: '',
      neighborhood: '',
      city: '',
      state: '',
      zipCode: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Cria um endereço a partir de JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zip_code'] as String,
      reference: json['reference'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'type': type,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'reference': reference,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Retorna o endereço completo formatado
  String get fullAddress {
    final parts = <String>[
      '$street, $number',
      if (complement != null && complement!.isNotEmpty) complement!,
      neighborhood,
      '$city - $state',
      'CEP: $zipCode',
    ];
    return parts.join(', ');
  }

  /// Retorna o endereço resumido
  String get shortAddress {
    return '$street, $number - $neighborhood';
  }

  /// Verifica se o endereço está completo
  bool get isComplete {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        label.isNotEmpty &&
        street.isNotEmpty &&
        number.isNotEmpty &&
        neighborhood.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        zipCode.isNotEmpty;
  }

  /// Verifica se tem coordenadas
  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        label,
        type,
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
        zipCode,
        reference,
        latitude,
        longitude,
        isDefault,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'AddressModel(id: $id, label: $label, fullAddress: $fullAddress)';
  }
}

/// Tipos de endereço predefinidos
class AddressType {
  static const String home = 'home';
  static const String work = 'work';
  static const String other = 'other';

  static const List<String> all = [home, work, other];

  static String getLabel(String type) {
    switch (type) {
      case home:
        return 'Casa';
      case work:
        return 'Trabalho';
      case other:
        return 'Outro';
      default:
        return 'Outro';
    }
  }
}