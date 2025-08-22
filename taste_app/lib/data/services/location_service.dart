import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';

@singleton
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService();
  
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  
  Position? _cachedLocation;
  Position? get cachedLocation => _cachedLocation;
  
  bool _isLocationEnabled = false;
  bool get isLocationEnabled => _isLocationEnabled;
  
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  PermissionStatus get permissionStatus => _permissionStatus;
  
  DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  
  bool get isCacheValid {
    if (_lastCacheTime == null || _cachedLocation == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidDuration;
  }
  /// Verifica se as permissões de localização estão concedidas
  Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission == PermissionStatus.granted;
  }

  /// Solicita permissões de localização
  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }

  /// Verifica se o serviço de localização está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtém a posição atual do usuário
  Future<Position?> getCurrentPosition() async {
    try {
      print('📍 LocationService: Tentando obter localização atual...');
      
      // Verifica se o serviço está habilitado
      if (!await isLocationServiceEnabled()) {
        print('❌ LocationService: Serviço de localização desabilitado');
        throw Exception('Serviço de localização desabilitado');
      }

      // Verifica permissões
      if (!await hasLocationPermission()) {
        print('⚠️ LocationService: Sem permissão, solicitando...');
        final granted = await requestLocationPermission();
        if (!granted) {
          print('❌ LocationService: Permissão negada pelo usuário');
          throw Exception('Permissão de localização negada');
        }
      }

      print('🎯 LocationService: Obtendo posição com alta precisão...');
      // Obtém a posição com configurações mais agressivas para web
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
        forceAndroidLocationManager: true,
      );
      
      print('✅ LocationService: Localização obtida: ${position.latitude}, ${position.longitude}');
      print('📊 LocationService: Precisão: ${position.accuracy}m, Timestamp: ${position.timestamp}');
      
      return position;
    } catch (e) {
      print('❌ LocationService: Erro ao obter localização: $e');
      return null;
    }
  }

  /// Calcula a distância entre duas coordenadas em metros
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Verifica se um ponto está dentro do raio especificado (em metros)
  bool isWithinRadius(
    double userLat,
    double userLng,
    double targetLat,
    double targetLng,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(userLat, userLng, targetLat, targetLng);
    return distance <= radiusInMeters;
  }

  /// Converte metros para quilômetros
  double metersToKilometers(double meters) {
    return meters / 1000;
  }

  /// Converte quilômetros para metros
  double kilometersToMeters(double kilometers) {
    return kilometers * 1000;
  }
  
  /// Abre as configurações do aplicativo
  Future<bool> openAppSettings() async {
    return await Permission.location.request().isGranted;
  }
  
  /// Limpa os dados de localização
  void clearLocationData() {
    _currentPosition = null;
    _cachedLocation = null;
    _isLocationEnabled = false;
    _permissionStatus = PermissionStatus.denied;
    _lastCacheTime = null;
  }
  
  /// Libera recursos
  void dispose() {
    clearLocationData();
  }
  
  /// Calcula distância em quilômetros
  double calculateDistanceInKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final distanceInMeters = calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return metersToKilometers(distanceInMeters);
  }
}
