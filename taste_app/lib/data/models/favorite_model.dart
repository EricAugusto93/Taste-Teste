import '../../domain/entities/favorite.dart';
import 'restaurant_model.dart';

/// Modelo de dados para favoritos
class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.restaurantId,
    required super.createdAt,
    super.rating,
    super.comment,
    super.reviewedAt,
    super.restaurant,
  });

  /// Criar FavoriteModel a partir de JSON
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      comment: json['comment'] as String?,
      reviewedAt: json['reviewed_at'] != null 
          ? DateTime.parse(json['reviewed_at'] as String) 
          : null,
      restaurant: json['restaurants'] != null 
          ? RestaurantModel.fromJson(json['restaurants'] as Map<String, dynamic>).toEntity()
          : null,
    );
  }

  /// Converter FavoriteModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'comment': comment,
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  /// Criar cópia com modificações
  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    DateTime? createdAt,
    double? rating,
    String? comment,
    DateTime? reviewedAt,
    dynamic restaurant,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      restaurant: restaurant is RestaurantModel ? restaurant.toEntity() : (restaurant ?? this.restaurant),
    );
  }

  @override
  String toString() {
    return 'FavoriteModel(id: $id, userId: $userId, restaurantId: $restaurantId, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is FavoriteModel &&
        other.id == id &&
        other.userId == userId &&
        other.restaurantId == restaurantId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ restaurantId.hashCode;
  }
}