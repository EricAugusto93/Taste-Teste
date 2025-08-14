import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';
import '../models/category_model.dart';
import '../models/search_params.dart';
import '../services/search_service.dart';
import '../services/location_service.dart';
import '../../core/utils/logger.dart';
import '../../core/services/cache_service.dart';
import '../../core/models/cache_item.dart';
import '../../core/di/injection_container.dart';

/// Resultado de busca com metadados
class SearchResult {
  final List<RestaurantModel> restaurants;
  final int totalCount;
  final bool hasMore;
  final String? error;
  final Map<String, dynamic>? metadata;

  const SearchResult({
    required this.restaurants,
    required this.totalCount,
    required this.hasMore,
    this.error,
    this.metadata,
  });

  bool get hasError => error != null;
  bool get isEmpty => restaurants.isEmpty;
  bool get isNotEmpty => restaurants.isNotEmpty;

  SearchResult copyWith({
    List<RestaurantModel>? restaurants,
    int? totalCount,
    bool? hasMore,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return SearchResult(
      restaurants: restaurants ?? this.restaurants,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }
}



/// Interface do repositório de busca
abstract class SearchRepository {
  Future<SearchResult> searchRestaurants(SearchParams params);
  Future<List<CategoryModel>> getCategories();
  Future<List<String>> getSearchSuggestions(String query);
  Future<List<String>> getPopularSearches();
  Future<List<String>> getRecentSearches(String userId);
  Future<void> saveRecentSearch(String userId, String query);
  Future<void> removeRecentSearch(String userId, String query);
  Future<void> clearRecentSearches(String userId);
  Future<List<RestaurantModel>> getFeaturedRestaurants();
  Future<List<RestaurantModel>> getNearbyRestaurants(double latitude, double longitude, {double radius = 10.0});
  Future<List<String>> getSearchHistory();
  Future<List<String>> getPopularSearchTerms();
  Future<List<RestaurantModel>> searchByCategory(String categoryId);
  Future<List<RestaurantModel>> searchNearbyRestaurants(double latitude, double longitude, {double radiusKm = 10.0});
  Future<void> addToSearchHistory(String query);
}

/// Implementação do repositório de busca com Supabase
class SearchRepositoryImpl implements SearchRepository {
  final SearchService _searchService;
  final SupabaseClient _supabase;
  final LocationService _locationService;
  final _cacheService = InjectionContainer.get<CacheService>();
  
  SearchRepositoryImpl(
    this._searchService, {
    SupabaseClient? supabase,
    LocationService? locationService,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _locationService = locationService ?? InjectionContainer.get<LocationService>();

  @override
  Future<SearchResult> searchRestaurants(SearchParams params) async {
    try {
      Logger.info('Iniciando busca de restaurantes', {
        'query': params.query,
        'categoryId': params.categoryId,
        'page': params.page,
        'pageSize': params.pageSize,
      });

      // Construir query base
      var query = _supabase
          .from('restaurants')
          .select('''
            *,
            categories!inner(id, name, icon, color),
            restaurant_hours(*),
            restaurant_tags(*),
            restaurant_payment_methods(*)
          ''');

      // Aplicar filtros
      var filteredQuery = _applyFilters(query, params);

      // Aplicar ordenação
      var sortedQuery = _applySorting(filteredQuery, params);

      // Aplicar paginação
      final offset = (params.page - 1) * params.pageSize;
      final paginatedQuery = sortedQuery.range(offset, offset + params.pageSize - 1);

      final response = await paginatedQuery;
      
      if (response == null) {
        return const SearchResult(
          restaurants: [],
          totalCount: 0,
          hasMore: false,
          error: 'Resposta nula do servidor',
        );
      }

      final restaurants = (response as List)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();

      // Calcular distâncias se localização fornecida
      List<RestaurantModel> restaurantsWithDistance = restaurants;
      if (params.latitude != null && params.longitude != null) {
        restaurantsWithDistance = restaurants.map((restaurant) {
          if (restaurant.latitude != null && restaurant.longitude != null) {
            final distance = _calculateDistance(
              params.latitude!,
              params.longitude!,
              restaurant.latitude!,
              restaurant.longitude!,
            );
            return restaurant.copyWith(distance: distance);
          }
          return restaurant;
        }).toList();
        
        // Aplicar filtro de distância máxima se especificado
        if (params.maxDistance != null) {
          restaurantsWithDistance = restaurantsWithDistance
              .where((restaurant) => 
                  restaurant.distance != null && 
                  restaurant.distance! <= params.maxDistance!)
              .toList();
        }
      }

      // Verificar se há mais resultados
      final hasMore = restaurantsWithDistance.length == params.pageSize;

      // Obter contagem total (apenas na primeira página)
      int totalCount = restaurantsWithDistance.length;
      if (params.page == 1) {
        totalCount = await _getTotalCount(params);
      }

      Logger.info('Busca concluída', {
        'resultados': restaurants.length,
        'totalCount': totalCount,
        'hasMore': hasMore,
      });

      return SearchResult(
        restaurants: restaurantsWithDistance,
        totalCount: totalCount,
        hasMore: hasMore,
        metadata: {
          'searchParams': params.toMap(),
          'executionTime': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e, stackTrace) {
      Logger.error('Erro na busca de restaurantes', e, stackTrace);
      return SearchResult(
        restaurants: [],
        totalCount: 0,
        hasMore: false,
        error: 'Erro na busca: ${e.toString()}',
      );
    }
  }

  dynamic _applyFilters(dynamic query, SearchParams params) {
    // Filtro por texto
    if (params.query != null && params.query!.isNotEmpty) {
      query = query.or(
        'name.ilike.%${params.query}%,description.ilike.%${params.query}%,tags.ilike.%${params.query}%'
      );
    }

    // Filtro por categoria
    if (params.categoryId != null) {
      query = query.eq('category_id', params.categoryId!);
    }

    // Filtro por avaliação mínima
    if (params.minRating != null) {
      query = query.gte('rating', params.minRating!);
    }

    // Filtro por status (aberto/fechado)
    if (params.isOpen != null && params.isOpen!) {
      query = query.eq('is_open', true);
    }

    // Filtro por promoção
    if (params.hasPromotion != null && params.hasPromotion!) {
      query = query.eq('has_promotion', true);
    }

    // Filtro por preço
    if (params.minPrice != null) {
      query = query.gte('average_price', params.minPrice!);
    }
    if (params.maxPrice != null) {
      query = query.lte('average_price', params.maxPrice!);
    }

    // Filtro por distância será aplicado após a busca
    // pois não temos função PostGIS disponível no momento

    return query;
  }

  dynamic _applySorting(dynamic query, SearchParams params) {
    switch (params.sortBy) {
      case 'rating':
        return query.order('rating', ascending: false);
      case 'distance':
        if (params.latitude != null && params.longitude != null) {
          // Ordenar por distância usando função SQL
          return query.order('distance_calculated', ascending: true);
        }
        return query.order('name', ascending: true);
      case 'delivery_time':
        return query.order('average_delivery_time', ascending: true);
      case 'delivery_fee':
        return query.order('delivery_fee', ascending: true);
      case 'alphabetical':
        return query.order('name', ascending: true);
      case 'relevance':
      default:
        // Ordenação por relevância: rating + popularidade
        return query.order('rating', ascending: false)
                   .order('review_count', ascending: false);
    }
  }

  Future<int> _getTotalCount(SearchParams params) async {
    try {
      var countQuery = _supabase
          .from('restaurants')
          .select('id');
      
      // Aplicar apenas filtros, não ordenação para contagem
      if (params.query != null && params.query!.isNotEmpty) {
        countQuery = countQuery.or(
          'name.ilike.%${params.query}%,description.ilike.%${params.query}%,tags.ilike.%${params.query}%'
        );
      }
      if (params.categoryId != null) {
        countQuery = countQuery.eq('category_id', params.categoryId!);
      }
      if (params.minRating != null) {
        countQuery = countQuery.gte('rating', params.minRating!);
      }
      if (params.isOpen != null && params.isOpen!) {
        countQuery = countQuery.eq('is_open', true);
      }
      
      final response = await countQuery;
      return (response as List).length;
    } catch (e) {
      Logger.error('Erro ao obter contagem total', e);
      return 0;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return _locationService.calculateDistance(lat1, lon1, lat2, lon2);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      Logger.info('Buscando categorias');
      
      // Gerar chave de cache
      const cacheKey = 'categories_active';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.getCategory(cacheKey);
      if (cachedData != null) {
        Logger.info('Categorias carregadas do cache');
        return cachedData;
      }
      
      final response = await _supabase
          .from('categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      // Salvar no cache
      await _cacheService.setCategory(cacheKey, categories);

      Logger.info('Categorias carregadas', {'count': categories.length});
      return categories;
    } catch (e, stackTrace) {
      Logger.error('Erro ao carregar categorias', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.length < 2) return [];

      Logger.info('Buscando sugestões', {'query': query});

      // Gerar chave de cache
      final cacheKey = 'search_suggestions_${query.toLowerCase()}';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.getSearch(cacheKey);
      if (cachedData != null) {
        Logger.info('Sugestões carregadas do cache');
        return (cachedData as List<dynamic>).map((e) => e.toString()).toList();
      }

      // Buscar em nomes de restaurantes
      final restaurantSuggestions = await _supabase
          .from('restaurants')
          .select('name')
          .ilike('name', '%$query%')
          .limit(5);

      // Buscar em categorias
      final categorySuggestions = await _supabase
          .from('categories')
          .select('name')
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .limit(3);

      // Buscar em tags populares
      final tagSuggestions = await _supabase
          .from('popular_search_tags')
          .select('tag')
          .ilike('tag', '%$query%')
          .limit(3);

      final suggestions = <String>{};
      
      // Adicionar sugestões de restaurantes
      for (final item in restaurantSuggestions) {
        suggestions.add(item['name'] as String);
      }
      
      // Adicionar sugestões de categorias
      for (final item in categorySuggestions) {
        suggestions.add(item['name'] as String);
      }
      
      // Adicionar sugestões de tags
      for (final item in tagSuggestions) {
        suggestions.add(item['tag'] as String);
      }

      final result = suggestions.toList();
      
      // Salvar no cache com TTL menor para sugestões
      await _cacheService.setSearch(cacheKey, result);
      
      Logger.info('Sugestões encontradas', {'count': result.length});
      return result;
    } catch (e, stackTrace) {
      Logger.error('Erro ao buscar sugestões', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<String>> getPopularSearches() async {
    try {
      Logger.info('Buscando buscas populares');
      
      final response = await _supabase
          .from('popular_searches')
          .select('query')
          .order('search_count', ascending: false)
          .limit(10);

      final searches = (response as List)
          .map((item) => item['query'] as String)
          .toList();

      Logger.info('Buscas populares carregadas', {'count': searches.length});
      return searches;
    } catch (e, stackTrace) {
      Logger.error('Erro ao carregar buscas populares', e, stackTrace);
      return [
        'Pizza',
        'Hambúrguer',
        'Sushi',
        'Açaí',
        'Comida Italiana',
        'Lanche',
        'Doces',
        'Comida Japonesa',
      ];
    }
  }

  @override
  Future<List<String>> getRecentSearches(String userId) async {
    try {
      Logger.info('Buscando histórico de buscas', {'userId': userId});
      
      final response = await _supabase
          .from('user_search_history')
          .select('query')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      final searches = (response as List)
          .map((item) => item['query'] as String)
          .toList();

      Logger.info('Histórico carregado', {'count': searches.length});
      return searches;
    } catch (e, stackTrace) {
      Logger.error('Erro ao carregar histórico', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> saveRecentSearch(String userId, String query) async {
    try {
      if (query.trim().isEmpty) return;

      Logger.info('Salvando busca recente', {
        'userId': userId,
        'query': query,
      });

      // Remover busca existente (se houver)
      await _supabase
          .from('user_search_history')
          .delete()
          .eq('user_id', userId)
          .eq('query', query);

      // Inserir nova busca
      await _supabase
          .from('user_search_history')
          .insert({
            'user_id': userId,
            'query': query,
            'created_at': DateTime.now().toIso8601String(),
          });

      // Manter apenas as 20 buscas mais recentes
      await _cleanupOldSearches(userId);

      // Atualizar contador de buscas populares
      await _updatePopularSearchCount(query);

      Logger.info('Busca recente salva');
    } catch (e, stackTrace) {
      Logger.error('Erro ao salvar busca recente', e, stackTrace);
    }
  }

  @override
  Future<void> removeRecentSearch(String userId, String query) async {
    try {
      Logger.info('Removendo busca recente', {
        'userId': userId,
        'query': query,
      });

      await _supabase
          .from('user_search_history')
          .delete()
          .eq('user_id', userId)
          .eq('query', query);

      Logger.info('Busca recente removida');
    } catch (e, stackTrace) {
      Logger.error('Erro ao remover busca recente', e, stackTrace);
    }
  }

  @override
  Future<void> clearRecentSearches(String userId) async {
    try {
      Logger.info('Limpando histórico de buscas', {'userId': userId});

      await _supabase
          .from('user_search_history')
          .delete()
          .eq('user_id', userId);

      Logger.info('Histórico limpo');
    } catch (e, stackTrace) {
      Logger.error('Erro ao limpar histórico', e, stackTrace);
    }
  }

  @override
  Future<List<RestaurantModel>> getFeaturedRestaurants() async {
    try {
      Logger.info('Buscando restaurantes em destaque');
      
      final response = await _supabase
          .from('restaurants')
          .select('''
            *,
            categories!inner(id, name, icon, color)
          ''')
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('rating', ascending: false)
          .limit(10);

      final restaurants = (response as List)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();

      Logger.info('Restaurantes em destaque carregados', {'count': restaurants.length});
      return restaurants;
    } catch (e, stackTrace) {
      Logger.error('Erro ao carregar restaurantes em destaque', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<RestaurantModel>> getNearbyRestaurants(
    double latitude, 
    double longitude, {
    double radius = 10.0,
  }) async {
    try {
      Logger.info('Buscando restaurantes próximos', {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      });

      final response = await _supabase
          .rpc('get_nearby_restaurants', params: {
            'lat': latitude,
            'lng': longitude,
            'radius_km': radius,
          });

      final restaurants = (response as List)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();

      // Calcular distâncias
      for (var restaurant in restaurants) {
        if (restaurant.latitude != null && restaurant.longitude != null) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            restaurant.latitude!,
            restaurant.longitude!,
          );
          // Note: distance property needs to be added to RestaurantModel
          // For now, we'll skip setting it directly
        }
      }

      // Note: Sorting by distance would require adding distance property to RestaurantModel

      Logger.info('Restaurantes próximos carregados', {'count': restaurants.length});
      return restaurants;
    } catch (e, stackTrace) {
      Logger.error('Erro ao carregar restaurantes próximos', e, stackTrace);
      return [];
    }
  }

  Future<void> _cleanupOldSearches(String userId) async {
    try {
      // Buscar IDs das buscas mais antigas (manter apenas 20)
      final oldSearches = await _supabase
          .from('user_search_history')
          .select('id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(20, 1000); // Pegar da posição 20 em diante

      if (oldSearches.isNotEmpty) {
        final idsToDelete = oldSearches.map((item) => item['id']).toList();
        
        await _supabase
            .from('user_search_history')
            .delete()
            .inFilter('id', idsToDelete);
      }
    } catch (e) {
      Logger.error('Erro ao limpar buscas antigas', e);
    }
  }

  Future<void> _updatePopularSearchCount(String query) async {
    try {
      // Verificar se a busca já existe
      final existing = await _supabase
          .from('popular_searches')
          .select('id, search_count')
          .eq('query', query)
          .maybeSingle();

      if (existing != null) {
        // Incrementar contador
        await _supabase
            .from('popular_searches')
            .update({
              'search_count': existing['search_count'] + 1,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id']);
      } else {
        // Criar nova entrada
        await _supabase
            .from('popular_searches')
            .insert({
              'query': query,
              'search_count': 1,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      }
    } catch (e) {
      Logger.error('Erro ao atualizar contador de busca popular', e);
    }
  }

  /// Obtém histórico de buscas do usuário
  Future<List<String>> getSearchHistory() async {
    try {
      final response = await _supabase
          .from('user_search_history')
          .select('query')
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List)
          .map((item) => item['query'] as String)
          .toList();
    } catch (e) {
      Logger.error('Erro ao obter histórico de buscas', e);
      return [];
    }
  }

  /// Obtém termos de busca populares
  Future<List<String>> getPopularSearchTerms() async {
    try {
      final response = await _supabase
          .from('popular_searches')
          .select('query')
          .order('search_count', ascending: false)
          .limit(10);

      return (response as List)
          .map((item) => item['query'] as String)
          .toList();
    } catch (e) {
      Logger.error('Erro ao obter termos populares', e);
      return [];
    }
  }

  /// Busca restaurantes por categoria
  Future<List<RestaurantModel>> searchByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select('''
            *,
            categories!inner(id, name, icon, color)
          ''')
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('rating', ascending: false);

      return (response as List)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Erro ao buscar por categoria', e);
      return [];
    }
  }

  /// Busca restaurantes próximos
  Future<List<RestaurantModel>> searchNearbyRestaurants(
    double latitude,
    double longitude, {
    double radiusKm = 10.0,
  }) async {
    return await getNearbyRestaurants(latitude, longitude, radius: radiusKm);
  }

  /// Adiciona uma busca ao histórico do usuário
  @override
  Future<void> addToSearchHistory(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await saveRecentSearch(user.id, query);
      }
    } catch (e) {
      Logger.error('Erro ao adicionar ao histórico de busca', e);
    }
  }
}