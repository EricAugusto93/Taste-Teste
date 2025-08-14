import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/navigation_helper.dart';
import '../core/models/category.dart';
import '../core/models/restaurant.dart';
import '../core/repositories/category_repository.dart';
import '../core/repositories/restaurant_repository.dart';
import '../core/services/location_service.dart';
import '../core/services/distance_service.dart';
import '../core/services/analytics_service.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_icons.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;
  final String? categoryName;

  const CategoryPage({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final LocationService _locationService = LocationService();
  final DistanceService _distanceService = DistanceService();
  final AnalyticsService _analytics = AnalyticsService.instance;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Category? _category;
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  String _sortBy = 'distance'; // distance, rating, name, price
  bool _sortAscending = true;
  Map<String, dynamic> _filters = {};
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMoreData = true;
  
  // Debounce para busca
  Timer? _searchDebounce;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 500);
  
  // Cache para evitar recálculos desnecessários
  String? _lastFilterKey;
  List<Restaurant>? _cachedFilteredResults;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreRestaurants();
    }
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text;
    if (newQuery != _searchQuery) {
      // Cancelar debounce anterior
      _searchDebounce?.cancel();
      
      // Configurar novo debounce
      _searchDebounce = Timer(_searchDebounceDelay, () {
        if (mounted) {
          setState(() {
            _searchQuery = newQuery;
          });
          _filterAndSortRestaurants();
        }
      });
    }
  }

  Future<void> _loadCategoryData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Carrega dados da categoria
      final category = await _categoryRepository.getCategoryById(widget.categoryId);
      if (category == null) {
        throw Exception('Categoria não encontrada');
      }

      // Carrega restaurantes da categoria
      final restaurants = await _restaurantRepository.getRestaurantsByCategory(
        widget.categoryId,
        page: 1,
        pageSize: _pageSize,
      );

      // Calcula distâncias se localização disponível
      final location = await _locationService.getCurrentLocation();
      List<Restaurant> restaurantsWithDistance = restaurants;
      if (location != null) {
        restaurantsWithDistance = await _distanceService
            .calculateDistanceForRestaurants(restaurants, location);
      }

      setState(() {
        _category = category;
        _restaurants = restaurantsWithDistance;
        _filteredRestaurants = restaurantsWithDistance;
        _isLoading = false;
        _hasMoreData = restaurants.length == _pageSize;
      });

      _filterAndSortRestaurants();

      _analytics.trackEvent('category_page_loaded', parameters: {
        'category_id': widget.categoryId,
        'category_name': category.name,
        'restaurants_count': restaurants.length,
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      _analytics.trackEvent('category_page_load_error', parameters: {
        'category_id': widget.categoryId,
        'error': e.toString(),
      });
    }
  }

  Future<void> _loadMoreRestaurants() async {
    if (_isLoadingMore || !_hasMoreData) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final newRestaurants = await _restaurantRepository.getRestaurantsByCategory(
        widget.categoryId,
        page: _currentPage + 1,
        pageSize: _pageSize,
      );

      if (newRestaurants.isNotEmpty) {
        // Calcula distâncias para novos restaurantes
        final location = await _locationService.getCurrentLocation();
        List<Restaurant> newRestaurantsWithDistance = newRestaurants;
        if (location != null) {
          newRestaurantsWithDistance = await _distanceService
              .calculateDistanceForRestaurants(newRestaurants, location);
        }

        setState(() {
          _restaurants.addAll(newRestaurantsWithDistance);
          _currentPage++;
          _hasMoreData = newRestaurants.length == _pageSize;
        });

        _filterAndSortRestaurants();
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      _analytics.trackEvent('category_load_more_error', parameters: {
        'category_id': widget.categoryId,
        'page': _currentPage + 1,
        'error': e.toString(),
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _filterAndSortRestaurants() {
    // Criar chave para cache baseada nos parâmetros de filtro
    final filterKey = '${_searchQuery}_${_sortBy}_${_sortAscending}_${_filters.toString()}';
    
    // Verificar se já temos resultado em cache
    if (_lastFilterKey == filterKey && _cachedFilteredResults != null) {
      setState(() {
        _filteredRestaurants = _cachedFilteredResults!;
      });
      return;
    }
    
    List<Restaurant> filtered = List.from(_restaurants);

    // Aplicar busca por texto
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((restaurant) {
        return restaurant.name.toLowerCase().contains(searchLower) ||
            restaurant.description.toLowerCase().contains(searchLower) ||
            restaurant.cuisine.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Aplicar filtros
    if (_filters.isNotEmpty) {
      // Filtro por avaliação mínima
      if (_filters['minRating'] != null) {
        filtered = filtered.where((r) => r.rating >= _filters['minRating']).toList();
      }

      // Filtro por faixa de preço
      if (_filters['priceRange'] != null) {
        filtered = filtered.where((r) => r.priceRange == _filters['priceRange']).toList();
      }

      // Filtro por distância máxima
      if (_filters['maxDistance'] != null && _filters['maxDistance'] > 0) {
        filtered = filtered.where((r) => 
            r.distance != null && r.distance! <= _filters['maxDistance']).toList();
      }

      // Filtro por status (aberto/fechado)
      if (_filters['isOpen'] == true) {
        filtered = filtered.where((r) => r.isOpen).toList();
      }
    }

    // Aplicar ordenação
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'distance':
          final aDistance = a.distance ?? double.infinity;
          final bDistance = b.distance ?? double.infinity;
          comparison = aDistance.compareTo(bDistance);
          break;
        case 'rating':
          comparison = b.rating.compareTo(a.rating); // Maior primeiro
          break;
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.priceRange.compareTo(b.priceRange);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    // Atualizar cache
    _lastFilterKey = filterKey;
    _cachedFilteredResults = filtered;

    setState(() {
      _filteredRestaurants = filtered;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _filters,
        onFiltersChanged: (filters) {
          setState(() {
            _filters = filters;
          });
          _filterAndSortRestaurants();
          _analytics.trackEvent('category_filters_applied', parameters: {
            'category_id': widget.categoryId,
            'filters': filters,
          });
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordenar por',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            _buildSortOption('distance', 'Distância', Icons.location_on),
            _buildSortOption('rating', 'Avaliação', Icons.star),
            _buildSortOption('name', 'Nome', Icons.sort_by_alpha),
            _buildSortOption('price', 'Preço', Icons.attach_money),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Ordem:',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Crescente'),
                  selected: _sortAscending,
                  onSelected: (selected) {
                    setState(() {
                      _sortAscending = true;
                    });
                    _filterAndSortRestaurants();
                    NavigationHelper.safeGoBack(context);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Decrescente'),
                  selected: !_sortAscending,
                  onSelected: (selected) {
                    setState(() {
                      _sortAscending = false;
                    });
                    _filterAndSortRestaurants();
                    NavigationHelper.safeGoBack(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: _sortBy == value ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        _filterAndSortRestaurants();
        NavigationHelper.safeGoBack(context);
        _analytics.trackEvent('category_sort_changed', parameters: {
          'category_id': widget.categoryId,
          'sort_by': value,
          'ascending': _sortAscending,
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _category?.color ?? AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.categoryName ?? _category?.name ?? 'Categoria',
          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar busca expandida se necessário
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorWidget(
                  message: _error!,
                  onRetry: _loadCategoryData,
                )
              : Column(
                  children: [
                    // Header com informações da categoria
                    if (_category != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _category!.color.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _category!.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _category!.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _category!.name,
                                    style: AppTextStyles.headingMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _category!.description,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Barra de busca e filtros
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar restaurantes...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _showFilterBottomSheet,
                            icon: Icon(
                              AppIcons.filter,
                              color: _filters.isNotEmpty ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          IconButton(
                            onPressed: _showSortBottomSheet,
                            icon: const Icon(Icons.sort),
                          ),
                        ],
                      ),
                    ),

                    // Contador de resultados
                    if (_filteredRestaurants.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              '${_filteredRestaurants.length} restaurante${_filteredRestaurants.length != 1 ? 's' : ''} encontrado${_filteredRestaurants.length != 1 ? 's' : ''}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Lista de restaurantes
                    Expanded(
                      child: _filteredRestaurants.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.restaurant,
                              title: 'Nenhum restaurante encontrado',
                              subtitle: _searchQuery.isNotEmpty
                                  ? 'Tente ajustar sua busca ou filtros'
                                  : 'Não há restaurantes nesta categoria no momento',
                              actionText: _filters.isNotEmpty ? 'Limpar filtros' : null,
                              onActionPressed: _filters.isNotEmpty
                                  ? () {
                                      setState(() {
                                        _filters.clear();
                                        _searchController.clear();
                                      });
                                      _filterAndSortRestaurants();
                                    }
                                  : null,
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredRestaurants.length + (_isLoadingMore ? 1 : 0),
                              itemExtent: 300, // Altura fixa para melhor performance
                              itemBuilder: (context, index) {
                                if (index == _filteredRestaurants.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final restaurant = _filteredRestaurants[index];
                                return RepaintBoundary(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: RestaurantCard(
                                      restaurant: restaurant,
                                      margin: EdgeInsets.zero,
                                      onTap: () {
                                        _analytics.trackEvent('category_restaurant_tapped', parameters: {
                                          'category_id': widget.categoryId,
                                          'restaurant_id': restaurant.id,
                                          'restaurant_name': restaurant.name,
                                        });
                                        Navigator.pushNamed(
                                          context,
                                          '/restaurant-details',
                                          arguments: restaurant.id,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}