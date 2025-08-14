import 'package:flutter/material.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_icons.dart';
import 'package:taste_app/core/theme/app_shadows.dart';
import 'package:taste_app/core/animations/app_animations.dart';
import 'package:taste_app/domain/entities/review.dart';
import '../cached_image_widget.dart';

/// Card para exibir avaliações de restaurantes
class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onReport;
  final bool showActions;
  final bool isCompact;
  
  const ReviewCard({
    super.key,
    required this.review,
    this.onTap,
    this.onLike,
    this.onReply,
    this.onReport,
    this.showActions = true,
    this.isCompact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeIn(
      child: ShadowContainer.soft(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AppAnimations.bounceOnTap(
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildRating(),
                if (review.comment?.isNotEmpty == true) ..[
                  const SizedBox(height: 12),
                  _buildComment(),
                ],
                if (review.photos?.isNotEmpty == true && !isCompact) ..[
                  const SizedBox(height: 12),
                  _buildPhotos(),
                ],
                if (review.visitDate != null) ..[
                  const SizedBox(height: 12),
                  _buildVisitDate(),
                ],
                if (showActions) ..[
                  const SizedBox(height: 16),
                  _buildActions(),
                ],
                if (review.ownerReply?.isNotEmpty == true) ..[
                  const SizedBox(height: 16),
                  _buildOwnerReply(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar do usuário
        ClipOval(
          child: CachedImageWidget(
            imageUrl: review.userPhoto,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorWidget: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.user,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Nome e data
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Menu de opções
        if (showActions)
          PopupMenuButton<String>(
            icon: Icon(
              AppIcons.more,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onSelected: (value) {
              switch (value) {
                case 'report':
                  onReport?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(
                      AppIcons.warning,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    const Text('Reportar'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildRating() {
    return Row(
      children: [
        // Estrelas
        Row(
          children: List.generate(5, (index) {
            final isFilled = index < review.rating;
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                AppIcons.getStarIcon(isFilled),
                size: 16,
                color: isFilled ? AppColors.warning : AppColors.border,
              ),
            );
          }),
        ),
        const SizedBox(width: 8),
        
        // Nota numérica
        Text(
          '${review.rating.toStringAsFixed(1)}/5',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        
        // Badges de experiência
        if (review.tags?.isNotEmpty == true) ..[
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: review.tags!.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildComment() {
    return Text(
      review.comment!,
      style: const TextStyle(
        fontSize: 14,
        height: 1.4,
        color: AppColors.textPrimary,
      ),
      maxLines: isCompact ? 3 : null,
      overflow: isCompact ? TextOverflow.ellipsis : null,
    );
  }
  
  Widget _buildPhotos() {
    if (review.photos?.isEmpty == true) return const SizedBox.shrink();
    
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: review.photos!.length,
        itemBuilder: (context, index) {
          final photo = review.photos![index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedImageWidget(
                  imageUrl: photo,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildVisitDate() {
    return Row(
      children: [
        Icon(
          AppIcons.calendar,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          'Visitado em ${_formatDate(review.visitDate!)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActions() {
    return Row(
      children: [
        // Botão de curtir
        AppAnimations.bounceOnTap(
          onTap: onLike ?? () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                review.isLiked ? AppIcons.thumbsUp : AppIcons.thumbsUp,
                size: 16,
                color: review.isLiked ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${review.likesCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: review.isLiked ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Botão de responder
        if (onReply != null)
          AppAnimations.bounceOnTap(
            onTap: onReply!,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.message,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Responder',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        
        const Spacer(),
        
        // Indicador de verificação
        if (review.isVerified)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.success,
                  size: 12,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Verificado',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildOwnerReply() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.chef,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Resposta do estabelecimento',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.ownerReply!,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}a';
    }
  }
}

/// Versão compacta do ReviewCard para listas
class CompactReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onTap;
  
  const CompactReviewCard({
    super.key,
    required this.review,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ReviewCard(
      review: review,
      onTap: onTap,
      showActions: false,
      isCompact: true,
    );
  }
}

/// Card para exibir estatísticas de avaliações
class ReviewStatsCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final VoidCallback? onTap;
  
  const ReviewStatsCard({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ShadowContainer.soft(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppAnimations.bounceOnTap(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Nota média
                  Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          final isFilled = index < averageRating.floor();
                          final isHalf = index == averageRating.floor() && 
                                        averageRating % 1 >= 0.5;
                          return Icon(
                            AppIcons.getStarIcon(isFilled || isHalf),
                            size: 16,
                            color: (isFilled || isHalf) 
                                ? AppColors.warning 
                                : AppColors.border,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalReviews avaliações',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Distribuição de estrelas
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final stars = 5 - index;
                        final count = ratingDistribution[stars] ?? 0;
                        final percentage = totalReviews > 0 
                            ? count / totalReviews 
                            : 0.0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$stars',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                AppIcons.star,
                                size: 12,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.warning,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 20,
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}