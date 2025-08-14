import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/services/interaction_service.dart';
import '../../data/models/menu_item_model.dart';
// MenuCategoryModel is defined in menu_item_model.dart
import 'cached_image_widget.dart';
/// Widget para exibir um item do cardápio
class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do item
              _buildItemImage(),
              const SizedBox(width: AppDimensions.paddingMedium),
              // Informações do item
              Expanded(
                child: _buildItemInfo(),
              ),
              // Botão de adicionar
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        width: 80,
        height: 80,
        color: AppColors.surface,
        child: item.imageUrl != null
            ? CachedImageWidget(
                imageUrl: item.imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                enableLazyLoading: true,
                placeholder: _buildPlaceholderImage(),
                errorWidget: _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.surface,
      child: const Icon(
        Icons.restaurant,
        color: AppColors.textLight,
        size: 32,
      ),
    );
  }

  Widget _buildItemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome do item
        Text(
          item.name,
          style: AppTextStyles.headingSmall.copyWith(
            color: item.isAvailable ? AppColors.textPrimary : AppColors.textLight,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.description != null) ...[
          const SizedBox(height: 4),
          Text(
            item.description!,
            style: AppTextStyles.bodySmall.copyWith(
              color: item.isAvailable ? AppColors.textSecondary : AppColors.textLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        // Preço
        Text(
          item.formattedPrice,
          style: AppTextStyles.headingSmall.copyWith(
            color: item.isAvailable ? AppColors.primary : AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Alérgenos (se houver)
        if (item.allergens.isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildAllergenInfo(),
        ],
        // Status de disponibilidade
        if (!item.isAvailable) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Text(
              'Indisponível',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAllergenInfo() {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: item.allergens.map((allergen) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            allergen,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.warning,
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddButton() {
    return Column(
      children: [
        if (item.isAvailable)
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: IconButton(
              onPressed: () {
                InteractionService.lightHaptic();
                onAddToCart?.call();
              },
              icon: const Icon(
                Icons.add,
                color: AppColors.surface,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
            ),
          )
        else
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(
              Icons.block,
              color: AppColors.surface,
              size: 20,
            ),
          ),
      ],
    );
  }
}

/// Widget para exibir uma categoria do cardápio
class MenuCategorySection extends StatelessWidget {
  final MenuCategoryModel category;
  final Function(MenuItemModel)? onItemTap;
  final Function(MenuItemModel)? onAddToCart;

  const MenuCategorySection({
    super.key,
    required this.category,
    this.onItemTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da categoria
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: AppTextStyles.headingMedium,
              ),
              if (category.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  category.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Lista de itens
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Column(
            children: category.items.map((item) {
              return MenuItemCard(
                item: item,
                onTap: () => onItemTap?.call(item),
                onAddToCart: () => onAddToCart?.call(item),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
      ],
    );
  }
}