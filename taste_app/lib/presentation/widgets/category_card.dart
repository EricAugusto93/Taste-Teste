import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../data/models/category_model.dart';

/// Helper para converter string para IconData
IconData _getIconFromString(String iconName) {
  switch (iconName.toLowerCase()) {
    case 'restaurant':
      return Icons.restaurant;
    case 'fastfood':
      return Icons.fastfood;
    case 'local_pizza':
      return Icons.local_pizza;
    case 'coffee':
      return Icons.coffee;
    case 'cake':
      return Icons.cake;
    case 'icecream':
      return Icons.icecream;
    case 'local_bar':
      return Icons.local_bar;
    case 'lunch_dining':
      return Icons.lunch_dining;
    default:
      return Icons.restaurant;
  }
}

/// Helper para converter string hex para Color
Color _getColorFromString(String colorString) {
  try {
    String hexColor = colorString.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  } catch (e) {
    return AppColors.primary;
  }
}

/// Card de categoria conforme design das referências
class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;
  final double? width;
  final double? height;
  
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppDimensions.animationDurationShort),
        width: width,
        height: height ?? AppDimensions.categoryCardHeight,
        decoration: BoxDecoration(
          color: isSelected ? _getColorFromString(category.color) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: isSelected ? _getColorFromString(category.color) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getColorFromString(category.color).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone
            Container(
              width: AppDimensions.categoryImageSize,
              height: AppDimensions.categoryImageSize,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.surface.withOpacity(0.2)
                    : _getColorFromString(category.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              ),
              child: Icon(
                _getIconFromString(category.icon),
                size: AppDimensions.iconLarge,
                color: isSelected ? AppColors.surface : _getColorFromString(category.color),
              ),
            ),
            
            SizedBox(height: AppDimensions.paddingSmall),
            
            // Nome da categoria
            Text(
              category.name,
              style: AppTextStyles.categoryTitle.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid de categorias para a home page
class CategoriesGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategoryTap;
  final String? selectedCategoryId;
  final EdgeInsetsGeometry? padding;
  final int crossAxisCount;
  final double? childAspectRatio;
  
  const CategoriesGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.selectedCategoryId,
    this.padding,
    this.crossAxisCount = AppDimensions.categoryGridCrossAxisCount,
    this.childAspectRatio,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio ?? AppDimensions.categoryGridAspectRatio,
          crossAxisSpacing: AppDimensions.gridSpacing,
          mainAxisSpacing: AppDimensions.gridSpacing,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategoryTap?.call(category),
          );
        },
      ),
    );
  }
}

/// Lista horizontal de categorias
class CategoriesHorizontalList extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategoryTap;
  final String? selectedCategoryId;
  final EdgeInsetsGeometry? padding;
  final double itemWidth;
  
  const CategoriesHorizontalList({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.selectedCategoryId,
    this.padding,
    this.itemWidth = 100,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.categoryCardHeight + AppDimensions.paddingMedium,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.only(
              right: AppDimensions.marginMedium,
            ),
            child: CategoryCard(
              category: category,
              isSelected: selectedCategoryId == category.id,
              onTap: () => onCategoryTap?.call(category),
            ),
          );
        },
      ),
    );
  }
}

/// Chip de categoria para filtros
class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppDimensions.animationDurationShort),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _getColorFromString(category.color) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          border: Border.all(
            color: _getColorFromString(category.color),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconFromString(category.icon),
              size: AppDimensions.iconSmall,
              color: isSelected ? AppColors.surface : _getColorFromString(category.color),
            ),
            SizedBox(width: AppDimensions.paddingSmall),
            Text(
              category.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.surface : _getColorFromString(category.color),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}