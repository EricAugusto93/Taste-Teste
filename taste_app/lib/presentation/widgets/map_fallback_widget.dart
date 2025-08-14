import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/config/google_maps_config.dart';

/// Widget de fallback para quando o Google Maps não está disponível
/// Especialmente útil para web quando a API key não está configurada
class MapFallbackWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final double? height;

  const MapFallbackWidget({
    super.key,
    this.message,
    this.onRetry,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    String defaultMessage;
    
    if (kIsWeb) {
      if (!GoogleMapsConfig.hasValidApiKey) {
        defaultMessage = 'API Key do Google Maps não configurada\nConfigure GOOGLE_MAPS_API_KEY no arquivo .env';
      } else if (!GoogleMapsConfig.isAvailable) {
        defaultMessage = 'Google Maps não carregado\nVerifique sua conexão com a internet';
      } else {
        defaultMessage = 'Erro ao carregar o mapa\nTente novamente';
      }
    } else {
      defaultMessage = 'Erro ao carregar o mapa\nVerifique sua conexão';
    }

    return Container(
      height: height ?? 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? defaultMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Tentar novamente',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (kIsWeb && !GoogleMapsConfig.hasValidApiKey) ...[            const SizedBox(height: 8),
            Text(
              'Para usar o mapa, configure a\nGOOGLE_MAPS_API_KEY no arquivo .env',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
          if (kDebugMode) ...[            const SizedBox(height: 8),
            Text(
              'Debug: ${GoogleMapsConfig.debugInfo}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget que detecta se o Google Maps está disponível e mostra fallback se necessário
class SafeGoogleMap extends StatefulWidget {
  final Widget mapWidget;
  final String? fallbackMessage;
  final double? height;

  const SafeGoogleMap({
    super.key,
    required this.mapWidget,
    this.fallbackMessage,
    this.height,
  });

  @override
  State<SafeGoogleMap> createState() => _SafeGoogleMapState();
}

class _SafeGoogleMapState extends State<SafeGoogleMap> {
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkMapAvailability();
  }

  void _checkMapAvailability() {
    // Verifica disponibilidade do Google Maps
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Verifica se há erro baseado na configuração
          _hasError = kIsWeb && (!GoogleMapsConfig.hasValidApiKey || !GoogleMapsConfig.isAvailable);
        });
      }
    });
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _checkMapAvailability();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height ?? 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_hasError) {
      return MapFallbackWidget(
        message: widget.fallbackMessage,
        onRetry: _retry,
        height: widget.height,
      );
    }

    return widget.mapWidget;
  }
}