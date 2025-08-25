import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/location_repository.dart';
import '../../core/utils/logger.dart';
import '../../services/analytics_service.dart';
import '../../core/utils/navigation_helper.dart';

/// Widget para gerenciar permissões de localização
/// Fornece uma interface amigável para solicitar e gerenciar permissões
class LocationPermissionWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  final bool showDialog;
  final String? customTitle;
  final String? customMessage;
  
  const LocationPermissionWidget({
    super.key,
    required this.child,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.showDialog = true,
    this.customTitle,
    this.customMessage,
  });

  @override
  State<LocationPermissionWidget> createState() => _LocationPermissionWidgetState();
}

class _LocationPermissionWidgetState extends State<LocationPermissionWidget> {
  final LocationRepository _locationRepository = LocationRepository.instance;
  bool _isCheckingPermissions = false;
  PermissionStatus? _currentStatus;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  /// Verifica o status atual das permissões
  Future<void> _checkPermissions() async {
    if (_isCheckingPermissions) return;
    
    setState(() {
      _isCheckingPermissions = true;
    });
    
    try {
      final status = await _locationRepository.getLocationPermissionStatus();
      final serviceEnabled = await _locationRepository.isLocationServiceEnabled();
      
      setState(() {
        _currentStatus = status;
        _isCheckingPermissions = false;
      });
      
      Logger.info('LocationPermissionWidget: Status verificado', {
        'permission': status.toString(),
        'service_enabled': serviceEnabled,
      });
      
      // Se as permissões estão OK, chama o callback
      if (status == PermissionStatus.granted && serviceEnabled) {
        widget.onPermissionGranted?.call();
      } else if (widget.showDialog && status != PermissionStatus.granted) {
        _showPermissionDialog();
      }
      
    } catch (e, stackTrace) {
      Logger.error('LocationPermissionWidget: Erro ao verificar permissões', e, stackTrace);
      setState(() {
        _isCheckingPermissions = false;
      });
    }
  }
  
  /// Solicita permissão de localização
  Future<void> _requestPermission() async {
    try {
      Logger.info('LocationPermissionWidget: Solicitando permissão');
      
      final status = await _locationRepository.requestLocationPermission();
      
      setState(() {
        _currentStatus = status;
      });
      
      AnalyticsService.instance.trackEvent('location_permission_dialog_result', parameters: {
        'status': status.toString(),
        'source': 'permission_widget',
      });
      
      if (status == PermissionStatus.granted) {
        // Verifica se o serviço também está habilitado
        final serviceEnabled = await _locationRepository.isLocationServiceEnabled();
        
        if (serviceEnabled) {
          widget.onPermissionGranted?.call();
          if (mounted) {
            NavigationHelper.safeGoBack(context);
          }
        } else {
          _showLocationServiceDialog();
        }
      } else if (status == PermissionStatus.permanentlyDenied) {
        _showPermanentlyDeniedDialog();
      } else {
        widget.onPermissionDenied?.call();
        if (mounted) {
          NavigationHelper.safeGoBack(context);
        }
      }
      
    } catch (e, stackTrace) {
      Logger.error('LocationPermissionWidget: Erro ao solicitar permissão', e, stackTrace);
      widget.onPermissionDenied?.call();
    }
  }
  
  /// Mostra dialog de solicitação de permissão
  void _showPermissionDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          widget.customTitle ?? 'Permissão de Localização',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          widget.customMessage ?? 
          'Para encontrar restaurantes próximos a você, precisamos acessar sua localização. '
          'Seus dados de localização são usados apenas para melhorar sua experiência no app.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              NavigationHelper.safeGoBack(context);
              widget.onPermissionDenied?.call();
              
              AnalyticsService.instance.trackEvent('location_permission_denied_dialog', parameters: {
                'action': 'cancel',
              });
            },
            child: const Text('Não Permitir'),
          ),
          ElevatedButton(
            onPressed: _requestPermission,
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
  }
  
  /// Mostra dialog quando o serviço de localização está desabilitado
  void _showLocationServiceDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Serviço de Localização Desabilitado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'O serviço de localização está desabilitado no seu dispositivo. '
          'Por favor, habilite-o nas configurações para usar recursos baseados em localização.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              NavigationHelper.safeGoBack(context);
              widget.onPermissionDenied?.call();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              NavigationHelper.safeGoBack(context);
              // Tenta abrir as configurações
              await _locationRepository.openAppSettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }
  
  /// Mostra dialog quando a permissão foi permanentemente negada
  void _showPermanentlyDeniedDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Permissão Negada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'A permissão de localização foi permanentemente negada. '
          'Para usar recursos baseados em localização, você precisa habilitar '
          'a permissão manualmente nas configurações do app.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              NavigationHelper.safeGoBack(context);
              widget.onPermissionDenied?.call();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              NavigationHelper.safeGoBack(context);
              await _locationRepository.openAppSettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Widget de status de permissão para mostrar o estado atual
class LocationPermissionStatus extends StatefulWidget {
  final Widget Function(PermissionStatus status, bool isServiceEnabled) builder;
  final Duration refreshInterval;
  
  const LocationPermissionStatus({
    super.key,
    required this.builder,
    this.refreshInterval = const Duration(seconds: 5),
  });

  @override
  State<LocationPermissionStatus> createState() => _LocationPermissionStatusState();
}

class _LocationPermissionStatusState extends State<LocationPermissionStatus> {
  final LocationRepository _locationRepository = LocationRepository.instance;
  PermissionStatus _status = PermissionStatus.denied;
  bool _isServiceEnabled = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkStatus();
    
    // Atualiza periodicamente o status
    Timer.periodic(widget.refreshInterval, (timer) {
      if (mounted) {
        _checkStatus();
      } else {
        timer.cancel();
      }
    });
  }
  
  Future<void> _checkStatus() async {
    try {
      final status = await _locationRepository.getLocationPermissionStatus();
      final serviceEnabled = await _locationRepository.isLocationServiceEnabled();
      
      if (mounted) {
        setState(() {
          _status = status;
          _isServiceEnabled = serviceEnabled;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      Logger.error('LocationPermissionStatus: Erro ao verificar status', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return widget.builder(_status, _isServiceEnabled);
  }
}

/// Botão para solicitar permissão de localização
class LocationPermissionButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  final ButtonStyle? style;
  
  const LocationPermissionButton({
    super.key,
    this.text,
    this.icon,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.style,
  });

  @override
  State<LocationPermissionButton> createState() => _LocationPermissionButtonState();
}

class _LocationPermissionButtonState extends State<LocationPermissionButton> {
  final LocationRepository _locationRepository = LocationRepository.instance;
  bool _isLoading = false;
  
  Future<void> _handlePress() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final hasPermissions = await _locationRepository.hasAllRequiredPermissions();
      
      if (hasPermissions) {
        widget.onPermissionGranted?.call();
      } else {
        final status = await _locationRepository.requestLocationPermission();
        
        if (status == PermissionStatus.granted) {
          final serviceEnabled = await _locationRepository.isLocationServiceEnabled();
          
          if (serviceEnabled) {
            widget.onPermissionGranted?.call();
          } else {
            widget.onPermissionDenied?.call();
          }
        } else {
          widget.onPermissionDenied?.call();
        }
      }
    } catch (e, stackTrace) {
      Logger.error('LocationPermissionButton: Erro ao processar permissão', e, stackTrace);
      widget.onPermissionDenied?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handlePress,
      style: widget.style,
      icon: _isLoading 
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(widget.icon ?? Icons.location_on),
      label: Text(widget.text ?? 'Permitir Localização'),
    );
  }
}