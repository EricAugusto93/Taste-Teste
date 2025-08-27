import 'package:flutter/material.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_icons.dart';
import 'package:taste_app/core/theme/app_shadows.dart';
import 'package:taste_app/core/animations/app_animations.dart';
import 'package:taste_app/domain/entities/restaurant.dart';

/// Item para exibir restaurantes na lista de favoritos
class FavoriteItem extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onShare;
  final VoidCallback? onDirections;
  final bool showActions;
  final bool isCompact;
  
  const FavoriteItem({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onRemove,
    this.onShare,
    this.onDirections,
    this.showActions = true,
    this.isCompact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.slideInLeft(
      child: ShadowContainer.soft(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        child: AppAnimations.bounceOnTap(
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFullLayout() {
    return Column(
      children: [
        Row(
          children: [
            _buildImage(),
            SizedBox(width: 12),
            Expanded(
              child: _buildInfo(),
            ),
            if (showActions) _buildFavoriteButton(),
          ],
        ),
        if (showActions && !isCompact) ..[
          SizedBox(height: 12),
          _buildActionButtons(),
        ],
      ],
    );
  }
  
  Widget _buildCompactLayout() {
    return Row(
      children: [
        _buildImage(size: 50),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              _buildRatingAndDistance(compact: true),
            ],
          ),
        ),
        if (showActions) _buildFavoriteButton(),
      ],
    );
  }
  
  Widget _buildImage({double size = 80}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: restaurant.imageUrl != null
            ? Image.network(
                restaurant.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(size);
                },
              )
            : _buildImagePlaceholder(size),
      ),
    );
  }
  
  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surface,
      child: Icon(
        AppIcons.restaurant,
        color: AppColors.textSecondary,
        size: size * 0.4,
      ),
    );
  }
  
  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome do restaurante
        Text(
          restaurant.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 4),
        
        // Categoria
        if (restaurant.category != null)
          Text(
            restaurant.category!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        
        SizedBox(height: 6),
        
        // Rating e distância
        _buildRatingAndDistance(),
        
        SizedBox(height: 6),
        
        // Status e horário
        _buildStatusAndHours(),
        
        // Tags especiais
        if (restaurant.tags?.isNotEmpty == true && !isCompact) ..[
          SizedBox(height: 8),
          _buildTags(),
        ],
      ],
    );
  }
  
  Widget _buildRatingAndDistance({bool compact = false}) {
    return Row(
      children: [
        // Rating
        if (restaurant.rating != null) ..[
          Icon(
            AppIcons.star,
            size: compact ? 12 : 14,
            color: AppColors.warning,
          ),
          SizedBox(width: 4),
          Text(
            restaurant.rating!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (restaurant.reviewCount != null) ..[
            SizedBox(width: 2),
            Text(
              '(${restaurant.reviewCount})',
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
        
        // Separador
        if (restaurant.rating != null && restaurant.distance != null) ..[
          SizedBox(width: 8),
          Container(
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
        ],
        
        // Distância
        if (restaurant.distance != null) ..[
          Icon(
            AppIcons.location,
            size: compact ? 12 : 14,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 4),
          Text(
            '${restaurant.distance!.toStringAsFixed(1)} km',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildStatusAndHours() {
    final isOpen = restaurant.isOpen ?? false;
    final statusColor = isOpen ? AppColors.success : AppColors.error;
    final statusText = isOpen ? 'Aberto' : 'Fechado';
    
    return Row(
      children: [
        // Status
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: statusColor,
          ),
        ),
        
        // Horário de funcionamento
        if (restaurant.openingHours != null) ..[
          SizedBox(width: 8),
          Text(
            '• ${restaurant.openingHours}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: restaurant.tags!.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildFavoriteButton() {
    return AppAnimations.bounceOnTap(
      onTap: onRemove ?? () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          AppIcons.heartFilled,
          size: 20,
          color: AppColors.error,
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botão de direções
        if (onDirections != null)
          Expanded(
            child: AppAnimations.bounceOnTap(
              onTap: onDirections!,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.directions,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Direções',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        if (onDirections != null && onShare != null)
          SizedBox(width: 8),
        
        // Botão de compartilhar
        if (onShare != null)
          Expanded(
            child: AppAnimations.bounceOnTap(
              onTap: onShare!,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.share,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Compartilhar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Versão compacta do FavoriteItem para listas densas
class CompactFavoriteItem extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  
  const CompactFavoriteItem({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onRemove,
  });
  
  @override
  Widget build(BuildContext context) {
    return FavoriteItem(
      restaurant: restaurant,
      onTap: onTap,
      onRemove: onRemove,
      showActions: true,
      isCompact: true,
    );
  }
}

/// Item para exibir categorias de favoritos
class FavoriteCategoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  
  const FavoriteCategoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeIn(
      child: ShadowContainer.soft(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        child: AppAnimations.bounceOnTap(
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contador
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Seta
                Icon(
                  AppIcons.back,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para estado vazio da lista de favoritos
class EmptyFavoritesWidget extends StatelessWidget {
  final VoidCallback? onExplore;
  
  const EmptyFavoritesWidget({
    super.key,
    this.onExplore,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  AppIcons.heartEmpty,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Título
              Text(
                'Nenhum favorito ainda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              // Descrição
              Text(
                'Explore restaurantes e adicione seus favoritos para encontrá-los facilmente aqui.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24),
              
              // Botão de explorar
              if (onExplore != null)
                AppAnimations.bounceOnTap(
                  onTap: onExplore!,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.search,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Explorar Restaurantes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}