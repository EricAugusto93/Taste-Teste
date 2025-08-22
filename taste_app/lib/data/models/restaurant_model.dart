import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant.dart';

/// Modelo de dados para restaurante
class RestaurantModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final String deliveryTime;
  final double deliveryFee;
  final double? minOrderValue;
  final double? distance;
  final bool hasPromotion;
  final String? priceRange;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? phone;
  final bool isOpen;
  final bool isFeatured;
  final String? emoji;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RestaurantModel({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.imageUrl,
    required this.rating,
    this.reviewCount = 0,
    this.category = '',
    required this.deliveryTime,
    required this.deliveryFee,
    this.minOrderValue,
    this.distance,
    this.hasPromotion = false,
    this.priceRange,
    this.latitude,
    this.longitude,
    this.address,
    this.phone,
    required this.isOpen,
    required this.isFeatured,
    this.emoji,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância a partir de um Map (JSON)
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      deliveryTime: json['delivery_time'] as String? ?? '30-45 min',
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (json['min_order_value'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      hasPromotion: json['has_promotion'] as bool? ?? false,
      priceRange: json['price_range'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isOpen: json['is_open'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      emoji: json['emoji'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Cria uma instância a partir de dados do Supabase
  factory RestaurantModel.fromSupabase(Map<String, dynamic> data) {
    return RestaurantModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString(),
      categoryId: data['category_id']?.toString(),
      imageUrl: data['image_url']?.toString(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['review_count'] as int? ?? 0,
      category: data['category']?.toString() ?? '', // Para joins com tabela categories
      deliveryTime: data['delivery_time']?.toString() ?? '30-45 min',
      deliveryFee: (data['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (data['min_order_value'] as num?)?.toDouble(),
      distance: (data['distance'] as num?)?.toDouble(),
      hasPromotion: data['has_promotion'] as bool? ?? false,
      priceRange: data['price_range']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      address: data['address']?.toString(),
      phone: data['phone']?.toString(),
      isOpen: data['is_open'] as bool? ?? true,
      isFeatured: data['is_featured'] as bool? ?? false,
      emoji: data['emoji']?.toString(),
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'].toString())
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at'].toString())
          : DateTime.now(),
    );
  }

  /// Converte para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'category': category,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'min_order_value': minOrderValue,
      'distance': distance,
      'has_promotion': hasPromotion,
      'price_range': priceRange,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'is_open': isOpen,
      'is_featured': isFeatured,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia com valores alterados
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? category,
    String? deliveryTime,
    double? deliveryFee,
    double? minOrderValue,
    double? distance,
    bool? hasPromotion,
    String? priceRange,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    bool? isOpen,
    bool? isFeatured,
    String? emoji,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      distance: distance ?? this.distance,
      hasPromotion: hasPromotion ?? this.hasPromotion,
      priceRange: priceRange ?? this.priceRange,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      isFeatured: isFeatured ?? this.isFeatured,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        categoryId,
        imageUrl,
        rating,
        reviewCount,
        category,
        deliveryTime,
        deliveryFee,
        minOrderValue,
        distance,
        hasPromotion,
        priceRange,
        latitude,
        longitude,
        address,
        phone,
        isOpen,
        isFeatured,
        emoji,
        createdAt,
        updatedAt,
      ];

  /// Cria uma instância a partir de uma entidade de domínio
  factory RestaurantModel.fromEntity(Restaurant entity) {
    return RestaurantModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      categoryId: entity.categoryId,
      imageUrl: entity.imageUrl,
      rating: entity.rating,
      reviewCount: 0, // Valor padrão
      category: '', // Valor padrão
      deliveryTime: entity.deliveryTime ?? '30-45 min',
      deliveryFee: entity.deliveryFee ?? 0.0,
      minOrderValue: null,
      distance: null,
      hasPromotion: false,
      priceRange: null,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      phone: entity.phone,
      isOpen: entity.isOpen,
      isFeatured: entity.isFeatured,
      emoji: null, // Valor padrão para entidade
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converte para entidade de domínio
  Restaurant toEntity() {
    return Restaurant(
      id: id,
      name: name,
      description: description,
      address: address ?? '',
      phone: phone,
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      categoryId: categoryId ?? '',
      rating: rating,
      deliveryFee: deliveryFee,
      deliveryTime: deliveryTime,
      isOpen: isOpen,
      isFeatured: isFeatured,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'RestaurantModel(id: $id, name: $name, rating: $rating, isOpen: $isOpen)';
  }
}