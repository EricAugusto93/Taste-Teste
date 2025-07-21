import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';

/// Widget de loader suave com diferentes estilos
class SmoothLoader extends StatefulWidget {
  final String message;
  final LoaderType type;
  final double size;
  final Color? color;
  final TextStyle? textStyle;

  const SmoothLoader({
    super.key,
    this.message = 'Carregando...',
    this.type = LoaderType.circular,
    this.size = 40.0,
    this.color,
    this.textStyle,
  });

  @override
  State<SmoothLoader> createState() => _SmoothLoaderState();

  /// Factory para loader de busca de restaurantes
  factory SmoothLoader.restaurantSearch({
    String message = 'Buscando restaurantes próximos...',
  }) {
    return SmoothLoader(
      message: message,
      type: LoaderType.restaurantSearch,
      size: 60,
    );
  }

  /// Factory para loader de favoritos
  factory SmoothLoader.favorites({
    String message = 'Carregando favoritos...',
  }) {
    return SmoothLoader(
      message: message,
      type: LoaderType.pulse,
      color: AppColors.favorito,
      size: 50,
    );
  }

  /// Factory para loader simples
  factory SmoothLoader.simple({
    String message = 'Carregando...',
  }) {
    return SmoothLoader(
      message: message,
      type: LoaderType.circular,
      size: 40,
    );
  }

  /// Factory para loader de pontos
  factory SmoothLoader.dots({
    String message = 'Processando...',
  }) {
    return SmoothLoader(
      message: message,
      type: LoaderType.dots,
    );
  }
}

enum LoaderType {
  circular,
  dots,
  pulse,
  restaurantSearch,
}

class _SmoothLoaderState extends State<SmoothLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _dotsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _dotsController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    switch (widget.type) {
      case LoaderType.circular:
      case LoaderType.restaurantSearch:
        _rotationController.repeat();
        break;
      case LoaderType.pulse:
        _pulseController.repeat(reverse: true);
        break;
      case LoaderType.dots:
        _dotsController.repeat();
        break;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoader(),
        const SizedBox(height: 16),
        Text(
          widget.message,
          style: widget.textStyle ?? TextStyle(
            color: AppColors.cinzaMedio,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoader() {
    switch (widget.type) {
      case LoaderType.circular:
        return _buildCircularLoader();
      case LoaderType.dots:
        return _buildDotsLoader();
      case LoaderType.pulse:
        return _buildPulseLoader();
      case LoaderType.restaurantSearch:
        return _buildRestaurantLoader();
    }
  }

  Widget _buildCircularLoader() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color ?? AppColors.mostarda,
                  (widget.color ?? AppColors.mostarda).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.color ?? AppColors.mostarda,
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsLoader() {
    return AnimatedBuilder(
      animation: _dotsAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final progress = (_dotsAnimation.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0));
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.color ?? AppColors.mostarda,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseLoader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.mostarda,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? AppColors.mostarda).withOpacity(0.3),
                  blurRadius: 10 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                ),
              ],
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantLoader() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: AppTheme.gradientPrimario,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.mostarda.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: const Center(
              child: Text(
                '🍽️',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget de overlay com loader para tela cheia
class LoaderOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String message;
  final LoaderType type;
  final Color? backgroundColor;

  const LoaderOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message = 'Carregando...',
    this.type = LoaderType.circular,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SmoothLoader(
                  message: message,
                  type: type,
                ),
              ),
            ),
          ),
      ],
    );
  }
} 