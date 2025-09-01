import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_model.dart';
import '../services/location/location_service.dart';
import '../../core/utils/logger.dart';
import '../../services/analytics_service.dart';

/// Repository para gerenciar dados de localização
/// Abstrai o acesso aos serviços de localização e fornece uma interface limpa
class LocationRepository {
  static LocationRepository? _instance;
  static LocationRepository get instance => _instance ??= LocationRepository._();
  
  final LocationService _locationService;
  
  LocationRepository._() : _locationService = LocationService.instance;
  
  // Construtor para testes com injeção de dependência
  LocationRepository.withService(this._locationService);
  
  /// Obtém a localização atual do usuário
  /// 
  /// [forceRefresh] - Se true, força uma nova busca ignorando o cache
  /// 
  /// Retorna [LocationModel] com a localização atual ou null se não conseguir obter
  Future<LocationModel?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      Logger.info('LocationRepository: Solicitando localização atual', {
        'forceRefresh': forceRefresh,
      });
      
      final position = await _locationService.getCurrentPosition();
      
      if (position != null) {
        final locationModel = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        );
        
        Logger.info('LocationRepository: Localização obtida com sucesso', {
          'latitude': locationModel.latitude,
          'longitude': locationModel.longitude,
          'accuracy': locationModel.accuracy,
        });
        
        AnalyticsService.instance.trackEvent(
          'location_repository_success',
          parameters: {
            'method': 'getCurrentLocation',
            'accuracy': position.accuracy,
            'from_cache': !forceRefresh && _locationService.isCacheValid,
          },
        );
        
        return locationModel;
      }
      
      Logger.warning('LocationRepository: Não foi possível obter localização');
      return null;
      
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao obter localização', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
        'location_repository_error',
        parameters: {
          'method': 'getCurrentLocation',
          'error': e.toString(),
        },
      );
      
      return null;
    }
  }
  
  /// Verifica se o serviço de localização está habilitado
  Future<bool> isLocationServiceEnabled() async {
    try {
      final isEnabled = await _locationService.isLocationServiceEnabled();
      
      Logger.info('LocationRepository: Status do serviço de localização', {
        'enabled': isEnabled,
      });
      
      return isEnabled;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao verificar serviço', e, stackTrace);
      return false;
    }
  }
  
  /// Verifica o status da permissão de localização
  Future<PermissionStatus> getLocationPermissionStatus() async {
    try {
      final status = await _locationService.hasLocationPermission() 
          ? PermissionStatus.granted 
          : PermissionStatus.denied;
      
      Logger.info('LocationRepository: Status da permissão', {
        'status': status.toString(),
      });
      
      return status;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao verificar permissão', e, stackTrace);
      return PermissionStatus.denied;
    }
  }
  
  /// Solicita permissão de localização
  Future<PermissionStatus> requestLocationPermission() async {
    try {
      Logger.info('LocationRepository: Solicitando permissão de localização');
      
      final granted = await _locationService.requestLocationPermission();
      final status = granted ? PermissionStatus.granted : PermissionStatus.denied;
      
      Logger.info('LocationRepository: Resultado da solicitação de permissão', {
        'status': status.toString(),
      });
      
      AnalyticsService.instance.trackEvent(
        'location_permission_requested',
      );
      
      return status;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao solicitar permissão', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
        'location_permission_error',
      );
      
      return PermissionStatus.denied;
    }
  }
  
  /// Verifica se todas as permissões necessárias estão concedidas
  Future<bool> hasAllRequiredPermissions() async {
    try {
      final hasPermissions = await _locationService.hasLocationPermission();
      
      Logger.info('LocationRepository: Status das permissões', {
        'hasAll': hasPermissions,
      });
      
      return hasPermissions;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao verificar permissões', e, stackTrace);
      return false;
    }
  }
  
  /// Calcula a distância entre duas localizações em metros
  double calculateDistanceInMeters(
    LocationModel from,
    LocationModel to,
  ) {
    try {
      final distance = _locationService.calculateDistance(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );
      
      Logger.debug('LocationRepository: Distância calculada', {
        'from': '${from.latitude},${from.longitude}',
        'to': '${to.latitude},${to.longitude}',
        'distance_meters': distance,
      });
      
      return distance;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao calcular distância', e, stackTrace);
      return 0.0;
    }
  }
  
  /// Calcula a distância entre duas localizações em quilômetros
  double calculateDistanceInKilometers(
    LocationModel from,
    LocationModel to,
  ) {
    try {
      final distance = _locationService.calculateDistanceInKm(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );
      
      Logger.debug('LocationRepository: Distância calculada em km', {
        'from': '${from.latitude},${from.longitude}',
        'to': '${to.latitude},${to.longitude}',
        'distance_km': distance,
      });
      
      return distance;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao calcular distância em km', e, stackTrace);
      return 0.0;
    }
  }
  
  /// Formata a distância para exibição amigável
  String formatDistanceForDisplay(double distanceInMeters) {
    try {
      if (distanceInMeters < 1000) {
        return '${distanceInMeters.round()}m';
      } else {
        final km = distanceInMeters / 1000;
        return '${km.toStringAsFixed(1)}km';
      }
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao formatar distância', e, stackTrace);
      return 'N/A';
    }
  }
  
  /// Obtém stream de atualizações de localização
  Stream<LocationModel> getLocationUpdates() {
    try {
      Logger.info('LocationRepository: Iniciando stream de localização');
      
      // Implementação temporária - retorna stream vazio
      return const Stream.empty();
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao obter stream', e, stackTrace);
      return const Stream.empty();
    }
  }
  
  /// Inicia o rastreamento contínuo de localização
  Future<void> startLocationTracking() async {
    try {
      Logger.info('LocationRepository: Iniciando rastreamento');
      
      // Implementação temporária - método não existe no LocationService
      // await _locationService.startLocationTracking();
      
      AnalyticsService.instance.trackEvent(
        'location_tracking_started_repo',
      );
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao iniciar rastreamento', e, stackTrace);
      
      AnalyticsService.instance.trackEvent(
        'location_tracking_error_repo',
      );
      
      rethrow;
    }
  }
  
  /// Para o rastreamento de localização
  Future<void> stopLocationTracking() async {
    try {
      Logger.info('LocationRepository: Parando rastreamento');
      
      // Implementação temporária - método não existe no LocationService
      // await _locationService.stopLocationTracking();
      
      AnalyticsService.instance.trackEvent(
        'location_tracking_stopped_repo',
      );
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao parar rastreamento', e, stackTrace);
    }
  }
  
  /// Obtém a localização em cache se disponível
  LocationModel? getCachedLocation() {
    try {
      final cached = _locationService.cachedLocation;
      
      if (cached != null && _locationService.isCacheValid) {
        Logger.debug('LocationRepository: Retornando localização do cache');
        // Converter Position para LocationModel
        return LocationModel(
          latitude: cached.latitude,
          longitude: cached.longitude,
          timestamp: DateTime.now(),
        );
      }
      
      Logger.debug('LocationRepository: Cache inválido ou vazio');
      return null;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao obter cache', e, stackTrace);
      return null;
    }
  }
  
  /// Verifica se o cache de localização é válido
  bool isCacheValid() {
    try {
      // Implementação temporária - sempre retorna false até implementar cache
      return false;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao verificar cache', e, stackTrace);
      return false;
    }
  }
  
  /// Abre as configurações do app para permissões
  Future<bool> openAppSettings() async {
    try {
      Logger.info('LocationRepository: Abrindo configurações do app');
      
      // Implementação temporária - sempre retorna false até implementar
      const result = false;
      
      AnalyticsService.instance.trackEvent(
        'location_settings_opened',
      );
      
      return result;
    } catch (e, stackTrace) {
      Logger.error('LocationRepository: Erro ao abrir configurações', e, stackTrace);
      return false;
    }
  }
}
