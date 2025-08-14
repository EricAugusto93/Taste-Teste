import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Serviço para gerenciar conectividade de rede
class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _hasInternetConnection = false;

  /// Status atual da conexão
  ConnectivityResult get connectionStatus => _connectionStatus;

  /// Se há conexão com a internet
  bool get hasInternetConnection => _hasInternetConnection;

  /// Alias para hasInternetConnection (compatibilidade)
  bool get isOnline => _hasInternetConnection;

  /// Se está conectado via WiFi
  bool get isWifiConnected => _connectionStatus == ConnectivityResult.wifi;

  /// Se está conectado via dados móveis
  bool get isMobileConnected => _connectionStatus == ConnectivityResult.mobile;

  /// Se está desconectado
  bool get isDisconnected => _connectionStatus == ConnectivityResult.none;

  /// Stream de mudanças na conectividade
  Stream<ConnectivityResult> get connectivityStream => 
      _connectivity.onConnectivityChanged;

  /// Inicializa o serviço de conectividade
  Future<void> initialize() async {
    try {
      // Verifica o status inicial
      await checkConnectivity();
      
      // Escuta mudanças na conectividade
      _connectivity.onConnectivityChanged.listen((result) {
        _updateConnectionStatus(result);
      });
      
      debugPrint('Serviço de conectividade inicializado');
    } catch (e) {
      debugPrint('Erro ao inicializar conectividade: $e');
    }
  }

  /// Verifica o status atual da conectividade
  Future<ConnectivityResult> checkConnectivity() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
      await _checkInternetConnection();
      return _connectionStatus;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade: $e');
      _connectionStatus = ConnectivityResult.none;
      _hasInternetConnection = false;
      return _connectionStatus;
    }
  }

  /// Atualiza o status da conexão
  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus = result;
    _checkInternetConnection();
    debugPrint('Status de conectividade atualizado: $result');
  }

  /// Verifica se há conexão real com a internet
  Future<void> _checkInternetConnection() async {
    if (_connectionStatus == ConnectivityResult.none) {
      _hasInternetConnection = false;
      return;
    }

    try {
      if (kIsWeb) {
        // Para Flutter Web, assume conectividade se há uma conexão de rede
        // Evita problemas de CORS em desenvolvimento
        _hasInternetConnection = _connectionStatus != ConnectivityResult.none;
      } else {
        // Para plataformas nativas, usa InternetAddress.lookup
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        _hasInternetConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (e) {
      _hasInternetConnection = false;
      debugPrint('Sem conexão real com a internet: $e');
    }
  }

  /// Verifica conectividade com timeout personalizado
  Future<bool> hasInternetConnectionWithTimeout({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      if (kIsWeb) {
        // Para Flutter Web, assume conectividade se há uma conexão de rede
        // Evita problemas de CORS em desenvolvimento
        return _connectionStatus != ConnectivityResult.none;
      } else {
        // Para plataformas nativas, usa InternetAddress.lookup
        final result = await InternetAddress.lookup('google.com')
            .timeout(timeout);
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Erro na verificação de conectividade: $e');
      return false;
    }
  }

  /// Obtém uma descrição amigável do status da conexão
  String getConnectionDescription() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return _hasInternetConnection ? 'Conectado via WiFi' : 'WiFi sem internet';
      case ConnectivityResult.mobile:
        return _hasInternetConnection ? 'Conectado via dados móveis' : 'Dados móveis sem internet';
      case ConnectivityResult.ethernet:
        return _hasInternetConnection ? 'Conectado via Ethernet' : 'Ethernet sem internet';
      case ConnectivityResult.bluetooth:
        return _hasInternetConnection ? 'Conectado via Bluetooth' : 'Bluetooth sem internet';
      case ConnectivityResult.vpn:
        return _hasInternetConnection ? 'Conectado via VPN' : 'VPN sem internet';
      case ConnectivityResult.other:
        return _hasInternetConnection ? 'Conectado (outro)' : 'Conexão sem internet';
      case ConnectivityResult.none:
      default:
        return 'Sem conexão';
    }
  }

  /// Verifica se a conexão é adequada para operações pesadas
  bool isGoodForHeavyOperations() {
    return _hasInternetConnection && 
           (_connectionStatus == ConnectivityResult.wifi || 
            _connectionStatus == ConnectivityResult.ethernet);
  }

  /// Verifica se deve usar cache devido à conectividade limitada
  bool shouldUseCache() {
    return !_hasInternetConnection || 
           _connectionStatus == ConnectivityResult.none;
  }

  /// Aguarda até ter conexão com a internet
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      await checkConnectivity();
      if (_hasInternetConnection) {
        return true;
      }
      await Future.delayed(checkInterval);
    }
    
    return false;
  }

  /// Executa uma ação quando houver conexão
  Future<T?> executeWhenConnected<T>(
    Future<T> Function() action, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_hasInternetConnection) {
      return await action();
    }
    
    final hasConnection = await waitForConnection(timeout: timeout);
    if (hasConnection) {
      return await action();
    }
    
    return null;
  }

  /// Limpa dados do serviço
  void clearData() {
    _connectionStatus = ConnectivityResult.none;
    _hasInternetConnection = false;
  }
}