import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../services/analytics_service.dart';
import '../services/cache_service.dart';

/// Repository para gerenciar dados de categorias
class CategoryRepository {
  static final CategoryRepository _instance = CategoryRepository._internal();
  factory CategoryRepository() => _instance;
  CategoryRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final CacheService _cache = CacheService();
  final AnalyticsService _analytics = AnalyticsService.instance;

  static const String _tableName = 'categories';
  static const String _cacheKey = 'categories_cache';
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Stream controller para notificar mudanças nas categorias
  final StreamController<List<Category>> _categoriesController =
      StreamController<List<Category>>.broadcast();

  /// Stream de categorias
  Stream<List<Category>> get categoriesStream => _categoriesController.stream;

  /// Cache local de categorias
  List<Category>? _cachedCategories;
  DateTime? _lastFetchTime;

  /// Obtém todas as categorias
  Future<List<Category>> getCategories({
    bool forceRefresh = false,
    bool activeOnly = true,
  }) async {
    try {
      // Verifica se deve usar cache
      if (!forceRefresh && _shouldUseCache()) {
        _analytics.trackEvent('categories_cache_hit', parameters: {
          'active_only': activeOnly,
        });
        return _filterCategories(_cachedCategories!, activeOnly);
      }

      // Busca do cache persistente
      if (!forceRefresh) {
        final cachedData = await _cache.get<List<dynamic>>(_cacheKey);
        if (cachedData != null) {
          final categories = cachedData
              .map((json) => Category.fromJson(json as Map<String, dynamic>))
              .toList();
          _updateLocalCache(categories);
          _analytics.trackEvent('categories_persistent_cache_hit', parameters: {
            'count': categories.length,
            'active_only': activeOnly,
          });
          return _filterCategories(categories, activeOnly);
        }
      }

      // Busca do servidor
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('sort_order', ascending: true);

      final categories = (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();

      // Atualiza caches
      await _updateCaches(categories);

      _analytics.trackEvent('categories_fetched', parameters: {
        'count': categories.length,
        'source': 'server',
        'active_only': activeOnly,
      });

      final filteredCategories = _filterCategories(categories, activeOnly);
      _categoriesController.add(filteredCategories);

      return filteredCategories;
    } catch (e) {
      _analytics.trackEvent('categories_fetch_error', parameters: {
        'error': e.toString(),
        'active_only': activeOnly,
      });

      // Fallback para categorias predefinidas
      final fallbackCategories = PredefinedCategories.getActiveCategories();
      _analytics.trackEvent('categories_fallback_used', parameters: {
        'count': fallbackCategories.length,
      });

      return activeOnly ? fallbackCategories : PredefinedCategories.categories;
    }
  }

  /// Obtém uma categoria por ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final categories = await getCategories(activeOnly: false);
      final category = categories.where((c) => c.id == id).firstOrNull;

      _analytics.trackEvent('category_by_id_requested', parameters: {
        'category_id': id,
        'found': category != null,
      });

      return category;
    } catch (e) {
      _analytics.trackEvent('category_by_id_error', parameters: {
        'category_id': id,
        'error': e.toString(),
      });

      // Fallback para categorias predefinidas
      return PredefinedCategories.getCategoryById(id);
    }
  }

  /// Busca categorias por nome
  Future<List<Category>> searchCategories(String query) async {
    try {
      final categories = await getCategories();
      final filteredCategories = categories
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()) ||
              category.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      _analytics.trackEvent('categories_searched', parameters: {
        'query': query,
        'results_count': filteredCategories.length,
      });

      return filteredCategories;
    } catch (e) {
      _analytics.trackEvent('categories_search_error', parameters: {
        'query': query,
        'error': e.toString(),
      });
      return [];
    }
  }

  /// Obtém categorias populares (baseado em uso)
  Future<List<Category>> getPopularCategories({int limit = 6}) async {
    try {
      // Por enquanto, retorna as primeiras categorias ordenadas
      // No futuro, pode ser baseado em estatísticas de uso
      final categories = await getCategories();
      final popularCategories = categories.take(limit).toList();

      _analytics.trackEvent('popular_categories_requested', parameters: {
        'limit': limit,
        'count': popularCategories.length,
      });

      return popularCategories;
    } catch (e) {
      _analytics.trackEvent('popular_categories_error', parameters: {
        'limit': limit,
        'error': e.toString(),
      });
      return [];
    }
  }

  /// Cria uma nova categoria (admin)
  Future<Category?> createCategory({
    required String name,
    required String description,
    required String iconString,
    required String colorString,
    String? imageUrl,
    int sortOrder = 0,
  }) async {
    try {
      final categoryData = {
        'name': name,
        'description': description,
        'icon': iconString,
        'color': colorString,
        'image_url': imageUrl,
        'sort_order': sortOrder,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .insert(categoryData)
          .select()
          .single();

      final category = Category.fromJson(response as Map<String, dynamic>);

      // Invalida cache
      await _invalidateCache();

      _analytics.trackEvent('category_created', parameters: {
        'category_id': category.id,
        'category_name': category.name,
      });

      return category;
    } catch (e) {
      _analytics.trackEvent('category_creation_error', parameters: {
        'name': name,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Atualiza uma categoria (admin)
  Future<Category?> updateCategory(
    String id, {
    String? name,
    String? description,
    String? iconString,
    String? colorString,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (iconString != null) updateData['icon'] = iconString;
      if (colorString != null) updateData['color'] = colorString;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (isActive != null) updateData['is_active'] = isActive;
      if (sortOrder != null) updateData['sort_order'] = sortOrder;

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final category = Category.fromJson(response as Map<String, dynamic>);

      // Invalida cache
      await _invalidateCache();

      _analytics.trackEvent('category_updated', parameters: {
        'category_id': id,
        'fields_updated': updateData.keys.toList(),
      });

      return category;
    } catch (e) {
      _analytics.trackEvent('category_update_error', parameters: {
        'category_id': id,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Remove uma categoria (admin)
  Future<bool> deleteCategory(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      // Invalida cache
      await _invalidateCache();

      _analytics.trackEvent('category_deleted', parameters: {
        'category_id': id,
      });

      return true;
    } catch (e) {
      _analytics.trackEvent('category_deletion_error', parameters: {
        'category_id': id,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Verifica se deve usar cache local
  bool _shouldUseCache() {
    if (_cachedCategories == null || _lastFetchTime == null) {
      return false;
    }
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  /// Filtra categorias por status ativo
  List<Category> _filterCategories(List<Category> categories, bool activeOnly) {
    if (!activeOnly) return categories;
    return categories.where((category) => category.isActive).toList();
  }

  /// Atualiza cache local
  void _updateLocalCache(List<Category> categories) {
    _cachedCategories = categories;
    _lastFetchTime = DateTime.now();
  }

  /// Atualiza todos os caches
  Future<void> _updateCaches(List<Category> categories) async {
    _updateLocalCache(categories);
    await _cache.set(
      _cacheKey,
      categories.map((c) => c.toJson()).toList(),
      ttl: _cacheDuration,
    );
  }

  /// Invalida todos os caches
  Future<void> _invalidateCache() async {
    _cachedCategories = null;
    _lastFetchTime = null;
    await _cache.delete(_cacheKey);
  }

  /// Limpa todos os caches
  Future<void> clearCache() async {
    await _invalidateCache();
    _analytics.trackEvent('categories_cache_cleared');
  }

  /// Pré-carrega categorias
  Future<void> preloadCategories() async {
    try {
      await getCategories();
      _analytics.trackEvent('categories_preloaded');
    } catch (e) {
      _analytics.trackEvent('categories_preload_error', parameters: {
        'error': e.toString(),
      });
    }
  }

  /// Dispose do repository
  void dispose() {
    _categoriesController.close();
  }
}

/// Extensão para facilitar o uso de firstOrNull
extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}