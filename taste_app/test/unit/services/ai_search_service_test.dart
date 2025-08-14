import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/services/ai_search_service.dart';

void main() {
  group('AISearchService Tests', () {
    group('Service Class', () {
      test('should have AISearchService class available', () {
        // Verificar que a classe existe através do import
        expect(AISearchService, isNotNull);
      });
    });

    group('SearchIntention Enum', () {
      test('should have all expected values', () {
        // Verificar que o enum tem todos os valores esperados
        expect(SearchIntention.values, contains(SearchIntention.general));
        expect(SearchIntention.values, contains(SearchIntention.cuisine));
        expect(SearchIntention.values, contains(SearchIntention.dish));
        expect(SearchIntention.values, contains(SearchIntention.location));
        expect(SearchIntention.values, contains(SearchIntention.price));
        expect(SearchIntention.values, contains(SearchIntention.rating));
        expect(SearchIntention.values, contains(SearchIntention.dietary));
      });

      test('should have correct number of values', () {
        // Verificar que o enum tem 7 valores
        expect(SearchIntention.values.length, equals(7));
      });
    });

    group('SearchInterpretation Class', () {
      test('should create SearchInterpretation instance', () {
        // Criar uma instância de SearchInterpretation
        final interpretation = SearchInterpretation(
          originalQuery: 'pizza italiana',
          normalizedQuery: 'pizza italiana',
          intention: SearchIntention.cuisine,
          entities: {'cuisine': ['italiana'], 'dish': ['pizza']},
          corrections: [],
          expandedTerms: ['pizzaria', 'margherita'],
          confidence: 0.8,
        );

        expect(interpretation, isA<SearchInterpretation>());
        expect(interpretation.originalQuery, equals('pizza italiana'));
        expect(interpretation.intention, equals(SearchIntention.cuisine));
        expect(interpretation.confidence, equals(0.8));
      });

      test('should have toString method', () {
        // Verificar método toString
        final interpretation = SearchInterpretation(
          originalQuery: 'sushi',
          normalizedQuery: 'sushi',
          intention: SearchIntention.dish,
          entities: {},
          corrections: [],
          expandedTerms: [],
          confidence: 0.7,
        );

        final stringRepresentation = interpretation.toString();
        expect(stringRepresentation, isA<String>());
        expect(stringRepresentation, contains('sushi'));
        expect(stringRepresentation, contains('dish'));
        expect(stringRepresentation, contains('0.7'));
      });

      test('should handle empty entities and corrections', () {
        // Testar com listas vazias
        final interpretation = SearchInterpretation(
          originalQuery: 'test',
          normalizedQuery: 'test',
          intention: SearchIntention.general,
          entities: {},
          corrections: [],
          expandedTerms: [],
          confidence: 0.5,
        );

        expect(interpretation.entities, isEmpty);
        expect(interpretation.corrections, isEmpty);
        expect(interpretation.expandedTerms, isEmpty);
      });

      test('should handle multiple entities', () {
        // Testar com múltiplas entidades
        final entities = {
          'cuisine': ['italiana', 'japonesa'],
          'dish': ['pizza', 'sushi'],
          'dietary': ['vegetariano']
        };

        final interpretation = SearchInterpretation(
          originalQuery: 'pizza italiana vegetariana',
          normalizedQuery: 'pizza italiana vegetariana',
          intention: SearchIntention.cuisine,
          entities: entities,
          corrections: [],
          expandedTerms: ['pizzaria', 'massa'],
          confidence: 0.9,
        );

        expect(interpretation.entities.length, equals(3));
        expect(interpretation.entities['cuisine'], contains('italiana'));
        expect(interpretation.entities['dish'], contains('pizza'));
        expect(interpretation.entities['dietary'], contains('vegetariano'));
      });
    });


  });
}