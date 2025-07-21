import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Widget animado para botão de favoritar com microinterações
class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final double size;
  final Color? favoriteColor;
  final Color? unfavoriteColor;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onTap,
    this.size = 24.0,
    this.favoriteColor,
    this.unfavoriteColor,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _setupColorAnimation();
    
    // Inicializar estado da animação
    if (widget.isFavorite) {
      _colorController.value = 1.0;
    }
  }

  void _setupColorAnimation() {
    _colorAnimation = ColorTween(
      begin: widget.unfavoriteColor ?? Colors.grey.shade400,
      end: widget.favoriteColor ?? AppColors.favorito,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isFavorite != widget.isFavorite) {
      _animateFavorite();
    }
    
    if (oldWidget.favoriteColor != widget.favoriteColor ||
        oldWidget.unfavoriteColor != widget.unfavoriteColor) {
      _setupColorAnimation();
    }
  }

  void _animateFavorite() {
    if (widget.isFavorite) {
      _colorController.forward();
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    } else {
      _colorController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        _scaleController.forward();
      },
      onTapUp: (_) {
        _scaleController.reverse();
      },
      onTapCancel: () {
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _colorAnimation.value?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: widget.isFavorite ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: widget.size,
                color: _colorAnimation.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget de favorito simples com animação suave
class SimpleFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final double size;

  const SimpleFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onTap,
    this.size = 20.0,
  });

  @override
  State<SimpleFavoriteButton> createState() => _SimpleFavoriteButtonState();
}

class _SimpleFavoriteButtonState extends State<SimpleFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(widget.isFavorite),
                size: widget.size,
                color: widget.isFavorite ? AppColors.favorito : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
} 