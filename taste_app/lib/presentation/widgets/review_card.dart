import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/services/reviews/review_service.dart';
import 'rating_widget.dart';

/// Widget para exibir uma avaliação
class ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final VoidCallback? onTap;
  final bool showRestaurantName;

  const ReviewCard({
    super.key,
    required this.review,
    this.onTap,
    this.showRestaurantName = false,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  final ReviewRepository _reviewRepository = ReviewRepository();

  ReviewModel get review => widget.review;
  VoidCallback? get onTap => widget.onTap;
  bool get showRestaurantName => widget.showRestaurantName;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.paddingSmall),
              _buildRating(),
              if (review.comment?.isNotEmpty == true) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildComment(),
              ],
              const SizedBox(height: AppDimensions.paddingSmall),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: review.userAvatar != null
              ? ClipOval(
                  child: Image.network(
                    review.userAvatar!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  ),
                )
              : _buildDefaultAvatar(),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      size: AppDimensions.iconMedium,
      color: AppColors.primary,
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final isFilled = index < review.rating;
          return Icon(
            isFilled ? Icons.star : Icons.star_border,
            size: AppDimensions.iconSmall,
            color: isFilled ? AppColors.warning : Colors.grey[300],
          );
        }),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          review.rating.toString(),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildComment() {
    return Text(
      review.comment ?? '',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDark,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (review.isVerified) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 12,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verificado',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
        ],

        if (review.helpfulCount > 0) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.thumb_up,
                size: AppDimensions.iconSmall,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                review.helpfulCount.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const Spacer(),
        ] else
          const Spacer(),

        // Ações da avaliação
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.thumb_up,
              label: 'Útil',
              onPressed: () => _onHelpfulPressed(),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildActionButton(
              icon: Icons.reply,
              label: 'Responder',
              onPressed: () => _onReplyPressed(),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildActionButton(
              icon: Icons.flag_outlined,
              label: 'Reportar',
              onPressed: () => _onReportPressed(),
            ),
          ],
        ),

        // Respostas
        if (widget.review.replies.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildReplies(),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSmall,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onHelpfulPressed() async {
    try {
      final reviewService = ReviewService.instance;
      final wasHelpful =
          await reviewService.toggleHelpfulVote(widget.review.id);

      if (mounted) {
        final message = wasHelpful
            ? 'Avaliação marcada como útil!'
            : 'Voto removido da avaliação';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        // Forçar atualização da página pai se possível
        // Isso atualizará o contador de helpful_count
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao votar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onReplyPressed() {
    _showReplyDialog();
  }

  void _onReportPressed() {
    _showReportDialog();
  }

  void _showReplyDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReplyDialog(
        reviewId: widget.review.id,
        onReplySubmitted: (content) async {
          try {
            await ReviewService.instance.createReply(
              reviewId: widget.review.id,
              content: content,
            );

            NavigationHelper.safeGoBack(context);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resposta enviada com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );

              // Recarregar respostas se possível
              setState(() {});
            }
          } catch (e) {
            NavigationHelper.safeGoBack(context);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao enviar resposta: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReportDialog(
        onReasonSelected: (reason) async {
          try {
            await ReviewService.instance.reportReview(
              reviewId: widget.review.id,
              reason: reason,
            );
            NavigationHelper.safeGoBack(context);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Avaliação reportada com sucesso'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            NavigationHelper.safeGoBack(context);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao reportar: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildReplies() {
    return Container(
      margin: const EdgeInsets.only(left: AppDimensions.paddingLarge),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Respostas (${widget.review.replies.length})',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          ...widget.review.replies.map((reply) => _buildReplyItem(reply)),
        ],
      ),
    );
  }

  Widget _buildReplyItem(ReviewReply reply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.reply,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(
                reply.userName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: reply.isRestaurantOwner
                      ? AppColors.primary
                      : AppColors.textDark,
                ),
              ),
              if (reply.isRestaurantOwner) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Restaurante',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.surface,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                _formatDate(reply.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: AppDimensions.paddingLarge),
            child: Text(
              reply.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora';
    }
  }
}

/// Widget para exibir estatísticas de avaliações
class ReviewStatsWidget extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const ReviewStatsWidget({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isFilled = index < averageRating.floor();
                        final isHalf = index == averageRating.floor() &&
                            averageRating % 1 >= 0.5;

                        return Icon(
                          isFilled || isHalf ? Icons.star : Icons.star_border,
                          size: AppDimensions.iconSmall,
                          color: isFilled || isHalf
                              ? AppColors.warning
                              : Colors.grey[300],
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews avaliações',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingLarge),
              Expanded(
                flex: 2,
                child: Column(
                  children: List.generate(5, (index) {
                    final rating = 5 - index;
                    final count = ratingDistribution[rating] ?? 0;
                    final percentage =
                        totalReviews > 0 ? count / totalReviews : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog para responder a uma avaliação
class _ReplyDialog extends StatefulWidget {
  final String reviewId;
  final Function(String) onReplySubmitted;

  const _ReplyDialog({
    required this.reviewId,
    required this.onReplySubmitted,
  });

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Responder Avaliação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Digite sua resposta...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            maxLength: 500,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _isSubmitting ? null : () => NavigationHelper.safeGoBack(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _controller.text.trim().isEmpty
              ? null
              : _submitReply,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }

  void _submitReply() {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    // Simular delay de envio
    Future.delayed(const Duration(seconds: 1), () {
      widget.onReplySubmitted(_controller.text.trim());
    });
  }
}

/// Dialog para reportar uma avaliação
class _ReportDialog extends StatelessWidget {
  final Function(String) onReasonSelected;

  const _ReportDialog({
    required this.onReasonSelected,
  });

  static const _reportReasons = [
    'Conteúdo ofensivo',
    'Spam',
    'Informação falsa',
    'Violação de direitos autorais',
    'Outro',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reportar Avaliação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Por que você está reportando esta avaliação?'),
          const SizedBox(height: AppDimensions.paddingMedium),
          ..._reportReasons.map(
            (reason) => ListTile(
              title: Text(reason),
              onTap: () => onReasonSelected(reason),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => NavigationHelper.safeGoBack(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
