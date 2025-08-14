import '../../data/models/restaurant_model.dart';

/// Modelo para representar uma avaliação de restaurante
class ReviewModel {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int helpfulCount;
  final bool isVerified;
  final List<ReviewReply> replies;
  final bool isHelpfulByCurrentUser;
  final bool isReportedByCurrentUser;
  final RestaurantModel? restaurant;

  const ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.helpfulCount = 0,
    this.isVerified = false,
    this.replies = const [],
    this.isHelpfulByCurrentUser = false,
    this.isReportedByCurrentUser = false,
    this.restaurant,
  });

  /// Cria uma instância de ReviewModel a partir de um Map (JSON)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((reply) => ReviewReply.fromJson(reply as Map<String, dynamic>))
          .toList(),
      isHelpfulByCurrentUser: json['is_helpful_by_current_user'] as bool? ?? false,
      isReportedByCurrentUser: json['is_reported_by_current_user'] as bool? ?? false,
      restaurant: json['restaurant'] != null
          ? RestaurantModel.fromJson(json['restaurant'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converte a instância para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'helpful_count': helpfulCount,
      'is_verified': isVerified,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'is_helpful_by_current_user': isHelpfulByCurrentUser,
      'is_reported_by_current_user': isReportedByCurrentUser,
      'restaurant': restaurant?.toJson(),
    };
  }

  /// Cria uma cópia da instância com alguns campos alterados
  ReviewModel copyWith({
    String? id,
    String? restaurantId,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? helpfulCount,
    bool? isVerified,
    List<ReviewReply>? replies,
    bool? isHelpfulByCurrentUser,
    bool? isReportedByCurrentUser,
    RestaurantModel? restaurant,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isVerified: isVerified ?? this.isVerified,
      replies: replies ?? this.replies,
      isHelpfulByCurrentUser: isHelpfulByCurrentUser ?? this.isHelpfulByCurrentUser,
      isReportedByCurrentUser: isReportedByCurrentUser ?? this.isReportedByCurrentUser,
      restaurant: restaurant ?? this.restaurant,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReviewModel(id: $id, restaurantId: $restaurantId, userId: $userId, userName: $userName, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt, helpfulCount: $helpfulCount, isVerified: $isVerified, replies: ${replies.length}, isHelpfulByCurrentUser: $isHelpfulByCurrentUser, isReportedByCurrentUser: $isReportedByCurrentUser)';
  }

  /// Verifica se a avaliação é recente (menos de 7 dias)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7;
  }

  /// Verifica se a avaliação tem uma boa nota (4 ou 5 estrelas)
  bool get isPositive => rating >= 4;

  /// Verifica se a avaliação tem uma nota ruim (1 ou 2 estrelas)
  bool get isNegative => rating <= 2;

  /// Verifica se a avaliação tem comentário
  bool get hasComment => comment?.trim().isNotEmpty ?? false;
}

/// Modelo para respostas a avaliações
class ReviewReply {
  final String id;
  final String reviewId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final bool isRestaurantOwner;

  const ReviewReply({
    required this.id,
    required this.reviewId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.isRestaurantOwner = false,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id'] as String,
      reviewId: json['review_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRestaurantOwner: json['is_restaurant_owner'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review_id': reviewId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_restaurant_owner': isRestaurantOwner,
    };
  }

  ReviewReply copyWith({
    String? id,
    String? reviewId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    DateTime? createdAt,
    bool? isRestaurantOwner,
  }) {
    return ReviewReply(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRestaurantOwner: isRestaurantOwner ?? this.isRestaurantOwner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewReply && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReviewReply(id: $id, reviewId: $reviewId, userId: $userId, userName: $userName, content: $content, createdAt: $createdAt, isRestaurantOwner: $isRestaurantOwner)';
  }
}

/// Classe para estatísticas de avaliações
class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      ratingDistribution: Map<int, int>.from(json['rating_distribution'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_distribution': ratingDistribution,
    };
  }

  /// Calcula a porcentagem de cada rating
  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }

  /// Verifica se há avaliações suficientes para mostrar estatísticas
  bool get hasEnoughReviews => totalReviews >= 5;

  /// Obtém a classificação textual baseada na média
  String get ratingText {
    if (averageRating >= 4.5) return 'Excelente';
    if (averageRating >= 4.0) return 'Muito Bom';
    if (averageRating >= 3.5) return 'Bom';
    if (averageRating >= 3.0) return 'Regular';
    return 'Ruim';
  }
}