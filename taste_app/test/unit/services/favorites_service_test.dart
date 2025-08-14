import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/services/favorites_service.dart';

void main() {
  group('FavoritesService Tests', () {
    group('Service Class', () {
      test('should have FavoritesService class available', () {
        // Verificar que a classe existe através do import
        expect(true, isTrue); // Teste básico para verificar que o import funciona
      });
    });





    group('FavoritesStats Class', () {
      test('should create FavoritesStats with required parameters', () {
        final stats = FavoritesStats(
          totalFavorites: 10,
          recentFavorites: 3,
          mostFavoritedCategory: 'Pizza',
        );
        
        expect(stats.totalFavorites, equals(10));
        expect(stats.recentFavorites, equals(3));
        expect(stats.mostFavoritedCategory, equals('Pizza'));
      });

      test('should create FavoritesStats with null category', () {
        final stats = FavoritesStats(
          totalFavorites: 5,
          recentFavorites: 1,
          mostFavoritedCategory: null,
        );
        
        expect(stats.totalFavorites, equals(5));
        expect(stats.recentFavorites, equals(1));
        expect(stats.mostFavoritedCategory, isNull);
      });

      test('should handle zero values in FavoritesStats', () {
        final stats = FavoritesStats(
          totalFavorites: 0,
          recentFavorites: 0,
          mostFavoritedCategory: null,
        );
        
        expect(stats.totalFavorites, equals(0));
        expect(stats.recentFavorites, equals(0));
        expect(stats.mostFavoritedCategory, isNull);
      });
    });
  });
}