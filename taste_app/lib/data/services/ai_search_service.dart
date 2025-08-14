import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/restaurant_model.dart';
import '../models/category_model.dart';
import '../repositories/restaurant_repository.dart';
import '../repositories/category_repository.dart';

/// Serviço de IA para interpretação inteligente de buscas
class AISearchService {
  static AISearchService? _instance;
  static AISearchService get instance => _instance ??= AISearchService._();
  AISearchService._();

  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final CategoryRepository _categoryRepository = CategoryRepository.instance;

  /// Interpreta a intenção do usuário na busca
  Future<SearchInterpretation> interpretSearchQuery(String query) async {
    try {
      final normalizedQuery = query.toLowerCase().trim();
      
      // Análise de intenção
      final intention = _analyzeSearchIntention(normalizedQuery);
      
      // Extração de entidades
      final entities = _extractEntities(normalizedQuery);
      
      // Sugestões de correção
      final corrections = _suggestCorrections(normalizedQuery);
      
      // Expansão de consulta
      final expandedTerms = _expandQuery(normalizedQuery);
      
      return SearchInterpretation(
        originalQuery: query,
        normalizedQuery: normalizedQuery,
        intention: intention,
        entities: entities,
        corrections: corrections,
        expandedTerms: expandedTerms,
        confidence: _calculateConfidence(intention, entities),
      );
    } catch (e) {
      debugPrint('Erro na interpretação da busca: $e');
      return SearchInterpretation(
        originalQuery: query,
        normalizedQuery: query.toLowerCase().trim(),
        intention: SearchIntention.general,
        entities: {},
        corrections: [],
        expandedTerms: [],
        confidence: 0.5,
      );
    }
  }

  /// Analisa a intenção da busca
  SearchIntention _analyzeSearchIntention(String query) {
    // Padrões de intenção
    final patterns = {
      SearchIntention.cuisine: [
        'comida', 'culinária', 'cozinha', 'gastronomia',
        'italiana', 'japonesa', 'chinesa', 'brasileira', 'mexicana',
        'árabe', 'francesa', 'indiana', 'tailandesa', 'coreana'
      ],
      SearchIntention.dish: [
        'pizza', 'hambúrguer', 'sushi', 'lasanha', 'risotto',
        'tacos', 'burrito', 'pad thai', 'curry', 'ramen',
        'açaí', 'sorvete', 'bolo', 'torta', 'sobremesa'
      ],
      SearchIntention.location: [
        'perto', 'próximo', 'aqui', 'centro', 'bairro',
        'delivery', 'entrega', 'balcão', 'local'
      ],
      SearchIntention.price: [
        'barato', 'caro', 'econômico', 'premium', 'luxo',
        'promoção', 'desconto', 'oferta', 'preço'
      ],
      SearchIntention.rating: [
        'melhor', 'top', 'avaliado', 'recomendado',
        'estrelas', 'nota', 'qualidade'
      ],
      SearchIntention.dietary: [
        'vegetariano', 'vegano', 'sem glúten', 'diet',
        'light', 'fitness', 'saudável', 'orgânico'
      ],
    };

    for (final entry in patterns.entries) {
      if (entry.value.any((pattern) => query.contains(pattern))) {
        return entry.key;
      }
    }

    return SearchIntention.general;
  }

  /// Extrai entidades da consulta
  Map<String, List<String>> _extractEntities(String query) {
    final entities = <String, List<String>>{};

    // Entidades de culinária
    final cuisines = [
      'italiana', 'japonesa', 'chinesa', 'brasileira', 'mexicana',
      'árabe', 'francesa', 'indiana', 'tailandesa', 'coreana'
    ];
    final foundCuisines = cuisines.where((c) => query.contains(c)).toList();
    if (foundCuisines.isNotEmpty) {
      entities['cuisine'] = foundCuisines;
    }

    // Entidades de pratos
    final dishes = [
      'pizza', 'hambúrguer', 'sushi', 'lasanha', 'risotto',
      'tacos', 'burrito', 'pad thai', 'curry', 'ramen'
    ];
    final foundDishes = dishes.where((d) => query.contains(d)).toList();
    if (foundDishes.isNotEmpty) {
      entities['dish'] = foundDishes;
    }

    // Entidades de localização
    final locations = ['centro', 'delivery', 'balcão', 'perto', 'próximo'];
    final foundLocations = locations.where((l) => query.contains(l)).toList();
    if (foundLocations.isNotEmpty) {
      entities['location'] = foundLocations;
    }

    // Entidades dietéticas
    final dietary = ['vegetariano', 'vegano', 'sem glúten', 'diet', 'light'];
    final foundDietary = dietary.where((d) => query.contains(d)).toList();
    if (foundDietary.isNotEmpty) {
      entities['dietary'] = foundDietary;
    }

    return entities;
  }

  /// Sugere correções para erros de digitação
  List<String> _suggestCorrections(String query) {
    final corrections = <String>[];
    
    // Dicionário de correções comuns
    final commonMistakes = {
      'piza': 'pizza',
      'hamburguer': 'hambúrguer',
      'suchi': 'sushi',
      'xines': 'chinês',
      'japones': 'japonês',
      'vegetarino': 'vegetariano',
      'vegano': 'vegano',
      'acai': 'açaí',
      'sorvte': 'sorvete',
      'lasanha': 'lasanha',
      'risooto': 'risotto',
    };

    for (final entry in commonMistakes.entries) {
      if (query.contains(entry.key)) {
        corrections.add(query.replaceAll(entry.key, entry.value));
      }
    }

    return corrections;
  }

  /// Expande a consulta com termos relacionados
  List<String> _expandQuery(String query) {
    final expandedTerms = <String>[];
    
    // Mapa de expansões
    final expansions = {
      'pizza': ['pizzaria', 'italiana', 'margherita', 'calabresa'],
      'hambúrguer': ['burger', 'lanche', 'sanduíche', 'batata frita'],
      'sushi': ['japonesa', 'sashimi', 'temaki', 'oriental'],
      'italiana': ['pizza', 'massa', 'lasanha', 'risotto'],
      'japonesa': ['sushi', 'sashimi', 'ramen', 'oriental'],
      'chinesa': ['oriental', 'yakisoba', 'rolinho primavera'],
      'mexicana': ['tacos', 'burrito', 'nachos', 'guacamole'],
      'vegetariano': ['vegano', 'salada', 'natural', 'saudável'],
      'açaí': ['sorvete', 'sobremesa', 'natural', 'fitness'],
      'café': ['cafeteria', 'expresso', 'cappuccino', 'latte'],
    };

    for (final entry in expansions.entries) {
      if (query.contains(entry.key)) {
        expandedTerms.addAll(entry.value);
      }
    }

    return expandedTerms.toSet().toList(); // Remove duplicatas
  }

  /// Calcula a confiança da interpretação
  double _calculateConfidence(SearchIntention intention, Map<String, List<String>> entities) {
    double confidence = 0.5; // Base

    // Aumenta confiança baseado na intenção
    if (intention != SearchIntention.general) {
      confidence += 0.2;
    }

    // Aumenta confiança baseado no número de entidades
    confidence += entities.length * 0.1;

    // Limita entre 0 e 1
    return confidence.clamp(0.0, 1.0);
  }

  /// Gera sugestões de busca baseadas no contexto
  Future<List<String>> generateSearchSuggestions(String partialQuery) async {
    try {
      final suggestions = <String>[];
      final query = partialQuery.toLowerCase();

      // Sugestões baseadas em categorias
      final categories = await _categoryRepository.getCategories();
      for (final category in categories) {
        if (category.name.toLowerCase().startsWith(query)) {
          suggestions.add(category.name);
        }
      }

      // Sugestões baseadas em pratos populares
      final popularDishes = [
        'Pizza Margherita', 'Hambúrguer Artesanal', 'Sushi Combo',
        'Lasanha Bolonhesa', 'Risotto de Camarão', 'Tacos Mexicanos',
        'Açaí com Granola', 'Café Expresso', 'Sorvete Artesanal'
      ];
      
      for (final dish in popularDishes) {
        if (dish.toLowerCase().contains(query)) {
          suggestions.add(dish);
        }
      }

      // Sugestões baseadas em tipos de culinária
      final cuisineTypes = [
        'Comida Italiana', 'Comida Japonesa', 'Comida Chinesa',
        'Comida Brasileira', 'Comida Mexicana', 'Comida Árabe',
        'Comida Vegetariana', 'Comida Vegana'
      ];
      
      for (final cuisine in cuisineTypes) {
        if (cuisine.toLowerCase().contains(query)) {
          suggestions.add(cuisine);
        }
      }

      // Limita a 8 sugestões e ordena por relevância
      suggestions.sort((a, b) {
        final aStarts = a.toLowerCase().startsWith(query);
        final bStarts = b.toLowerCase().startsWith(query);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        return a.length.compareTo(b.length);
      });

      return suggestions.take(8).toList();
    } catch (e) {
      debugPrint('Erro ao gerar sugestões: $e');
      return [];
    }
  }
}

/// Enumeração das intenções de busca
enum SearchIntention {
  general,
  cuisine,
  dish,
  location,
  price,
  rating,
  dietary,
}

/// Classe para interpretação de busca
class SearchInterpretation {
  final String originalQuery;
  final String normalizedQuery;
  final SearchIntention intention;
  final Map<String, List<String>> entities;
  final List<String> corrections;
  final List<String> expandedTerms;
  final double confidence;

  const SearchInterpretation({
    required this.originalQuery,
    required this.normalizedQuery,
    required this.intention,
    required this.entities,
    required this.corrections,
    required this.expandedTerms,
    required this.confidence,
  });

  @override
  String toString() {
    return 'SearchInterpretation(query: $originalQuery, intention: $intention, confidence: $confidence)';
  }
}