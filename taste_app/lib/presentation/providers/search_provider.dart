import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/search_filters.dart';
import '../../data/models/search_params.dart' as search_params;
import '../../../core/di/injection_container.dart';

/// Estado da busca
class SearchState {
  final List<RestaurantModel> restaurants;
  final List<String> suggestions;
  final List<String> searchHistory;
  final List<String> popularTerms;
  final String currentQuery;
  final SearchFilters filters;
  final bool isLoading;
  final bool isLoadingSuggestions;
  final String? error;
  final int totalResults;
  final int searchTime;

  const SearchState({
    this.restaurants = const [],
    this.suggestions = const [],
    this.searchHistory = const [],
    this.popularTerms = const [],
    this.currentQuery = '',
    this.filters = const SearchFilters(),
    this.isLoading = false,
    this.isLoadingSuggestions = false,
    this.error,
    this.totalResults = 0,
    this.searchTime = 0,
  });

  SearchState copyWith({
    List<RestaurantModel>? restaurants,
    List<String>? suggestions,
    List<String>? searchHistory,
    List<String>? popularTerms,
    String? currentQuery,
    SearchFilters? filters,
    bool? isLoading,
    bool? isLoadingSuggestions,
    String? error,
    int? totalResults,
    int? searchTime,
  }) {
    return SearchState(
      restaurants: restaurants ?? this.restaurants,
      suggestions: suggestions ?? this.suggestions,
      searchHistory: searchHistory ?? this.searchHistory,
      popularTerms: popularTerms ?? this.popularTerms,
      currentQuery: currentQuery ?? this.currentQuery,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      error: error,
      totalResults: totalResults ?? this.totalResults,
      searchTime: searchTime ?? this.searchTime,
    );
  }

  bool get hasResults => restaurants.isNotEmpty;
  bool get hasError => error != null;
  bool get isEmpty => restaurants.isEmpty && !isLoading;
  bool get hasSuggestions => suggestions.isNotEmpty;
  bool get hasHistory => searchHistory.isNotEmpty;

  @override
  String toString() {
    return 'SearchState(query: $currentQuery, results: ${restaurants.length}, loading: $isLoading)';
  }
}

/// Provider do repositório de busca
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return getIt<SearchRepository>();
});

/// Provider principal da busca
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchNotifier(repository);
});

/// Notifier para gerenciar o estado da busca
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState()) {
    _initialize();
  }

  /// Inicializar dados
  Future<void> _initialize() async {
    try {
      final history = await _repository.getSearchHistory();
      final popularTerms = await _repository.getPopularSearchTerms();
      
      state = state.copyWith(
        searchHistory: history,
        popularTerms: popularTerms,
      );
    } catch (e) {
      debugPrint('Erro ao inicializar SearchProvider: $e');
    }
  }

  /// Buscar restaurantes
  Future<void> searchRestaurants(String query) async {
    if (query.trim() == state.currentQuery.trim()) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentQuery: query.trim(),
    );

    try {
      final params = search_params.SearchParams(
        query: query,
        categoryId: state.filters.categoryId,
        latitude: state.filters.latitude,
        longitude: state.filters.longitude,
        maxDistance: state.filters.maxDistance,
        minRating: state.filters.minRating,
        isOpen: state.filters.isOpen,
        sortBy: state.filters.sortBy ?? 'relevance',
      );
      final results = await _repository.searchRestaurants(params);

      if (results.hasError) {
        state = state.copyWith(
          isLoading: false,
          error: results.error,
          restaurants: [],
          totalResults: 0,
          searchTime: 0,
        );
      } else {
        // Atualizar histórico
        final updatedHistory = await _repository.getSearchHistory();
        
        state = state.copyWith(
          isLoading: false,
          restaurants: results.restaurants,
          searchHistory: updatedHistory,
          totalResults: results.totalCount,
          searchTime: 0,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        restaurants: [],
        totalResults: 0,
      );
    }
  }

  /// Buscar com filtros
  Future<void> searchWithFilters(String query, SearchFilters filters) async {
    state = state.copyWith(
      filters: filters,
      isLoading: true,
      error: null,
      currentQuery: query.trim(),
    );

    try {
      final params = search_params.SearchParams(
        query: query,
        categoryId: filters.categoryId,
        latitude: filters.latitude,
        longitude: filters.longitude,
        maxDistance: filters.maxDistance,
        minRating: filters.minRating,
        isOpen: filters.isOpen,
        sortBy: filters.sortBy ?? 'relevance',
      );
      final results = await _repository.searchRestaurants(params);

      if (results.hasError) {
        state = state.copyWith(
          isLoading: false,
          error: results.error,
          restaurants: [],
          totalResults: 0,
          searchTime: 0,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          restaurants: results.restaurants,
          totalResults: results.totalCount,
          searchTime: 0,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        restaurants: [],
        totalResults: 0,
      );
    }
  }

  /// Obter sugestões de busca
  Future<void> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }

    state = state.copyWith(isLoadingSuggestions: true);

    try {
      final suggestions = await _repository.getSearchSuggestions(query);
      state = state.copyWith(
        suggestions: suggestions,
        isLoadingSuggestions: false,
      );
    } catch (e) {
      state = state.copyWith(
        suggestions: [],
        isLoadingSuggestions: false,
      );
      debugPrint('Erro ao obter sugestões: $e');
    }
  }

  /// Buscar por categoria
  Future<void> searchByCategory(String categoryId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      filters: state.filters.copyWith(categoryId: categoryId),
    );

    try {
      final restaurants = await _repository.searchByCategory(categoryId);
      state = state.copyWith(
        isLoading: false,
        restaurants: restaurants,
        totalResults: restaurants.length,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        restaurants: [],
        totalResults: 0,
      );
    }
  }

  /// Buscar restaurantes próximos
  Future<void> searchNearby({
    required double latitude,
    required double longitude,
    double maxDistance = 5.0,
    String? categoryId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      filters: state.filters.copyWith(
        latitude: latitude,
        longitude: longitude,
        maxDistance: maxDistance,
        categoryId: categoryId,
      ),
    );

    try {
      final restaurants = await _repository.searchNearbyRestaurants(
        latitude,
        longitude,
        radiusKm: maxDistance,
      );
      
      state = state.copyWith(
        isLoading: false,
        restaurants: restaurants,
        totalResults: restaurants.length,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        restaurants: [],
        totalResults: 0,
      );
    }
  }

  /// Aplicar filtros
  void applyFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    if (state.currentQuery.isNotEmpty) {
      searchWithFilters(state.currentQuery, filters);
    }
  }

  /// Limpar filtros
  void clearFilters() {
    state = state.copyWith(filters: const SearchFilters());
    if (state.currentQuery.isNotEmpty) {
      searchRestaurants(state.currentQuery);
    }
  }

  /// Limpar busca
  void clearSearch() {
    state = state.copyWith(
      restaurants: [],
      currentQuery: '',
      suggestions: [],
      totalResults: 0,
      searchTime: 0,
      error: null,
    );
  }

  /// Limpar histórico
  Future<void> clearHistory() async {
    try {
      // TODO: Implementar clearSearchHistory no repositório
      state = state.copyWith(searchHistory: []);
    } catch (e) {
      debugPrint('Erro ao limpar histórico: $e');
    }
  }

  /// Limpar cache
  void clearCache() {
    // TODO: Implementar clearSearchCache no repositório
  }

  /// Atualizar query atual (sem buscar)
  void updateQuery(String query) {
    state = state.copyWith(currentQuery: query);
  }

  /// Recarregar dados
  Future<void> refresh() async {
    if (state.currentQuery.isNotEmpty) {
      await searchRestaurants(state.currentQuery);
    }
    await _initialize();
  }
}

/// Provider para sugestões de busca
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getSearchSuggestions(query);
});

/// Provider para histórico de busca
final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getSearchHistory();
});

/// Provider para termos populares
final popularSearchTermsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getPopularSearchTerms();
});

/// Provider para busca por categoria
final searchByCategoryProvider = FutureProvider.family<List<RestaurantModel>, String>((ref, categoryId) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.searchByCategory(categoryId);
});

/// Provider para restaurantes próximos
final nearbyRestaurantsProvider = FutureProvider.family<List<RestaurantModel>, Map<String, double>>((ref, location) async {
  final repository = ref.read(searchRepositoryProvider);
  return repository.searchNearbyRestaurants(
    location['latitude']!,
    location['longitude']!,
    radiusKm: location['radius'] ?? 10.0,
  );
});
