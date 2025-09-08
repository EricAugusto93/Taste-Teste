import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../data/models/restaurant_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/logger.dart';

/// InfoWindow personalizada avançada para restaurantes
class AdvancedInfoWindow extends StatefulWidget {
  final RestaurantModel restaurant;
  final String? distance;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final VoidCallback? onFavorite;
  final VoidCallback? onDirections;
  final bool showActions;
  final bool compact;
  final Offset position;
  final double maxWidth;

  const AdvancedInfoWindow({
    super.key,
    required this.restaurant,
    this.distance,
    this.onTap,
    this.onClose,
    this.onFavorite,
    this.onDirections,
    this.showActions = true,
    this.compact = false,
    required this.position,
    this.maxWidth = 280,
  });

  @override
  State<AdvancedInfoWindow> createState() => _AdvancedInfoWindowState();
}

class _AdvancedInfoWindowState extends State<AdvancedInfoWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _close() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - (widget.maxWidth / 2),
      top: widget.position.dy - (widget.compact ? 120 : 160),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: _buildInfoWindow(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoWindow() {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withOpacity(0.3),
      child: Container(
        width: widget.maxWidth,
        constraints: BoxConstraints(
          maxHeight: widget.compact ? 120 : 180,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (!widget.compact) _buildContent(),
            if (widget.showActions) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          // Ícone da categoria
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _getCategoryEmoji(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Informações principais
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurant.name,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildRatingChip(),
                    const SizedBox(width: 8),
                    if (widget.distance != null) _buildDistanceChip(),
                  ],
                ),
              ],
            ),
          ),

          // Botão fechar
          GestureDetector(
            onTap: _close,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações adicionais
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.access_time,
                text: '${widget.restaurant.deliveryTime} min',
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              if (widget.restaurant.priceRange != null)
                _buildInfoChip(
                  icon: Icons.attach_money,
                  text: widget.restaurant.priceRange!,
                  color: Colors.green,
                ),
              const SizedBox(width: 8),
              _buildStatusChip(),
            ],
          ),

          if (widget.restaurant.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              widget.restaurant.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        color: Colors.grey.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.info_outline,
            label: 'Detalhes',
            onTap: widget.onTap,
            color: AppColors.primary,
          ),
          _buildActionButton(
            icon: Icons.directions,
            label: 'Rota',
            onTap: widget.onDirections,
            color: Colors.blue,
          ),
          _buildActionButton(
            icon: Icons.favorite_border,
            label: 'Favorito',
            onTap: widget.onFavorite,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getRatingColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getRatingColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: _getRatingColor(),
          ),
          const SizedBox(width: 2),
          Text(
            widget.restaurant.rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getRatingColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            size: 12,
            color: Colors.blue,
          ),
          const SizedBox(width: 2),
          Text(
            widget.distance!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final isOpen = widget.restaurant.isOpen ?? true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isOpen ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Aberto' : 'Fechado',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isOpen ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji() {
    switch (widget.restaurant.categoryId?.toLowerCase()) {
      case 'pizza':
        return '🍕';
      case 'hamburguer':
        return '🍔';
      case 'japonesa':
        return '🍣';
      case 'chinesa':
        return '🥡';
      case 'brasileira':
        return '🍽️';
      case 'mexicana':
        return '🌮';
      case 'doce':
        return '🍰';
      case 'café':
        return '☕';
      case 'vegetariana':
        return '🥗';
      case 'churrasco':
        return '🥩';
      case 'frutos do mar':
        return '🐟';
      case 'árabe':
        return '🥙';
      case 'indiana':
        return '🍛';
      default:
        return '🍽️';
    }
  }

  Color _getRatingColor() {
    final rating = widget.restaurant.rating;
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.orange;
    if (rating >= 3.5) return Colors.amber;
    return Colors.red;
  }
}

/// Overlay para mostrar InfoWindow personalizada
class InfoWindowOverlay {
  final RestaurantModel restaurant;
  final String? distance;
  final Offset position;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final VoidCallback? onFavorite;
  final VoidCallback? onDirections;
  final bool showActions;
  final bool compact;

  InfoWindowOverlay({
    required this.restaurant,
    this.distance,
    required this.position,
    this.onTap,
    this.onClose,
    this.onFavorite,
    this.onDirections,
    this.showActions = true,
    this.compact = false,
  });

  Widget build(BuildContext context) {
    return AdvancedInfoWindow(
      restaurant: restaurant,
      distance: distance,
      position: position,
      onTap: onTap,
      onClose: onClose,
      onFavorite: onFavorite,
      onDirections: onDirections,
      showActions: showActions,
      compact: compact,
    );
  }
}
