import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';
import 'search_analytics_service.dart';

/// Serviço para gerar relatórios de métricas de IA
class AIMetricsReportService {
  static final AIMetricsReportService _instance = AIMetricsReportService._internal();
  factory AIMetricsReportService() => _instance;
  AIMetricsReportService._internal();

  static AIMetricsReportService get instance => _instance;

  final SearchAnalyticsService _searchAnalytics = SearchAnalyticsService.instance;

  /// Gerar relatório completo de métricas de IA
  Future<AIMetricsReport> generateReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 7));
      final end = endDate ?? now;

      // Simular coleta de métricas (em uma implementação real, viria do banco de dados)
      final searchMetrics = await _generateSearchMetrics(start, end);
      final performanceMetrics = await _generatePerformanceMetrics(start, end);
      final userBehaviorMetrics = await _generateUserBehaviorMetrics(start, end);
      final aiAccuracyMetrics = await _generateAIAccuracyMetrics(start, end);

      return AIMetricsReport(
        period: ReportPeriod(start: start, end: end),
        searchMetrics: searchMetrics,
        performanceMetrics: performanceMetrics,
        userBehaviorMetrics: userBehaviorMetrics,
        aiAccuracyMetrics: aiAccuracyMetrics,
        generatedAt: now,
      );
    } catch (e) {
      debugPrint('Erro ao gerar relatório de métricas: $e');
      rethrow;
    }
  }

  /// Gerar métricas de busca
  Future<SearchMetrics> _generateSearchMetrics(DateTime start, DateTime end) async {
    // Em uma implementação real, estes dados viriam do banco de dados
    return SearchMetrics(
      totalSearches: 1250,
      aiInterpretedSearches: 1100,
      averageConfidence: 0.82,
      topQueries: [
        QueryMetric(query: 'pizza italiana', count: 45, avgConfidence: 0.95),
        QueryMetric(query: 'comida japonesa', count: 38, avgConfidence: 0.88),
        QueryMetric(query: 'hamburguer artesanal', count: 32, avgConfidence: 0.91),
        QueryMetric(query: 'restaurante vegano', count: 28, avgConfidence: 0.85),
        QueryMetric(query: 'churrascaria', count: 25, avgConfidence: 0.93),
      ],
      intentionDistribution: {
        'cuisine': 0.45,
        'dish': 0.30,
        'dietary': 0.15,
        'location': 0.08,
        'other': 0.02,
      },
      correctionsUsed: 89,
      suggestionsGenerated: 3420,
      suggestionsSelected: 1876,
    );
  }

  /// Gerar métricas de performance
  Future<PerformanceMetrics> _generatePerformanceMetrics(DateTime start, DateTime end) async {
    return PerformanceMetrics(
      averageSearchTime: 245,
      averageAITime: 120,
      averageDBTime: 85,
      cacheHitRate: 0.68,
      p95SearchTime: 450,
      p99SearchTime: 680,
      slowestQueries: [
        SlowQueryMetric(query: 'restaurante com vista para o mar perto de mim', timeMs: 1200),
        SlowQueryMetric(query: 'comida italiana autêntica delivery', timeMs: 980),
        SlowQueryMetric(query: 'melhor churrascaria rodízio zona sul', timeMs: 850),
      ],
      errorRate: 0.02,
      timeoutRate: 0.005,
    );
  }

  /// Gerar métricas de comportamento do usuário
  Future<UserBehaviorMetrics> _generateUserBehaviorMetrics(DateTime start, DateTime end) async {
    return UserBehaviorMetrics(
      averageQueryLength: 3.2,
      mostCommonQueryTypes: [
        'Busca por culinária',
        'Busca por prato específico',
        'Busca por localização',
        'Busca por restrições dietéticas',
      ],
      feedbackDistribution: {
        'positive': 0.78,
        'negative': 0.15,
        'neutral': 0.07,
      },
      averageResultsClicked: 2.4,
      searchAbandonmentRate: 0.12,
      refinementRate: 0.35,
    );
  }

  /// Gerar métricas de precisão da IA
  Future<AIAccuracyMetrics> _generateAIAccuracyMetrics(DateTime start, DateTime end) async {
    return AIAccuracyMetrics(
      overallAccuracy: 0.87,
      intentionAccuracy: 0.91,
      entityExtractionAccuracy: 0.84,
      confidenceCalibration: 0.89,
      falsePositiveRate: 0.08,
      falseNegativeRate: 0.05,
      accuracyByIntention: {
        'cuisine': 0.93,
        'dish': 0.89,
        'location': 0.85,
        'dietary': 0.82,
        'price': 0.78,
      },
      improvementSuggestions: [
        'Melhorar detecção de pratos regionais',
        'Aprimorar interpretação de consultas de preço',
        'Expandir base de sinônimos para termos dietéticos',
      ],
    );
  }

  /// Exportar relatório como JSON
  String exportAsJson(AIMetricsReport report) {
    return jsonEncode(report.toJson());
  }

  /// Gerar resumo executivo
  String generateExecutiveSummary(AIMetricsReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== RELATÓRIO DE MÉTRICAS DE IA ===');
    buffer.writeln('Período: ${_formatDate(report.period.start)} - ${_formatDate(report.period.end)}');
    buffer.writeln('Gerado em: ${_formatDate(report.generatedAt)}');
    buffer.writeln();
    
    buffer.writeln('📊 RESUMO EXECUTIVO:');
    buffer.writeln('• Total de buscas: ${report.searchMetrics.totalSearches}');
    buffer.writeln('• Buscas interpretadas por IA: ${report.searchMetrics.aiInterpretedSearches} (${((report.searchMetrics.aiInterpretedSearches / report.searchMetrics.totalSearches) * 100).toStringAsFixed(1)}%)');
    buffer.writeln('• Confiança média: ${(report.searchMetrics.averageConfidence * 100).toStringAsFixed(1)}%');
    buffer.writeln('• Tempo médio de busca: ${report.performanceMetrics.averageSearchTime}ms');
    buffer.writeln('• Taxa de acerto do cache: ${(report.performanceMetrics.cacheHitRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('• Precisão geral da IA: ${(report.aiAccuracyMetrics.overallAccuracy * 100).toStringAsFixed(1)}%');
    buffer.writeln();
    
    buffer.writeln('🔍 TOP CONSULTAS:');
    for (int i = 0; i < report.searchMetrics.topQueries.length && i < 3; i++) {
      final query = report.searchMetrics.topQueries[i];
      buffer.writeln('${i + 1}. "${query.query}" - ${query.count} buscas (${(query.avgConfidence * 100).toStringAsFixed(1)}% confiança)');
    }
    buffer.writeln();
    
    buffer.writeln('⚡ PERFORMANCE:');
    buffer.writeln('• Tempo médio IA: ${report.performanceMetrics.averageAITime}ms');
    buffer.writeln('• Tempo médio DB: ${report.performanceMetrics.averageDBTime}ms');
    buffer.writeln('• P95 tempo de busca: ${report.performanceMetrics.p95SearchTime}ms');
    buffer.writeln('• Taxa de erro: ${(report.performanceMetrics.errorRate * 100).toStringAsFixed(2)}%');
    buffer.writeln();
    
    buffer.writeln('👥 COMPORTAMENTO DO USUÁRIO:');
    buffer.writeln('• Feedback positivo: ${(report.userBehaviorMetrics.feedbackDistribution['positive']! * 100).toStringAsFixed(1)}%');
    buffer.writeln('• Taxa de abandono: ${(report.userBehaviorMetrics.searchAbandonmentRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('• Taxa de refinamento: ${(report.userBehaviorMetrics.refinementRate * 100).toStringAsFixed(1)}%');
    buffer.writeln();
    
    if (report.aiAccuracyMetrics.improvementSuggestions.isNotEmpty) {
      buffer.writeln('💡 SUGESTÕES DE MELHORIA:');
      for (final suggestion in report.aiAccuracyMetrics.improvementSuggestions) {
        buffer.writeln('• $suggestion');
      }
    }
    
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Modelo do relatório de métricas
class AIMetricsReport {
  final ReportPeriod period;
  final SearchMetrics searchMetrics;
  final PerformanceMetrics performanceMetrics;
  final UserBehaviorMetrics userBehaviorMetrics;
  final AIAccuracyMetrics aiAccuracyMetrics;
  final DateTime generatedAt;

  AIMetricsReport({
    required this.period,
    required this.searchMetrics,
    required this.performanceMetrics,
    required this.userBehaviorMetrics,
    required this.aiAccuracyMetrics,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'searchMetrics': searchMetrics.toJson(),
      'performanceMetrics': performanceMetrics.toJson(),
      'userBehaviorMetrics': userBehaviorMetrics.toJson(),
      'aiAccuracyMetrics': aiAccuracyMetrics.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

class ReportPeriod {
  final DateTime start;
  final DateTime end;

  ReportPeriod({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }
}

class SearchMetrics {
  final int totalSearches;
  final int aiInterpretedSearches;
  final double averageConfidence;
  final List<QueryMetric> topQueries;
  final Map<String, double> intentionDistribution;
  final int correctionsUsed;
  final int suggestionsGenerated;
  final int suggestionsSelected;

  SearchMetrics({
    required this.totalSearches,
    required this.aiInterpretedSearches,
    required this.averageConfidence,
    required this.topQueries,
    required this.intentionDistribution,
    required this.correctionsUsed,
    required this.suggestionsGenerated,
    required this.suggestionsSelected,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSearches': totalSearches,
      'aiInterpretedSearches': aiInterpretedSearches,
      'averageConfidence': averageConfidence,
      'topQueries': topQueries.map((q) => q.toJson()).toList(),
      'intentionDistribution': intentionDistribution,
      'correctionsUsed': correctionsUsed,
      'suggestionsGenerated': suggestionsGenerated,
      'suggestionsSelected': suggestionsSelected,
    };
  }
}

class QueryMetric {
  final String query;
  final int count;
  final double avgConfidence;

  QueryMetric({
    required this.query,
    required this.count,
    required this.avgConfidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'count': count,
      'avgConfidence': avgConfidence,
    };
  }
}

class PerformanceMetrics {
  final int averageSearchTime;
  final int averageAITime;
  final int averageDBTime;
  final double cacheHitRate;
  final int p95SearchTime;
  final int p99SearchTime;
  final List<SlowQueryMetric> slowestQueries;
  final double errorRate;
  final double timeoutRate;

  PerformanceMetrics({
    required this.averageSearchTime,
    required this.averageAITime,
    required this.averageDBTime,
    required this.cacheHitRate,
    required this.p95SearchTime,
    required this.p99SearchTime,
    required this.slowestQueries,
    required this.errorRate,
    required this.timeoutRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageSearchTime': averageSearchTime,
      'averageAITime': averageAITime,
      'averageDBTime': averageDBTime,
      'cacheHitRate': cacheHitRate,
      'p95SearchTime': p95SearchTime,
      'p99SearchTime': p99SearchTime,
      'slowestQueries': slowestQueries.map((q) => q.toJson()).toList(),
      'errorRate': errorRate,
      'timeoutRate': timeoutRate,
    };
  }
}

class SlowQueryMetric {
  final String query;
  final int timeMs;

  SlowQueryMetric({required this.query, required this.timeMs});

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timeMs': timeMs,
    };
  }
}

class UserBehaviorMetrics {
  final double averageQueryLength;
  final List<String> mostCommonQueryTypes;
  final Map<String, double> feedbackDistribution;
  final double averageResultsClicked;
  final double searchAbandonmentRate;
  final double refinementRate;

  UserBehaviorMetrics({
    required this.averageQueryLength,
    required this.mostCommonQueryTypes,
    required this.feedbackDistribution,
    required this.averageResultsClicked,
    required this.searchAbandonmentRate,
    required this.refinementRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageQueryLength': averageQueryLength,
      'mostCommonQueryTypes': mostCommonQueryTypes,
      'feedbackDistribution': feedbackDistribution,
      'averageResultsClicked': averageResultsClicked,
      'searchAbandonmentRate': searchAbandonmentRate,
      'refinementRate': refinementRate,
    };
  }
}

class AIAccuracyMetrics {
  final double overallAccuracy;
  final double intentionAccuracy;
  final double entityExtractionAccuracy;
  final double confidenceCalibration;
  final double falsePositiveRate;
  final double falseNegativeRate;
  final Map<String, double> accuracyByIntention;
  final List<String> improvementSuggestions;

  AIAccuracyMetrics({
    required this.overallAccuracy,
    required this.intentionAccuracy,
    required this.entityExtractionAccuracy,
    required this.confidenceCalibration,
    required this.falsePositiveRate,
    required this.falseNegativeRate,
    required this.accuracyByIntention,
    required this.improvementSuggestions,
  });

  Map<String, dynamic> toJson() {
    return {
      'overallAccuracy': overallAccuracy,
      'intentionAccuracy': intentionAccuracy,
      'entityExtractionAccuracy': entityExtractionAccuracy,
      'confidenceCalibration': confidenceCalibration,
      'falsePositiveRate': falsePositiveRate,
      'falseNegativeRate': falseNegativeRate,
      'accuracyByIntention': accuracyByIntention,
      'improvementSuggestions': improvementSuggestions,
    };
  }
}