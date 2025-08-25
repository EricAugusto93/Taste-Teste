import 'package:flutter/foundation.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/di/injection_container.dart';
import 'ai_search_service.dart';

/// Serviço de analytics para buscas
class SearchAnalyticsService {
  static SearchAnalyticsService? _instance;
  static SearchAnalyticsService get instance => _instance ??= SearchAnalyticsService._();
  SearchAnalyticsService._();

  final CacheService _cacheService = getIt<CacheService>();

  /// Registra uma busca com interpretação de IA
  Future<void> trackAISearch({
    required String originalQuery,
    required SearchInterpretation interpretation,
    required int resultsCount,
    required int searchTimeMs,
    String? categoryId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      debugPrint('🤖 Analytics: AI Search - $originalQuery');
      
      final searchData = {
        'originalQuery': originalQuery,
        'processedQuery': interpretation.normalizedQuery,
        'intention': interpretation.intention.toString(),
        'resultsCount': resultsCount,
        'searchTimeMs': searchTimeMs,
        'categoryId': categoryId,
        'filters': filters ?? {},
        'confidence': interpretation.confidence,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _saveAnalytics('ai_search', searchData);
    } catch (e) {
      debugPrint('❌ Erro ao registrar AI search analytics: $e');
    }
  }

  /// Registra performance de busca
  Future<void> trackSearchPerformance({
    required String query,
    required int totalResults,
    required int searchTimeMs,
    required int cacheHit,
    String? errorMessage,
  }) async {
    try {
      debugPrint('⚡ Analytics: Search Performance - $query ($searchTimeMs ms)');
      
      final performanceData = {
        'query': query,
        'totalResults': totalResults,
        'searchTimeMs': searchTimeMs,
        'cacheHit': cacheHit,
        'errorMessage': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _saveAnalytics('search_performance', performanceData);
    } catch (e) {
      debugPrint('❌ Erro ao registrar search performance analytics: $e');
    }
  }

  /// Registra sugestões de IA
  Future<void> trackAISuggestions({
    required String query,
    required List<String> suggestions,
    required int responseTimeMs,
  }) async {
    try {
      debugPrint('💡 Analytics: AI Suggestions - $query');
      
      final suggestionsData = {
        'query': query,
        'suggestions': suggestions,
        'suggestionsCount': suggestions.length,
        'responseTimeMs': responseTimeMs,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _saveAnalytics('ai_suggestions', suggestionsData);
    } catch (e) {
      debugPrint('❌ Erro ao registrar AI suggestions analytics: $e');
    }
  }

  /// Registra uma busca básica
  Future<void> logSearch(String query, {
    String? category,
    int? resultsCount,
    double? latitude,
    double? longitude,
  }) async {
    try {
      debugPrint('🔍 Analytics: Busca registrada - $query');
      
      final searchData = {
        'query': query,
        'category': category,
        'resultsCount': resultsCount,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _saveAnalytics('basic_search', searchData);
    } catch (e) {
      debugPrint('❌ Erro ao registrar analytics de busca: $e');
    }
  }

  /// Registra um clique em resultado de busca
  Future<void> logSearchResultClick(String restaurantId, String query, int position) async {
    try {
      debugPrint('👆 Analytics: Clique registrado - $restaurantId (posição $position)');
      
      final clickData = {
        'restaurantId': restaurantId,
        'query': query,
        'position': position,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _saveAnalytics('search_click', clickData);
    } catch (e) {
      debugPrint('❌ Erro ao registrar clique: $e');
    }
  }

  /// Salva dados de analytics
  Future<void> _saveAnalytics(String type, Map<String, dynamic> data) async {
    try {
      final history = await _getAnalyticsHistory(type);
      history.add(data);
      
      // Mantém apenas os últimos 100 registros
      if (history.length > 100) {
        history.removeAt(0);
      }
      
      await _cacheService.set('${type}_analytics', history);
    } catch (e) {
      debugPrint('❌ Erro ao salvar analytics: $e');
    }
  }

  /// Obtém histórico de analytics
  Future<List<Map<String, dynamic>>> _getAnalyticsHistory(String type) async {
    try {
      final data = await _cacheService.get('${type}_analytics');
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('❌ Erro ao obter histórico de analytics: $e');
    }
    return [];
  }

  /// Registra sugestão selecionada
  Future<void> trackSuggestionSelected(String suggestion, String originalQuery) async {
    try {
      debugPrint('💡 Analytics: Sugestão selecionada - $suggestion');
      
      final data = {
        'suggestion': suggestion,
        'originalQuery': originalQuery,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _saveAnalytics('suggestion_selected', data);
    } catch (e) {
      debugPrint('❌ Erro ao registrar sugestão selecionada: $e');
    }
  }

  /// Registra correção usada
  Future<void> trackCorrectionUsed(String correction, String originalQuery) async {
    try {
      debugPrint('✏️ Analytics: Correção usada - $correction');
      
      final data = {
        'correction': correction,
        'originalQuery': originalQuery,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _saveAnalytics('correction_used', data);
    } catch (e) {
      debugPrint('❌ Erro ao registrar correção: $e');
    }
  }

  /// Limpa dados de analytics
  Future<void> clearAnalytics() async {
    try {
      await _cacheService.remove('ai_search_analytics');
      await _cacheService.remove('search_performance_analytics');
      await _cacheService.remove('ai_suggestions_analytics');
      await _cacheService.remove('basic_search_analytics');
      await _cacheService.remove('search_click_analytics');
      debugPrint('🗑️ Analytics: Dados limpos');
    } catch (e) {
      debugPrint('❌ Erro ao limpar analytics: $e');
    }
  }
}