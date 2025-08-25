import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_icons.dart';
import '../../core/services/ui/interaction_service.dart';

/// Banner que exibe o status de conectividade
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final bool showWhenOnline;
  final Duration animationDuration;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.showWhenOnline = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initConnectivityListener();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initConnectivityListener() {
    // Obtém o status inicial
    _currentStatus = ConnectivityService.instance.status;
    _updateBannerVisibility();
    
    // Escuta mudanças no status
    ConnectivityService.instance.statusStream.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    final newStatus = ConnectivityService.instance.status;
    
    if (_currentStatus != newStatus) {
      setState(() {
        _currentStatus = newStatus;
      });
      
      _updateBannerVisibility();
      
      // Feedback háptico para mudanças importantes
      if (newStatus == ConnectivityStatus.connected) {
        InteractionService.lightHaptic();
      } else if (newStatus == ConnectivityStatus.disconnected) {
        InteractionService.mediumHaptic();
      }
    }
  }

  void _updateBannerVisibility() {
    final shouldShow = _shouldShowBanner();
    
    if (shouldShow != _showBanner) {
      setState(() {
        _showBanner = shouldShow;
      });
      
      if (_showBanner) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  bool _shouldShowBanner() {
    switch (_currentStatus) {
      case ConnectivityStatus.disconnected:
        return true;
      case ConnectivityStatus.connected:
        return widget.showWhenOnline;
      case ConnectivityStatus.unknown:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * 60),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _showBanner ? _buildBanner() : const SizedBox.shrink(),
              ),
            );
          },
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildBanner() {
    final bannerData = _getBannerData();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: bannerData.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              bannerData.icon,
              color: bannerData.textColor,
              size: AppDimensions.iconSmall,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Text(
                bannerData.message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: bannerData.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (bannerData.showAction)
              TextButton(
                onPressed: _handleBannerAction,
                child: Text(
                  bannerData.actionText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: bannerData.textColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _BannerData _getBannerData() {
    switch (_currentStatus) {
      case ConnectivityStatus.connected:
        return _BannerData(
          message: 'Conectado à internet',
          icon: AppIcons.wifi,
          backgroundColor: AppColors.success,
          textColor: AppColors.surface,
          showAction: false,
          actionText: '',
        );
      case ConnectivityStatus.disconnected:
        return _BannerData(
          message: 'Sem conexão - Dados salvos sendo exibidos',
          icon: AppIcons.wifiOff,
          backgroundColor: AppColors.warning,
          textColor: AppColors.surface,
          showAction: true,
          actionText: 'Tentar novamente',
        );
      case ConnectivityStatus.unknown:
      default:
        return _BannerData(
          message: 'Verificando conexão...',
          icon: AppIcons.refresh,
          backgroundColor: AppColors.textLight,
          textColor: AppColors.surface,
          showAction: false,
          actionText: '',
        );
    }
  }

  void _handleBannerAction() {
    switch (_currentStatus) {
      case ConnectivityStatus.disconnected:
        _retryConnection();
        break;
      default:
        break;
    }
  }

  Future<void> _retryConnection() async {
    InteractionService.lightHaptic();
    await ConnectivityService.instance.checkConnectivity();
  }
}

/// Dados para configurar o banner
class _BannerData {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final bool showAction;
  final String actionText;

  _BannerData({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.showAction,
    required this.actionText,
  });
}

/// Widget compacto para mostrar status de conectividade
class ConnectivityIndicator extends StatelessWidget {
  final bool showLabel;
  final double iconSize;

  const ConnectivityIndicator({
    super.key,
    this.showLabel = true,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConnectivityStatus>(
      valueListenable: ConnectivityService.instance.statusStream,
      builder: (context, status, child) {
        final data = _getIndicatorData(status);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              color: data.color,
              size: iconSize,
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                data.label,
                style: AppTextStyles.caption.copyWith(
                  color: data.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  _IndicatorData _getIndicatorData(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return _IndicatorData(
          icon: AppIcons.wifi,
          color: AppColors.success,
          label: 'Online',
        );
      case ConnectivityStatus.disconnected:
        return _IndicatorData(
          icon: AppIcons.wifiOff,
          color: AppColors.error,
          label: 'Offline',
        );
      case ConnectivityStatus.unknown:
      default:
        return _IndicatorData(
          icon: AppIcons.help,
          color: AppColors.textLight,
          label: 'Verificando',
        );
    }
  }
}

/// Dados para o indicador de conectividade
class _IndicatorData {
  final IconData icon;
  final Color color;
  final String label;

  _IndicatorData({
    required this.icon,
    required this.color,
    required this.label,
  });
}