import 'package:equatable/equatable.dart';
import 'restaurant.dart';

/// Entidade de favorito
class Favorite extends Equatable {
  final String id;
  final String userId;
  final String restaurantId;
  final DateTime createdAt;
  final double? rating;
  final String? comment;
  final DateTime? reviewedAt;
  final Restaurant? restaurant;

  const Favorite({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.createdAt,
    this.rating,
    this.comment,
    this.reviewedAt,
    this.restaurant,
  });

  /// Verificar se tem avaliação
  bool get hasReview => rating != null;

  /// Verificar se foi avaliado recentemente (últimas 24h)
  bool get isRecentReview {
    if (reviewedAt == null) return false;
    return DateTime.now().difference(reviewedAt!).inHours < 24;
  }

  /// Obter texto da avaliação formatado
  String get ratingText {
    if (rating == null) return 'Sem avaliação';
    return '${rating!.toStringAsFixed(1)} estrelas';
  }

  /// Obter emoji baseado na avaliação
  String get ratingEmoji {
    if (rating == null) return '⭐';
    if (rating! >= 4.5) return '🌟';
    if (rating! >= 4.0) return '⭐';
    if (rating! >= 3.0) return '🙂';
    if (rating! >= 2.0) return '😐';
    return '😞';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        restaurantId,
        createdAt,
        rating,
        comment,
        reviewedAt,
        restaurant,
      ];
}