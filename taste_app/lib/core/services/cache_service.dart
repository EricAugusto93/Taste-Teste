import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;


import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../models/cache_item.dart';

/// Serviço de cache usando Hive com suporte a TTL e estatísticas
@singleton
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService();
  static const String _cacheBoxName = 'taste_cache';
  static const String _statsBoxName = 'cache_stats';
  
  Box<CacheItem>? _cacheBox;
  Box<Map>? _statsBox;
  
  // Estatísticas de cache
  int _hitCount = 0;
  int _missCount = 0;
  
  // Timer para limpeza automática
  Timer? _cleanupTimer;
  
  // Configurações
  static const Duration _defaultCleanupInterval = Duration(hours: 1);
  static const int _maxCacheSize = 1000; // Máximo de itens em cache
  
  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    try {
      // Inicializar Hive se ainda não foi inicializado
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CacheItemAdapter());
      }
      
      // Abrir boxes
      _cacheBox = await Hive.openBox<CacheItem>(_cacheBoxName);
      _statsBox = await Hive.openBox<Map>(_statsBoxName);
      
      // Carregar estatísticas salvas
      await _loadStats();
      
      // Iniciar limpeza automática
      _startCleanupTimer();
      
      // Limpeza inicial de itens expirados
      await _cleanupExpiredItems();
      
      developer.log('CacheService inicializado com sucesso', name: 'CacheService');
    } catch (e) {
      developer.log('Erro ao inicializar CacheService: $e', name: 'CacheService');
      rethrow;
    }
  }
  
  /// Obtém um item do cache
  Future<T?> get<T>(String key, {bool updateLastAccessed = true}) async {
    try {
      final cacheItem = _cacheBox?.get(key);
      
      if (cacheItem == null) {
        _missCount++;
        await _saveStats();
        return null;
      }
      
      // Verificar se expirou
      if (cacheItem.isExpired()) {
        await delete(key);
        _missCount++;
        await _saveStats();
        return null;
      }
      
      // Atualizar último acesso
      if (updateLastAccessed) {
        cacheItem.updateLastAccessed();
        await _cacheBox?.put(key, cacheItem);
      }
      
      _hitCount++;
      await _saveStats();
      
      // Tentar deserializar o dado
      if (cacheItem.data is String && T != String) {
        try {
          final decoded = jsonDecode(cacheItem.data as String);
          return decoded as T?;
        } catch (e) {
          return cacheItem.data as T?;
        }
      }
      
      return cacheItem.data as T?;
    } catch (e) {
      developer.log('Erro ao obter item do cache: $e', name: 'CacheService');
      return null;
    }
  }
  
  /// Armazena um item no cache
  Future<bool> set<T>(
    String key,
    T data, {
    Duration? ttl,
    CacheDataType? dataType,
  }) async {
    try {
      // Verificar limite de cache
      if ((_cacheBox?.length ?? 0) >= _maxCacheSize) {
        await _evictOldestItems();
      }
      
      // Determinar TTL
      final effectiveTtl = ttl ?? dataType?.defaultTtl ?? const Duration(minutes: 15);
      final expirationTime = DateTime.now().add(effectiveTtl);
      
      // Serializar dados complexos
      dynamic serializedData = data;
      if (data is! String && data is! num && data is! bool) {
        try {
          serializedData = jsonEncode(data);
        } catch (e) {
          developer.log('Erro ao serializar dados para cache: $e', name: 'CacheService');
          return false;
        }
      }
      
      final cacheItem = CacheItem(
        key: key,
        data: serializedData,
        expirationTime: expirationTime,
        dataType: dataType?.value,
      );
      
      await _cacheBox?.put(key, cacheItem);
      
      developer.log('Item armazenado no cache: $key (TTL: ${effectiveTtl.inMinutes}min)', 
          name: 'CacheService');
      
      return true;
    } catch (e) {
      developer.log('Erro ao armazenar item no cache: $e', name: 'CacheService');
      return false;
    }
  }
  
  /// Remove um item do cache
  Future<bool> delete(String key) async {
    try {
      await _cacheBox?.delete(key);
      return true;
    } catch (e) {
      developer.log('Erro ao remover item do cache: $e', name: 'CacheService');
      return false;
    }
  }
  
  /// Alias para delete - remove um item do cache
  Future<bool> remove(String key) async {
    return await delete(key);
  }
  
  /// Limpa todo o cache
  Future<bool> clear() async {
    try {
      await _cacheBox?.clear();
      _hitCount = 0;
      _missCount = 0;
      await _saveStats();
      developer.log('Cache limpo completamente', name: 'CacheService');
      return true;
    } catch (e) {
      developer.log('Erro ao limpar cache: $e', name: 'CacheService');
      return false;
    }
  }
  
  /// Limpa itens de um tipo específico
  Future<bool> clearByType(CacheDataType dataType) async {
    try {
      final keysToDelete = <String>[];
      
      _cacheBox?.toMap().forEach((key, item) {
        if (item.dataType == dataType.value) {
          keysToDelete.add(key);
        }
      });
      
      for (final key in keysToDelete) {
        await _cacheBox?.delete(key);
      }
      
      developer.log('Cache limpo para tipo: ${dataType.value} (${keysToDelete.length} itens)', 
          name: 'CacheService');
      
      return true;
    } catch (e) {
      developer.log('Erro ao limpar cache por tipo: $e', name: 'CacheService');
      return false;
    }
  }
  
  /// Verifica se um item existe no cache e não expirou
  Future<bool> exists(String key) async {
    final item = await get<dynamic>(key, updateLastAccessed: false);
    return item != null;
  }
  
  /// Obtém estatísticas do cache
  Future<CacheStats> getStats() async {
    final totalItems = _cacheBox?.length ?? 0;
    final expiredItems = await _countExpiredItems();
    final totalRequests = _hitCount + _missCount;
    final hitRatio = totalRequests > 0 ? _hitCount / totalRequests : 0.0;
    
    final itemsByType = <String, int>{};
    _cacheBox?.toMap().forEach((key, item) {
      final type = item.dataType ?? 'unknown';
      itemsByType[type] = (itemsByType[type] ?? 0) + 1;
    });
    
    return CacheStats(
      totalItems: totalItems,
      expiredItems: expiredItems,
      hitCount: _hitCount,
      missCount: _missCount,
      hitRatio: hitRatio,
      totalSize: totalItems, // Simplificado - poderia calcular tamanho real
      itemsByType: itemsByType,
    );
  }
  
  /// Força limpeza de itens expirados
  Future<int> cleanupExpiredItems() async {
    return await _cleanupExpiredItems();
  }
  
  /// Obtém todas as chaves do cache
  List<String> getAllKeys() {
    return _cacheBox?.keys.cast<String>().toList() ?? [];
  }
  
  /// Obtém itens próximos do vencimento
  Future<List<CacheItem>> getItemsNearExpiration() async {
    final items = <CacheItem>[];
    
    _cacheBox?.toMap().forEach((key, item) {
      if (item.isNearExpiration()) {
        items.add(item);
      }
    });
    
    return items;
  }
  
  // Métodos privados
  
  Future<void> _loadStats() async {
    try {
      final stats = _statsBox?.get('cache_stats');
      if (stats != null) {
        _hitCount = stats['hitCount'] ?? 0;
        _missCount = stats['missCount'] ?? 0;
      }
    } catch (e) {
      developer.log('Erro ao carregar estatísticas: $e', name: 'CacheService');
    }
  }
  
  Future<void> _saveStats() async {
    try {
      await _statsBox?.put('cache_stats', {
        'hitCount': _hitCount,
        'missCount': _missCount,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Erro ao salvar estatísticas: $e', name: 'CacheService');
    }
  }
  
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_defaultCleanupInterval, (_) {
      _cleanupExpiredItems();
    });
  }
  
  Future<int> _cleanupExpiredItems() async {
    try {
      final keysToDelete = <String>[];
      
      _cacheBox?.toMap().forEach((key, item) {
        if (item.isExpired()) {
          keysToDelete.add(key);
        }
      });
      
      for (final key in keysToDelete) {
        await _cacheBox?.delete(key);
      }
      
      if (keysToDelete.isNotEmpty) {
        developer.log('Limpeza automática: ${keysToDelete.length} itens expirados removidos', 
            name: 'CacheService');
      }
      
      return keysToDelete.length;
    } catch (e) {
      developer.log('Erro na limpeza automática: $e', name: 'CacheService');
      return 0;
    }
  }
  
  Future<int> _countExpiredItems() async {
    int count = 0;
    _cacheBox?.toMap().forEach((key, item) {
      if (item.isExpired()) count++;
    });
    return count;
  }
  
  Future<void> _evictOldestItems() async {
    try {
      final items = _cacheBox?.toMap().entries.toList() ?? [];
      
      // Ordenar por último acesso (mais antigo primeiro)
      items.sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));
      
      // Remover 10% dos itens mais antigos
      final itemsToRemove = (items.length * 0.1).ceil();
      
      for (int i = 0; i < itemsToRemove && i < items.length; i++) {
        await _cacheBox?.delete(items[i].key);
      }
      
      developer.log('Eviction: $itemsToRemove itens mais antigos removidos', 
          name: 'CacheService');
    } catch (e) {
      developer.log('Erro na eviction de itens: $e', name: 'CacheService');
    }
  }
  
  /// Dispose do serviço
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    await _saveStats();
    await _cacheBox?.close();
    await _statsBox?.close();
  }
}

/// Extension para facilitar o uso do cache
extension CacheServiceExtension on CacheService {
  /// Cache para restaurantes
  Future<T?> getRestaurant<T>(String key) => get<T>('restaurant_$key');
  Future<bool> setRestaurant<T>(String key, T data, {Duration? ttl}) => 
      set('restaurant_$key', data, ttl: ttl, dataType: CacheDataType.restaurant);
  
  /// Cache para usuários
  Future<T?> getUser<T>(String key) => get<T>('user_$key');
  Future<bool> setUser<T>(String key, T data, {Duration? ttl}) => 
      set('user_$key', data, ttl: ttl, dataType: CacheDataType.user);
  
  /// Cache para categorias
  Future<T?> getCategory<T>(String key) => get<T>('category_$key');
  Future<bool> setCategory<T>(String key, T data, {Duration? ttl}) => 
      set('category_$key', data, ttl: ttl, dataType: CacheDataType.category);
  
  /// Cache para buscas
  Future<T?> getSearch<T>(String query) => get<T>('search_${query.hashCode}');
  Future<bool> setSearch<T>(String query, T data, {Duration? ttl}) => 
      set('search_${query.hashCode}', data, ttl: ttl, dataType: CacheDataType.search);
}