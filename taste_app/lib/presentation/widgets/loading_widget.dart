import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

/// Widget de carregamento customizado do aplicativo Taste
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;
  final bool useLottie;
  final String? lottieAsset;
  
  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
    this.useLottie = false,
    this.lottieAsset,
  });
  
  /// Factory para loading simples
  factory LoadingWidget.simple({
    Key? key,
    double? size,
    Color? color,
  }) {
    return LoadingWidget(
      key: key,
      size: size,
      color: color,
      showMessage: false,
    );
  }
  
  /// Factory para loading com Lottie
  factory LoadingWidget.lottie({
    Key? key,
    String? message,
    String? lottieAsset,
    double? size,
  }) {
    return LoadingWidget(
      key: key,
      message: message,
      size: size,
      useLottie: true,
      lottieAsset: lottieAsset ?? 'assets/lottie/loading.json',
    );
  }
  
  /// Factory para tela cheia
  factory LoadingWidget.fullScreen({
    Key? key,
    String? message,
    bool useLottie = false,
    String? lottieAsset,
  }) {
    return LoadingWidget(
      key: key,
      message: message ?? 'Carregando...',
      useLottie: useLottie,
      lottieAsset: lottieAsset,
      size: 80,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoadingIndicator(),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    if (useLottie && lottieAsset != null) {
      return SizedBox(
        width: size ?? AppDimensions.iconXLarge,
        height: size ?? AppDimensions.iconXLarge,
        child: Lottie.asset(
          lottieAsset!,
          fit: BoxFit.contain,
        ),
      );
    }
    
    return SizedBox(
      width: size ?? AppDimensions.iconLarge,
      height: size ?? AppDimensions.iconLarge,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Widget de carregamento para listas
class ListLoadingWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  
  const ListLoadingWidget({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }
  
  Widget _buildShimmerItem() {
    return Container(
      height: itemHeight,
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: const BorderRadius.all(Radius.circular(AppDimensions.cardRadius)),
      ),
      child: const ShimmerEffect(),
    );
  }
}

/// Efeito shimmer para carregamento
class ShimmerEffect extends StatefulWidget {
  final Widget? child;
  final Color? baseColor;
  final Color? highlightColor;
  
  const ShimmerEffect({
    super.key,
    this.child,
    this.baseColor,
    this.highlightColor,
  });
  
  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: [
                widget.baseColor ?? AppColors.shimmer,
                widget.highlightColor ?? AppColors.surface,
                widget.baseColor ?? AppColors.shimmer,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Widget de carregamento para overlay
class OverlayLoadingWidget extends StatelessWidget {
  final String? message;
  final bool dismissible;
  
  const OverlayLoadingWidget({
    super.key,
    this.message,
    this.dismissible = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.overlay,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(AppDimensions.cardRadius)),
          ),
          child: LoadingWidget(
            message: message ?? 'Carregando...',
            size: AppDimensions.iconXLarge,
          ),
        ),
      ),
    );
  }
}