import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taste_app/data/services/connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ConnectivityService Tests', () {
    late ConnectivityService connectivityService;

    setUp(() {
      connectivityService = ConnectivityService.instance;
      // Limpa dados antes de cada teste
      connectivityService.clearData();
    });

    group('Singleton Pattern', () {
      test('should return the same instance', () {
        // Act
        final instance1 = ConnectivityService.instance;
        final instance2 = ConnectivityService.instance;

        // Assert
        expect(instance1, same(instance2));
      });
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        // Assert
        expect(connectivityService.connectionStatus, equals(ConnectivityResult.none));
        expect(connectivityService.hasInternetConnection, isFalse);
        expect(connectivityService.isWifiConnected, isFalse);
        expect(connectivityService.isMobileConnected, isFalse);
        expect(connectivityService.isDisconnected, isTrue);
      });
    });

    group('Connection Status Properties', () {
      test('should correctly identify WiFi connection', () {
        // Arrange
        connectivityService.clearData();
        
        // Simula status WiFi (não podemos testar diretamente sem mock)
        // Testamos apenas a lógica dos getters
        
        // Assert
        expect(connectivityService.isWifiConnected, 
               equals(connectivityService.connectionStatus == ConnectivityResult.wifi));
      });

      test('should correctly identify mobile connection', () {
        // Assert
        expect(connectivityService.isMobileConnected, 
               equals(connectivityService.connectionStatus == ConnectivityResult.mobile));
      });

      test('should correctly identify disconnected state', () {
        // Assert
        expect(connectivityService.isDisconnected, 
               equals(connectivityService.connectionStatus == ConnectivityResult.none));
      });
    });

    group('Connection Descriptions', () {
      test('should return correct description for no connection', () {
        // Arrange
        connectivityService.clearData();
        
        // Act
        final description = connectivityService.getConnectionDescription();
        
        // Assert
        expect(description, equals('Sem conexão'));
      });

      test('should handle different connection types in description', () {
        // Act
        final description = connectivityService.getConnectionDescription();
        
        // Assert
        expect(description, isA<String>());
        expect(description.isNotEmpty, isTrue);
      });
    });

    group('Connection Quality Assessment', () {
      test('should not recommend heavy operations without internet', () {
        // Arrange
        connectivityService.clearData();
        
        // Act
        final isGoodForHeavy = connectivityService.isGoodForHeavyOperations();
        
        // Assert
        expect(isGoodForHeavy, isFalse);
      });

      test('should recommend cache when no connection', () {
        // Arrange
        connectivityService.clearData();
        
        // Act
        final shouldUseCache = connectivityService.shouldUseCache();
        
        // Assert
        expect(shouldUseCache, isTrue);
      });
    });

    group('Connection Waiting', () {
      test('should timeout when waiting for connection', () async {
        // Arrange
        connectivityService.clearData();
        const shortTimeout = Duration(milliseconds: 100);
        
        // Act
        final hasConnection = await connectivityService.waitForConnection(
          timeout: shortTimeout,
          checkInterval: const Duration(milliseconds: 50),
        );
        
        // Assert
        expect(hasConnection, isFalse);
      });

      test('should return null when executing action without connection', () async {
        // Arrange
        connectivityService.clearData();
        
        // Act
        final result = await connectivityService.executeWhenConnected<String>(
          () async => 'success',
          timeout: const Duration(milliseconds: 100),
        );
        
        // Assert
        expect(result, isNull);
      });
    });

    group('Internet Connection Verification', () {
      test('should handle timeout in internet connection check', () async {
        // Act
        final hasConnection = await connectivityService.hasInternetConnectionWithTimeout(
          timeout: const Duration(milliseconds: 1), // Timeout muito curto
        );
        
        // Assert
        // Pode ser true ou false dependendo da conectividade real
        expect(hasConnection, isA<bool>());
      });

      test('should handle internet connection check with default timeout', () async {
        // Act
        final hasConnection = await connectivityService.hasInternetConnectionWithTimeout();
        
        // Assert
        expect(hasConnection, isA<bool>());
      });
    });

    group('Service Management', () {
      test('should initialize service without errors', () async {
        // Act & Assert
        expect(() => connectivityService.initialize(), returnsNormally);
      });

      test('should check connectivity without errors', () async {
        // Act
        final result = await connectivityService.checkConnectivity();
        
        // Assert
        expect(result, isA<ConnectivityResult>());
      });

      test('should clear data correctly', () {
        // Act
        connectivityService.clearData();
        
        // Assert
        expect(connectivityService.connectionStatus, equals(ConnectivityResult.none));
        expect(connectivityService.hasInternetConnection, isFalse);
      });
    });

    group('Stream Access', () {
      test('should provide connectivity stream', () {
        // Act
        final stream = connectivityService.connectivityStream;
        
        // Assert
        expect(stream, isA<Stream<ConnectivityResult>>());
      });
    });

    group('Edge Cases', () {
      test('should handle multiple consecutive calls to checkConnectivity', () async {
        // Act
        final result1 = await connectivityService.checkConnectivity();
        final result2 = await connectivityService.checkConnectivity();
        final result3 = await connectivityService.checkConnectivity();
        
        // Assert
        expect(result1, isA<ConnectivityResult>());
        expect(result2, isA<ConnectivityResult>());
        expect(result3, isA<ConnectivityResult>());
      });

      test('should handle multiple consecutive calls to clearData', () {
        // Act & Assert
        expect(() {
          connectivityService.clearData();
          connectivityService.clearData();
          connectivityService.clearData();
        }, returnsNormally);
      });

      test('should handle executeWhenConnected with immediate execution', () async {
        // Arrange
        var executionCount = 0;
        
        // Act
        final result = await connectivityService.executeWhenConnected<int>(
          () async {
            executionCount++;
            return executionCount;
          },
          timeout: const Duration(milliseconds: 100),
        );
        
        // Assert
        // Se há conexão, deve executar; se não há, deve retornar null
        if (connectivityService.hasInternetConnection) {
          expect(result, equals(1));
          expect(executionCount, equals(1));
        } else {
          expect(result, isNull);
          expect(executionCount, equals(0));
        }
      });
    });

    group('Connection Type Validation', () {
      test('should validate connection status consistency', () {
        // Act
        final status = connectivityService.connectionStatus;
        final isWifi = connectivityService.isWifiConnected;
        final isMobile = connectivityService.isMobileConnected;
        final isDisconnected = connectivityService.isDisconnected;
        
        // Assert - apenas um deve ser verdadeiro
        final trueCount = [isWifi, isMobile, isDisconnected].where((x) => x).length;
        expect(trueCount, lessThanOrEqualTo(1));
        
        // Verifica consistência com o status
        if (status == ConnectivityResult.wifi) {
          expect(isWifi, isTrue);
        } else if (status == ConnectivityResult.mobile) {
          expect(isMobile, isTrue);
        } else if (status == ConnectivityResult.none) {
          expect(isDisconnected, isTrue);
        }
      });
    });
  });
}