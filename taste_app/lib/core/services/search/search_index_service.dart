import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/data/models/restaurant_model.dart';

/// Entrada do índice de busca
class SearchIndexEntry {
  final String id;
  final String field;
  final String value;
  final String normalizedValue;
  final List<String> tokens;
  final Map<String, dynamic> metadata;
  
  const SearchIndexEntry({
    required this.id,
    required this.field,
    required this.value,
    required this.normalizedValue,
    required this.tokens,
    required this.metadata,
  });
  
  factory SearchIndexEntry.fromJson(Map<String, dynamic> json) {
    return SearchIndexEntry(
      id: json['id'] as String,
      field: json['field'] as String,
      value: json['value'] as String,
      normalizedValue: json['normalizedValue'] as String,
      tokens: List<String>.from(json['tokens'] as List),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field': field,
      'value': value,
      'normalizedValue': normalizedValue,
      'tokens': tokens,
      'metadata': metadata,
    };
  }
}

/// Configurações do índice de busca
class SearchIndexConfig {
  final List<String> indexedFields;
  final Map<String, double> fieldWeights;
  final int minTokenLength;
  final int maxTokenLength;
  final bool enableNGrams;
  final int nGramSize;
  final bool enableStemming;
  final bool enableStopWords;
  final List<String> stopWords;
  
  const SearchIndexConfig({
    this.indexedFields = const [
      'name',
      'cuisine',
      'description',
      'address',
      'tags',
    ],
    this.fieldWeights = const {
      'name': 1.0,
      'cuisine': 0.8,
      'description': 0.6,
      'address': 0.4,
      'tags': 0.7,
    },
    this.minTokenLength = 2,
    this.maxTokenLength = 50,
    this.enableNGrams = true,
    this.nGramSize = 3,
    this.enableStemming = false,
    this.enableStopWords = true,
    this.stopWords = const [
      'o', 'a', 'os', 'as', 'um', 'uma', 'uns', 'umas',
      'de', 'do', 'da', 'dos', 'das', 'em', 'no', 'na',
      'nos', 'nas', 'por', 'para', 'com', 'sem', 'sob',
      'sobre', 'entre', 'até', 'desde', 'durante',
      'e', 'ou', 'mas', 'porém', 'contudo', 'todavia',
      'que', 'qual', 'quais', 'quando', 'onde', 'como',
      'porque', 'se', 'então', 'assim', 'também',
    ],
  });
}

/// Resultado de busca indexada
class IndexedSearchResult {
  final String restaurantId;
  final double score;
  final Map<String, List<SearchIndexEntry>> matches;
  
  const IndexedSearchResult({
    required this.restaurantId,
    required this.score,
    required this.matches,
  });
}

/// Serviço de indexação de busca
class SearchIndexService {
  static SearchIndexService? _instance;
  static SearchIndexService get instance => _instance ??= SearchIndexService._();
  
  SearchIndexService._();
  
  final CacheService _cacheService = CacheService.instance;
  final SearchIndexConfig _config = const SearchIndexConfig();
  
  // Índices em memória
  final Map<String, List<SearchIndexEntry>> _tokenIndex = {};
  final Map<String, List<SearchIndexEntry>> _nGramIndex = {};
  final Map<String, SearchIndexEntry> _entryIndex = {};
  
  // Estado do índice
  bool _isIndexed = false;
  DateTime? _lastIndexUpdate;
  
  /// Verifica se o índice está atualizado
  bool get isIndexed => _isIndexed;
  
  /// Data da última atualização do índice
  DateTime? get lastIndexUpdate => _lastIndexUpdate;
  
  /// Indexa uma lista de restaurantes
  Future<void> indexRestaurants(List<RestaurantModel> restaurants) async {
    try {
      debugPrint('Starting restaurant indexing...');
      
      // Limpa índices existentes
      _clearIndexes();
      
      // Indexa cada restaurante
      for (final restaurant in restaurants) {
        await _indexRestaurant(restaurant);
      }
      
      // Salva índice no cache
      await _saveIndexToCache();
      
      _isIndexed = true;
      _lastIndexUpdate = DateTime.now();
      
      debugPrint('Indexing completed. Indexed ${restaurants.length} restaurants.');
      debugPrint('Token index size: ${_tokenIndex.length}');
      debugPrint('N-gram index size: ${_nGramIndex.length}');
      
    } catch (e) {
      debugPrint('Error indexing restaurants: $e');
      rethrow;
    }
  }
  
  /// Indexa um restaurante individual
  Future<void> _indexRestaurant(RestaurantModel restaurant) async {
    for (final field in _config.indexedFields) {
      final value = _getFieldValue(restaurant, field);
      if (value.isEmpty) continue;
      
      final entries = _createIndexEntries(
        restaurant.id,
        field,
        value,
        restaurant,
      );
      
      for (final entry in entries) {
        _addEntryToIndexes(entry);
      }
    }
  }
  
  /// Obtém valor do campo do restaurante
  String _getFieldValue(RestaurantModel restaurant, String field) {
    switch (field) {
      case 'name':
        return restaurant.name;
      case 'cuisine':
        return restaurant.category;
      case 'description':
        return restaurant.description ?? '';
      case 'address':
        return restaurant.address ?? '';
      case 'tags':
        return ''; // Tags not available in RestaurantModel
      default:
        return '';
    }
  }
  
  /// Cria entradas de índice para um campo
  List<SearchIndexEntry> _createIndexEntries(
    String restaurantId,
    String field,
    String value,
    RestaurantModel restaurant,
  ) {
    final entries = <SearchIndexEntry>[];
    
    // Normaliza o valor
    final normalizedValue = _normalizeText(value);
    
    // Tokeniza
    final tokens = _tokenize(normalizedValue);
    
    // Cria entrada principal
    final mainEntry = SearchIndexEntry(
      id: '${restaurantId}_$field',
      field: field,
      value: value,
      normalizedValue: normalizedValue,
      tokens: tokens,
      metadata: {
        'restaurantId': restaurantId,
        'weight': _config.fieldWeights[field] ?? 1.0,
        'rating': restaurant.rating,
        'priceRange': restaurant.priceRange,
        'isOpen': restaurant.isOpen,
      },
    );
    
    entries.add(mainEntry);
    
    // Cria entradas para tokens individuais
    for (final token in tokens) {
      if (token.length >= _config.minTokenLength && 
          token.length <= _config.maxTokenLength) {
        final tokenEntry = SearchIndexEntry(
          id: '${restaurantId}_${field}_token_$token',
          field: field,
          value: token,
          normalizedValue: token,
          tokens: [token],
          metadata: mainEntry.metadata,
        );
        
        entries.add(tokenEntry);
      }
    }
    
    return entries;
  }
  
  /// Adiciona entrada aos índices
  void _addEntryToIndexes(SearchIndexEntry entry) {
    // Adiciona ao índice de entradas
    _entryIndex[entry.id] = entry;
    
    // Adiciona ao índice de tokens
    for (final token in entry.tokens) {
      _tokenIndex.putIfAbsent(token, () => []).add(entry);
      
      // Adiciona n-gramas se habilitado
      if (_config.enableNGrams) {
        final nGrams = _generateNGrams(token, _config.nGramSize);
        for (final nGram in nGrams) {
          _nGramIndex.putIfAbsent(nGram, () => []).add(entry);
        }
      }
    }
  }
  
  /// Normaliza texto para indexação
  String _normalizeText(String text) {
    String normalized = text.toLowerCase();
    
    // Remove acentos
    normalized = _removeAccents(normalized);
    
    // Remove caracteres especiais
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    
    // Normaliza espaços
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return normalized;
  }
  
  /// Remove acentos
  String _removeAccents(String text) {
    const accents = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
    };
    
    String result = text;
    accents.forEach((accented, normal) {
      result = result.replaceAll(accented, normal);
    });
    
    return result;
  }
  
  /// Tokeniza texto
  List<String> _tokenize(String text) {
    final tokens = text.split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    
    // Remove stop words se habilitado
    if (_config.enableStopWords) {
      return tokens.where((token) => !_config.stopWords.contains(token)).toList();
    }
    
    return tokens;
  }
  
  /// Gera n-gramas
  List<String> _generateNGrams(String text, int n) {
    if (text.length < n) return [];
    
    final nGrams = <String>[];
    for (int i = 0; i <= text.length - n; i++) {
      nGrams.add(text.substring(i, i + n));
    }
    
    return nGrams;
  }
  
  /// Busca usando o índice
  List<IndexedSearchResult> search(String query, {int limit = 50}) {
    if (!_isIndexed || query.trim().isEmpty) return [];
    
    final normalizedQuery = _normalizeText(query);
    final queryTokens = _tokenize(normalizedQuery);
    
    final resultMap = <String, IndexedSearchResult>{};
    
    // Busca por tokens exatos
    for (final token in queryTokens) {
      final entries = _tokenIndex[token] ?? [];
      _processSearchEntries(entries, token, resultMap, 1.0);
    }
    
    // Busca por n-gramas (para matches parciais)
    if (_config.enableNGrams) {
      for (final token in queryTokens) {
        final nGrams = _generateNGrams(token, _config.nGramSize);
        for (final nGram in nGrams) {
          final entries = _nGramIndex[nGram] ?? [];
          _processSearchEntries(entries, nGram, resultMap, 0.5);
        }
      }
    }
    
    // Converte para lista e ordena por score
    final results = resultMap.values.toList();
    results.sort((a, b) => b.score.compareTo(a.score));
    
    return results.take(limit).toList();
  }
  
  /// Processa entradas de busca
  void _processSearchEntries(
    List<SearchIndexEntry> entries,
    String searchTerm,
    Map<String, IndexedSearchResult> resultMap,
    double baseScore,
  ) {
    for (final entry in entries) {
      final restaurantId = entry.metadata['restaurantId'] as String;
      final weight = entry.metadata['weight'] as double;
      
      // Calcula score baseado na relevância
      double score = baseScore * weight;
      
      // Bônus para matches exatos
      if (entry.normalizedValue == searchTerm) {
        score *= 2.0;
      }
      
      // Bônus para restaurantes bem avaliados
      final rating = entry.metadata['rating'] as double? ?? 0.0;
      score *= (1.0 + rating / 10.0);
      
      // Bônus para restaurantes abertos
      final isOpen = entry.metadata['isOpen'] as bool? ?? false;
      if (isOpen) {
        score *= 1.2;
      }
      
      if (resultMap.containsKey(restaurantId)) {
        // Atualiza resultado existente
        final existing = resultMap[restaurantId]!;
        final newScore = existing.score + score;
        final newMatches = Map<String, List<SearchIndexEntry>>.from(existing.matches);
        
        newMatches.putIfAbsent(entry.field, () => []).add(entry);
        
        resultMap[restaurantId] = IndexedSearchResult(
          restaurantId: restaurantId,
          score: newScore,
          matches: newMatches,
        );
      } else {
        // Cria novo resultado
        resultMap[restaurantId] = IndexedSearchResult(
          restaurantId: restaurantId,
          score: score,
          matches: {
            entry.field: [entry],
          },
        );
      }
    }
  }
  
  /// Salva índice no cache
  Future<void> _saveIndexToCache() async {
    try {
      final indexData = {
        'tokenIndex': _tokenIndex.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
        'nGramIndex': _nGramIndex.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
        'entryIndex': _entryIndex.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'lastUpdate': DateTime.now().toIso8601String(),
      };
      
      await _cacheService.set(
        'search_index',
        indexData,
        ttl: const Duration(hours: 24),
      );
      
      debugPrint('Search index saved to cache');
    } catch (e) {
      debugPrint('Error saving index to cache: $e');
    }
  }
  
  /// Carrega índice do cache
  Future<bool> loadIndexFromCache() async {
    try {
      final indexData = await _cacheService.get('search_index');
      if (indexData == null) return false;
      
      _clearIndexes();
      
      // Carrega token index
      final tokenIndexData = indexData['tokenIndex'] as Map<String, dynamic>;
      for (final entry in tokenIndexData.entries) {
        final entries = (entry.value as List)
            .map((e) => SearchIndexEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _tokenIndex[entry.key] = entries;
      }
      
      // Carrega n-gram index
      final nGramIndexData = indexData['nGramIndex'] as Map<String, dynamic>;
      for (final entry in nGramIndexData.entries) {
        final entries = (entry.value as List)
            .map((e) => SearchIndexEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _nGramIndex[entry.key] = entries;
      }
      
      // Carrega entry index
      final entryIndexData = indexData['entryIndex'] as Map<String, dynamic>;
      for (final entry in entryIndexData.entries) {
        _entryIndex[entry.key] = SearchIndexEntry.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
      
      _isIndexed = true;
      _lastIndexUpdate = DateTime.parse(indexData['lastUpdate'] as String);
      
      debugPrint('Search index loaded from cache');
      debugPrint('Token index size: ${_tokenIndex.length}');
      debugPrint('N-gram index size: ${_nGramIndex.length}');
      
      return true;
    } catch (e) {
      debugPrint('Error loading index from cache: $e');
      return false;
    }
  }
  
  /// Limpa todos os índices
  void _clearIndexes() {
    _tokenIndex.clear();
    _nGramIndex.clear();
    _entryIndex.clear();
    _isIndexed = false;
    _lastIndexUpdate = null;
  }
  
  /// Atualiza um restaurante no índice
  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    if (!_isIndexed) return;
    
    // Remove entradas antigas
    _removeRestaurantFromIndex(restaurant.id);
    
    // Adiciona novas entradas
    await _indexRestaurant(restaurant);
    
    // Atualiza cache
    await _saveIndexToCache();
    
    debugPrint('Restaurant ${restaurant.id} updated in index');
  }
  
  /// Remove restaurante do índice
  void _removeRestaurantFromIndex(String restaurantId) {
    final entriesToRemove = _entryIndex.values
        .where((entry) => entry.metadata['restaurantId'] == restaurantId)
        .toList();
    
    for (final entry in entriesToRemove) {
      // Remove do índice de entradas
      _entryIndex.remove(entry.id);
      
      // Remove do índice de tokens
      for (final token in entry.tokens) {
        _tokenIndex[token]?.removeWhere((e) => e.id == entry.id);
        if (_tokenIndex[token]?.isEmpty == true) {
          _tokenIndex.remove(token);
        }
        
        // Remove do índice de n-gramas
        if (_config.enableNGrams) {
          final nGrams = _generateNGrams(token, _config.nGramSize);
          for (final nGram in nGrams) {
            _nGramIndex[nGram]?.removeWhere((e) => e.id == entry.id);
            if (_nGramIndex[nGram]?.isEmpty == true) {
              _nGramIndex.remove(nGram);
            }
          }
        }
      }
    }
  }
  
  /// Obtém estatísticas do índice
  Map<String, dynamic> getIndexStats() {
    return {
      'isIndexed': _isIndexed,
      'lastUpdate': _lastIndexUpdate?.toIso8601String(),
      'tokenIndexSize': _tokenIndex.length,
      'nGramIndexSize': _nGramIndex.length,
      'entryIndexSize': _entryIndex.length,
      'totalEntries': _entryIndex.length,
      'config': {
        'indexedFields': _config.indexedFields,
        'fieldWeights': _config.fieldWeights,
        'enableNGrams': _config.enableNGrams,
        'nGramSize': _config.nGramSize,
        'enableStopWords': _config.enableStopWords,
      },
    };
  }
  
  /// Limpa cache do índice
  Future<void> clearIndexCache() async {
    await _cacheService.remove('search_index');
    _clearIndexes();
    debugPrint('Search index cache cleared');
  }
}

/// Extensões úteis
extension IndexedSearchResultExtension on IndexedSearchResult {
  /// Obtém o melhor match por campo
  SearchIndexEntry? getBestMatchForField(String field) {
    final fieldMatches = matches[field];
    if (fieldMatches == null || fieldMatches.isEmpty) return null;
    
    return fieldMatches.reduce((a, b) => 
        (a.metadata['weight'] as double) > (b.metadata['weight'] as double) ? a : b);
  }
  
  /// Obtém todos os campos com matches
  List<String> get matchedFields => matches.keys.toList();
  
  /// Verifica se tem match em um campo específico
  bool hasMatchInField(String field) => matches.containsKey(field);
  
  /// Obtém score normalizado (0.0 a 1.0)
  double get normalizedScore {
    // Normaliza baseado no score máximo possível
    const maxPossibleScore = 10.0;
    return (score / maxPossibleScore).clamp(0.0, 1.0);
  }
}