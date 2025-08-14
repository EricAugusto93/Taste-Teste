import 'dart:math';
import 'package:flutter/foundation.dart';
import '../repositories/restaurant_repository.dart';
import '../repositories/category_repository.dart';
import '../models/restaurant_model.dart';
import '../models/category_model.dart';
import 'ai_search_service.dart';
import 'search_analytics_service.dart';

/// Serviço de busca inteligente para restaurantes
class SearchService {
  static SearchService? _instance;
  static SearchService get instance => _instance ??= SearchService._();
  SearchService._();

  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final CategoryRepository _categoryRepository = CategoryRepository.instance;
  final AISearchService _aiSearchService = AISearchService.instance;
  final SearchAnalyticsService _analyticsService = SearchAnalyticsService.instance;

  /// Cache de resultados de busca
  final Map<String, List<RestaurantModel>> _searchCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  /// Duração do cache (5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Busca inteligente de restaurantes com IA
  Future<SearchResults> searchRestaurants({
    required String query,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? maxDistance,
    double? minRating,
    bool? isOpen,
    String? sortBy,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      final aiStopwatch = Stopwatch()..start();
      
      // Interpretar a consulta com IA
      final interpretation = await _aiSearchService.interpretSearchQuery(query);
      aiStopwatch.stop();
      debugPrint('Interpretação da busca: $interpretation');
      
      // Usar a consulta normalizada ou corrigida
      String searchQuery = interpretation.normalizedQuery;
      if (interpretation.corrections.isNotEmpty && interpretation.confidence > 0.7) {
        searchQuery = interpretation.corrections.first;
        debugPrint('Usando correção sugerida: $searchQuery');
      }
      
      // Verificar cache
      final cacheKey = _generateCacheKey(
        searchQuery,
        categoryId,
        latitude,
        longitude,
        maxDistance,
        minRating,
        isOpen,
        sortBy,
      );
      
      if (_isCacheValid(cacheKey)) {
        debugPrint('Retornando resultados do cache para: $searchQuery');
        return SearchResults(
          restaurants: _searchCache[cacheKey]!,
          query: query,
          totalResults: _searchCache[cacheKey]!.length,
          searchTime: 0,
          interpretation: interpretation,
        );
      }

      // Buscar com o termo principal
      List<RestaurantModel> results = await _restaurantRepository.searchWithFilters(
        searchTerm: searchQuery.isEmpty ? null : searchQuery,
        categoryId: categoryId,
        minRating: minRating?.toDouble(),
        isOpen: isOpen,
        latitude: latitude,
        longitude: longitude,
        radiusKm: maxDistance ?? 10.0,
        limit: 50,
      );
      
      // Se não encontrou resultados, tentar com termos expandidos
      if (results.isEmpty && interpretation.expandedTerms.isNotEmpty) {
        for (final expandedTerm in interpretation.expandedTerms) {
          final expandedResults = await _restaurantRepository.searchWithFilters(
            searchTerm: expandedTerm,
            categoryId: categoryId,
            minRating: minRating?.toDouble(),
            isOpen: isOpen,
            latitude: latitude,
            longitude: longitude,
            radiusKm: maxDistance ?? 10.0,
             limit: 20,
          );
          results.addAll(expandedResults);
          if (results.length >= 10) break; // Limitar resultados
        }
      }
      
      // Busca por categoria baseada na intenção
      if (results.isEmpty && interpretation.intention == SearchIntention.cuisine) {
        final categoryResults = await _searchByCategory(searchQuery);
        if (categoryResults.isNotEmpty) {
          results = await _restaurantRepository.getRestaurantsByCategory(categoryResults.first.id);
        }
      }
      
      // Busca inteligente adicional se ainda não há resultados
      if (results.isEmpty && searchQuery.isNotEmpty) {
        results = await _intelligentSearch(searchQuery);
      }
      
      // Remover duplicatas
      final uniqueResults = <String, RestaurantModel>{};
      for (final restaurant in results) {
        uniqueResults[restaurant.id] = restaurant;
      }
      results = uniqueResults.values.toList();
      
      stopwatch.stop();
      final dbQueryTime = stopwatch.elapsedMilliseconds - aiStopwatch.elapsedMilliseconds;
      
      // Salvar no cache
      _searchCache[cacheKey] = results;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      debugPrint('Busca IA concluída em ${stopwatch.elapsedMilliseconds}ms: ${results.length} resultados');
      
      // Rastrear analytics detalhados
      await _analyticsService.trackAISearch(
        originalQuery: query,
        interpretation: interpretation,
        resultsCount: results.length,
        searchTimeMs: stopwatch.elapsedMilliseconds,
        categoryId: categoryId,
        filters: {
          'latitude': latitude,
          'longitude': longitude,
          'maxDistance': maxDistance,
          'minRating': minRating,
          'isOpen': isOpen,
          'sortBy': sortBy,
        },
      );
      
      // Rastrear performance
      await _analyticsService.trackSearchPerformance(
        query: query,
        totalTimeMs: stopwatch.elapsedMilliseconds,
        aiInterpretationTimeMs: aiStopwatch.elapsedMilliseconds,
        databaseQueryTimeMs: dbQueryTime,
        resultsCount: results.length,
        usedCache: _isCacheValid(cacheKey),
      );
      
      return SearchResults(
        restaurants: results,
        query: query,
        totalResults: results.length,
        searchTime: stopwatch.elapsedMilliseconds,
        interpretation: interpretation,
        aiProcessingTime: aiStopwatch.elapsedMilliseconds,
        dbQueryTime: dbQueryTime,
        usedCache: _isCacheValid(cacheKey),
      );
    } catch (e) {
      debugPrint('Erro na busca: $e');
      return SearchResults(
        restaurants: [],
        query: query,
        totalResults: 0,
        searchTime: 0,
        error: e.toString(),
      );
    }
  }

  /// Busca por categoria
  Future<List<CategoryModel>> _searchByCategory(String query) async {
    try {
      final categories = await _categoryRepository.getCategories();
      return categories.where((category) {
        return category.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint('Erro ao buscar categorias: $e');
      return [];
    }
  }

  /// Busca restaurantes por categoria (delegando para o repository)
  Future<List<RestaurantModel>> _getRestaurantsByCategory(String categoryId) async {
    try {
      return await _restaurantRepository.getRestaurantsByCategory(categoryId);
    } catch (e) {
      debugPrint('Erro ao buscar restaurantes por categoria: $e');
      return [];
    }
  }

  /// Busca inteligente com sinônimos e termos relacionados
  Future<List<RestaurantModel>> _intelligentSearch(String query) async {
    try {
      final restaurants = await _restaurantRepository.getRestaurants();
      final normalizedQuery = query.toLowerCase();
      
      // Mapa de sinônimos e termos relacionados
      final synonyms = {
        'pizza': ['pizzaria', 'italiana', 'italiano'],
        'hamburguer': ['burger', 'lanche', 'sanduiche'],
        'japonesa': ['japonês', 'sushi', 'sashimi', 'oriental'],
        'chinesa': ['chinês', 'oriental', 'asiática'],
        'brasileira': ['brasileiro', 'nacional', 'caseira'],
        'italiana': ['italiano', 'pizza', 'massa'],
        'mexicana': ['mexicano', 'tex-mex'],
        'vegetariana': ['vegetariano', 'vegana', 'vegano'],
        'doce': ['sobremesa', 'açaí', 'sorvete'],
        'bebida': ['suco', 'refrigerante', 'café'],
      };
      
      final results = <RestaurantModel>[];
      
      for (final restaurant in restaurants) {
        // Buscar no nome
        if (restaurant.name.toLowerCase().contains(normalizedQuery)) {
          results.add(restaurant);
          continue;
        }
        
        // Buscar na descrição
        if (restaurant.description?.toLowerCase().contains(normalizedQuery) == true) {
          results.add(restaurant);
          continue;
        }
        
        // Buscar por sinônimos
        for (final entry in synonyms.entries) {
          if (normalizedQuery.contains(entry.key) || 
              entry.value.any((synonym) => normalizedQuery.contains(synonym))) {
            if (restaurant.name.toLowerCase().contains(entry.key) ||
                restaurant.description?.toLowerCase().contains(entry.key) == true ||
                entry.value.any((synonym) => 
                  restaurant.name.toLowerCase().contains(synonym) ||
                  restaurant.description?.toLowerCase().contains(synonym) == true)) {
              results.add(restaurant);
              break;
            }
          }
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Erro na busca inteligente: $e');
      return [];
    }
  }

  /// Aplicar filtros aos resultados (método legado - usar RestaurantRepository.searchWithFilters)
  @deprecated
  List<RestaurantModel> _applyFilters(
    List<RestaurantModel> restaurants, {
    String? categoryId,
    double? latitude,
    double? longitude,
    double? maxDistance,
    double? minRating,
    bool? isOpen,
  }) {
    // Este método foi movido para RestaurantRepository.searchWithFilters
    // Mantido apenas para compatibilidade com busca inteligente
    var filtered = restaurants;
    
    if (categoryId != null) {
      filtered = filtered.where((r) => r.categoryId == categoryId).toList();
    }
    
    if (minRating != null) {
      filtered = filtered.where((r) => r.rating >= minRating).toList();
    }
    
    if (isOpen != null) {
      filtered = filtered.where((r) => r.isOpen == isOpen).toList();
    }
    
    return filtered;
  }

  /// Aplicar ordenação aos resultados (método legado - usar RestaurantRepository.searchWithFilters)
  @deprecated
  List<RestaurantModel> _applySorting(
    List<RestaurantModel> restaurants,
    String? sortBy,
    double? latitude,
    double? longitude,
  ) {
    // Este método foi movido para RestaurantRepository.searchWithFilters
    // Mantido apenas para compatibilidade com busca inteligente
    switch (sortBy) {
      case 'rating':
        restaurants.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        restaurants.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        restaurants.sort((a, b) {
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          return b.rating.compareTo(a.rating);
        });
    }
    
    return restaurants;
  }

  /// Calcular distância entre dois pontos (fórmula de Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Raio da Terra em km
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Normalizar query de busca
  String _normalizeQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// Gerar chave de cache
  String _generateCacheKey(
    String query,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? maxDistance,
    double? minRating,
    bool? isOpen,
    String? sortBy,
  ) {
    return '$query|$categoryId|$latitude|$longitude|$maxDistance|$minRating|$isOpen|$sortBy';
  }

  /// Verificar se o cache é válido
  bool _isCacheValid(String cacheKey) {
    if (!_searchCache.containsKey(cacheKey) || !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Limpar cache
  void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    debugPrint('Cache de busca limpo');
  }

  /// Obter sugestões de busca inteligentes
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.length < 2) return [];
      
      final stopwatch = Stopwatch()..start();
      
      // Usar IA para gerar sugestões inteligentes
      final aiSuggestions = await _aiSearchService.generateSearchSuggestions(query);
      
      // Combinar com sugestões tradicionais se necessário
      final suggestions = <String>{};
      suggestions.addAll(aiSuggestions);
      
      // Buscar em restaurantes se ainda precisamos de mais sugestões
      if (suggestions.length < 8) {
        final restaurants = await _restaurantRepository.getRestaurants();
        for (final restaurant in restaurants) {
          if (restaurant.name.toLowerCase().contains(query.toLowerCase())) {
            suggestions.add(restaurant.name);
            if (suggestions.length >= 8) break;
          }
        }
      }
      
      // Buscar em categorias se ainda precisamos de mais sugestões
      if (suggestions.length < 8) {
        final categories = await _categoryRepository.getCategories();
        for (final category in categories) {
          if (category.name.toLowerCase().contains(query.toLowerCase())) {
            suggestions.add(category.name);
            if (suggestions.length >= 8) break;
          }
        }
      }
      
      stopwatch.stop();
      final finalSuggestions = suggestions.take(8).toList();
      
      // Rastrear analytics das sugestões
      await _analyticsService.trackAISuggestions(
        partialQuery: query,
        suggestions: finalSuggestions,
        responseTimeMs: stopwatch.elapsedMilliseconds,
      );
      
      return finalSuggestions;
    } catch (e) {
      debugPrint('Erro ao obter sugestões: $e');
      return [];
    }
  }
}

/// Resultado de busca
class SearchResults {
  final List<RestaurantModel> restaurants;
  final String query;
  final int totalResults;
  final int searchTime; // em millisegundos
  final String? error;
  final SearchInterpretation? interpretation;
  
  // Métricas de performance
  final int? aiProcessingTime;
  final int? dbQueryTime;
  final bool? usedCache;

  SearchResults({
    required this.restaurants,
    required this.query,
    required this.totalResults,
    required this.searchTime,
    this.error,
    this.interpretation,
    this.aiProcessingTime,
    this.dbQueryTime,
    this.usedCache,
  });

  bool get hasError => error != null;
  bool get isEmpty => restaurants.isEmpty;
  bool get isNotEmpty => restaurants.isNotEmpty;
  bool get hasCorrections => interpretation?.corrections.isNotEmpty == true;
  bool get hasHighConfidence => interpretation?.confidence != null && interpretation!.confidence > 0.8;
}