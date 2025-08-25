import 'package:flutter/foundation.dart';
import '../../core/services/cache_service.dart';
import '../models/search_history_model.dart';

/// Repository para gerenciar histórico de buscas
class SearchHistoryRepository {
  static final SearchHistoryRepository _instance = SearchHistoryRepository._internal();
  factory SearchHistoryRepository() => _instance;
  SearchHistoryRepository._internal();

  static const String _cacheKey = 'search_history';
  static const int _maxHistoryItems = 50;

  final CacheService _cacheService = CacheService.instance;

  /// Adiciona uma busca ao histórico
  Future<void> addSearchToHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final history = await getSearchHistory();
      
      // Remove se já existe (para colocar no topo)
      history.removeWhere((item) => item.query.toLowerCase() == query.toLowerCase());
      
      // Adiciona no início
      history.insert(0, SearchHistoryModel(
        id: 'search_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'anonymous',
        query: query.trim(),
        searchedAt: DateTime.now(),
      ));
      
      // Limita o tamanho do histórico
      if (history.length > _maxHistoryItems) {
        history.removeLast();
      }
      
      await _cacheService.set(_cacheKey, history.map((e) => e.toMap()).toList());
      debugPrint('Adicionado ao histórico de busca: $query');
    } catch (e) {
      debugPrint('Erro ao adicionar busca ao histórico: $e');
    }
  }

  /// Obtém o histórico de buscas
  Future<List<SearchHistoryModel>> getSearchHistory() async {
    try {
      final List<dynamic>? historyData = await _cacheService.get(_cacheKey);
      
      if (historyData == null) return [];
      
      return historyData
          .map((item) => SearchHistoryModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter histórico de busca: $e');
      return [];
    }
  }

  /// Remove uma busca específica do histórico
  Future<void> removeSearchFromHistory(String query) async {
    try {
      final history = await getSearchHistory();
      history.removeWhere((item) => item.query.toLowerCase() == query.toLowerCase());
      await _cacheService.set(_cacheKey, history.map((e) => e.toMap()).toList());
      debugPrint('Removido do histórico de busca: $query');
    } catch (e) {
      debugPrint('Erro ao remover busca do histórico: $e');
    }
  }

  /// Limpa todo o histórico de buscas
  Future<void> clearSearchHistory() async {
    try {
      await _cacheService.remove(_cacheKey);
      debugPrint('Histórico de busca limpo');
    } catch (e) {
      debugPrint('Erro ao limpar histórico de busca: $e');
    }
  }

  /// Obtém as buscas mais frequentes
  Future<List<String>> getFrequentSearches({int limit = 10}) async {
    try {
      final history = await getSearchHistory();
      
      // Conta a frequência de cada busca
      final Map<String, int> frequency = {};
      for (final item in history) {
        final query = item.query.toLowerCase();
        frequency[query] = (frequency[query] ?? 0) + 1;
      }
      
      // Ordena por frequência e retorna os mais frequentes
      final frequentQueries = frequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return frequentQueries
          .take(limit)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter buscas frequentes: $e');
      return [];
    }
  }

  /// Obtém buscas recentes (últimas N)
  Future<List<String>> getRecentSearches({int limit = 5}) async {
    try {
      final history = await getSearchHistory();
      return history
          .take(limit)
          .map((item) => item.query)
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter buscas recentes: $e');
      return [];
    }
  }

  /// Busca no histórico por termo
  Future<List<String>> searchInHistory(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return [];

    try {
      final history = await getSearchHistory();
      final lowerSearchTerm = searchTerm.toLowerCase();
      
      return history
          .where((item) => item.query.toLowerCase().contains(lowerSearchTerm))
          .map((item) => item.query)
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar no histórico: $e');
      return [];
    }
  }

  /// Obtém estatísticas do histórico
  Future<Map<String, dynamic>> getHistoryStats() async {
    try {
      final history = await getSearchHistory();
      
      if (history.isEmpty) {
        return {
          'totalSearches': 0,
          'uniqueQueries': 0,
          'averageQueryLength': 0.0,
          'oldestSearch': null,
          'newestSearch': null,
        };
      }
      
      final uniqueQueries = Set<String>.from(
        history.map((item) => item.query.toLowerCase())
      ).length;
      
      final averageLength = history
          .map((item) => item.query.length)
          .reduce((a, b) => a + b) / history.length;
      
      return {
        'totalSearches': history.length,
        'uniqueQueries': uniqueQueries,
        'averageQueryLength': averageLength,
        'oldestSearch': history.last.timestamp.toIso8601String(),
        'newestSearch': history.first.timestamp.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas do histórico: $e');
      return {};
    }
  }
  
  /// Alias para searchInHistory (compatibilidade com código existente)
  Future<List<String>> searchHistory(String searchTerm) async {
    return await searchInHistory(searchTerm);
  }
  
  /// Alias para addSearchToHistory (compatibilidade com código existente)
  Future<void> addSearch(String query) async {
    await addSearchToHistory(query);
  }
}