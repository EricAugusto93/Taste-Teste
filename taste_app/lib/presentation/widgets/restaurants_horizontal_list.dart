import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../data/models/restaurant_model.dart';
import 'restaurant_card.dart';
import 'skeleton_loading.dart';

/// Widget para exibir lista horizontal de restaurantes
class RestaurantsHorizontalList extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  final String title;
  final VoidCallback? onSeeAll;
  final Function(RestaurantModel)? onRestaurantTap;
  final Function(bool)? onFavoriteChanged;
  final bool isLoading;

  const RestaurantsHorizontalList({
    super.key,
    required this.restaurants,
    required this.title,
    this.onSeeAll,
    this.onRestaurantTap,
    this.onFavoriteChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const HorizontalRestaurantListSkeleton();
    }

    if (restaurants.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho com título e botão "Ver todos"
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'Ver todos',
                    style: AppTextStyles.buttonTextSecondary,
                  ),
                ),
            ],
          ),
        ),
        
        SizedBox(height: AppDimensions.paddingSmall),
        
        // Lista horizontal de restaurantes
        SizedBox(
          height: 280, // Altura fixa para os cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                child: RestaurantCard(
                  restaurant: restaurant,
                  onTap: () => onRestaurantTap?.call(restaurant),
                  onFavoriteChanged: onFavoriteChanged,
                  isCompact: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 48,
            color: AppColors.textLight,
          ),
          SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Nenhum restaurante encontrado',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}