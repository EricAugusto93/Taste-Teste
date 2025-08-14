import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';
import 'ai_search_service.dart';

/// Serviço especializado em analytics de busca com IA
class SearchAnalyticsService {
  static SearchAnalyticsService? _instance;
  static SearchAnalyticsService get instance => _instance ??= SearchAnalyticsService._();
  SearchAnalyticsService._();

  final AnalyticsService _analytics = AnalyticsService.instance;

  /// Rastrear busca com interpretação de IA
  Future<void> trackAISearch({
    required String originalQuery,
    required SearchInterpretation interpretation,
    required int resultsCount,
    required int searchTimeMs,
    String? categoryId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'ai_search_performed',
        parameters: {
          'original_query': originalQuery,
          'normalized_query': interpretation.normalizedQuery,
          'search_intention': interpretation.intention.toString(),
          'confidence_score': interpretation.confidence,
          'confidence_level': _getConfidenceLevel(interpretation.confidence),
          'entities_detected': interpretation.entities.keys.toList(),
          'entities_count': interpretation.entities.length,
          'corrections_suggested': interpretation.corrections.length,
          'expanded_terms_count': interpretation.expandedTerms.length,
          'results_count': resultsCount,
          'search_time_ms': searchTimeMs,
          'category_id': categoryId,
          'has_filters': filters?.isNotEmpty ?? false,
          'query_length': originalQuery.length,
          'has_results': resultsCount > 0,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Rastrear entidades específicas detectadas
      for (final entry in interpretation.entities.entries) {
        await _analytics.trackEvent(
          type: AnalyticsEventType.custom,
          name: 'ai_entity_detected',
          parameters: {
            'entity_type': entry.key,
            'entity_values': entry.value,
            'query': originalQuery,
            'confidence': interpretation.confidence,
          },
        );
      }

      // Rastrear correções se houver
      if (interpretation.corrections.isNotEmpty) {
        await _analytics.trackEvent(
          type: AnalyticsEventType.custom,
          name: 'ai_corrections_suggested',
          parameters: {
            'original_query': originalQuery,
            'corrections': interpretation.corrections,
            'confidence': interpretation.confidence,
            'results_count': resultsCount,
          },
        );
      }
    } catch (e) {
      debugPrint('Erro ao rastrear busca com IA: $e');
    }
  }

  /// Rastrear feedback do usuário sobre a interpretação da IA
  Future<void> trackAIFeedback({
    required String query,
    required SearchInterpretation interpretation,
    required String feedback, // 'positive', 'negative'
    required int resultsCount,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'ai_interpretation_feedback',
        parameters: {
          'query': query,
          'confidence': interpretation.confidence,
          'intention': interpretation.intention.toString(),
          'feedback': feedback,
          'results_count': resultsCount,
          'entities_count': interpretation.entities.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao rastrear feedback da IA: $e');
    }
  }

  /// Rastrear uso de correções sugeridas
  Future<void> trackCorrectionUsed({
    required String originalQuery,
    required String correctedQuery,
    required double confidence,
    required int originalResultsCount,
    required int correctedResultsCount,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'ai_correction_used',
        parameters: {
          'original_query': originalQuery,
          'corrected_query': correctedQuery,
          'confidence': confidence,
          'original_results': originalResultsCount,
          'corrected_results': correctedResultsCount,
          'improvement': correctedResultsCount - originalResultsCount,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao rastrear uso de correção: $e');
    }
  }

  /// Rastrear sugestões de busca geradas pela IA
  Future<void> trackAISuggestions({
    required String partialQuery,
    required List<String> suggestions,
    required int responseTimeMs,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'ai_suggestions_generated',
        parameters: {
          'partial_query': partialQuery,
          'suggestions_count': suggestions.length,
          'suggestions': suggestions.take(5).toList(), // Limitar para não sobrecarregar
          'response_time_ms': responseTimeMs,
          'query_length': partialQuery.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao rastrear sugestões da IA: $e');
    }
  }

  /// Rastrear seleção de sugestão
  Future<void> trackSuggestionSelected({
    required String originalQuery,
    required String selectedSuggestion,
    required int suggestionIndex,
    required bool wasAIGenerated,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'search_suggestion_selected',
        parameters: {
          'original_query': originalQuery,
          'selected_suggestion': selectedSuggestion,
          'suggestion_index': suggestionIndex,
          'was_ai_generated': wasAIGenerated,
          'query_length': originalQuery.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao rastrear seleção de sugestão: $e');
    }
  }

  /// Rastrear performance da busca
  Future<void> trackSearchPerformance({
    required String query,
    required int totalTimeMs,
    required int aiInterpretationTimeMs,
    required int databaseQueryTimeMs,
    required int resultsCount,
    required bool usedCache,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'search_performance',
        parameters: {
          'query': query,
          'total_time_ms': totalTimeMs,
          'ai_interpretation_time_ms': aiInterpretationTimeMs,
          'database_query_time_ms': databaseQueryTimeMs,
          'results_count': resultsCount,
          'used_cache': usedCache,
          'ai_overhead_percentage': (aiInterpretationTimeMs / totalTimeMs * 100).round(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao rastrear performance da busca: $e');
    }
  }

  /// Rastrear padrões de busca do usuário
  Future<void> trackSearchPattern({
    required List<String> recentQueries,
    required Map<String, int> queryFrequency,
    required Map<SearchIntention, int> intentionFrequency,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'user_search_patterns',
        parameters: {
          'recent_queries_count': recentQueries.length,
          'unique_queries_count': queryFrequency.length,
          'most_frequent_query': _getMostFrequent(queryFrequency),
          'most_common_intention': _getMostFrequentIntention(intentionFrequency),
          'search_diversity': _calculateSearchDiversity(queryFrequency),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao rastrear padrões de busca: $e');
    }
  }

  /// Rastrear falhas da IA
  Future<void> trackAIFailure({
    required String query,
    required String errorType,
    required String errorMessage,
    required int fallbackResultsCount,
  }) async {
    try {
      await _analytics.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'ai_search_failure',
        parameters: {
          'query': query,
          'error_type': errorType,
          'error_message': errorMessage,
          'fallback_results_count': fallbackResultsCount,
          'query_length': query.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao rastrear falha da IA: $e');
    }
  }

  /// Gerar relatório de métricas da IA
  Future<Map<String, dynamic>> generateAIMetricsReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Este método seria implementado para gerar relatórios
    // baseados nos dados coletados
    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'metrics': {
        'total_ai_searches': 0, // Implementar contagem
        'average_confidence': 0.0, // Implementar cálculo
        'most_common_intentions': [], // Implementar análise
        'correction_usage_rate': 0.0, // Implementar cálculo
        'user_satisfaction_rate': 0.0, // Baseado no feedback
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  // Métodos auxiliares
  String _getConfidenceLevel(double confidence) {
    if (confidence >= 0.8) return 'high';
    if (confidence >= 0.6) return 'medium';
    if (confidence >= 0.4) return 'low';
    return 'very_low';
  }

  String? _getMostFrequent(Map<String, int> frequency) {
    if (frequency.isEmpty) return null;
    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String? _getMostFrequentIntention(Map<SearchIntention, int> frequency) {
    if (frequency.isEmpty) return null;
    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .toString();
  }

  double _calculateSearchDiversity(Map<String, int> frequency) {
    if (frequency.isEmpty) return 0.0;
    final totalQueries = frequency.values.reduce((a, b) => a + b);
    final uniqueQueries = frequency.length;
    return uniqueQueries / totalQueries;
  }
}