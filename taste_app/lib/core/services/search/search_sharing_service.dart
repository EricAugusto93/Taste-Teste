import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/data/models/restaurant_model.dart';

/// Modelo para busca salva
class SavedSearch {
  final String id;
  final String name;
  final String query;
  final Map<String, dynamic> filters;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final int useCount;
  final bool isPublic;
  final List<String> tags;
  
  const SavedSearch({
    required this.id,
    required this.name,
    required this.query,
    required this.filters,
    required this.createdAt,
    this.lastUsed,
    this.useCount = 0,
    this.isPublic = false,
    this.tags = const [],
  });
  
  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] as String,
      name: json['name'] as String,
      query: json['query'] as String,
      filters: json['filters'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
      useCount: json['useCount'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'query': query,
      'filters': filters,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'useCount': useCount,
      'isPublic': isPublic,
      'tags': tags,
    };
  }
  
  SavedSearch copyWith({
    String? id,
    String? name,
    String? query,
    Map<String, dynamic>? filters,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? useCount,
    bool? isPublic,
    List<String>? tags,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      name: name ?? this.name,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      useCount: useCount ?? this.useCount,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
    );
  }
}

/// Modelo para link de busca compartilhada
class SharedSearchLink {
  final String id;
  final String query;
  final Map<String, dynamic> filters;
  final List<RestaurantModel>? results;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? title;
  final String? description;
  
  const SharedSearchLink({
    required this.id,
    required this.query,
    required this.filters,
    this.results,
    required this.createdAt,
    this.expiresAt,
    this.title,
    this.description,
  });
  
  factory SharedSearchLink.fromJson(Map<String, dynamic> json) {
    return SharedSearchLink(
      id: json['id'] as String,
      query: json['query'] as String,
      filters: json['filters'] as Map<String, dynamic>,
      results: json['results'] != null
          ? (json['results'] as List)
              .map((r) => RestaurantModel.fromJson(r as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'filters': filters,
      'results': results?.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'title': title,
      'description': description,
    };
  }
}

/// Serviço de compartilhamento e salvamento de buscas
class SearchSharingService {
  static SearchSharingService? _instance;
  static SearchSharingService get instance => _instance ??= SearchSharingService._();
  
  SearchSharingService._();
  
  final CacheService _cacheService = CacheService.instance;
  
  static const String _savedSearchesKey = 'saved_searches';
  static const String _sharedLinksKey = 'shared_links';
  
  /// Salva uma busca
  Future<SavedSearch> saveSearch({
    required String name,
    required String query,
    required Map<String, dynamic> filters,
    List<String> tags = const [],
    bool isPublic = false,
  }) async {
    try {
      final savedSearch = SavedSearch(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        query: query,
        filters: filters,
        createdAt: DateTime.now(),
        tags: tags,
        isPublic: isPublic,
      );
      
      final savedSearches = await getSavedSearches();
      savedSearches.add(savedSearch);
      
      await _saveSavedSearches(savedSearches);
      
      debugPrint('Search saved: ${savedSearch.name}');
      return savedSearch;
    } catch (e) {
      debugPrint('Error saving search: $e');
      rethrow;
    }
  }
  
  /// Obtém todas as buscas salvas
  Future<List<SavedSearch>> getSavedSearches() async {
    try {
      final data = await _cacheService.get(_savedSearchesKey);
      if (data == null) return [];
      
      final List<dynamic> searchesData = data as List<dynamic>;
      return searchesData
          .map((s) => SavedSearch.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting saved searches: $e');
      return [];
    }
  }
  
  /// Atualiza uma busca salva
  Future<void> updateSavedSearch(SavedSearch updatedSearch) async {
    try {
      final savedSearches = await getSavedSearches();
      final index = savedSearches.indexWhere((s) => s.id == updatedSearch.id);
      
      if (index != -1) {
        savedSearches[index] = updatedSearch;
        await _saveSavedSearches(savedSearches);
        debugPrint('Search updated: ${updatedSearch.name}');
      }
    } catch (e) {
      debugPrint('Error updating saved search: $e');
    }
  }
  
  /// Remove uma busca salva
  Future<void> removeSavedSearch(String searchId) async {
    try {
      final savedSearches = await getSavedSearches();
      savedSearches.removeWhere((s) => s.id == searchId);
      
      await _saveSavedSearches(savedSearches);
      debugPrint('Search removed: $searchId');
    } catch (e) {
      debugPrint('Error removing saved search: $e');
    }
  }
  
  /// Marca uma busca como usada
  Future<void> markSearchAsUsed(String searchId) async {
    try {
      final savedSearches = await getSavedSearches();
      final index = savedSearches.indexWhere((s) => s.id == searchId);
      
      if (index != -1) {
        final updatedSearch = savedSearches[index].copyWith(
          lastUsed: DateTime.now(),
          useCount: savedSearches[index].useCount + 1,
        );
        
        savedSearches[index] = updatedSearch;
        await _saveSavedSearches(savedSearches);
      }
    } catch (e) {
      debugPrint('Error marking search as used: $e');
    }
  }
  
  /// Cria um link de compartilhamento
  Future<SharedSearchLink> createShareLink({
    required String query,
    required Map<String, dynamic> filters,
    List<RestaurantModel>? results,
    String? title,
    String? description,
    Duration? expiration,
  }) async {
    try {
      final sharedLink = SharedSearchLink(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        query: query,
        filters: filters,
        results: results,
        createdAt: DateTime.now(),
        expiresAt: expiration != null 
            ? DateTime.now().add(expiration)
            : null,
        title: title,
        description: description,
      );
      
      final sharedLinks = await _getSharedLinks();
      sharedLinks.add(sharedLink);
      
      await _saveSharedLinks(sharedLinks);
      
      debugPrint('Share link created: ${sharedLink.id}');
      return sharedLink;
    } catch (e) {
      debugPrint('Error creating share link: $e');
      rethrow;
    }
  }
  
  /// Obtém um link compartilhado
  Future<SharedSearchLink?> getSharedLink(String linkId) async {
    try {
      final sharedLinks = await _getSharedLinks();
      final link = sharedLinks.where((l) => l.id == linkId).firstOrNull;
      
      // Verifica se o link expirou
      if (link != null && link.expiresAt != null && 
          DateTime.now().isAfter(link.expiresAt!)) {
        await _removeSharedLink(linkId);
        return null;
      }
      
      return link;
    } catch (e) {
      debugPrint('Error getting shared link: $e');
      return null;
    }
  }
  
  /// Compartilha busca via sistema nativo
  Future<void> shareSearch({
    required String query,
    required Map<String, dynamic> filters,
    List<RestaurantModel>? results,
    String? customMessage,
  }) async {
    try {
      // Cria link de compartilhamento
      final sharedLink = await createShareLink(
        query: query,
        filters: filters,
        results: results,
        title: 'Busca no Taste: $query',
        description: _generateSearchDescription(query, filters),
        expiration: const Duration(days: 30),
      );
      
      // Gera URL de compartilhamento
      final shareUrl = _generateShareUrl(sharedLink.id);
      
      // Monta mensagem
      final message = customMessage ?? _generateShareMessage(query, filters, shareUrl);
      
      // Compartilha
      await Share.share(
        message,
        subject: 'Busca no Taste: $query',
      );
      
      debugPrint('Search shared: $shareUrl');
    } catch (e) {
      debugPrint('Error sharing search: $e');
      rethrow;
    }
  }
  
  /// Copia link de busca para área de transferência
  Future<void> copySearchLink({
    required String query,
    required Map<String, dynamic> filters,
    List<RestaurantModel>? results,
  }) async {
    try {
      // Cria link de compartilhamento
      final sharedLink = await createShareLink(
        query: query,
        filters: filters,
        results: results,
        title: 'Busca no Taste: $query',
        expiration: const Duration(days: 30),
      );
      
      // Gera URL
      final shareUrl = _generateShareUrl(sharedLink.id);
      
      // Copia para área de transferência
      await Clipboard.setData(ClipboardData(text: shareUrl));
      
      debugPrint('Search link copied: $shareUrl');
    } catch (e) {
      debugPrint('Error copying search link: $e');
      rethrow;
    }
  }
  
  /// Exporta buscas salvas
  Future<String> exportSavedSearches({String format = 'json'}) async {
    try {
      final savedSearches = await getSavedSearches();
      
      switch (format.toLowerCase()) {
        case 'json':
          return json.encode(savedSearches.map((s) => s.toJson()).toList());
        
        case 'csv':
          return _exportToCsv(savedSearches);
        
        default:
          throw ArgumentError('Formato não suportado: $format');
      }
    } catch (e) {
      debugPrint('Error exporting saved searches: $e');
      rethrow;
    }
  }
  
  /// Importa buscas salvas
  Future<void> importSavedSearches(String data, {String format = 'json'}) async {
    try {
      List<SavedSearch> importedSearches;
      
      switch (format.toLowerCase()) {
        case 'json':
          final List<dynamic> jsonData = json.decode(data) as List<dynamic>;
          importedSearches = jsonData
              .map((s) => SavedSearch.fromJson(s as Map<String, dynamic>))
              .toList();
          break;
        
        default:
          throw ArgumentError('Formato não suportado: $format');
      }
      
      final existingSearches = await getSavedSearches();
      
      // Mescla buscas (evita duplicatas por nome)
      for (final importedSearch in importedSearches) {
        final exists = existingSearches.any((s) => s.name == importedSearch.name);
        if (!exists) {
          existingSearches.add(importedSearch.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          ));
        }
      }
      
      await _saveSavedSearches(existingSearches);
      debugPrint('Imported ${importedSearches.length} searches');
    } catch (e) {
      debugPrint('Error importing saved searches: $e');
      rethrow;
    }
  }
  
  /// Obtém buscas populares
  Future<List<SavedSearch>> getPopularSearches({int limit = 10}) async {
    try {
      final savedSearches = await getSavedSearches();
      
      // Filtra apenas buscas públicas e ordena por uso
      final popularSearches = savedSearches
          .where((s) => s.isPublic)
          .toList()
        ..sort((a, b) => b.useCount.compareTo(a.useCount));
      
      return popularSearches.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting popular searches: $e');
      return [];
    }
  }
  
  /// Limpa buscas expiradas
  Future<void> cleanupExpiredLinks() async {
    try {
      final sharedLinks = await _getSharedLinks();
      final now = DateTime.now();
      
      final validLinks = sharedLinks.where((link) {
        return link.expiresAt == null || now.isBefore(link.expiresAt!);
      }).toList();
      
      if (validLinks.length != sharedLinks.length) {
        await _saveSharedLinks(validLinks);
        debugPrint('Cleaned up ${sharedLinks.length - validLinks.length} expired links');
      }
    } catch (e) {
      debugPrint('Error cleaning up expired links: $e');
    }
  }
  
  // Métodos privados
  
  Future<void> _saveSavedSearches(List<SavedSearch> searches) async {
    await _cacheService.set(
      _savedSearchesKey,
      searches.map((s) => s.toJson()).toList(),
    );
  }
  
  Future<List<SharedSearchLink>> _getSharedLinks() async {
    try {
      final data = await _cacheService.get(_sharedLinksKey);
      if (data == null) return [];
      
      final List<dynamic> linksData = data as List<dynamic>;
      return linksData
          .map((l) => SharedSearchLink.fromJson(l as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting shared links: $e');
      return [];
    }
  }
  
  Future<void> _saveSharedLinks(List<SharedSearchLink> links) async {
    await _cacheService.set(
      _sharedLinksKey,
      links.map((l) => l.toJson()).toList(),
    );
  }
  
  Future<void> _removeSharedLink(String linkId) async {
    final sharedLinks = await _getSharedLinks();
    sharedLinks.removeWhere((l) => l.id == linkId);
    await _saveSharedLinks(sharedLinks);
  }
  
  String _generateShareUrl(String linkId) {
    return 'https://taste.app/search/shared/$linkId';
  }
  
  String _generateSearchDescription(String query, Map<String, dynamic> filters) {
    final parts = <String>[];
    
    if (query.isNotEmpty) {
      parts.add('"$query"');
    }
    
    if (filters.containsKey('cuisine') && filters['cuisine'] != null) {
      parts.add('Culinária: ${filters['cuisine']}');
    }
    
    if (filters.containsKey('priceRange') && filters['priceRange'] != null) {
      parts.add('Preço: ${filters['priceRange']}');
    }
    
    if (filters.containsKey('rating') && filters['rating'] != null) {
      parts.add('Avaliação: ${filters['rating']}+');
    }
    
    return parts.join(' • ');
  }
  
  String _generateShareMessage(String query, Map<String, dynamic> filters, String url) {
    final description = _generateSearchDescription(query, filters);
    return 'Confira esta busca no Taste: $description\n\n$url';
  }
  
  String _exportToCsv(List<SavedSearch> searches) {
    final buffer = StringBuffer();
    
    // Cabeçalho
    buffer.writeln('Nome,Query,Filtros,Criado em,Último uso,Usos,Público,Tags');
    
    // Dados
    for (final search in searches) {
      final filters = json.encode(search.filters).replaceAll(',', ';');
      final tags = search.tags.join(';');
      
      buffer.writeln([
        search.name,
        search.query,
        filters,
        search.createdAt.toIso8601String(),
        search.lastUsed?.toIso8601String() ?? '',
        search.useCount,
        search.isPublic,
        tags,
      ].join(','));
    }
    
    return buffer.toString();
  }
}

/// Widget para gerenciar buscas salvas
class SavedSearchesWidget extends StatefulWidget {
  final Function(SavedSearch)? onSearchSelected;
  final bool showActions;
  
  const SavedSearchesWidget({
    super.key,
    this.onSearchSelected,
    this.showActions = true,
  });
  
  @override
  State<SavedSearchesWidget> createState() => _SavedSearchesWidgetState();
}

class _SavedSearchesWidgetState extends State<SavedSearchesWidget> {
  List<SavedSearch> _savedSearches = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSavedSearches();
  }
  
  Future<void> _loadSavedSearches() async {
    try {
      final searches = await SearchSharingService.instance.getSavedSearches();
      if (mounted) {
        setState(() {
          _savedSearches = searches;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_savedSearches.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma busca salva',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _savedSearches.length,
      itemBuilder: (context, index) {
        final search = _savedSearches[index];
        
        return ListTile(
          title: Text(search.name),
          subtitle: Text(
            search.query.isNotEmpty ? search.query : 'Busca por filtros',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: widget.showActions
              ? PopupMenuButton<String>(
                  onSelected: (action) => _handleAction(action, search),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Text('Compartilhar'),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Text('Copiar link'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                )
              : null,
          onTap: () {
            widget.onSearchSelected?.call(search);
            SearchSharingService.instance.markSearchAsUsed(search.id);
          },
        );
      },
    );
  }
  
  void _handleAction(String action, SavedSearch search) async {
    switch (action) {
      case 'share':
        await SearchSharingService.instance.shareSearch(
          query: search.query,
          filters: search.filters,
        );
        break;
      
      case 'copy':
        await SearchSharingService.instance.copySearchLink(
          query: search.query,
          filters: search.filters,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link copiado!')),
          );
        }
        break;
      
      case 'delete':
        await SearchSharingService.instance.removeSavedSearch(search.id);
        _loadSavedSearches();
        break;
    }
  }
}