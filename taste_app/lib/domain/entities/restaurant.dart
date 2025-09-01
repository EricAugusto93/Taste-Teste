import 'package:equatable/equatable.dart';
import '../../data/models/restaurant_model.dart';

/// Entidade Restaurant do domínio
class Restaurant extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;
  final String categoryId;
  final double rating;
  final double? deliveryFee;
  final String? deliveryTime;
  final bool isOpen;
  final bool isFeatured;
  final String? imageUrl;
  final String? emoji;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Restaurant({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.rating,
    this.deliveryFee,
    this.deliveryTime,
    required this.isOpen,
    required this.isFeatured,
    this.imageUrl,
    this.emoji,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        phone,
        latitude,
        longitude,
        categoryId,
        rating,
        deliveryFee,
        deliveryTime,
        isOpen,
        isFeatured,
        imageUrl,
        emoji,
        createdAt,
        updatedAt,
      ];

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    String? categoryId,
    double? rating,
    double? deliveryFee,
    String? deliveryTime,
    bool? isOpen,
    bool? isFeatured,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isOpen: isOpen ?? this.isOpen,
      isFeatured: isFeatured ?? this.isFeatured,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte RestaurantModel para Restaurant entity
  static Restaurant fromModel(RestaurantModel model) {
    return Restaurant(
      id: model.id,
      name: model.name,
      description: model.description,
      address: model.address ?? '',
      phone: model.phone,
      latitude: model.latitude ?? 0.0,
      longitude: model.longitude ?? 0.0,
      categoryId: model.categoryId ?? '',
      rating: model.rating,
      deliveryFee: model.deliveryFee,
      deliveryTime: model.deliveryTime,
      isOpen: model.isOpen,
      isFeatured: model.isFeatured,
      imageUrl: model.imageUrl,
      emoji: model.emoji,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, rating: $rating, isOpen: $isOpen)';
  }
}