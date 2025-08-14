import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Enum para definir o tamanho do widget de avaliação
enum RatingSize {
  small,
  medium,
  large,
}

/// Widget para exibir avaliação com estrelas
class RatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final RatingSize size;
  final bool showReviewCount;
  final bool showRatingValue;
  final Color? starColor;
  final Color? textColor;
  final MainAxisAlignment alignment;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = RatingSize.medium,
    this.showReviewCount = true,
    this.showRatingValue = true,
    this.starColor,
    this.textColor,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getRatingConfig();
    
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showRatingValue) ...[
          Text(
            rating.toStringAsFixed(1),
            style: config.textStyle.copyWith(
              color: textColor ?? AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: config.spacing),
        ],
        _buildStars(config),
        if (showReviewCount && reviewCount != null && reviewCount! > 0) ...[
          SizedBox(width: config.spacing),
          Text(
            '(${_formatReviewCount(reviewCount!)})',
            style: config.textStyle.copyWith(
              color: textColor ?? AppColors.textLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStars(RatingConfig config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final starFill = _getStarFill(starValue);
        
        return Padding(
          padding: EdgeInsets.only(
            right: index < 4 ? config.starSpacing : 0,
          ),
          child: _buildStar(starFill, config),
        );
      }),
    );
  }

  Widget _buildStar(double fill, RatingConfig config) {
    if (fill >= 1.0) {
      // Estrela cheia
      return Icon(
        Icons.star,
        size: config.starSize,
        color: starColor ?? AppColors.warning,
      );
    } else if (fill > 0.0) {
      // Estrela parcial
      return Stack(
        children: [
          Icon(
            Icons.star,
            size: config.starSize,
            color: AppColors.divider,
          ),
          ClipRect(
            clipper: _StarClipper(fill),
            child: Icon(
              Icons.star,
              size: config.starSize,
              color: starColor ?? AppColors.warning,
            ),
          ),
        ],
      );
    } else {
      // Estrela vazia
      return Icon(
        Icons.star,
        size: config.starSize,
        color: AppColors.divider,
      );
    }
  }

  double _getStarFill(int starPosition) {
    if (rating >= starPosition) {
      return 1.0;
    } else if (rating > starPosition - 1) {
      return rating - (starPosition - 1);
    } else {
      return 0.0;
    }
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      final thousands = count / 1000;
      if (thousands >= 10) {
        return '${thousands.toInt()}k';
      } else {
        return '${thousands.toStringAsFixed(1)}k';
      }
    }
    return count.toString();
  }

  RatingConfig _getRatingConfig() {
    switch (size) {
      case RatingSize.small:
        return RatingConfig(
          starSize: 12,
          starSpacing: 1,
          spacing: 4,
          textStyle: AppTextStyles.bodySmall,
        );
      case RatingSize.medium:
        return RatingConfig(
          starSize: 16,
          starSpacing: 2,
          spacing: 6,
          textStyle: AppTextStyles.bodyMedium,
        );
      case RatingSize.large:
        return RatingConfig(
          starSize: 20,
          starSpacing: 3,
          spacing: 8,
          textStyle: AppTextStyles.bodyLarge,
        );
    }
  }
}

/// Configuração para o widget de avaliação
class RatingConfig {
  final double starSize;
  final double starSpacing;
  final double spacing;
  final TextStyle textStyle;

  const RatingConfig({
    required this.starSize,
    required this.starSpacing,
    required this.spacing,
    required this.textStyle,
  });
}

/// Clipper para estrelas parciais
class _StarClipper extends CustomClipper<Rect> {
  final double fillPercentage;

  _StarClipper(this.fillPercentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      0,
      size.width * fillPercentage,
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is _StarClipper &&
           oldClipper.fillPercentage != fillPercentage;
  }
}

/// Widget para exibir avaliação detalhada
class DetailedRatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final Map<int, int>? ratingDistribution; // 5: 100, 4: 50, etc.
  final VoidCallback? onTap;

  const DetailedRatingWidget({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.ratingDistribution,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avaliações',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          RatingWidget(
                            rating: rating,
                            size: RatingSize.medium,
                            showRatingValue: false,
                            showReviewCount: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatReviewCount(reviewCount)} avaliações',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: AppDimensions.iconSmall,
                    color: AppColors.textLight,
                  ),
              ],
            ),
            if (ratingDistribution != null) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              _buildRatingDistribution(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution() {
    final total = ratingDistribution!.values.fold(0, (sum, count) => sum + count);
    
    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = ratingDistribution![stars] ?? 0;
        final percentage = total > 0 ? count / total : 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(
                '$stars',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                size: 12,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              SizedBox(
                width: 30,
                child: Text(
                  count.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      final thousands = count / 1000;
      if (thousands >= 10) {
        return '${thousands.toInt()}k';
      } else {
        return '${thousands.toStringAsFixed(1)}k';
      }
    }
    return count.toString();
  }
}

/// Widget para exibir avaliação compacta em uma linha
class CompactRatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const CompactRatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reviewCount != null && reviewCount! > 0) ...[
            const SizedBox(width: 4),
            Text(
              '(${_formatReviewCount(reviewCount!)})',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      final thousands = count / 1000;
      if (thousands >= 10) {
        return '${thousands.toInt()}k';
      } else {
        return '${thousands.toStringAsFixed(1)}k';
      }
    }
    return count.toString();
  }
}