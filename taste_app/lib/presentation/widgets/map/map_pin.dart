import 'package:flutter/material.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_icons.dart';
import 'package:taste_app/core/theme/app_shadows.dart';
import 'package:taste_app/core/animations/app_animations.dart';
import 'package:taste_app/domain/entities/restaurant.dart';

/// Pin customizado para o mapa com emoji e informações do restaurante
class MapPin extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showInfo;
  final double size;
  final String? emoji;
  
  const MapPin({
    super.key,
    required this.restaurant,
    this.onTap,
    this.isSelected = false,
    this.showInfo = false,
    this.size = 40,
    this.emoji,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.scaleIn(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info card (se selecionado)
            if (showInfo && isSelected) ..[
              _buildInfoCard(),
              const SizedBox(height: 8),
            ],
            
            // Pin principal
            _buildPin(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPin() {
    final pinSize = isSelected ? size * 1.2 : size;
    final shadowSize = isSelected ? AppShadows.medium : AppShadows.soft;
    
    return AppAnimations.bounceOnTap(
      onTap: onTap ?? () {},
      child: Container(
        width: pinSize,
        height: pinSize,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.primary,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: shadowSize,
        ),
        child: Center(
          child: _buildPinContent(),
        ),
      ),
    );
  }
  
  Widget _buildPinContent() {
    // Se tem emoji personalizado, usa ele
    if (emoji != null) {
      return Text(
        emoji!,
        style: TextStyle(
          fontSize: size * 0.5,
        ),
      );
    }
    
    // Se tem categoria, usa emoji baseado na categoria
    final categoryEmoji = _getCategoryEmoji(restaurant.category);
    if (categoryEmoji != null) {
      return Text(
        categoryEmoji,
        style: TextStyle(
          fontSize: size * 0.5,
        ),
      );
    }
    
    // Fallback para ícone padrão
    return Icon(
      AppIcons.restaurant,
      size: size * 0.5,
      color: isSelected ? Colors.white : AppColors.primary,
    );
  }
  
  Widget _buildInfoCard() {
    return AppAnimations.slideInTop(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          minWidth: 150,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.medium,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do restaurante
            Text(
              restaurant.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 6),
            
            // Rating e categoria
            Row(
              children: [
                if (restaurant.rating != null) ..[
                  Icon(
                    AppIcons.star,
                    size: 12,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                
                if (restaurant.rating != null && restaurant.category != null) ..[
                  const SizedBox(width: 8),
                  Container(
                    width: 2,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                if (restaurant.category != null)
                  Expanded(
                    child: Text(
                      restaurant.category!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Status e distância
            Row(
              children: [
                // Status
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: (restaurant.isOpen ?? false) 
                        ? AppColors.success 
                        : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  (restaurant.isOpen ?? false) ? 'Aberto' : 'Fechado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: (restaurant.isOpen ?? false) 
                        ? AppColors.success 
                        : AppColors.error,
                  ),
                ),
                
                if (restaurant.distance != null) ..[
                  const Spacer(),
                  Icon(
                    AppIcons.location,
                    size: 10,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${restaurant.distance!.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String? _getCategoryEmoji(String? category) {
    if (category == null) return null;
    
    final categoryLower = category.toLowerCase();
    
    // Mapeamento de categorias para emojis
    final categoryEmojis = {
      // Comida italiana
      'italiana': '🍝',
      'pizza': '🍕',
      'pizzaria': '🍕',
      
      // Comida japonesa
      'japonesa': '🍣',
      'sushi': '🍣',
      'ramen': '🍜',
      
      // Comida chinesa
      'chinesa': '🥢',
      'oriental': '🥢',
      
      // Comida mexicana
      'mexicana': '🌮',
      'tex-mex': '🌮',
      
      // Comida brasileira
      'brasileira': '🇧🇷',
      'churrascaria': '🥩',
      'churrasco': '🥩',
      
      // Fast food
      'fast food': '🍔',
      'hamburger': '🍔',
      'hambúrguer': '🍔',
      'lanchonete': '🍔',
      
      // Bebidas
      'bar': '🍺',
      'pub': '🍺',
      'café': '☕',
      'cafeteria': '☕',
      'sorveteria': '🍦',
      
      // Doces
      'padaria': '🥖',
      'confeitaria': '🧁',
      'doceria': '🍰',
      
      // Frutos do mar
      'frutos do mar': '🦐',
      'peixaria': '🐟',
      'mariscos': '🦞',
      
      // Vegetariano/Vegano
      'vegetariana': '🥗',
      'vegana': '🌱',
      'saudável': '🥗',
      
      // Outros
      'árabe': '🥙',
      'indiana': '🍛',
      'francesa': '🥐',
      'alemã': '🍺',
      'argentina': '🥩',
      'peruana': '🌶️',
      'tailandesa': '🌶️',
      'coreana': '🍲',
      'grega': '🫒',
      'turca': '🥙',
    };
    
    // Busca por correspondência exata primeiro
    if (categoryEmojis.containsKey(categoryLower)) {
      return categoryEmojis[categoryLower];
    }
    
    // Busca por correspondência parcial
    for (final entry in categoryEmojis.entries) {
      if (categoryLower.contains(entry.key) || entry.key.contains(categoryLower)) {
        return entry.value;
      }
    }
    
    return null;
  }
}

/// Pin simples para localização do usuário
class UserLocationPin extends StatelessWidget {
  final double size;
  final bool isAnimated;
  
  const UserLocationPin({
    super.key,
    this.size = 20,
    this.isAnimated = true,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget pin = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Icon(
        AppIcons.currentLocation,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
    
    if (isAnimated) {
      return AppAnimations.pulse(
        child: pin,
      );
    }
    
    return pin;
  }
}

/// Pin para pontos de interesse
class POIPin extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double size;
  
  const POIPin({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.size = 32,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.scaleIn(
      child: AppAnimations.bounceOnTap(
        onTap: onTap ?? () {},
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: AppShadows.soft,
          ),
          child: Icon(
            icon,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Pin para clusters de restaurantes
class ClusterPin extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final double size;
  
  const ClusterPin({
    super.key,
    required this.count,
    this.onTap,
    this.size = 50,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.scaleIn(
      child: AppAnimations.bounceOnTap(
        onTap: onTap ?? () {},
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: AppShadows.medium,
          ),
          child: Center(
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para exibir múltiplos pins em uma área
class PinGroup extends StatelessWidget {
  final List<Restaurant> restaurants;
  final Function(Restaurant)? onRestaurantTap;
  final Restaurant? selectedRestaurant;
  final double spacing;
  
  const PinGroup({
    super.key,
    required this.restaurants,
    this.onRestaurantTap,
    this.selectedRestaurant,
    this.spacing = 8,
  });
  
  @override
  Widget build(BuildContext context) {
    if (restaurants.length == 1) {
      return MapPin(
        restaurant: restaurants.first,
        onTap: () => onRestaurantTap?.call(restaurants.first),
        isSelected: selectedRestaurant?.id == restaurants.first.id,
        showInfo: selectedRestaurant?.id == restaurants.first.id,
      );
    }
    
    if (restaurants.length <= 5) {
      return _buildSmallGroup();
    }
    
    return ClusterPin(
      count: restaurants.length,
      onTap: () {
        // Implementar lógica para expandir cluster
      },
    );
  }
  
  Widget _buildSmallGroup() {
    return Stack(
      children: restaurants.asMap().entries.map((entry) {
        final index = entry.key;
        final restaurant = entry.value;
        final isSelected = selectedRestaurant?.id == restaurant.id;
        
        // Calcula posição em círculo
        final angle = (index * 2 * 3.14159) / restaurants.length;
        final radius = spacing * 2;
        final x = radius * (1 + 0.5 * (index / restaurants.length)) * 
                  (index.isEven ? 1 : -1);
        final y = radius * (1 + 0.5 * (index / restaurants.length)) * 
                  (index % 3 == 0 ? 1 : -1);
        
        return Positioned(
          left: x,
          top: y,
          child: MapPin(
            restaurant: restaurant,
            onTap: () => onRestaurantTap?.call(restaurant),
            isSelected: isSelected,
            showInfo: isSelected,
            size: isSelected ? 40 : 32,
          ),
        );
      }).toList(),
    );
  }
}

/// Enum para tipos de pin
enum PinType {
  restaurant,
  userLocation,
  poi,
  cluster,
}

/// Factory para criar pins baseado no tipo
class PinFactory {
  static Widget createPin({
    required PinType type,
    Restaurant? restaurant,
    String? title,
    IconData? icon,
    Color? color,
    int? count,
    VoidCallback? onTap,
    bool isSelected = false,
    bool showInfo = false,
    double size = 40,
    String? emoji,
  }) {
    switch (type) {
      case PinType.restaurant:
        assert(restaurant != null, 'Restaurant is required for restaurant pin');
        return MapPin(
          restaurant: restaurant!,
          onTap: onTap,
          isSelected: isSelected,
          showInfo: showInfo,
          size: size,
          emoji: emoji,
        );
        
      case PinType.userLocation:
        return UserLocationPin(
          size: size,
        );
        
      case PinType.poi:
        assert(title != null && icon != null && color != null, 
               'Title, icon and color are required for POI pin');
        return POIPin(
          title: title!,
          icon: icon!,
          color: color!,
          onTap: onTap,
          size: size,
        );
        
      case PinType.cluster:
        assert(count != null, 'Count is required for cluster pin');
        return ClusterPin(
          count: count!,
          onTap: onTap,
          size: size,
        );
    }
  }
}