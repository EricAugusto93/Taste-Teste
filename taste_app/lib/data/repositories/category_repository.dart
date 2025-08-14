import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../../core/config/supabase_config.dart';
import '../../core/utils/logger.dart';
import '../../core/services/analytics_service.dart';
import 'predefined_categories.dart';

/// Repositório para operações com categorias
/// Gerencia dados de categorias com cache local e fallback para categorias predefinidas
class CategoryRepository {
  static CategoryRepository? _instance;
  static CategoryRepository get instance => _instance ??= CategoryRepository._();
  CategoryRepository._();

  // Cache local
  List<CategoryModel>? _cachedCategories;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 30);
  
  // Cache persistente (simulado com variável estática)
  static List<CategoryModel>? _persistentCache;
  
  /// Verifica se o cache é válido
  bool get _isCacheValid {
    if (_lastCacheUpdate == null || _cachedCategories == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  /// Busca todas as categorias ativas
  /// Usa cache local primeiro, depois Supabase, e fallback para categorias predefinidas
  Future<List<CategoryModel>> getCategories() async {
    try {
      Logger.info('CategoryRepository: Buscando categorias');
      
      // Verifica cache local primeiro
      if (_isCacheValid && _cachedCategories != null) {
        Logger.info('CategoryRepository: Retornando categorias do cache local');
        AnalyticsService.instance.trackEvent(
        type: AnalyticsEventType.custom,
        name: 'categories_cache_hit',
        parameters: {
          'source': 'local_cache',
          'count': _cachedCategories!.length,
        },
      );
        return _cachedCategories!;
      }
      
      // Tenta buscar do Supabase
      try {
        final response = await SupabaseDatabase.categories
            .select()
            .eq('is_active', true)
            .order('sort_order')
            .order('name');

        final categories = (response as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();
            
        // Atualiza cache local
        _cachedCategories = categories;
        _lastCacheUpdate = DateTime.now();
        _persistentCache = categories;
        
        Logger.info('CategoryRepository: Categorias carregadas do Supabase', {
          'count': categories.length,
        });
        
        AnalyticsService.instance.trackEvent(
           type: AnalyticsEventType.custom,
           name: 'categories_loaded',
           parameters: {
             'source': 'supabase',
             'count': categories.length,
           },
         );
        
        return categories;
      } catch (supabaseError) {
        Logger.warning('CategoryRepository: Erro ao buscar do Supabase, tentando cache persistente: ${supabaseError.toString()}');
        
        // Tenta usar cache persistente
        if (_persistentCache != null && _persistentCache!.isNotEmpty) {
          Logger.info('CategoryRepository: Usando cache persistente');
          _cachedCategories = _persistentCache!;
          _lastCacheUpdate = DateTime.now();
          
          AnalyticsService.instance.trackEvent(
             type: AnalyticsEventType.custom,
             name: 'categories_cache_hit',
             parameters: {
               'source': 'persistent_cache',
               'count': _persistentCache!.length,
             },
           );
          
          return _persistentCache!;
        }
        
        // Fallback para categorias predefinidas
        Logger.info('CategoryRepository: Usando categorias predefinidas como fallback');
        final predefinedCategories = PredefinedCategories.getAllCategories();
        
        _cachedCategories = predefinedCategories;
        _lastCacheUpdate = DateTime.now();
        
        AnalyticsService.instance.trackEvent(
           type: AnalyticsEventType.custom,
           name: 'categories_fallback_used',
           parameters: {
             'count': predefinedCategories.length,
             'error': supabaseError.toString(),
           },
         );
        
        return predefinedCategories;
      }
    } catch (e, stackTrace) {
      Logger.error('CategoryRepository: Erro geral ao buscar categorias', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.error,
         name: 'categories_error',
         parameters: {
           'error': e.toString(),
         },
       );
      
      // Fallback final para categorias predefinidas
      return PredefinedCategories.getAllCategories();
    }
  }

  /// Busca categorias ativas (filtro adicional)
  Future<List<CategoryModel>> getActiveCategories() async {
    final allCategories = await getCategories();
    return allCategories.where((category) => category.isActive).toList();
  }

  /// Busca uma categoria por ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      Logger.info('CategoryRepository: Buscando categoria por ID', {'id': id});
      
      // Primeiro verifica no cache local
      if (_cachedCategories != null) {
        final cached = _cachedCategories!.where((cat) => cat.id == id).firstOrNull;
        if (cached != null) {
          Logger.info('CategoryRepository: Categoria encontrada no cache');
          return cached;
        }
      }
      
      // Busca no Supabase
      try {
        final response = await SupabaseDatabase.categories
            .select()
            .eq('id', id)
            .single();

        final category = CategoryModel.fromJson(response);
        
        Logger.info('CategoryRepository: Categoria encontrada no Supabase');
        
        AnalyticsService.instance.trackEvent(
            type: AnalyticsEventType.custom,
            name: 'category_found',
            parameters: {
              'source': 'supabase',
              'category_id': id,
            },
          );
        
        return category;
      } catch (supabaseError) {
        Logger.warning('CategoryRepository: Categoria não encontrada no Supabase, tentando predefinidas');
        
        // Fallback para categorias predefinidas
        final predefined = PredefinedCategories.getCategoryById(id);
        
        if (predefined != null) {
          AnalyticsService.instance.trackEvent(
            type: AnalyticsEventType.custom,
            name: 'category_found',
            parameters: {
              'source': 'predefined',
              'category_id': id,
            },
          );
        }
        
        return predefined;
      }
    } catch (e, stackTrace) {
      Logger.error('CategoryRepository: Erro ao buscar categoria por ID', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
        type: AnalyticsEventType.error,
        name: 'category_error',
        parameters: {
          'method': 'getCategoryById',
          'category_id': id,
          'error': e.toString(),
        },
      );
      
      return null;
    }
  }

  /// Busca categorias por nome (busca parcial)
  Future<List<CategoryModel>> searchCategoriesByName(String query) async {
    try {
      final allCategories = await getCategories();
      final lowercaseQuery = query.toLowerCase();
      
      final filtered = allCategories.where((category) {
        return category.name.toLowerCase().contains(lowercaseQuery) ||
               (category.description?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
      
      Logger.info('CategoryRepository: Busca por nome realizada', {
        'query': query,
        'results': filtered.length,
      });
      
      AnalyticsService.instance.trackEvent(
        type: AnalyticsEventType.search,
        name: 'categories_search',
        parameters: {
          'query_length': query.length,
          'results_count': filtered.length,
        },
      );
      
      return filtered;
    } catch (e, stackTrace) {
      Logger.error('CategoryRepository: Erro na busca por nome', e, stackTrace);
      return [];
    }
  }

  /// Força atualização do cache
  Future<void> refreshCache() async {
    try {
      Logger.info('CategoryRepository: Forçando atualização do cache');
      
      _cachedCategories = null;
      _lastCacheUpdate = null;
      
      await getCategories();
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.custom,
         name: 'categories_cache_refreshed',
       );
    } catch (e, stackTrace) {
      Logger.error('CategoryRepository: Erro ao atualizar cache', e, stackTrace);
    }
  }

  /// Limpa o cache local
  void clearCache() {
    Logger.info('CategoryRepository: Limpando cache local');
    _cachedCategories = null;
    _lastCacheUpdate = null;
    
    AnalyticsService.instance.trackEvent(
       type: AnalyticsEventType.custom,
       name: 'categories_cache_cleared',
     );
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStats() {
    return {
      'has_local_cache': _cachedCategories != null,
      'local_cache_count': _cachedCategories?.length ?? 0,
      'cache_valid': _isCacheValid,
      'last_update': _lastCacheUpdate?.toIso8601String(),
      'has_persistent_cache': _persistentCache != null,
      'persistent_cache_count': _persistentCache?.length ?? 0,
    };
  }

  // ============================================================================
  // MÉTODOS DE ESCRITA (para futuras implementações)
  // ============================================================================

  /// Cria uma nova categoria (requer permissões administrativas)
  Future<CategoryModel?> createCategory(CategoryModel category) async {
    try {
      Logger.info('CategoryRepository: Criando nova categoria', {
        'name': category.name,
      });
      
      final response = await SupabaseDatabase.categories
          .insert(category.toJson())
          .select()
          .single();

      final createdCategory = CategoryModel.fromJson(response);
      
      // Invalida cache para forçar atualização
      clearCache();
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.custom,
         name: 'category_created',
         parameters: {
           'category_id': createdCategory.id,
           'category_name': createdCategory.name,
         },
       );
      
      return createdCategory;
    } catch (e, stackTrace) {
      Logger.error('CategoryRepository: Erro ao criar categoria', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.error,
         name: 'category_create_error',
         parameters: {
           'error': e.toString(),
         },
       );
      
      return null;
    }
  }

  /// Atualiza uma categoria existente
  Future<CategoryModel?> updateCategory(CategoryModel category) async {
    try {
      Logger.info('CategoryRepository: Atualizando categoria', {
        'id': category.id,
        'name': category.name,
      });
      
      final response = await SupabaseDatabase.categories
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();

      final updatedCategory = CategoryModel.fromJson(response);
      
      // Invalida cache para forçar atualização
      clearCache();
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.custom,
         name: 'category_updated',
         parameters: {
           'category_id': updatedCategory.id,
         },
       );
      
      return updatedCategory;
    } catch (e, stackTrace) {
      Logger.error('CategoryRepository: Erro ao atualizar categoria', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.error,
         name: 'category_update_error',
         parameters: {
           'category_id': category.id,
           'error': e.toString(),
         },
       );
      
      return null;
    }
  }

  /// Remove uma categoria (soft delete - marca como inativa)
  Future<bool> deactivateCategory(String categoryId) async {
    try {
      Logger.info('CategoryRepository: Desativando categoria', {
        'id': categoryId,
      });
      
      await SupabaseDatabase.categories
          .update({'is_active': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', categoryId);
      
      // Invalida cache para forçar atualização
      clearCache();
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.custom,
         name: 'category_deactivated',
         parameters: {
           'category_id': categoryId,
         },
       );
      
      return true;
    } catch (e, stackTrace) {
      Logger.error('CategoryRepository: Erro ao desativar categoria', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
         type: AnalyticsEventType.error,
         name: 'category_deactivate_error',
         parameters: {
           'category_id': categoryId,
           'error': e.toString(),
         },
       );
      
      return false;
    }
  }
}