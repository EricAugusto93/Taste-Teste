import 'package:flutter/material.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_text_styles.dart';
import 'package:taste_app/core/theme/app_dimensions.dart';
import 'package:taste_app/core/theme/app_icons.dart';
import 'package:taste_app/core/services/interaction_service.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:get_it/get_it.dart';

/// Widget de erro aprimorado com retry automático e fallbacks
class EnhancedErrorWidget extends StatefulWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final Widget? fallbackWidget;
  final bool enableAutoRetry;
  final Duration autoRetryDelay;
  final int maxRetryAttempts;
  final ErrorType errorType;
  final String? cacheKey;

  const EnhancedErrorWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.fallbackWidget,
    this.enableAutoRetry = false,
    this.autoRetryDelay = const Duration(seconds: 3),
    this.maxRetryAttempts = 3,
    this.errorType = ErrorType.general,
    this.cacheKey,
  });

  /// Erro de rede com retry automático
  const EnhancedErrorWidget.network({
    super.key,
    this.title = 'Erro de Conexão',
    this.message = 'Verifique sua conexão com a internet e tente novamente.',
    this.onRetry,
    this.fallbackWidget,
    this.enableAutoRetry = true,
    this.autoRetryDelay = const Duration(seconds: 5),
    this.maxRetryAttempts = 3,
    this.cacheKey,
  }) : errorType = ErrorType.network;

  /// Erro de servidor
  const EnhancedErrorWidget.server({
    super.key,
    this.title = 'Erro do Servidor',
    this.message = 'Nossos servidores estão temporariamente indisponíveis.',
    this.onRetry,
    this.fallbackWidget,
    this.enableAutoRetry = true,
    this.autoRetryDelay = const Duration(seconds: 10),
    this.maxRetryAttempts = 2,
    this.cacheKey,
  }) : errorType = ErrorType.server;

  /// Erro de dados não encontrados
  const EnhancedErrorWidget.notFound({
    super.key,
    this.title = 'Dados Não Encontrados',
    this.message = 'Os dados solicitados não foram encontrados.',
    this.onRetry,
    this.fallbackWidget,
    this.enableAutoRetry = false,
    this.autoRetryDelay = const Duration(seconds: 3),
    this.maxRetryAttempts = 1,
    this.cacheKey,
  }) : errorType = ErrorType.notFound;

  /// Erro de timeout
  const EnhancedErrorWidget.timeout({
    super.key,
    this.title = 'Tempo Esgotado',
    this.message = 'A operação demorou mais que o esperado.',
    this.onRetry,
    this.fallbackWidget,
    this.enableAutoRetry = true,
    this.autoRetryDelay = const Duration(seconds: 3),
    this.maxRetryAttempts = 2,
    this.cacheKey,
  }) : errorType = ErrorType.timeout;

  @override
  State<EnhancedErrorWidget> createState() => _EnhancedErrorWidgetState();
}

class _EnhancedErrorWidgetState extends State<EnhancedErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _retryAttempts = 0;
  bool _isRetrying = false;
  bool _showFallback = false;
  Widget? _cachedFallback;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkForCachedData();
    
    if (widget.enableAutoRetry && widget.onRetry != null) {
      _startAutoRetry();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  Future<void> _checkForCachedData() async {
    if (widget.cacheKey != null) {
      try {
        final cacheService = GetIt.instance<CacheService>();
        final cachedData = await cacheService.get(widget.cacheKey!);
        
        if (cachedData != null && widget.fallbackWidget != null) {
          setState(() {
            _showFallback = true;
            _cachedFallback = widget.fallbackWidget;
          });
        }
      } catch (e) {
        // Ignora erros de cache
      }
    }
  }

  void _startAutoRetry() {
    if (_retryAttempts >= widget.maxRetryAttempts) return;
    
    Future.delayed(widget.autoRetryDelay, () {
      if (mounted && !_isRetrying) {
        _handleRetry(isAutomatic: true);
      }
    });
  }

  Future<void> _handleRetry({bool isAutomatic = false}) async {
    if (_isRetrying || widget.onRetry == null) return;
    
    setState(() {
      _isRetrying = true;
    });
    
    if (!isAutomatic) {
      await InteractionService.mediumHaptic();
    }
    
    try {
      widget.onRetry!();
    } catch (e) {
      _retryAttempts++;
      
      if (widget.enableAutoRetry && _retryAttempts < widget.maxRetryAttempts) {
        _startAutoRetry();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showFallback && _cachedFallback != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            margin: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.warning,
                  color: AppColors.warning,
                  size: AppDimensions.iconSmall,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(
                    'Exibindo dados salvos (offline)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.onRetry != null)
                  TextButton(
                    onPressed: _isRetrying ? null : () => _handleRetry(),
                    child: Text(
                      'Atualizar',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _cachedFallback!),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildErrorContent(),
          ),
        );
      },
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildErrorIcon(),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildErrorTitle(),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildErrorMessage(),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildActionButtons(),
            if (widget.enableAutoRetry && _retryAttempts < widget.maxRetryAttempts)
              _buildAutoRetryIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    IconData icon;
    Color color;
    
    switch (widget.errorType) {
      case ErrorType.network:
        icon = AppIcons.wifiOff;
        color = AppColors.error;
        break;
      case ErrorType.server:
        icon = AppIcons.server;
        color = AppColors.warning;
        break;
      case ErrorType.notFound:
        icon = AppIcons.searchOff;
        color = AppColors.textLight;
        break;
      case ErrorType.timeout:
        icon = AppIcons.clock;
        color = AppColors.warning;
        break;
      case ErrorType.general:
      default:
        icon = AppIcons.alertCircle;
        color = AppColors.error;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 48,
        color: color,
      ),
    );
  }

  Widget _buildErrorTitle() {
    return Text(
      widget.title ?? _getDefaultTitle(),
      style: AppTextStyles.headingMedium.copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      widget.message ?? _getDefaultMessage(),
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textLight,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.onRetry != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRetrying ? null : () => _handleRetry(),
              icon: _isRetrying
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.surface,
                        ),
                      ),
                    )
                  : Icon(AppIcons.refresh),
              label: Text(_isRetrying ? 'Tentando...' : 'Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAutoRetryIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingLarge),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            'Tentativa ${_retryAttempts + 1} de ${widget.maxRetryAttempts}...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getDefaultTitle() {
    switch (widget.errorType) {
      case ErrorType.network:
        return 'Erro de Conexão';
      case ErrorType.server:
        return 'Erro do Servidor';
      case ErrorType.notFound:
        return 'Dados Não Encontrados';
      case ErrorType.timeout:
        return 'Tempo Esgotado';
      case ErrorType.general:
      default:
        return 'Ops! Algo deu errado';
    }
  }

  String _getDefaultMessage() {
    switch (widget.errorType) {
      case ErrorType.network:
        return 'Verifique sua conexão com a internet e tente novamente.';
      case ErrorType.server:
        return 'Nossos servidores estão temporariamente indisponíveis.';
      case ErrorType.notFound:
        return 'Os dados solicitados não foram encontrados.';
      case ErrorType.timeout:
        return 'A operação demorou mais que o esperado.';
      case ErrorType.general:
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}

/// Tipos de erro suportados
enum ErrorType {
  network,
  server,
  notFound,
  timeout,
  general,
}

/// Widget para exibir erro em contextos específicos
class ContextualErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final Widget? fallbackWidget;
  final ErrorType errorType;
  final bool isCompact;

  const ContextualErrorWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.fallbackWidget,
    this.errorType = ErrorType.general,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactError();
    }
    
    return EnhancedErrorWidget(
      title: title,
      message: message,
      onRetry: onRetry,
      fallbackWidget: fallbackWidget,
      errorType: errorType,
      enableAutoRetry: errorType == ErrorType.network || errorType == ErrorType.timeout,
    );
  }

  Widget _buildCompactError() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      margin: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(),
            color: AppColors.error,
            size: AppDimensions.iconSmall,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (message != null)
                  Text(
                    message!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Tentar',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case ErrorType.network:
        return AppIcons.wifiOff;
      case ErrorType.server:
        return AppIcons.server;
      case ErrorType.notFound:
        return AppIcons.searchOff;
      case ErrorType.timeout:
        return AppIcons.clock;
      case ErrorType.general:
      default:
        return AppIcons.alertCircle;
    }
  }
}