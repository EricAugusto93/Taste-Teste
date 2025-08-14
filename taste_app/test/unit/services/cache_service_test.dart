import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/core/models/cache_item.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('CacheService Tests', () {
    late CacheService cacheService;
    late String testDir;
    
    setUpAll(() async {
      // Configurar diretório temporário para testes
      testDir = '${Directory.systemTemp.path}/cache_test_${DateTime.now().millisecondsSinceEpoch}';
      await Directory(testDir).create(recursive: true);
      
      // Inicializar Hive para testes
      Hive.init(testDir);
    });
    
    setUp(() async {
      cacheService = CacheService();
      await cacheService.initialize();
    });
    
    tearDown(() async {
      await cacheService.dispose();
      await Hive.deleteFromDisk();
    });
    
    tearDownAll(() async {
      try {
        await Directory(testDir).delete(recursive: true);
      } catch (e) {
        // Ignorar erros de limpeza
      }
    });
    
    group('Initialization', () {
      test('should initialize successfully', () async {
        final newCacheService = CacheService();
        await expectLater(() => newCacheService.initialize(), returnsNormally);
        await newCacheService.dispose();
      });
    });
    
    group('Basic CRUD Operations', () {
      test('should store and retrieve string data', () async {
        // Arrange
        const key = 'test_string';
        const value = 'Hello World';
        
        // Act
        final setResult = await cacheService.set(key, value);
        final retrievedValue = await cacheService.get<String>(key);
        
        // Assert
        expect(setResult, isTrue);
        expect(retrievedValue, equals(value));
      });
      
      test('should store and retrieve complex data', () async {
        // Arrange
        const key = 'test_map';
        final value = {
          'id': 1,
          'name': 'Test Restaurant',
          'rating': 4.5,
          'isOpen': true,
        };
        
        // Act
        final setResult = await cacheService.set(key, value);
        final retrievedValue = await cacheService.get<Map<String, dynamic>>(key);
        
        // Assert
        expect(setResult, isTrue);
        expect(retrievedValue, equals(value));
      });
      
      test('should return null for non-existent key', () async {
        // Act
        final result = await cacheService.get<String>('non_existent_key');
        
        // Assert
        expect(result, isNull);
      });
      
      test('should delete item successfully', () async {
        // Arrange
        const key = 'test_delete';
        const value = 'to be deleted';
        await cacheService.set(key, value);
        
        // Act
        final deleteResult = await cacheService.delete(key);
        final retrievedValue = await cacheService.get<String>(key);
        
        // Assert
        expect(deleteResult, isTrue);
        expect(retrievedValue, isNull);
      });
      
      test('should clear all cache', () async {
        // Arrange
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        await cacheService.set('key3', 'value3');
        
        // Act
        final clearResult = await cacheService.clear();
        final value1 = await cacheService.get<String>('key1');
        final value2 = await cacheService.get<String>('key2');
        final value3 = await cacheService.get<String>('key3');
        
        // Assert
        expect(clearResult, isTrue);
        expect(value1, isNull);
        expect(value2, isNull);
        expect(value3, isNull);
      });
    });
    
    group('TTL (Time To Live)', () {
      test('should expire items after TTL', () async {
        // Arrange
        const key = 'test_ttl';
        const value = 'expires soon';
        const ttl = Duration(milliseconds: 100);
        
        // Act
        await cacheService.set(key, value, ttl: ttl);
        final immediateValue = await cacheService.get<String>(key);
        
        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 150));
        final expiredValue = await cacheService.get<String>(key);
        
        // Assert
        expect(immediateValue, equals(value));
        expect(expiredValue, isNull);
      });
      
      test('should use default TTL for data types', () async {
        // Arrange
        const key = 'test_default_ttl';
        const value = 'restaurant data';
        
        // Act
        await cacheService.set(key, value, dataType: CacheDataType.restaurant);
        final exists = await cacheService.exists(key);
        
        // Assert
        expect(exists, isTrue);
      });
      
      test('should not expire items without TTL', () async {
        // Arrange
        const key = 'test_no_ttl';
        const value = 'never expires';
        
        // Act
        await cacheService.set(key, value);
        
        // Wait a bit
        await Future.delayed(const Duration(milliseconds: 100));
        final retrievedValue = await cacheService.get<String>(key);
        
        // Assert
        expect(retrievedValue, equals(value));
      });
    });
    
    group('Cache Statistics', () {
      setUp(() async {
        // Limpar cache antes de cada teste de estatísticas
        await cacheService.clear();
      });
      
      test('should track hit and miss counts', () async {
        // Arrange
        const key = 'stats_test';
        const value = 'test value';
        
        // Act - Generate hits and misses
        await cacheService.get<String>('non_existent'); // Miss
        await cacheService.set(key, value);
        await cacheService.get<String>(key); // Hit
        await cacheService.get<String>(key); // Hit
        await cacheService.get<String>('another_non_existent'); // Miss
        
        final stats = await cacheService.getStats();
        
        // Assert
        expect(stats.hitCount, equals(2));
        expect(stats.missCount, equals(2));
        expect(stats.hitRatio, equals(0.5));
      });
      
      test('should count items by type', () async {
        // Arrange & Act
        await cacheService.set('rest1', 'restaurant1', dataType: CacheDataType.restaurant);
        await cacheService.set('rest2', 'restaurant2', dataType: CacheDataType.restaurant);
        await cacheService.set('user1', 'user1', dataType: CacheDataType.user);
        
        final stats = await cacheService.getStats();
        
        // Assert
        expect(stats.totalItems, equals(3));
        expect(stats.itemsByType['restaurant'], equals(2));
        expect(stats.itemsByType['user'], equals(1));
      });
    });
    
    group('Cache Cleanup', () {
      test('should cleanup expired items manually', () async {
        // Arrange
        const shortTtl = Duration(milliseconds: 50);
        await cacheService.set('expire1', 'value1', ttl: shortTtl);
        await cacheService.set('expire2', 'value2', ttl: shortTtl);
        await cacheService.set('keep', 'value3'); // No TTL
        
        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act
        final cleanedCount = await cacheService.cleanupExpiredItems();
        
        // Assert
        expect(cleanedCount, equals(2));
        expect(await cacheService.exists('expire1'), isFalse);
        expect(await cacheService.exists('expire2'), isFalse);
        expect(await cacheService.exists('keep'), isTrue);
      });
      
      test('should clear items by type', () async {
        // Arrange
        await cacheService.set('rest1', 'restaurant1', dataType: CacheDataType.restaurant);
        await cacheService.set('rest2', 'restaurant2', dataType: CacheDataType.restaurant);
        await cacheService.set('user1', 'user1', dataType: CacheDataType.user);
        
        // Act
        final clearResult = await cacheService.clearByType(CacheDataType.restaurant);
        
        // Assert
        expect(clearResult, isTrue);
        expect(await cacheService.exists('rest1'), isFalse);
        expect(await cacheService.exists('rest2'), isFalse);
        expect(await cacheService.exists('user1'), isTrue);
      });
    });
    
    group('Cache Extensions', () {
      test('should use restaurant extension methods', () async {
        // Arrange
        const restaurantId = 'rest123';
        final restaurantData = {
          'id': restaurantId,
          'name': 'Test Restaurant',
          'rating': 4.5,
        };
        
        // Act
        final setResult = await cacheService.setRestaurant(restaurantId, restaurantData);
        final retrievedData = await cacheService.getRestaurant<Map<String, dynamic>>(restaurantId);
        
        // Assert
        expect(setResult, isTrue);
        expect(retrievedData, equals(restaurantData));
      });
      
      test('should use user extension methods', () async {
        // Arrange
        const userId = 'user123';
        final userData = {
          'id': userId,
          'name': 'Test User',
          'email': 'test@example.com',
        };
        
        // Act
        final setResult = await cacheService.setUser(userId, userData);
        final retrievedData = await cacheService.getUser<Map<String, dynamic>>(userId);
        
        // Assert
        expect(setResult, isTrue);
        expect(retrievedData, equals(userData));
      });
      
      test('should use search extension methods', () async {
        // Arrange
        const query = 'pizza';
        final searchResults = [
          {'id': '1', 'name': 'Pizza Place 1'},
          {'id': '2', 'name': 'Pizza Place 2'},
        ];
        
        // Act
        final setResult = await cacheService.setSearch(query, searchResults);
        final retrievedResults = await cacheService.getSearch<List>(query);
        
        // Assert
        expect(setResult, isTrue);
        expect(retrievedResults, isNotNull);
        expect(retrievedResults, hasLength(2));
        expect(retrievedResults![0]['id'], equals('1'));
        expect(retrievedResults[1]['id'], equals('2'));
      });
    });
    
    group('Utility Methods', () {
      test('should check if item exists', () async {
        // Arrange
        const key = 'exists_test';
        const value = 'test value';
        
        // Act & Assert
        expect(await cacheService.exists(key), isFalse);
        
        await cacheService.set(key, value);
        expect(await cacheService.exists(key), isTrue);
        
        await cacheService.delete(key);
        expect(await cacheService.exists(key), isFalse);
      });
      
      test('should get all cache keys', () async {
        // Arrange - Clear cache first
        await cacheService.clear();
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        await cacheService.set('key3', 'value3');
        
        // Act
        final keys = cacheService.getAllKeys();
        
        // Assert
        expect(keys, hasLength(3));
        expect(keys, containsAll(['key1', 'key2', 'key3']));
      });
      
      test('should get items near expiration', () async {
        // Arrange
        const shortTtl = Duration(milliseconds: 1000); // 1 segundo
        const longTtl = Duration(seconds: 10);
        
        await cacheService.set('near_expire', 'value1', ttl: shortTtl);
        await cacheService.set('far_expire', 'value2', ttl: longTtl);
        
        // Wait to get close to expiration (90% do TTL = 900ms)
        await Future.delayed(const Duration(milliseconds: 950));
        
        // Act
        final nearExpirationItems = await cacheService.getItemsNearExpiration();
        
        // Assert
        expect(nearExpirationItems, hasLength(1));
        expect(nearExpirationItems.first.key, equals('near_expire'));
      });
    });
    
    group('Error Handling', () {
      test('should handle serialization errors gracefully', () async {
        // Arrange
        const key = 'error_test';
        
        // Act - Try to store a function (not serializable)
        final setResult = await cacheService.set(key, () => 'function');
        
        // Assert
        expect(setResult, isFalse);
      });
      
      test('should handle get errors gracefully', () async {
        // Act - Try to get from corrupted cache
        final result = await cacheService.get<String>('non_existent');
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('Cache Size Management', () {
      test('should handle cache size limits', () async {
        // Arrange - Clear cache first to ensure clean state
        await cacheService.clear();
        
        // Add multiple items
        for (int i = 0; i < 10; i++) {
          await cacheService.set('item_$i', 'value_$i');
        }
        
        // Act
        final stats = await cacheService.getStats();
        
        // Assert
        expect(stats.totalItems, equals(10));
      });
    });
  });
}

/// Helper class para criar dados de teste
class TestData {
  static Map<String, dynamic> createRestaurant(String id) {
    return {
      'id': id,
      'name': 'Restaurant $id',
      'rating': 4.5,
      'isOpen': true,
      'category': 'Italian',
    };
  }
  
  static Map<String, dynamic> createUser(String id) {
    return {
      'id': id,
      'name': 'User $id',
      'email': 'user$id@example.com',
      'preferences': ['pizza', 'pasta'],
    };
  }
  
  static List<Map<String, dynamic>> createSearchResults(String query) {
    return [
      {'id': '1', 'name': '$query Place 1', 'rating': 4.2},
      {'id': '2', 'name': '$query Place 2', 'rating': 4.7},
      {'id': '3', 'name': '$query Place 3', 'rating': 4.0},
    ];
  }
}