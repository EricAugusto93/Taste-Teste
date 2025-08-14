import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Widget para exibir imagens com cache e lazy loading
class CachedImageWidget extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final bool enableLazyLoading;
  final double visibilityThreshold;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration? cacheMaxAge;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.enableLazyLoading = true,
    this.visibilityThreshold = 0.1,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeInCurve = Curves.easeInOut,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.cacheMaxAge,
  });

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  bool _shouldLoad = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: widget.fadeInCurve,
    ));
    
    // Se lazy loading estiver desabilitado, carrega imediatamente
    if (!widget.enableLazyLoading) {
      _shouldLoad = true;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!widget.enableLazyLoading) return;
    
    final isVisible = info.visibleFraction >= widget.visibilityThreshold;
    if (isVisible && !_isVisible) {
      setState(() {
        _isVisible = true;
        _shouldLoad = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    Widget content = _shouldLoad ? _buildImageWidget() : _buildPlaceholder();

    if (widget.enableLazyLoading) {
      content = VisibilityDetector(
        key: Key('cached_image_${widget.imageUrl}'),
        onVisibilityChanged: _onVisibilityChanged,
        child: content,
      );
    }

    return content;
  }

  Widget _buildImageWidget() {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      memCacheWidth: widget.enableMemoryCache ? _getOptimalCacheSize(widget.width) : null,
      memCacheHeight: widget.enableMemoryCache ? _getOptimalCacheSize(widget.height) : null,
      maxWidthDiskCache: widget.enableDiskCache ? _getOptimalCacheSize(widget.width) : null,
      maxHeightDiskCache: widget.enableDiskCache ? _getOptimalCacheSize(widget.height) : null,
      placeholder: (context, url) => widget.placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => widget.errorWidget ?? _buildErrorWidget(),
      fadeInDuration: widget.fadeInDuration,
      fadeInCurve: widget.fadeInCurve,
      useOldImageOnUrlChange: true,
      cacheManager: widget.cacheMaxAge != null 
          ? _createCustomCacheManager() 
          : null,
    );

    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    if (widget.backgroundColor != null) {
      imageWidget = Container(
        width: widget.width,
        height: widget.height,
        color: widget.backgroundColor,
        child: imageWidget,
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: imageWidget,
    );
  }

  int? _getOptimalCacheSize(double? size) {
    if (size == null) return null;
    // Otimiza o tamanho do cache baseado no tamanho da tela
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (size * devicePixelRatio).round();
  }

  dynamic _createCustomCacheManager() {
    // TODO: Implementar cache manager customizado com TTL
    // Por enquanto retorna null para usar o padrão
    return null;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.surface,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: AppColors.textLight,
          size: AppDimensions.iconMedium,
        ),
      ),
    );
  }
}