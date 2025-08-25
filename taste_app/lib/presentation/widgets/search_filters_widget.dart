import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_icons.dart';
import '../../core/animations/animation_service.dart';
import '../../data/models/category_model.dart';
import '../../services/analytics_service.dart';

/// Classe para representar filtros de busca
class SearchFilters {
  final String? categoryId;
  final double? maxDistance;
  final double? minRating;
  final bool? isOpen;
  final double? latitude;
  final double? longitude;
  final String? sortBy;

  const SearchFilters({
    this.categoryId,
    this.maxDistance,
    this.minRating,
    this.isOpen,
    this.latitude,
    this.longitude,
    this.sortBy,
  });

  SearchFilters copyWith({
    String? categoryId,
    double? maxDistance,
    double? minRating,
    bool? isOpen,
    double? latitude,
    double? longitude,
    String? sortBy,
  }) {
    return SearchFilters(
      categoryId: categoryId ?? this.categoryId,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      isOpen: isOpen ?? this.isOpen,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return categoryId != null ||
           maxDistance != null ||
           minRating != null ||
           isOpen != null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (categoryId != null) count++;
    if (maxDistance != null) count++;
    if (minRating != null) count++;
    if (isOpen != null) count++;
    return count;
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'maxDistance': maxDistance,
      'minRating': minRating,
      'isOpen': isOpen,
      'latitude': latitude,
      'longitude': longitude,
      'sortBy': sortBy,
    };
  }
}

/// Widget para filtros de busca avançados
class SearchFiltersWidget extends StatefulWidget {
  final SearchFilters initialFilters;
  final List<CategoryModel> categories;
  final Function(SearchFilters) onFiltersChanged;
  final VoidCallback? onClearFilters;
  final bool isCompact;

  const SearchFiltersWidget({
    super.key,
    required this.initialFilters,
    required this.categories,
    required this.onFiltersChanged,
    this.onClearFilters,
    this.isCompact = false,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget>
    with TickerProviderStateMixin {
  late SearchFilters _currentFilters;
  late AnimationController _animationController;
  
  // Opções de distância (em km)
  final List<double> _distanceOptions = [1, 2, 5, 10, 15, 20];
  
  // Opções de avaliação
  final List<double> _ratingOptions = [3.0, 3.5, 4.0, 4.5];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    
    _animationController = AnimationController(
      duration: AnimationService.normal,
      vsync: this,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            )),
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isCompact) {
      return _buildCompactFilters();
    }
    
    return _buildFullFilters();
  }

  Widget _buildCompactFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filtros',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textDark,
              ),
            ),
            if (_currentFilters.hasActiveFilters)
              TextButton(
                onPressed: () {
                  AnimationService.lightHaptic();
                  _clearAllFilters();
                },
                child: Text(
                  'Limpar tudo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        _buildQuickFilters(),
        const SizedBox(height: AppDimensions.paddingMedium),
        _buildApplyButton(),
      ],
    );
  }

  Widget _buildFullFilters() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildCategoryFilter(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildDistanceFilter(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildRatingFilter(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildOpenNowFilter(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filtros de Busca',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textDark,
          ),
        ),
        if (_currentFilters.hasActiveFilters)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Text(
              '${_currentFilters.activeFiltersCount}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: widget.categories.map((category) {
            final isSelected = _currentFilters.categoryId == category.id;
            
            return GestureDetector(
              onTap: () {
                AnimationService.selectionHaptic();
                _updateCategoryFilter(isSelected ? null : category.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  category.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.surface : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ).scaleIn(delay: Duration(milliseconds: widget.categories.indexOf(category) * 50));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distância máxima',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _distanceOptions.map((distance) {
            final isSelected = _currentFilters.maxDistance == distance;
            
            return GestureDetector(
              onTap: () {
                AnimationService.selectionHaptic();
                _updateDistanceFilter(isSelected ? null : distance);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.location,
                      size: AppDimensions.iconSmall,
                      color: isSelected ? AppColors.surface : AppColors.textLight,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      '${distance.toInt()} km',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.surface : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ).scaleIn(delay: Duration(milliseconds: _distanceOptions.indexOf(distance) * 50));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avaliação mínima',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _ratingOptions.map((rating) {
            final isSelected = _currentFilters.minRating == rating;
            
            return GestureDetector(
              onTap: () {
                AnimationService.selectionHaptic();
                _updateRatingFilter(isSelected ? null : rating);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.star,
                      size: AppDimensions.iconSmall,
                      color: isSelected ? AppColors.surface : AppColors.warning,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      rating.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.surface : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.surface : AppColors.textLight,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ).scaleIn(delay: Duration(milliseconds: _ratingOptions.indexOf(rating) * 50));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOpenNowFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aberto agora',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Mostrar apenas restaurantes abertos',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        Switch(
          value: _currentFilters.isOpen ?? false,
          onChanged: (value) {
            AnimationService.selectionHaptic();
            _updateOpenNowFilter(value ? true : null);
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      children: [
        // Filtros rápidos em linha
        Row(
          children: [
            Expanded(
              child: _buildQuickFilterChip(
                label: 'Aberto',
                icon: AppIcons.clock,
                isSelected: _currentFilters.isOpen == true,
                onTap: () => _updateOpenNowFilter(
                  _currentFilters.isOpen == true ? null : true,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: _buildQuickFilterChip(
                label: 'Perto',
                icon: AppIcons.location,
                isSelected: _currentFilters.maxDistance != null,
                onTap: () => _updateDistanceFilter(
                  _currentFilters.maxDistance != null ? null : 5.0,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: _buildQuickFilterChip(
                label: 'Top rated',
                icon: AppIcons.star,
                isSelected: _currentFilters.minRating != null,
                onTap: () => _updateRatingFilter(
                  _currentFilters.minRating != null ? null : 4.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        AnimationService.selectionHaptic();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSmall,
              color: isSelected ? AppColors.surface : AppColors.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          AnimationService.mediumHaptic();
          widget.onFiltersChanged(_currentFilters);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
        ),
        child: Text(
          'Aplicar Filtros',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_currentFilters.hasActiveFilters)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                AnimationService.lightHaptic();
                _clearAllFilters();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDark,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
              ),
              child: Text(
                'Limpar',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_currentFilters.hasActiveFilters)
          const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          flex: _currentFilters.hasActiveFilters ? 2 : 1,
          child: ElevatedButton(
            onPressed: () {
              AnimationService.mediumHaptic();
              widget.onFiltersChanged(_currentFilters);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: Text(
              'Aplicar Filtros',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Métodos para atualizar filtros
  void _updateCategoryFilter(String? categoryId) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(categoryId: categoryId);
    });
  }

  void _updateDistanceFilter(double? maxDistance) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(maxDistance: maxDistance);
    });
  }

  void _updateRatingFilter(double? minRating) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(minRating: minRating);
    });
  }

  void _updateOpenNowFilter(bool? isOpen) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(isOpen: isOpen);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = const SearchFilters();
    });
    
    if (widget.onClearFilters != null) {
      widget.onClearFilters!();
    }
    
    // Analytics: rastrear limpeza de filtros
    AnalyticsService.instance.trackEvent(
      'search_filters_cleared',
      parameters: {
        'source': 'filters_widget',
      },
    );
  }
}

/// Widget para exibir filtros ativos de forma compacta
class ActiveFiltersWidget extends StatelessWidget {
  final SearchFilters filters;
  final List<CategoryModel> categories;
  final Function(SearchFilters) onFiltersChanged;

  const ActiveFiltersWidget({
    super.key,
    required this.filters,
    required this.categories,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!filters.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    final activeFilters = <Widget>[];

    // Categoria
    if (filters.categoryId != null) {
      final category = categories.firstWhere(
        (cat) => cat.id == filters.categoryId,
        orElse: () => CategoryModel(
          id: filters.categoryId!,
          name: 'Categoria',
          icon: 'category',
          color: '#FF6B47',
          isActive: true,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      activeFilters.add(
        _buildFilterChip(
          label: category.name,
          icon: AppIcons.category,
          onRemove: () => _removeFilter('category'),
        ),
      );
    }

    // Distância
    if (filters.maxDistance != null) {
      activeFilters.add(
        _buildFilterChip(
          label: '${filters.maxDistance!.toInt()} km',
          icon: AppIcons.location,
          onRemove: () => _removeFilter('distance'),
        ),
      );
    }

    // Avaliação
    if (filters.minRating != null) {
      activeFilters.add(
        _buildFilterChip(
          label: '${filters.minRating}+ ⭐',
          icon: AppIcons.star,
          onRemove: () => _removeFilter('rating'),
        ),
      );
    }

    // Aberto agora
    if (filters.isOpen == true) {
      activeFilters.add(
        _buildFilterChip(
          label: 'Aberto',
          icon: AppIcons.clock,
          onRemove: () => _removeFilter('open'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros ativos',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: activeFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
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
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              AnimationService.lightHaptic();
              onRemove();
            },
            child: const Icon(
              AppIcons.close,
              size: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _removeFilter(String filterType) {
    SearchFilters newFilters;
    
    switch (filterType) {
      case 'category':
        newFilters = filters.copyWith(categoryId: null);
        break;
      case 'distance':
        newFilters = filters.copyWith(maxDistance: null);
        break;
      case 'rating':
        newFilters = filters.copyWith(minRating: null);
        break;
      case 'open':
        newFilters = filters.copyWith(isOpen: null);
        break;
      default:
        return;
    }
    
    onFiltersChanged(newFilters);
  }
}