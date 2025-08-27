import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/services/search/ai_search_service.dart';
import '../../extensions/widget_extensions.dart';

/// Widget para exibir métricas de performance da busca (apenas em modo debug)
class SearchPerformanceWidget extends StatelessWidget {
  final String query;
  final int totalTimeMs;
  final int aiTimeMs;
  final int dbTimeMs;
  final int resultsCount;
  final bool usedCache;
  final SearchInterpretation? interpretation;

  const SearchPerformanceWidget({
    super.key,
    required this.query,
    required this.totalTimeMs,
    required this.aiTimeMs,
    required this.dbTimeMs,
    required this.resultsCount,
    required this.usedCache,
    this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    // Só exibir em modo debug
    if (!kDebugMode) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppDimensions.paddingSmall),
          _buildMetrics(),
          if (interpretation != null) ...[_buildAIMetrics()],
        ],
      ),
    ).fadeIn();
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.analytics,
          color: AppColors.textLight,
          size: AppDimensions.iconSmall,
        ),
        SizedBox(width: AppDimensions.paddingSmall),
        Text(
          'Performance Debug',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (usedCache)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall,
              vertical: AppDimensions.paddingXSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Text(
              'CACHE',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetrics() {
    return Column(
      children: [
        _buildMetricRow(
          'Tempo Total',
          '${totalTimeMs}ms',
          _getTimeColor(totalTimeMs),
        ),
        _buildMetricRow(
          'Interpretação IA',
          '${aiTimeMs}ms (${_getPercentage(aiTimeMs, totalTimeMs)}%)',
          _getTimeColor(aiTimeMs),
        ),
        _buildMetricRow(
          'Consulta DB',
          '${dbTimeMs}ms (${_getPercentage(dbTimeMs, totalTimeMs)}%)',
          _getTimeColor(dbTimeMs),
        ),
        _buildMetricRow(
          'Resultados',
          '$resultsCount',
          _getResultsColor(resultsCount),
        ),
        _buildMetricRow(
          'Query',
          query.length > 30 ? '${query.substring(0, 30)}...' : query,
          AppColors.textLight,
        ),
      ],
    );
  }

  Widget _buildAIMetrics() {
    if (interpretation == null) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: AppDimensions.paddingSmall),
        const Divider(color: AppColors.divider),
        SizedBox(height: AppDimensions.paddingSmall),
        _buildMetricRow(
          'Confiança IA',
          '${(interpretation!.confidence * 100).toStringAsFixed(1)}%',
          _getConfidenceColor(interpretation!.confidence),
        ),
        _buildMetricRow(
          'Intenção',
          _getIntentionText(interpretation!.intention),
          AppColors.primary,
        ),
        _buildMetricRow(
          'Entidades',
          '${interpretation!.entities.length}',
          AppColors.textLight,
        ),
        _buildMetricRow(
          'Correções',
          '${interpretation!.corrections.length}',
          interpretation!.corrections.isNotEmpty ? AppColors.warning : AppColors.textLight,
        ),
        _buildMetricRow(
          'Expansões',
          '${interpretation!.expandedTerms.length}',
          AppColors.textLight,
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimeColor(int timeMs) {
    if (timeMs < 100) return AppColors.success;
    if (timeMs < 500) return AppColors.warning;
    return AppColors.error;
  }

  Color _getResultsColor(int count) {
    if (count == 0) return AppColors.error;
    if (count < 5) return AppColors.warning;
    return AppColors.success;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  String _getIntentionText(SearchIntention intention) {
    switch (intention) {
      case SearchIntention.cuisine:
        return 'Culinária';
      case SearchIntention.dish:
        return 'Prato';
      case SearchIntention.location:
        return 'Localização';
      case SearchIntention.dietary:
        return 'Dietético';
      case SearchIntention.price:
        return 'Preço';
      case SearchIntention.rating:
        return 'Avaliação';
      default:
        return 'Geral';
    }
  }

  int _getPercentage(int part, int total) {
    if (total == 0) return 0;
    return ((part / total) * 100).round();
  }
}
