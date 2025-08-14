import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Widget otimizado para carregamento de imagens com lazy loading
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      // Otimizações de performance
      cacheKey: imageUrl,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: imageWidget,
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.restaurant_menu,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

/// Widget especializado para imagens de restaurantes
class RestaurantImage extends StatelessWidget {
  const RestaurantImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onFavoritePressed,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OptimizedImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          borderRadius: borderRadius,
          // Otimizações específicas para imagens de restaurantes
          memCacheWidth: width?.toInt(),
          memCacheHeight: height?.toInt(),
        ),
        if (showFavoriteButton)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onFavoritePressed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget para avatar de usuário otimizado
class OptimizedAvatar extends StatelessWidget {
  const OptimizedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.backgroundColor,
    this.fallbackIcon = Icons.person,
  });

  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: Icon(
          fallbackIcon,
          size: radius * 0.8,
          color: Colors.grey[600],
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      child: ClipOval(
        child: OptimizedImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          // Otimizações para avatares pequenos
          memCacheWidth: (radius * 2 * 2).toInt(), // 2x para densidade de tela
          memCacheHeight: (radius * 2 * 2).toInt(),
        ),
      ),
    );
  }
}