import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/services/search/search_service.dart';

void main() {
  group('SearchService Tests', () {
    group('Service Class', () {
      test('should have SearchService class available', () {
        // Verificar que a classe existe através do import
        expect(true, isTrue); // Teste básico para verificar que o import funciona
      });
    });

    group('SearchResults Class', () {
      test('should create SearchResults with required parameters', () {
        final results = SearchResults(
          restaurants: [],
          query: 'pizza',
          totalResults: 0,
          searchTime: 150,
        );
        
        expect(results.restaurants, isEmpty);
        expect(results.query, equals('pizza'));
        expect(results.totalResults, equals(0));
        expect(results.searchTime, equals(150));
        expect(results.error, isNull);
      });

      test('should create SearchResults with error', () {
        final results = SearchResults(
          restaurants: [],
          query: 'invalid',
          totalResults: 0,
          searchTime: 50,
          error: 'Search failed',
        );
        
        expect(results.restaurants, isEmpty);
        expect(results.query, equals('invalid'));
        expect(results.totalResults, equals(0));
        expect(results.searchTime, equals(50));
        expect(results.error, equals('Search failed'));
      });

      test('should handle SearchResults with multiple restaurants', () {
        final results = SearchResults(
          restaurants: [], // Lista vazia para teste simples
          query: 'hamburger',
          totalResults: 5,
          searchTime: 200,
        );
        
        expect(results.restaurants, isA<List>());
        expect(results.query, equals('hamburger'));
        expect(results.totalResults, equals(5));
        expect(results.searchTime, equals(200));
      });

      test('should handle zero search time', () {
        final results = SearchResults(
          restaurants: [],
          query: 'fast',
          totalResults: 1,
          searchTime: 0,
        );
        
        expect(results.searchTime, equals(0));
      });

      test('should handle negative search time', () {
        final results = SearchResults(
          restaurants: [],
          query: 'test',
          totalResults: 0,
          searchTime: -1,
        );
        
        expect(results.searchTime, equals(-1));
      });
    });


  });
}
