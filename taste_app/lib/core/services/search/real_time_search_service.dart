import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/data/repositories/restaurant_repository.dart';
import 'package:taste_app/data/repositories/search_history_repository.dart';
import '../../../core/di/injection_container.dart';

/// Modelo para resultado de busca em tempo real
class RealTimeSearchResult {
  final List<RestaurantModel> restaurants;
  final String query;
  final Map<String, dynamic> filters;
  final DateTime timestamp;
  final bool isFromCache;
  final int totalCount;
  
  const RealTimeSearchResult({
    required this.restaurants,
    required this.query,
    required this.filters,
    required this.timestamp,
    required this.isFromCache,
    required this.totalCount,
  });
  
  factory RealTimeSearchResult.fromJson(Map<String, dynamic> json) {
    return RealTimeSearchResult(
      restaurants: (json['restaurants'] as List)
          .map((r) => RestaurantModel.fromJson(r))
          .toList(),
      query: json['query'] as String,
      filters: json['filters'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromCache: json['isFromCache'] as bool,
      totalCount: json['totalCount'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'restaurants': restaurants.map((r) => r.toJson()).toList(),
      'query': query,
      'filters': filters,
      'timestamp': timestamp.toIso8601String(),
      'isFromCache': isFromCache,
      'totalCount': totalCount,
    };
  }
}

/// Configurações para busca em tempo real
class RealTimeSearchConfig {
  final Duration debounceDelay;
  final Duration cacheExpiration;
  final int maxCacheSize;
  final int minQueryLength;
  final int maxResults;
  final bool enableCache;
  final bool enableHistory;
  
  const RealTimeSearchConfig({
    this.debounceDelay = const Duration(milliseconds: 300),
    this.cacheExpiration = const Duration(minutes: 15),
    this.maxCacheSize = 100,
    this.minQueryLength = 2,
    this.maxResults = 20,
    this.enableCache = true,
    this.enableHistory = true,
  });
}

/// Serviço de busca em tempo real
class RealTimeSearchService {
  static RealTimeSearchService? _instance;
  static RealTimeSearchService get instance => _instance ??= RealTimeSearchService._();
  
  RealTimeSearchService._();
  
  final RestaurantRepository _restaurantRepository = getIt<RestaurantRepository>();
  final SearchHistoryRepository _searchHistoryRepository = getIt<SearchHistoryRepository>();
  final CacheService _cacheService = CacheService.instance;
  
  final RealTimeSearchConfig _config = const RealTimeSearchConfig();
  
  // Cache em memória para resultados recentes
  final Map<String, RealTimeSearchResult> _memoryCache = {};
  
  // Controle de debounce
  Timer? _debounceTimer;
  
  // Stream controllers
  final StreamController<RealTimeSearchResult> _resultsController =
      StreamController<RealTimeSearchResult>.broadcast();
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();
  final StreamController<String?> _errorController =
      StreamController<String?>.broadcast();
  
  /// Stream de resultados de busca
  Stream<RealTimeSearchResult> get resultsStream => _resultsController.stream;
  
  /// Stream de estado de carregamento
  Stream<bool> get loadingStream => _loadingController.stream;
  
  /// Stream de erros
  Stream<String?> get errorStream => _errorController.stream;
  
  /// Realiza busca em tempo real
  void search({
    required String query,
    Map<String, dynamic>? filters,
    bool forceRefresh = false,
  }) {
    // Cancela busca anterior
    _debounceTimer?.cancel();
    
    // Limpa erro anterior
    _errorController.add(null);
    
    // Verifica se a query é válida
    if (query.trim().length < _config.minQueryLength) {
      _resultsController.add(RealTimeSearchResult(
        restaurants: [],
        query: query,
        filters: filters ?? {},
        timestamp: DateTime.now(),
        isFromCache: false,
        totalCount: 0,
      ));
      return;
    }
    
    // Aplica debounce
    _debounceTimer = Timer(_config.debounceDelay, () {
      _performSearch(
        query: query.trim(),
        filters: filters ?? {},
        forceRefresh: forceRefresh,
      );
    });
  }
  
  /// Executa a busca
  Future<void> _performSearch({
    required String query,
    required Map<String, dynamic> filters,
    required bool forceRefresh,
  }) async {
    try {
      _loadingController.add(true);
      
      final cacheKey = _generateCacheKey(query, filters);
      
      // Verifica cache primeiro (se não for refresh forçado)
      if (!forceRefresh && _config.enableCache) {
        final cachedResult = await _getCachedResult(cacheKey);
        if (cachedResult != null) {
          _resultsController.add(cachedResult.copyWith(isFromCache: true));
          _loadingController.add(false);
          return;
        }
      }
      
      // Busca no repositório
      final restaurants = await _restaurantRepository.searchRestaurants(query);
      
      final result = RealTimeSearchResult(
        restaurants: restaurants,
        query: query,
        filters: filters,
        timestamp: DateTime.now(),
        isFromCache: false,
        totalCount: restaurants.length,
      );
      
      // Salva no cache
      if (_config.enableCache) {
        await _cacheResult(cacheKey, result);
      }
      
      // Salva no histórico
      if (_config.enableHistory && query.isNotEmpty) {
        await _searchHistoryRepository.addSearch(query);
      }
      
      _resultsController.add(result);
      
    } catch (e) {
      debugPrint('Error in real-time search: $e');
      _errorController.add('Erro na busca: ${e.toString()}');
    } finally {
      _loadingController.add(false);
    }
  }
  
  /// Gera chave de cache
  String _generateCacheKey(String query, Map<String, dynamic> filters) {
    final filterString = json.encode(filters);
    return 'search_${query.toLowerCase()}_${filterString.hashCode}';
  }
  
  /// Obtém resultado do cache
  Future<RealTimeSearchResult?> _getCachedResult(String cacheKey) async {
    try {
      // Verifica cache em memória primeiro
      if (_memoryCache.containsKey(cacheKey)) {
        final cached = _memoryCache[cacheKey]!;
        final age = DateTime.now().difference(cached.timestamp);
        
        if (age < _config.cacheExpiration) {
          return cached;
        } else {
          _memoryCache.remove(cacheKey);
        }
      }
      
      // Verifica cache persistente
      final cachedData = await _cacheService.get(cacheKey);
      if (cachedData != null) {
        final result = RealTimeSearchResult.fromJson(cachedData);
        final age = DateTime.now().difference(result.timestamp);
        
        if (age < _config.cacheExpiration) {
          // Adiciona ao cache em memória
          _memoryCache[cacheKey] = result;
          return result;
        } else {
          // Remove cache expirado
          await _cacheService.remove(cacheKey);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting cached result: $e');
      return null;
    }
  }
  
  /// Salva resultado no cache
  Future<void> _cacheResult(String cacheKey, RealTimeSearchResult result) async {
    try {
      // Salva no cache em memória
      _memoryCache[cacheKey] = result;
      
      // Limita tamanho do cache em memória
      if (_memoryCache.length > _config.maxCacheSize) {
        final oldestKey = _memoryCache.keys.first;
        _memoryCache.remove(oldestKey);
      }
      
      // Salva no cache persistente
      await _cacheService.set(
        cacheKey,
        result.toJson(),
        expiration: _config.cacheExpiration,
      );
    } catch (e) {
      debugPrint('Error caching result: $e');
    }
  }
  
  /// Limpa cache de busca
  Future<void> clearCache() async {
    try {
      _memoryCache.clear();
      
      // Remove caches persistentes relacionados à busca
      final keys = await _cacheService.getKeys();
      final searchKeys = keys.where((key) => key.startsWith('search_'));
      
      for (final key in searchKeys) {
        await _cacheService.remove(key);
      }
      
      debugPrint('Search cache cleared');
    } catch (e) {
      debugPrint('Error clearing search cache: $e');
    }
  }
  
  /// Pré-carrega buscas populares
  Future<void> preloadPopularSearches() async {
    try {
      final popularQueries = [
        'pizza',
        'hambúrguer',
        'sushi',
        'café',
        'sobremesa',
      ];
      
      for (final query in popularQueries) {
        await _performSearch(
          query: query,
          filters: {},
          forceRefresh: false,
        );
        
        // Pequeno delay entre as buscas
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      debugPrint('Popular searches preloaded');
    } catch (e) {
      debugPrint('Error preloading popular searches: $e');
    }
  }
  
  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCache': {
        'size': _memoryCache.length,
        'maxSize': _config.maxCacheSize,
        'keys': _memoryCache.keys.toList(),
      },
      'config': {
        'debounceDelay': _config.debounceDelay.inMilliseconds,
        'cacheExpiration': _config.cacheExpiration.inMinutes,
        'maxResults': _config.maxResults,
        'minQueryLength': _config.minQueryLength,
      },
    };
  }
  
  /// Cancela busca atual
  void cancelSearch() {
    _debounceTimer?.cancel();
    _loadingController.add(false);
  }
  
  /// Limpa recursos
  void dispose() {
    _debounceTimer?.cancel();
    _resultsController.close();
    _loadingController.close();
    _errorController.close();
    _memoryCache.clear();
  }
}

/// Extensão para RealTimeSearchResult
extension RealTimeSearchResultExtension on RealTimeSearchResult {
  RealTimeSearchResult copyWith({
    List<RestaurantModel>? restaurants,
    String? query,
    Map<String, dynamic>? filters,
    DateTime? timestamp,
    bool? isFromCache,
    int? totalCount,
  }) {
    return RealTimeSearchResult(
      restaurants: restaurants ?? this.restaurants,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      timestamp: timestamp ?? this.timestamp,
      isFromCache: isFromCache ?? this.isFromCache,
      totalCount: totalCount ?? this.totalCount,
    );
  }
  
  /// Verifica se o resultado está expirado
  bool get isExpired {
    const expiration = Duration(minutes: 15);
    return DateTime.now().difference(timestamp) > expiration;
  }
  
  /// Obtém idade do resultado
  Duration get age => DateTime.now().difference(timestamp);
  
  /// Verifica se há resultados
  bool get hasResults => restaurants.isNotEmpty;
  
  /// Obtém texto de status
  String get statusText {
    if (restaurants.isEmpty) {
      return 'Nenhum resultado encontrado';
    }
    
    final cacheText = isFromCache ? ' (cache)' : '';
    return '${restaurants.length} resultado${restaurants.length != 1 ? 's' : ''} encontrado${restaurants.length != 1 ? 's' : ''}$cacheText';
  }
}

/// Widget para exibir status da busca em tempo real
class RealTimeSearchStatus extends StatefulWidget {
  final Widget? child;
  
  const RealTimeSearchStatus({
    super.key,
    this.child,
  });
  
  @override
  State<RealTimeSearchStatus> createState() => _RealTimeSearchStatusState();
}

class _RealTimeSearchStatusState extends State<RealTimeSearchStatus> {
  late StreamSubscription<bool> _loadingSubscription;
  late StreamSubscription<String?> _errorSubscription;
  late StreamSubscription<RealTimeSearchResult> _resultsSubscription;
  
  bool _isLoading = false;
  String? _error;
  RealTimeSearchResult? _lastResult;
  
  @override
  void initState() {
    super.initState();
    
    _loadingSubscription = RealTimeSearchService.instance.loadingStream.listen(
      (loading) {
        if (mounted) {
          setState(() {
            _isLoading = loading;
          });
        }
      },
    );
    
    _errorSubscription = RealTimeSearchService.instance.errorStream.listen(
      (error) {
        if (mounted) {
          setState(() {
            _error = error;
          });
        }
      },
    );
    
    _resultsSubscription = RealTimeSearchService.instance.resultsStream.listen(
      (result) {
        if (mounted) {
          setState(() {
            _lastResult = result;
            _error = null;
          });
        }
      },
    );
  }
  
  @override
  void dispose() {
    _loadingSubscription.cancel();
    _errorSubscription.cancel();
    _resultsSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status da busca
        if (_isLoading || _error != null || _lastResult != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_error != null)
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red,
                  )
                else if (_lastResult != null)
                  Icon(
                    _lastResult!.isFromCache ? Icons.cached : Icons.search,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error ?? _lastResult?.statusText ?? 'Buscando...',
                    style: TextStyle(
                      fontSize: 12,
                      color: _error != null ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Conteúdo
        if (widget.child != null) widget.child!,
      ],
    );
  }
}
