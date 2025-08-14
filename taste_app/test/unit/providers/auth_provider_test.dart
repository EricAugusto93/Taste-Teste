import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/presentation/providers/auth_provider.dart';

void main() {
  group('AppAuthState Tests', () {
    test('should create AppAuthState with default values', () {
      // Act
      const authState = AppAuthState();

      // Assert
      expect(authState.isAuthenticated, isFalse);
      expect(authState.user, isNull);
      expect(authState.isLoading, isFalse);
      expect(authState.error, isNull);
    });

    test('should create AppAuthState with custom values', () {
      // Act
      const authState = AppAuthState(
        isAuthenticated: true,
        isLoading: true,
        error: 'Test error',
      );

      // Assert
      expect(authState.isAuthenticated, isTrue);
      expect(authState.user, isNull);
      expect(authState.isLoading, isTrue);
      expect(authState.error, equals('Test error'));
    });

    test('should copy AppAuthState with new values', () {
      // Arrange
      const originalState = AppAuthState(
        isAuthenticated: false,
        isLoading: false,
        error: null,
      );

      // Act
      final newState = originalState.copyWith(
        isAuthenticated: true,
        isLoading: true,
        error: 'New error',
      );

      // Assert
      expect(newState.isAuthenticated, isTrue);
      expect(newState.isLoading, isTrue);
      expect(newState.error, equals('New error'));
      
      // Original state should remain unchanged
      expect(originalState.isAuthenticated, isFalse);
      expect(originalState.isLoading, isFalse);
      expect(originalState.error, isNull);
    });

    test('should copy AppAuthState keeping original values when not specified', () {
      // Arrange
      const originalState = AppAuthState(
        isAuthenticated: true,
        isLoading: false,
        error: 'Original error',
      );

      // Act
      final newState = originalState.copyWith(
        isLoading: true,
      );

      // Assert
      expect(newState.isAuthenticated, isTrue); // Kept from original
      expect(newState.isLoading, isTrue); // Updated
      expect(newState.error, equals('Original error')); // Kept from original
    });
  });
}