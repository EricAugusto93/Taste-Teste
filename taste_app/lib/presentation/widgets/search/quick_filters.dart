import 'package:flutter/material.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_icons.dart';

/// Modelo para filtro rápido
class QuickFilter {
  final String id;
  final String label;
  final IconData icon;
  final Color? color;
  final Map<String, dynamic>? filterData;
  final bool isSelected;
  
  const QuickFilter({
    required this.id,
    required this.label,
    required this.icon,
    this.color,
    this.filterData,
    this.isSelected = false,
  });
  
  QuickFilter copyWith({
    String? id,
    String? label,
    IconData? icon,
    Color? color,
    Map<String, dynamic>? filterData,
    bool? isSelected,
  }) {
    return QuickFilter(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      filterData: filterData ?? this.filterData,
      isSelected: isSelected ?? this.isSelected,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickFilter && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Widget para filtros rápidos
class QuickFilters extends StatefulWidget {
  final List<QuickFilter> filters;
  final Function(List<QuickFilter>)? onFiltersChanged;
  final bool allowMultipleSelection;
  final EdgeInsets? padding;
  final double? height;
  
  const QuickFilters({
    super.key,
    required this.filters,
    this.onFiltersChanged,
    this.allowMultipleSelection = true,
    this.padding,
    this.height,
  });
  
  @override
  State<QuickFilters> createState() => _QuickFiltersState();
}

class _QuickFiltersState extends State<QuickFilters> {
  late List<QuickFilter> _filters;
  
  @override
  void initState() {
    super.initState();
    _filters = List.from(widget.filters);
  }
  
  @override
  void didUpdateWidget(QuickFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters != oldWidget.filters) {
      _filters = List.from(widget.filters);
    }
  }
  
  void _onFilterTap(QuickFilter filter) {
    setState(() {
      if (widget.allowMultipleSelection) {
        // Múltipla seleção
        final index = _filters.indexWhere((f) => f.id == filter.id);
        if (index != -1) {
          _filters[index] = _filters[index].copyWith(
            isSelected: !_filters[index].isSelected,
          );
        }
      } else {
        // Seleção única
        _filters = _filters.map((f) {
          if (f.id == filter.id) {
            return f.copyWith(isSelected: !f.isSelected);
          } else {
            return f.copyWith(isSelected: false);
          }
        }).toList();
      }
    });
    
    widget.onFiltersChanged?.call(_filters);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 50,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return QuickFilterChip(
            filter: filter,
            onTap: () => _onFilterTap(filter),
          );
        },
      ),
    );
  }
}

/// Widget para chip de filtro individual
class QuickFilterChip extends StatelessWidget {
  final QuickFilter filter;
  final VoidCallback? onTap;
  
  const QuickFilterChip({
    super.key,
    required this.filter,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = filter.isSelected;
    final color = filter.color ?? theme.primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filtros pré-definidos para diferentes contextos
class QuickFilterPresets {
  /// Filtros para busca geral
  static List<QuickFilter> get searchFilters => [
    const QuickFilter(
      id: 'nearby',
      label: 'Perto de mim',
      icon: AppIcons.location,
      filterData: {'sortBy': 'distance'},
    ),
    const QuickFilter(
      id: 'rating',
      label: 'Bem avaliados',
      icon: AppIcons.star,
      filterData: {'minRating': 4.0},
    ),
    const QuickFilter(
      id: 'price_low',
      label: 'Barato',
      icon: AppIcons.money,
      color: Colors.green,
      filterData: {'maxPrice': 2},
    ),
    const QuickFilter(
      id: 'open_now',
      label: 'Aberto agora',
      icon: AppIcons.time,
      color: Colors.orange,
      filterData: {'openNow': true},
    ),
    const QuickFilter(
      id: 'delivery',
      label: 'Delivery',
      icon: AppIcons.delivery,
      color: Colors.blue,
      filterData: {'hasDelivery': true},
    ),
  ];
  
  /// Filtros para categorias de comida
  static List<QuickFilter> get categoryFilters => [
    const QuickFilter(
      id: 'pizza',
      label: 'Pizza',
      icon: AppIcons.pizza,
      color: Colors.red,
      filterData: {'category': 'pizza'},
    ),
    const QuickFilter(
      id: 'burger',
      label: 'Hambúrguer',
      icon: AppIcons.burger,
      color: Colors.orange,
      filterData: {'category': 'hambúrguer'},
    ),
    const QuickFilter(
      id: 'sushi',
      label: 'Sushi',
      icon: AppIcons.sushi,
      color: Colors.green,
      filterData: {'category': 'sushi'},
    ),
    const QuickFilter(
      id: 'coffee',
      label: 'Café',
      icon: AppIcons.coffee,
      color: Colors.brown,
      filterData: {'category': 'café'},
    ),
    const QuickFilter(
      id: 'dessert',
      label: 'Sobremesa',
      icon: AppIcons.dessert,
      color: Colors.pink,
      filterData: {'category': 'sobremesa'},
    ),
  ];
  
  /// Filtros para preço
  static List<QuickFilter> get priceFilters => [
    const QuickFilter(
      id: 'price_1',
      label: '\$',
      icon: AppIcons.money,
      color: Colors.green,
      filterData: {'priceRange': 1},
    ),
    const QuickFilter(
      id: 'price_2',
      label: '\$\$',
      icon: AppIcons.money,
      color: Colors.orange,
      filterData: {'priceRange': 2},
    ),
    const QuickFilter(
      id: 'price_3',
      label: '\$\$\$',
      icon: AppIcons.money,
      color: Colors.red,
      filterData: {'priceRange': 3},
    ),
  ];
  
  /// Filtros para distância
  static List<QuickFilter> get distanceFilters => [
    const QuickFilter(
      id: 'distance_1km',
      label: '1 km',
      icon: AppIcons.location,
      filterData: {'maxDistance': 1000},
    ),
    const QuickFilter(
      id: 'distance_3km',
      label: '3 km',
      icon: AppIcons.location,
      filterData: {'maxDistance': 3000},
    ),
    const QuickFilter(
      id: 'distance_5km',
      label: '5 km',
      icon: AppIcons.location,
      filterData: {'maxDistance': 5000},
    ),
    const QuickFilter(
      id: 'distance_10km',
      label: '10 km',
      icon: AppIcons.location,
      filterData: {'maxDistance': 10000},
    ),
  ];
  
  /// Filtros para horário
  static List<QuickFilter> get timeFilters => [
    const QuickFilter(
      id: 'open_now',
      label: 'Aberto agora',
      icon: AppIcons.time,
      color: Colors.green,
      filterData: {'openNow': true},
    ),
    const QuickFilter(
      id: 'open_24h',
      label: '24 horas',
      icon: AppIcons.time,
      color: Colors.blue,
      filterData: {'open24h': true},
    ),
    const QuickFilter(
      id: 'breakfast',
      label: 'Café da manhã',
      icon: AppIcons.coffee,
      color: Colors.orange,
      filterData: {'mealType': 'breakfast'},
    ),
    const QuickFilter(
      id: 'lunch',
      label: 'Almoço',
      icon: AppIcons.restaurant,
      color: Colors.red,
      filterData: {'mealType': 'lunch'},
    ),
    const QuickFilter(
      id: 'dinner',
      label: 'Jantar',
      icon: AppIcons.restaurant,
      color: Colors.purple,
      filterData: {'mealType': 'dinner'},
    ),
  ];
  
  /// Filtros para características especiais
  static List<QuickFilter> get featureFilters => [
    const QuickFilter(
      id: 'vegetarian',
      label: 'Vegetariano',
      icon: AppIcons.vegetarian,
      color: Colors.green,
      filterData: {'isVegetarian': true},
    ),
    const QuickFilter(
      id: 'vegan',
      label: 'Vegano',
      icon: AppIcons.vegetarian,
      color: Colors.lightGreen,
      filterData: {'isVegan': true},
    ),
    const QuickFilter(
      id: 'gluten_free',
      label: 'Sem glúten',
      icon: AppIcons.health,
      color: Colors.blue,
      filterData: {'isGlutenFree': true},
    ),
    const QuickFilter(
      id: 'pet_friendly',
      label: 'Pet friendly',
      icon: AppIcons.pets,
      color: Colors.brown,
      filterData: {'isPetFriendly': true},
    ),
    const QuickFilter(
      id: 'wifi',
      label: 'Wi-Fi',
      icon: AppIcons.wifi,
      color: Colors.indigo,
      filterData: {'hasWifi': true},
    ),
    const QuickFilter(
      id: 'parking',
      label: 'Estacionamento',
      icon: AppIcons.parking,
      color: Colors.grey,
      filterData: {'hasParking': true},
    ),
  ];
}

/// Widget para seção de filtros com título
class QuickFilterSection extends StatelessWidget {
  final String title;
  final List<QuickFilter> filters;
  final Function(List<QuickFilter>)? onFiltersChanged;
  final bool allowMultipleSelection;
  final bool showTitle;
  
  const QuickFilterSection({
    super.key,
    required this.title,
    required this.filters,
    this.onFiltersChanged,
    this.allowMultipleSelection = true,
    this.showTitle = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        QuickFilters(
          filters: filters,
          onFiltersChanged: onFiltersChanged,
          allowMultipleSelection: allowMultipleSelection,
        ),
      ],
    );
  }
}

/// Utilitários para filtros rápidos
class QuickFilterUtils {
  /// Converte filtros selecionados em parâmetros de busca
  static Map<String, dynamic> filtersToSearchParams(List<QuickFilter> filters) {
    final params = <String, dynamic>{};
    
    for (final filter in filters.where((f) => f.isSelected)) {
      if (filter.filterData != null) {
        params.addAll(filter.filterData!);
      }
    }
    
    return params;
  }
  
  /// Obtém filtros selecionados
  static List<QuickFilter> getSelectedFilters(List<QuickFilter> filters) {
    return filters.where((f) => f.isSelected).toList();
  }
  
  /// Limpa seleção de todos os filtros
  static List<QuickFilter> clearAllFilters(List<QuickFilter> filters) {
    return filters.map((f) => f.copyWith(isSelected: false)).toList();
  }
  
  /// Seleciona filtro por ID
  static List<QuickFilter> selectFilterById(
    List<QuickFilter> filters,
    String id, {
    bool allowMultiple = true,
  }) {
    return filters.map((f) {
      if (f.id == id) {
        return f.copyWith(isSelected: true);
      } else if (!allowMultiple) {
        return f.copyWith(isSelected: false);
      } else {
        return f;
      }
    }).toList();
  }
  
  /// Obtém texto descritivo dos filtros selecionados
  static String getSelectedFiltersDescription(List<QuickFilter> filters) {
    final selected = getSelectedFilters(filters);
    
    if (selected.isEmpty) {
      return 'Nenhum filtro aplicado';
    }
    
    if (selected.length == 1) {
      return selected.first.label;
    }
    
    if (selected.length <= 3) {
      return selected.map((f) => f.label).join(', ');
    }
    
    return '${selected.take(2).map((f) => f.label).join(', ')} e mais ${selected.length - 2}';
  }
}