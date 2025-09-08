import 'package:flutter/material.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/presentation/widgets/restaurant_card.dart';
import 'package:taste_app/presentation/widgets/skeleton_loading.dart';
import 'package:taste_app/presentation/widgets/cached_image_widget.dart';

class NearbyRestaurantsSection extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final Function(RestaurantModel)? onRestaurantTap;
  final Function(RestaurantModel)? onFavoriteToggle;
  final String title;

  const NearbyRestaurantsSection({
    super.key,
    required this.restaurants,
    this.isLoading = false,
    this.onSeeAll,
    this.onRestaurantTap,
    this.onFavoriteToggle,
    this.title = 'Perto de você',
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
        // Header com título e botão "Ver todos"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lista horizontal de restaurantes
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                child: NearbyRestaurantCard(
                  restaurant: restaurant,
                  onTap: () => onRestaurantTap?.call(restaurant),
                  onFavoriteToggle: () => onFavoriteToggle?.call(restaurant),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum restaurante próximo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ative sua localização para encontrar restaurantes perto de você',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// Card específico para restaurantes próximos (formato vertical)
class NearbyRestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const NearbyRestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do restaurante
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedImageWidget(
                    imageUrl: restaurant.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),

                // Botão de favorito
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),

                // Badge de distância (placeholder)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '2.5 km',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Informações do restaurante
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do restaurante
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Categoria
                    const Text(
                      'Restaurante',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating e tempo de entrega
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          restaurant.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            restaurant.deliveryTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Taxa de entrega
                    if (restaurant.deliveryFee > 0)
                      Text(
                        'Entrega R\$ ${restaurant.deliveryFee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      const Text(
                        'Entrega grátis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
