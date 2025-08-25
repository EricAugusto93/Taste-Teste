import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/models/location_model.dart';
import '../../../core/di/injection_container.dart';

/// Estado da localização
class LocationState {
  final LocationModel? currentLocation;
  final bool isLoading;
  final String? error;
  final bool isLocationServiceEnabled;
  final PermissionStatus permissionStatus;
  final bool hasAllPermissions;
  
  const LocationState({
    this.currentLocation,
    this.isLoading = false,
    this.error,
    this.isLocationServiceEnabled = false,
    this.permissionStatus = PermissionStatus.denied,
    this.hasAllPermissions = false,
  });
  
  LocationState copyWith({
    LocationModel? currentLocation,
    bool? isLoading,
    String? error,
    bool? isLocationServiceEnabled,
    PermissionStatus? permissionStatus,
    bool? hasAllPermissions,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLocationServiceEnabled: isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      hasAllPermissions: hasAllPermissions ?? this.hasAllPermissions,
    );
  }
}

/// Provider do repositório de localização
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return getIt<LocationRepository>();
});

/// Provider do estado da localização
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return LocationNotifier(repository);
});

/// Notifier para gerenciar o estado da localização
class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository _repository;
  
  LocationNotifier(this._repository) : super(const LocationState()) {
    _initializeLocation();
  }
  
  /// Inicializa a localização verificando permissões e serviços
  Future<void> _initializeLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Verifica se o serviço está habilitado
      final isServiceEnabled = await _repository.isLocationServiceEnabled();
      
      // Verifica o status da permissão
      final permissionStatus = await _repository.getLocationPermissionStatus();
      
      // Verifica se tem todas as permissões
      final hasAllPermissions = await _repository.hasAllRequiredPermissions();
      
      state = state.copyWith(
        isLocationServiceEnabled: isServiceEnabled,
        permissionStatus: permissionStatus,
        hasAllPermissions: hasAllPermissions,
        isLoading: false,
      );
      
      // Se tem todas as permissões, obtém a localização atual
      if (hasAllPermissions) {
        await getCurrentLocation();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao inicializar localização: $e',
      );
    }
  }
  
  /// Obtém a localização atual do usuário
  Future<void> getCurrentLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final location = await _repository.getCurrentLocation();
      
      state = state.copyWith(
        currentLocation: location,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao obter localização: $e',
      );
    }
  }
  
  /// Solicita permissão de localização
  Future<bool> requestLocationPermission() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final permissionStatus = await _repository.requestLocationPermission();
      final hasAllPermissions = await _repository.hasAllRequiredPermissions();
      
      state = state.copyWith(
        permissionStatus: permissionStatus,
        hasAllPermissions: hasAllPermissions,
        isLoading: false,
      );
      
      // Se obteve permissão, tenta obter a localização
      if (permissionStatus == PermissionStatus.granted) {
        await getCurrentLocation();
        return true;
      }
      
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao solicitar permissão: $e',
      );
      return false;
    }
  }
  
  /// Abre as configurações do app
  Future<void> openAppSettings() async {
    try {
      await _repository.openAppSettings();
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao abrir configurações: $e',
      );
    }
  }
  
  /// Calcula a distância entre duas localizações
  double calculateDistance(LocationModel from, LocationModel to) {
    return _repository.calculateDistanceInMeters(from, to);
  }

  /// Calcula a distância em quilômetros
  double calculateDistanceInKm(LocationModel from, LocationModel to) {
    return _repository.calculateDistanceInKilometers(from, to);
  }

  /// Formata a distância para exibição
  String formatDistance(double distanceInMeters) {
    return _repository.formatDistanceForDisplay(distanceInMeters);
  }
  
  /// Verifica se uma localização está dentro de um raio
  bool isWithinRadius(LocationModel center, LocationModel target, double radiusInMeters) {
    final distance = _repository.calculateDistanceInMeters(center, target);
    return distance <= radiusInMeters;
  }
  
  /// Encontra a localização mais próxima
  LocationModel? findNearestLocation(List<LocationModel> locations) {
    if (state.currentLocation == null || locations.isEmpty) return null;
    
    LocationModel? nearest;
    double minDistance = double.infinity;
    
    for (final location in locations) {
      final distance = _repository.calculateDistanceInMeters(state.currentLocation!, location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }
    
    return nearest;
  }
  
  /// Ordena localizações por distância
  List<LocationModel> sortLocationsByDistance(List<LocationModel> locations) {
    if (state.currentLocation == null) return locations;
    
    final locationsWithDistance = locations.map((location) {
      final distance = _repository.calculateDistanceInMeters(state.currentLocation!, location);
      return {'location': location, 'distance': distance};
    }).toList();
    
    locationsWithDistance.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    
    return locationsWithDistance.map((item) => item['location'] as LocationModel).toList();
  }
  
  /// Limpa os dados de localização
  void clearLocationData() {
    state = const LocationState();
  }
  
  /// Atualiza o estado com uma nova localização
  void updateLocation(LocationModel location) {
    state = state.copyWith(currentLocation: location);
  }
  
  /// Limpa apenas o erro
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Recarrega todas as informações de localização
  Future<void> refresh() async {
    await _initializeLocation();
  }
}

/// Provider para stream de localização em tempo real
final locationStreamProvider = StreamProvider<LocationModel>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getLocationUpdates();
});

/// Provider para verificar se tem permissões
final hasLocationPermissionsProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.hasAllRequiredPermissions();
});

/// Provider para verificar se o serviço está habilitado
final isLocationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.isLocationServiceEnabled();
});

/// Provider para obter a localização atual (uma vez)
final currentLocationProvider = FutureProvider<LocationModel?>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getCurrentLocation();
});

/// Provider para calcular distância entre duas localizações
final distanceCalculatorProvider = Provider.family<double, ({LocationModel from, LocationModel to})>((ref, params) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.calculateDistanceInMeters(params.from, params.to);
});

/// Provider para formatar distância
final distanceFormatterProvider = Provider.family<String, double>((ref, distanceInMeters) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.formatDistanceForDisplay(distanceInMeters);
});
