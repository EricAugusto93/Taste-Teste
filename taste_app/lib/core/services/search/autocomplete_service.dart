import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/data/repositories/restaurant_repository.dart';
import 'package:taste_app/data/repositories/search_history_repository.dart';
import '../../../core/di/injection_container.dart';

/// Modelo para sugestão de autocomplete
class AutocompleteSuggestion {
  final String text;
  final AutocompleteSuggestionType type;
  final String? subtitle;
  final IconData? icon;
  final Map<String, dynamic>? metadata;
  
  const AutocompleteSuggestion({
    required this.text,
    required this.type,
    this.subtitle,
    this.icon,
    this.metadata,
  });
  
  factory AutocompleteSuggestion.fromJson(Map<String, dynamic> json) {
    return AutocompleteSuggestion(
      text: json['text'] as String,
      type: AutocompleteSuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AutocompleteSuggestionType.query,
      ),
      subtitle: json['subtitle'] as String?,
      icon: json['icon'] != null ? IconData(json['icon'], fontFamily: 'MaterialIcons') : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.name,
      'subtitle': subtitle,
      'icon': icon?.codePoint,
      'metadata': metadata,
    };
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutocompleteSuggestion &&
        other.text == text &&
        other.type == type;
  }
  
  @override
  int get hashCode => text.hashCode ^ type.hashCode;
}

/// Tipos de sugestão de autocomplete
enum AutocompleteSuggestionType {
  query,        // Consulta de busca
  restaurant,   // Nome de restaurante
  category,     // Categoria de comida
  location,     // Localização
  history,      // Histórico de busca
  trending,     // Tendências
  cuisine,      // Tipo de culinária
}

/// Serviço de autocomplete para busca
class AutocompleteService {
  static AutocompleteService? _instance;
  static AutocompleteService get instance => _instance ??= AutocompleteService._();
  
  AutocompleteService._();
  
  final RestaurantRepository _restaurantRepository = getIt<RestaurantRepository>();
  final SearchHistoryRepository _searchHistoryRepository = getIt<SearchHistoryRepository>();
  final CacheService _cacheService = CacheService.instance;
  
  static const String _cacheKey = 'autocomplete_suggestions';
  static const Duration _cacheDuration = Duration(hours: 6);
  
  // Cache em memória para sugestões frequentes
  final Map<String, List<AutocompleteSuggestion>> _memoryCache = {};
  
  // Sugestões populares pré-definidas
  static const List<AutocompleteSuggestion> _popularSuggestions = [
    AutocompleteSuggestion(
      text: 'pizza',
      type: AutocompleteSuggestionType.category,
      icon: Icons.local_pizza,
      subtitle: 'Categoria',
    ),
    AutocompleteSuggestion(
      text: 'hambúrguer',
      type: AutocompleteSuggestionType.category,
      icon: Icons.lunch_dining,
      subtitle: 'Categoria',
    ),
    AutocompleteSuggestion(
      text: 'sushi',
      type: AutocompleteSuggestionType.category,
      icon: Icons.set_meal,
      subtitle: 'Categoria',
    ),
    AutocompleteSuggestion(
      text: 'café',
      type: AutocompleteSuggestionType.category,
      icon: Icons.local_cafe,
      subtitle: 'Categoria',
    ),
    AutocompleteSuggestion(
      text: 'sobremesa',
      type: AutocompleteSuggestionType.category,
      icon: Icons.cake,
      subtitle: 'Categoria',
    ),
  ];
  
  /// Obtém sugestões de autocomplete
  Future<List<AutocompleteSuggestion>> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return await _getDefaultSuggestions();
    }
    
    final normalizedQuery = query.toLowerCase().trim();
    
    // Verifica cache em memória primeiro
    if (_memoryCache.containsKey(normalizedQuery)) {
      return _memoryCache[normalizedQuery]!;
    }
    
    try {
      final suggestions = await _buildSuggestions(normalizedQuery);
      
      // Armazena no cache em memória (limitado a 100 entradas)
      if (_memoryCache.length >= 100) {
        _memoryCache.clear();
      }
      _memoryCache[normalizedQuery] = suggestions;
      
      return suggestions;
    } catch (e) {
      debugPrint('Error getting autocomplete suggestions: $e');
      return _getPopularSuggestions(normalizedQuery);
    }
  }
  
  /// Constrói lista de sugestões
  Future<List<AutocompleteSuggestion>> _buildSuggestions(String query) async {
    final suggestions = <AutocompleteSuggestion>[];
    
    // 1. Histórico de busca
    final historySuggestions = await _getHistorySuggestions(query);
    suggestions.addAll(historySuggestions.take(3));
    
    // 2. Restaurantes
    final restaurantSuggestions = await _getRestaurantSuggestions(query);
    suggestions.addAll(restaurantSuggestions.take(5));
    
    // 3. Categorias
    final categorySuggestions = _getCategorySuggestions(query);
    suggestions.addAll(categorySuggestions.take(3));
    
    // 4. Tipos de culinária
    final cuisineSuggestions = _getCuisineSuggestions(query);
    suggestions.addAll(cuisineSuggestions.take(3));
    
    // 5. Sugestões populares
    final popularSuggestions = _getPopularSuggestions(query);
    suggestions.addAll(popularSuggestions.take(2));
    
    // Remove duplicatas e limita a 10 sugestões
    final uniqueSuggestions = suggestions.toSet().toList();
    return uniqueSuggestions.take(10).toList();
  }
  
  /// Obtém sugestões padrão (quando não há query)
  Future<List<AutocompleteSuggestion>> _getDefaultSuggestions() async {
    final suggestions = <AutocompleteSuggestion>[];
    
    try {
      // Histórico recente
      final recentHistory = await _searchHistoryRepository.getRecentSearches(limit: 5);
      suggestions.addAll(
        recentHistory.map((search) => AutocompleteSuggestion(
          text: search,
          type: AutocompleteSuggestionType.history,
          icon: Icons.history,
          subtitle: 'Busca recente',
        )),
      );
      
      // Sugestões populares
      suggestions.addAll(_popularSuggestions);
      
      return suggestions.take(8).toList();
    } catch (e) {
      debugPrint('Error getting default suggestions: $e');
      return _popularSuggestions.toList();
    }
  }
  
  /// Obtém sugestões do histórico
  Future<List<AutocompleteSuggestion>> _getHistorySuggestions(String query) async {
    try {
      final history = await _searchHistoryRepository.searchHistory(query);
      return history.map((search) => AutocompleteSuggestion(
        text: search,
        type: AutocompleteSuggestionType.history,
        icon: Icons.history,
        subtitle: 'Busca anterior',
      )).toList();
    } catch (e) {
      debugPrint('Error getting history suggestions: $e');
      return [];
    }
  }
  
  /// Obtém sugestões de restaurantes
  Future<List<AutocompleteSuggestion>> _getRestaurantSuggestions(String query) async {
    try {
      final restaurants = await _restaurantRepository.searchRestaurants(query);
      
      return restaurants.map((restaurant) => AutocompleteSuggestion(
        text: restaurant.name,
        type: AutocompleteSuggestionType.restaurant,
        icon: Icons.restaurant,
        subtitle: restaurant.category,
        metadata: {'id': restaurant.id},
      )).toList();
    } catch (e) {
      debugPrint('Error getting restaurant suggestions: $e');
      return [];
    }
  }
  
  /// Obtém sugestões de categorias
  List<AutocompleteSuggestion> _getCategorySuggestions(String query) {
    final categories = [
      'pizza', 'hambúrguer', 'sushi', 'café', 'sobremesa',
      'italiana', 'japonesa', 'brasileira', 'mexicana', 'chinesa',
      'vegetariana', 'vegana', 'churrasco', 'frutos do mar',
    ];
    
    return categories
        .where((category) => category.toLowerCase().contains(query.toLowerCase()))
        .map((category) => AutocompleteSuggestion(
          text: category,
          type: AutocompleteSuggestionType.category,
          icon: Icons.category,
          subtitle: 'Categoria',
        ))
        .toList();
  }
  
  /// Obtém sugestões de tipos de culinária
  List<AutocompleteSuggestion> _getCuisineSuggestions(String query) {
    final cuisines = [
      'comida italiana', 'comida japonesa', 'comida brasileira',
      'comida mexicana', 'comida chinesa', 'comida árabe',
      'comida francesa', 'comida tailandesa', 'comida indiana',
    ];
    
    return cuisines
        .where((cuisine) => cuisine.toLowerCase().contains(query.toLowerCase()))
        .map((cuisine) => AutocompleteSuggestion(
          text: cuisine,
          type: AutocompleteSuggestionType.cuisine,
          icon: Icons.public,
          subtitle: 'Culinária',
        ))
        .toList();
  }
  
  /// Obtém sugestões populares
  List<AutocompleteSuggestion> _getPopularSuggestions(String query) {
    return _popularSuggestions
        .where((suggestion) => suggestion.text.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  
  /// Salva sugestão selecionada no histórico
  Future<void> saveSuggestionToHistory(AutocompleteSuggestion suggestion) async {
    try {
      await _searchHistoryRepository.addSearch(suggestion.text);
    } catch (e) {
      debugPrint('Error saving suggestion to history: $e');
    }
  }
  
  /// Limpa cache de sugestões
  void clearCache() {
    _memoryCache.clear();
    _cacheService.remove(_cacheKey);
  }
  
  /// Pré-carrega sugestões populares
  Future<void> preloadSuggestions() async {
    try {
      // Pré-carrega sugestões para termos populares
      final popularTerms = ['pizza', 'hambúrguer', 'sushi', 'café'];
      
      for (final term in popularTerms) {
        await getSuggestions(term);
      }
      
      debugPrint('Autocomplete suggestions preloaded');
    } catch (e) {
      debugPrint('Error preloading suggestions: $e');
    }
  }
}

/// Widget de campo de busca com autocomplete
class AutocompleteSearchField extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final Function(String)? onSubmitted;
  final Function(AutocompleteSuggestion)? onSuggestionSelected;
  final VoidCallback? onVoiceSearch;
  final bool showVoiceButton;
  final bool enabled;
  
  const AutocompleteSearchField({
    super.key,
    this.initialValue,
    this.hintText,
    this.onSubmitted,
    this.onSuggestionSelected,
    this.onVoiceSearch,
    this.showVoiceButton = true,
    this.enabled = true,
  });
  
  @override
  State<AutocompleteSearchField> createState() => _AutocompleteSearchFieldState();
}

class _AutocompleteSearchFieldState extends State<AutocompleteSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  
  List<AutocompleteSuggestion> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;
  
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    
    // Carrega sugestões padrão
    _loadDefaultSuggestions();
  }
  
  void _onTextChanged() {
    final query = _controller.text;
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadSuggestions(query);
    });
  }
  
  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = true;
      });
      
      if (_controller.text.isEmpty) {
        _loadDefaultSuggestions();
      }
    } else {
      // Delay para permitir clique em sugestão
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }
  
  void _loadDefaultSuggestions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final suggestions = await AutocompleteService.instance.getSuggestions('');
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }
  
  void _loadSuggestions(String query) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final suggestions = await AutocompleteService.instance.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }
  
  void _onSuggestionTap(AutocompleteSuggestion suggestion) {
    _controller.text = suggestion.text;
    _focusNode.unfocus();
    
    // Salva no histórico
    AutocompleteService.instance.saveSuggestionToHistory(suggestion);
    
    // Callbacks
    widget.onSuggestionSelected?.call(suggestion);
    widget.onSubmitted?.call(suggestion.text);
  }
  
  void _onSubmit(String value) {
    if (value.trim().isNotEmpty) {
      _focusNode.unfocus();
      widget.onSubmitted?.call(value.trim());
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Campo de busca
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            onSubmitted: _onSubmit,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'O que você está procurando?',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.showVoiceButton
                  ? IconButton(
                      onPressed: widget.onVoiceSearch,
                      icon: const Icon(Icons.mic),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        
        // Lista de sugestões
        if (_showSuggestions && (_suggestions.isNotEmpty || _isLoading))
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        leading: Icon(
                          suggestion.icon ?? Icons.search,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        title: Text(
                          suggestion.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: suggestion.subtitle != null
                            ? Text(
                                suggestion.subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              )
                            : null,
                        trailing: suggestion.type == AutocompleteSuggestionType.history
                            ? const Icon(
                                Icons.north_west,
                                size: 16,
                                color: Colors.grey,
                              )
                            : null,
                        onTap: () => _onSuggestionTap(suggestion),
                        dense: true,
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
