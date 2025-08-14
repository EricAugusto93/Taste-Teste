import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:taste_app/core/services/analytics_service.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/core/services/connectivity_service.dart';

// Manual mocks
class MockCacheService extends Mock implements CacheService {
  @override
  Future<T?> get<T>(String key, {bool updateLastAccessed = true}) async {
    return null;
  }
  
  @override
  Future<bool> set<T>(String key, T data, {Duration? ttl, dynamic dataType}) async {
    return true;
  }
}

class MockConnectivityService extends Mock implements ConnectivityService {
  @override
  bool get isOnline => true;
}

void main() {
  group('AnalyticsService Tests', () {
    late AnalyticsService analyticsService;
    late MockCacheService mockCacheService;
    late MockConnectivityService mockConnectivityService;
    
    setUp(() async {
      // Reset GetIt
      GetIt.instance.reset();
      
      // Create mocks
      mockCacheService = MockCacheService();
      mockConnectivityService = MockConnectivityService();
      
      // Register mocks
      GetIt.instance.registerSingleton<CacheService>(mockCacheService);
      GetIt.instance.registerSingleton<ConnectivityService>(mockConnectivityService);
      
      // Mocks já implementam o comportamento necessário
      
      // Reset singleton
      AnalyticsService.resetInstance();
      analyticsService = AnalyticsService.instance;
    });
    
    tearDown(() {
      GetIt.instance.reset();
    });
    
    group('Singleton Pattern', () {
      test('should return same instance', () {
        // Arrange & Act
        final instance1 = AnalyticsService.instance;
        final instance2 = AnalyticsService.instance;
        final instance3 = AnalyticsService.instance;
        
        // Assert
        expect(instance1, equals(instance2));
        expect(instance2, equals(instance3));
        expect(identical(instance1, instance2), isTrue);
      });
    });
    
    group('Search Event Tracking', () {
      test('should track search event with required parameters', () async {
        // Arrange
        const query = 'pizza';
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackSearch(query),
          completes,
        );
      });
      
      test('should track search event with all parameters', () async {
        // Arrange
        const query = 'italian food';
        final metadata = {
          'location': 'São Paulo',
          'timestamp': DateTime.now().toIso8601String(),
          'searchType': 'category',
          'resultsCount': 15,
        };
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackSearch(query, parameters: metadata),
          completes,
        );
      });
      
      test('should track search with trackSearch method', () async {
        // Arrange
        const query = 'sushi';
        final parameters = {
          'category': 'japanese',
          'resultsCount': 8,
          'filters': {
            'priceRange': 'medium',
            'rating': '4+',
          },
        };
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackSearch(query, parameters: parameters),
          completes,
        );
      });
    });
    
    group('Click Event Tracking', () {
      test('should track click event with required parameters', () async {
        // Arrange
        const elementId = 'restaurant_card_123';
        const elementType = 'restaurant_card';
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.buttonTap,
            name: 'element_click',
            parameters: {
              'elementId': elementId,
              'elementType': elementType,
            },
          ),
          completes,
        );
      });
      
      test('should track click event with metadata', () async {
        // Arrange
        const elementId = 'category_button_italian';
        const elementType = 'category_button';
        final metadata = {
          'page': 'home',
          'position': 2,
          'section': 'categories',
          'elementId': elementId,
          'elementType': elementType,
        };
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.buttonTap,
            name: 'element_click',
            parameters: metadata,
          ),
          completes,
        );
      });
    });
    
    group('Custom Event Tracking', () {
      test('should track custom event with name only', () async {
        // Arrange
        const eventName = 'user_login';
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.custom,
            name: eventName,
          ),
          completes,
        );
      });
      
      test('should track custom event with parameters', () async {
        // Arrange
        const eventName = 'order_completed';
        final parameters = {
          'orderId': 'ORD123456',
          'totalAmount': 45.90,
          'itemCount': 3,
          'paymentMethod': 'credit_card',
        };
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.custom,
            name: eventName,
            parameters: parameters,
          ),
          completes,
        );
      });
    });
    
    group('Performance Tracking', () {
      test('should track performance with required parameters', () async {
        // Arrange
        const operation = 'api_call_restaurants';
        const duration = Duration(milliseconds: 250);
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackLoadTime(operation, duration),
          completes,
        );
      });
      
      test('should track performance with metadata', () async {
        // Arrange
        const operation = 'image_load';
        const duration = Duration(milliseconds: 150);
        final metadata = {
          'imageSize': '1024x768',
          'cacheHit': false,
          'networkType': 'wifi',
        };
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackLoadTime(
            operation,
            duration,
            parameters: metadata,
          ),
          completes,
        );
      });
    });
    
    group('Generic Event Tracking', () {
      test('should track generic event with name only', () async {
        // Arrange
        const eventName = 'app_opened';
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.custom,
            name: eventName,
          ),
          completes,
        );
      });
      
      test('should track generic event with parameters', () async {
        // Arrange
        const eventName = 'page_view';
        final parameters = {
          'page': 'restaurant_details',
          'restaurantId': 'rest_123',
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.pageView,
            name: eventName,
            parameters: parameters,
          ),
          completes,
        );
      });
    });
    
    group('Edge Cases', () {
      test('should handle empty strings gracefully', () async {
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackSearch(''),
          completes,
        );
        
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.buttonTap,
            name: 'button_click',
            parameters: {'elementId': '', 'elementType': ''},
          ),
          completes,
        );
        
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.custom,
            name: '',
          ),
          completes,
        );
      });
      
      test('should handle null optional parameters', () async {
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackSearch('test'),
          completes,
        );
        
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.buttonTap,
            name: 'button_click',
            parameters: {'elementId': 'test', 'elementType': 'test'},
          ),
          completes,
        );
      });
      
      test('should handle empty maps', () async {
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.custom,
            name: 'test',
            parameters: {},
          ),
          completes,
        );
        
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.buttonTap,
            name: 'button_click',
            parameters: {'elementId': 'test', 'elementType': 'test'},
          ),
          completes,
        );
      });
      
      test('should handle zero duration', () async {
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackLoadTime(
            'instant_operation',
            Duration.zero,
          ),
          completes,
        );
      });
      
      test('should handle very long duration', () async {
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackLoadTime(
            'long_operation',
            const Duration(hours: 1),
          ),
          completes,
        );
      });
    });
    
    group('Complex Scenarios', () {
      test('should handle multiple rapid events', () async {
        // Act & Assert - Should not throw
        for (int i = 0; i < 10; i++) {
          await analyticsService.trackEvent(
            type: AnalyticsEventType.buttonTap,
            name: 'button_click',
            parameters: {
              'elementId': 'button_$i',
              'elementType': 'button',
            },
          );
        }
        // Should complete without throwing
        expect(true, isTrue);
      });
      
      test('should handle events with complex metadata', () async {
        // Arrange
        final complexMetadata = {
          'user': {
            'id': 'user123',
            'preferences': ['italian', 'japanese'],
            'location': {
              'lat': -23.5505,
              'lng': -46.6333,
              'city': 'São Paulo',
            },
          },
          'session': {
            'id': 'session456',
            'startTime': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
            'events': 25,
          },
          'app': {
            'version': '1.0.0',
            'platform': 'android',
            'buildNumber': 123,
          },
        };
        
        // Act & Assert - Should not throw
        await expectLater(
          analyticsService.trackEvent(
            type: AnalyticsEventType.custom,
            name: 'complex_user_action',
            parameters: complexMetadata,
          ),
          completes,
        );
      });
    });
  });
}

/// Helper class para criar dados de teste
class AnalyticsTestData {
  static Map<String, dynamic> createSearchMetadata() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': 'session_123',
      'userId': 'user_456',
      'location': 'São Paulo',
    };
  }
  
  static Map<String, dynamic> createClickMetadata() {
    return {
      'page': 'home',
      'section': 'featured',
      'position': 1,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  static Map<String, dynamic> createPerformanceMetadata() {
    return {
      'networkType': 'wifi',
      'deviceType': 'mobile',
      'cacheHit': false,
      'retryCount': 0,
    };
  }
}