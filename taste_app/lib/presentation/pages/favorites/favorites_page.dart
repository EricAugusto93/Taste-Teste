import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/models/favorite_model.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/repositories/favorites_repository.dart' as data_repo;
import '../../../domain/repositories/favorites_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/favorites_sync_service.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/debounced_search_field.dart';
import '../../widgets/optimized_list_view.dart';
import '../restaurant/restaurant_details_page.dart';

/// Página para exibir os restaurantes favoritos do usuário
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  final data_repo.FavoritesRepositoryImpl _favoritesRepository = data_repo.FavoritesRepositoryImpl(
    Supabase.instance.client,
  );
  final TextEditingController _searchController = TextEditingController();
  
  List<FavoriteModel> _favorites = [];
  List<FavoriteModel> _filteredFavorites = [];
  bool _isLoading = true;
  String? _error;
  
  // Filtros e busca
  String _searchQuery = '';
  String? _selectedCategory;
  FavoritesSortOption _sortOption = FavoritesSortOption.newest;
  
  // Categorias disponíveis
  final List<String> _categories = [
    'Todos',
    'Italiana',
    'Japonesa',
    'Brasileira',
    'Mexicana',
    'Chinesa',
    'Fast Food',
    'Vegetariana',
    'Sobremesas',
  ];
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        final result = await _favoritesRepository.getFavoriteRestaurants(userId: currentUser.id);
        result.fold(
          (failure) => throw Exception(failure.message),
          (restaurants) {
            // Convert restaurants to FavoriteModel for UI compatibility
            _favorites = restaurants.map((restaurant) => FavoriteModel(
              id: restaurant.id,
              userId: currentUser.id,
              restaurantId: restaurant.id,
              createdAt: DateTime.now(),
              restaurant: null, // Will be populated from restaurant data
            )).toList();
          },
        );
      }
      _applyFiltersAndSort();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFiltersAndSort() {
    var filtered = List<FavoriteModel>.from(_favorites);
    
    // Aplicar busca por texto
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((fav) {
        final restaurant = fav.restaurant;
        if (restaurant == null) return false;
        
        return restaurant.name.toLowerCase().contains(query) ||
               (restaurant.categoryId?.toLowerCase().contains(query) ?? false) ||
               (restaurant.description?.toLowerCase().contains(query) ?? false) ||
               (restaurant.address?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // Aplicar filtro de categoria
    if (_selectedCategory != null && _selectedCategory != 'Todos') {
      filtered = filtered
          .where((fav) => fav.restaurant?.categoryId == _selectedCategory)
          .toList();
    }
    
    // Aplicar ordenação
    switch (_sortOption) {
      case FavoritesSortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case FavoritesSortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case FavoritesSortOption.alphabetical:
        filtered.sort((a, b) => (a.restaurant?.name ?? '')
            .compareTo(b.restaurant?.name ?? ''));
        break;
      case FavoritesSortOption.rating:
        filtered.sort((a, b) => (b.restaurant?.rating ?? 0)
            .compareTo(a.restaurant?.rating ?? 0));
        break;
      case FavoritesSortOption.distance:
        // TODO: Implementar ordenação por distância
        break;
    }
    
    setState(() {
      _filteredFavorites = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Meus Favoritos',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Lista', icon: Icon(Icons.list)),
            Tab(text: 'Categorias', icon: Icon(Icons.category)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Campo de busca
          _buildSearchField(),
          // Conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(),
                _buildCategoryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Nenhum resultado para "$_searchQuery"';
    }
    if (_selectedCategory != null && _selectedCategory != 'Todos') {
      return 'Nenhum favorito em $_selectedCategory';
    }
    return 'Nenhum favorito ainda';
  }

  String _getEmptyStateSubtitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Tente buscar por outro termo ou remover filtros';
    }
    if (_selectedCategory != null && _selectedCategory != 'Todos') {
      return 'Tente remover os filtros para ver mais favoritos';
    }
    return 'Comece explorando restaurantes e adicionando aos favoritos';
   }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: DebouncedSearchField(
        controller: _searchController,
        hintText: 'Buscar nos favoritos...',
        debounceDuration: const Duration(milliseconds: 400),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _applyFiltersAndSort();
        },
        onClear: () {
          setState(() {
            _searchQuery = '';
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return CustomErrorWidget.general(
        message: _error!,
        onRetry: _loadFavorites,
      );
    }

    return Column(
      children: [
        // Filtros ativos
        if (_searchQuery.isNotEmpty ||
            _selectedCategory != null && _selectedCategory != 'Todos' ||
            _sortOption != FavoritesSortOption.newest)
          _buildActiveFilters(),
        
        // Lista de favoritos
        Expanded(
          child: _filteredFavorites.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
        ),
      ],
    );
  }

  Widget _buildCategoryView() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return CustomErrorWidget.general(
        message: _error!,
        onRetry: _loadFavorites,
      );
    }

    // Agrupar favoritos por categoria
    final groupedFavorites = <String, List<FavoriteModel>>{};
    for (final favorite in _favorites) {
      final category = favorite.restaurant?.categoryId ?? 'Outros';
      groupedFavorites.putIfAbsent(category, () => []).add(favorite);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: groupedFavorites.keys.length,
      itemBuilder: (context, index) {
        final category = groupedFavorites.keys.elementAt(index);
        final categoryFavorites = groupedFavorites[category]!;
        
        return _buildCategorySection(category, categoryFavorites);
      },
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Text(
            'Filtros:',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          if (_searchQuery.isNotEmpty) ...[
            _buildFilterChip(
              label: 'Busca: "$_searchQuery"',
              onRemove: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
                _applyFiltersAndSort();
              },
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
          ],
          if (_selectedCategory != null && _selectedCategory != 'Todos') ...[
            _buildFilterChip(
              label: _selectedCategory!,
              onRemove: () {
                setState(() {
                  _selectedCategory = null;
                });
                _applyFiltersAndSort();
              },
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
          ],
          if (_sortOption != FavoritesSortOption.newest)
            _buildFilterChip(
              label: _sortOption.label,
              onRemove: () {
                setState(() {
                  _sortOption = FavoritesSortOption.newest;
                });
                _applyFiltersAndSort();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            _getEmptyStateTitle(),
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            _getEmptyStateSubtitle(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          CustomButton(
            text: 'Explorar Restaurantes',
            onPressed: () {
              NavigationHelper.safeGoBack(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: OptimizedListView<FavoriteModel>(
        items: _filteredFavorites,
        isLoading: _isLoading,
        enableLazyLoading: false, // Não precisamos de lazy loading para favoritos
        enableAnimations: true,
        itemExtent: 300, // Altura estimada do RestaurantCard
        itemBuilder: (context, favorite, index) {
          if (favorite.restaurant == null) return const SizedBox.shrink();
          
          return RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: RestaurantCard(
                restaurant: RestaurantModel.fromEntity(favorite.restaurant!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantDetailsPage(
                        restaurantId: favorite.restaurant!.id,
                        restaurant: RestaurantModel.fromEntity(favorite.restaurant!),
                      ),
                    ),
                  );
                },
                showFavoriteButton: true,
                enableQuickRating: true,
                onFavoriteChanged: (isFavorite) {
                  if (!isFavorite) {
                    // Remover da lista local
                    setState(() {
                      _filteredFavorites.removeAt(index);
                      _favorites.removeWhere((f) => f.id == favorite.id);
                    });
                  }
                },
                onRatingChanged: (rating) {
                  // Recarregar favoritos para atualizar as avaliações
                  _loadFavorites();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String category, List<FavoriteModel> favorites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
          child: Row(
            children: [
              Text(
                category,
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${favorites.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            itemExtent: 280, // Largura fixa para melhor performance
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              if (favorite.restaurant == null) return const SizedBox.shrink();
              
              return RepaintBoundary(
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: RestaurantCard(
                    restaurant: RestaurantModel.fromEntity(favorite.restaurant!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailsPage(
                            restaurantId: favorite.restaurant!.id,
                            restaurant: RestaurantModel.fromEntity(favorite.restaurant!),
                          ),
                        ),
                      );
                    },
                    showFavoriteButton: true,
                    enableQuickRating: true,
                    onRatingChanged: (rating) {
                      // Recarregar favoritos para atualizar as avaliações
                      _loadFavorites();
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
      ],
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SortOptionsSheet(
        currentOption: _sortOption,
        onOptionSelected: (option) {
          setState(() {
            _sortOption = option;
          });
          _applyFiltersAndSort();
          NavigationHelper.safeGoBack(context);
        },
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterOptionsSheet(
        categories: _categories,
        currentCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          _applyFiltersAndSort();
          NavigationHelper.safeGoBack(context);
        },
      ),
    );
  }
}

/// Enum para opções de ordenação de favoritos
enum FavoritesSortOption {
  newest('Mais recentes'),
  oldest('Mais antigos'),
  alphabetical('Alfabética'),
  rating('Melhor avaliação'),
  distance('Mais próximos');

  const FavoritesSortOption(this.label);
  final String label;
}

/// Sheet para opções de ordenação
class _SortOptionsSheet extends StatelessWidget {
  final FavoritesSortOption currentOption;
  final Function(FavoritesSortOption) onOptionSelected;

  const _SortOptionsSheet({
    required this.currentOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ordenar por',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ...FavoritesSortOption.values.map((option) => ListTile(
            title: Text(option.label),
            trailing: currentOption == option
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () => onOptionSelected(option),
          )),
        ],
      ),
    );
  }
}

/// Sheet para opções de filtro
class _FilterOptionsSheet extends StatelessWidget {
  final List<String> categories;
  final String? currentCategory;
  final Function(String?) onCategorySelected;

  const _FilterOptionsSheet({
    required this.categories,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por categoria',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ...categories.map((category) => ListTile(
            title: Text(category),
            trailing: (currentCategory == category || 
                     (category == 'Todos' && currentCategory == null))
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () => onCategorySelected(
              category == 'Todos' ? null : category,
            ),
          )),
        ],
      ),
    );
  }
}