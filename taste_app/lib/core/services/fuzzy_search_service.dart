import 'dart:math';
import 'package:flutter/material.dart';
import 'package:taste_app/data/models/restaurant_model.dart';

/// Resultado de busca fuzzy
class FuzzySearchResult {
  final RestaurantModel restaurant;
  final double score;
  final List<FuzzyMatch> matches;
  
  const FuzzySearchResult({
    required this.restaurant,
    required this.score,
    required this.matches,
  });
}

/// Match fuzzy individual
class FuzzyMatch {
  final String field;
  final String value;
  final double score;
  final List<int> matchedIndices;
  
  const FuzzyMatch({
    required this.field,
    required this.value,
    required this.score,
    required this.matchedIndices,
  });
}

/// Configurações de busca fuzzy
class FuzzySearchConfig {
  final double threshold;
  final int maxDistance;
  final Map<String, double> fieldWeights;
  final bool caseSensitive;
  final bool includeMatches;
  final int maxResults;
  
  const FuzzySearchConfig({
    this.threshold = 0.3,
    this.maxDistance = 3,
    this.fieldWeights = const {
      'name': 1.0,
      'cuisine': 0.8,
      'description': 0.6,
      'address': 0.4,
      'tags': 0.7,
    },
    this.caseSensitive = false,
    this.includeMatches = true,
    this.maxResults = 50,
  });
}

/// Serviço de busca fuzzy
class FuzzySearchService {
  static FuzzySearchService? _instance;
  static FuzzySearchService get instance => _instance ??= FuzzySearchService._();
  
  FuzzySearchService._();
  
  final FuzzySearchConfig _config = const FuzzySearchConfig();
  
  /// Realiza busca fuzzy em uma lista de restaurantes
  List<FuzzySearchResult> search(
    String query,
    List<RestaurantModel> restaurants, {
    FuzzySearchConfig? config,
  }) {
    if (query.trim().isEmpty) return [];
    
    final searchConfig = config ?? _config;
    final normalizedQuery = _normalizeString(query, searchConfig.caseSensitive);
    
    final results = <FuzzySearchResult>[];
    
    for (final restaurant in restaurants) {
      final result = _searchInRestaurant(normalizedQuery, restaurant, searchConfig);
      if (result != null && result.score >= searchConfig.threshold) {
        results.add(result);
      }
    }
    
    // Ordena por score (maior primeiro)
    results.sort((a, b) => b.score.compareTo(a.score));
    
    // Limita resultados
    return results.take(searchConfig.maxResults).toList();
  }
  
  /// Busca fuzzy em um restaurante específico
  FuzzySearchResult? _searchInRestaurant(
    String query,
    RestaurantModel restaurant,
    FuzzySearchConfig config,
  ) {
    final matches = <FuzzyMatch>[];
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    // Busca no nome
    if (config.fieldWeights.containsKey('name')) {
      final nameMatch = _fuzzyMatch(
        query,
        _normalizeString(restaurant.name, config.caseSensitive),
        config,
      );
      
      if (nameMatch != null) {
        final weight = config.fieldWeights['name']!;
        matches.add(FuzzyMatch(
          field: 'name',
          value: restaurant.name,
          score: nameMatch.score,
          matchedIndices: nameMatch.indices,
        ));
        totalScore += nameMatch.score * weight;
        totalWeight += weight;
      }
    }
    
    // Busca na culinária
    if (config.fieldWeights.containsKey('cuisine') && restaurant.cuisine.isNotEmpty) {
      final cuisineMatch = _fuzzyMatch(
        query,
        _normalizeString(restaurant.cuisine, config.caseSensitive),
        config,
      );
      
      if (cuisineMatch != null) {
        final weight = config.fieldWeights['cuisine']!;
        matches.add(FuzzyMatch(
          field: 'cuisine',
          value: restaurant.cuisine,
          score: cuisineMatch.score,
          matchedIndices: cuisineMatch.indices,
        ));
        totalScore += cuisineMatch.score * weight;
        totalWeight += weight;
      }
    }
    
    // Busca na descrição
    if (config.fieldWeights.containsKey('description') && restaurant.description.isNotEmpty) {
      final descriptionMatch = _fuzzyMatch(
        query,
        _normalizeString(restaurant.description, config.caseSensitive),
        config,
      );
      
      if (descriptionMatch != null) {
        final weight = config.fieldWeights['description']!;
        matches.add(FuzzyMatch(
          field: 'description',
          value: restaurant.description,
          score: descriptionMatch.score,
          matchedIndices: descriptionMatch.indices,
        ));
        totalScore += descriptionMatch.score * weight;
        totalWeight += weight;
      }
    }
    
    // Busca no endereço
    if (config.fieldWeights.containsKey('address') && restaurant.address.isNotEmpty) {
      final addressMatch = _fuzzyMatch(
        query,
        _normalizeString(restaurant.address, config.caseSensitive),
        config,
      );
      
      if (addressMatch != null) {
        final weight = config.fieldWeights['address']!;
        matches.add(FuzzyMatch(
          field: 'address',
          value: restaurant.address,
          score: addressMatch.score,
          matchedIndices: addressMatch.indices,
        ));
        totalScore += addressMatch.score * weight;
        totalWeight += weight;
      }
    }
    
    // Busca nas tags
    if (config.fieldWeights.containsKey('tags') && restaurant.tags.isNotEmpty) {
      for (final tag in restaurant.tags) {
        final tagMatch = _fuzzyMatch(
          query,
          _normalizeString(tag, config.caseSensitive),
          config,
        );
        
        if (tagMatch != null) {
          final weight = config.fieldWeights['tags']!;
          matches.add(FuzzyMatch(
            field: 'tags',
            value: tag,
            score: tagMatch.score,
            matchedIndices: tagMatch.indices,
          ));
          totalScore += tagMatch.score * weight;
          totalWeight += weight;
        }
      }
    }
    
    if (matches.isEmpty || totalWeight == 0) return null;
    
    final finalScore = totalScore / totalWeight;
    
    return FuzzySearchResult(
      restaurant: restaurant,
      score: finalScore,
      matches: matches,
    );
  }
  
  /// Realiza match fuzzy entre duas strings
  _FuzzyMatchResult? _fuzzyMatch(
    String pattern,
    String text,
    FuzzySearchConfig config,
  ) {
    if (pattern.isEmpty || text.isEmpty) return null;
    
    // Busca exata primeiro (score máximo)
    if (text.contains(pattern)) {
      final startIndex = text.indexOf(pattern);
      return _FuzzyMatchResult(
        score: 1.0,
        indices: List.generate(
          pattern.length,
          (i) => startIndex + i,
        ),
      );
    }
    
    // Busca fuzzy usando algoritmo de distância de Levenshtein modificado
    final result = _fuzzyMatchAdvanced(pattern, text, config.maxDistance);
    
    if (result == null) return null;
    
    // Normaliza o score (0.0 a 1.0)
    final normalizedScore = _normalizeScore(
      result.score,
      pattern.length,
      text.length,
    );
    
    return _FuzzyMatchResult(
      score: normalizedScore,
      indices: result.indices,
    );
  }
  
  /// Algoritmo de busca fuzzy avançado
  _FuzzyMatchResult? _fuzzyMatchAdvanced(
    String pattern,
    String text,
    int maxDistance,
  ) {
    final patternLength = pattern.length;
    final textLength = text.length;
    
    if (patternLength == 0) return null;
    
    final matchedIndices = <int>[];
    int patternIndex = 0;
    int score = 0;
    
    for (int textIndex = 0; textIndex < textLength && patternIndex < patternLength; textIndex++) {
      if (pattern[patternIndex] == text[textIndex]) {
        matchedIndices.add(textIndex);
        score += 2; // Match exato vale mais
        patternIndex++;
      } else {
        // Verifica caracteres próximos (tolerância a erros)
        bool foundNear = false;
        for (int offset = 1; offset <= maxDistance && textIndex + offset < textLength; offset++) {
          if (pattern[patternIndex] == text[textIndex + offset]) {
            matchedIndices.add(textIndex + offset);
            score += 1; // Match próximo vale menos
            patternIndex++;
            textIndex += offset;
            foundNear = true;
            break;
          }
        }
        
        if (!foundNear) {
          // Verifica se pode pular caractere do pattern (inserção)
          if (patternIndex + 1 < patternLength) {
            for (int offset = 1; offset <= maxDistance; offset++) {
              if (patternIndex + offset < patternLength && 
                  pattern[patternIndex + offset] == text[textIndex]) {
                matchedIndices.add(textIndex);
                score += 1;
                patternIndex += offset + 1;
                foundNear = true;
                break;
              }
            }
          }
        }
      }
    }
    
    // Verifica se encontrou pelo menos 60% do pattern
    if (matchedIndices.length < (patternLength * 0.6).ceil()) {
      return null;
    }
    
    return _FuzzyMatchResult(
      score: score.toDouble(),
      indices: matchedIndices,
    );
  }
  
  /// Normaliza o score para um valor entre 0.0 e 1.0
  double _normalizeScore(double rawScore, int patternLength, int textLength) {
    final maxPossibleScore = patternLength * 2.0; // Todos os caracteres com match exato
    final normalizedScore = rawScore / maxPossibleScore;
    
    // Aplica bônus para matches em textos menores (mais precisos)
    final lengthBonus = 1.0 - (textLength - patternLength).abs() / (textLength + patternLength);
    
    return (normalizedScore * 0.8 + lengthBonus * 0.2).clamp(0.0, 1.0);
  }
  
  /// Normaliza string para busca
  String _normalizeString(String text, bool caseSensitive) {
    String normalized = text;
    
    if (!caseSensitive) {
      normalized = normalized.toLowerCase();
    }
    
    // Remove acentos
    normalized = _removeAccents(normalized);
    
    // Remove caracteres especiais extras
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    
    // Normaliza espaços
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return normalized;
  }
  
  /// Remove acentos de uma string
  String _removeAccents(String text) {
    const accents = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
      'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Ç': 'C', 'Ñ': 'N',
    };
    
    String result = text;
    accents.forEach((accented, normal) {
      result = result.replaceAll(accented, normal);
    });
    
    return result;
  }
  
  /// Calcula distância de Levenshtein entre duas strings
  int levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final matrix = List.generate(
      a.length + 1,
      (i) => List.filled(b.length + 1, 0),
    );
    
    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    
    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,     // deletion
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce(min);
      }
    }
    
    return matrix[a.length][b.length];
  }
  
  /// Calcula similaridade entre duas strings (0.0 a 1.0)
  double similarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final distance = levenshteinDistance(a, b);
    final maxLength = max(a.length, b.length);
    
    return 1.0 - (distance / maxLength);
  }
  
  /// Sugere correções para uma query
  List<String> suggestCorrections(
    String query,
    List<String> dictionary, {
    int maxSuggestions = 5,
    double minSimilarity = 0.6,
  }) {
    if (query.trim().isEmpty) return [];
    
    final normalizedQuery = _normalizeString(query, false);
    final suggestions = <MapEntry<String, double>>[];
    
    for (final word in dictionary) {
      final normalizedWord = _normalizeString(word, false);
      final sim = similarity(normalizedQuery, normalizedWord);
      
      if (sim >= minSimilarity) {
        suggestions.add(MapEntry(word, sim));
      }
    }
    
    suggestions.sort((a, b) => b.value.compareTo(a.value));
    
    return suggestions
        .take(maxSuggestions)
        .map((e) => e.key)
        .toList();
  }
}

/// Resultado interno de match fuzzy
class _FuzzyMatchResult {
  final double score;
  final List<int> indices;
  
  const _FuzzyMatchResult({
    required this.score,
    required this.indices,
  });
}

/// Widget para destacar matches fuzzy
class FuzzyHighlightText extends StatelessWidget {
  final String text;
  final List<int> matchedIndices;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int maxLines;
  final TextOverflow overflow;
  
  const FuzzyHighlightText({
    super.key,
    required this.text,
    required this.matchedIndices,
    this.style,
    this.highlightStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });
  
  @override
  Widget build(BuildContext context) {
    if (matchedIndices.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    
    final spans = <TextSpan>[];
    final highlightedIndices = Set<int>.from(matchedIndices);
    
    for (int i = 0; i < text.length; i++) {
      final isHighlighted = highlightedIndices.contains(i);
      final char = text[i];
      
      spans.add(TextSpan(
        text: char,
        style: isHighlighted 
            ? (highlightStyle ?? TextStyle(
                backgroundColor: Colors.yellow.withOpacity(0.3),
                fontWeight: FontWeight.bold,
              ))
            : style,
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Extensões úteis
extension FuzzySearchResultExtension on FuzzySearchResult {
  /// Obtém o melhor match
  FuzzyMatch? get bestMatch {
    if (matches.isEmpty) return null;
    return matches.reduce((a, b) => a.score > b.score ? a : b);
  }
  
  /// Verifica se é um match exato
  bool get isExactMatch => score >= 0.95;
  
  /// Verifica se é um bom match
  bool get isGoodMatch => score >= 0.7;
  
  /// Obtém descrição do match
  String get matchDescription {
    if (isExactMatch) return 'Match exato';
    if (isGoodMatch) return 'Boa correspondência';
    return 'Correspondência parcial';
  }
}