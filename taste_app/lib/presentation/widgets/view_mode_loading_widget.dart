import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

/// Widget de loading customizado para alternância entre modos de visualização
/// (lista, grade, mapa)
class ViewModeLoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;

  const ViewModeLoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
  });

  @override
  State<ViewModeLoadingWidget> createState() => _ViewModeLoadingWidgetState();
}

class _ViewModeLoadingWidgetState extends State<ViewModeLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador de rotação
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controlador de escala
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Animação de rotação contínua
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // Animação de escala pulsante
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animações
    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading animado
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(widget.size / 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: AppColors.textPrimary,
                      size: widget.size * 0.5,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Mensagem opcional
          if (widget.message != null) ..[
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              widget.message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: widget.color ?? AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de loading overlay para transições entre modos de visualização
class ViewModeLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String? message;
  final Widget child;

  const ViewModeLoadingOverlay({
    super.key,
    required this.isVisible,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: AppColors.overlay.withOpacity(0.7),
            child: ViewModeLoadingWidget(
              message: message ?? 'Carregando...',
              size: 50.0,
            ),
          ),
      ],
    );
  }
}

/// Widget de loading compacto para uso em botões ou espaços pequenos
class CompactViewModeLoading extends StatefulWidget {
  final double size;
  final Color? color;

  const CompactViewModeLoading({
    super.key,
    this.size = 20.0,
    this.color,
  });

  @override
  State<CompactViewModeLoading> createState() => _CompactViewModeLoadingState();
}

class _CompactViewModeLoadingState extends State<CompactViewModeLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(widget.size / 2),
            ),
            child: Icon(
              Icons.refresh,
              color: AppColors.textPrimary,
              size: widget.size * 0.6,
            ),
          ),
        );
      },
    );
  }
}