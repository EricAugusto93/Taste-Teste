import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class LocalizacaoService {
  // Coordenadas de Porto Alegre como fallback
  static const double _portoAlegreeLat = -30.0346;
  static const double _portoAlegreeLng = -51.2177;

  /// Verifica se o serviço de localização está habilitado
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Verifica o status atual da permissão de localização
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Solicita permissão de localização
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Abre as configurações de localização do dispositivo
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Obtém a posição atual do usuário
  static Future<Position?> getCurrentPosition() async {
    try {
      // Verificar se o serviço está habilitado
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Serviço de localização desabilitado');
        return null;
      }

      // Verificar permissões
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Permissão de localização negada');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Permissão de localização negada permanentemente');
        return null;
      }

      // Obter posição com configurações otimizadas
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      debugPrint('Localização obtida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      return null;
    }
  }

  /// Retorna coordenadas de fallback (Porto Alegre)
  static Map<String, double> getFallbackLocation() {
    return {
      'latitude': _portoAlegreeLat,
      'longitude': _portoAlegreeLng,
    };
  }

  /// Obtém localização atual ou fallback
  static Future<Map<String, double>> getLocationOrFallback() async {
    final position = await getCurrentPosition();
    
    if (position != null) {
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    }
    
    debugPrint('Usando localização fallback: Porto Alegre');
    return getFallbackLocation();
  }

  /// Calcula a distância entre duas coordenadas usando fórmula de Haversine
  static double calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double raioTerra = 6371; // raio da Terra em km
    
    final double dLat = _grausParaRadianos(lat2 - lat1);
    final double dLon = _grausParaRadianos(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_grausParaRadianos(lat1)) * math.cos(_grausParaRadianos(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return raioTerra * c;
  }

  /// Converte graus para radianos
  static double _grausParaRadianos(double graus) {
    return graus * (math.pi / 180);
  }

  /// Formata distância para exibição
  static String formatarDistancia(double distanciaKm) {
    if (distanciaKm < 1) {
      return '${(distanciaKm * 1000).round()}m';
    } else {
      return '${distanciaKm.toStringAsFixed(1)}km';
    }
  }

  /// Obtém informações sobre a distância para categorização
  static DistanciaInfo getDistanciaInfo(double distanciaKm) {
    if (distanciaKm <= 1.0) {
      return const DistanciaInfo(
        cor: Colors.green,
        icone: '🚶',
        descricao: 'Muito próximo',
      );
    } else if (distanciaKm <= 3.0) {
      return const DistanciaInfo(
        cor: Colors.orange,
        icone: '🚗',
        descricao: 'Próximo',
      );
    } else {
      return const DistanciaInfo(
        cor: Colors.red,
        icone: '🚙',
        descricao: 'Distante',
      );
    }
  }

  /// Verifica se restaurante está dentro do raio especificado
  static bool isWithinRadius(
    double userLat,
    double userLng,
    double restauranteLat,
    double restauranteLng,
    double raioKm,
  ) {
    final distancia = calcularDistancia(userLat, userLng, restauranteLat, restauranteLng);
    return distancia <= raioKm;
  }

  /// Filtra e ordena restaurantes por proximidade
  static List<T> filtrarPorProximidade<T>(
    List<T> restaurantes,
    double userLat,
    double userLng,
    double raioKm,
    double Function(T) getLatitude,
    double Function(T) getLongitude,
  ) {
    // Filtrar por raio e adicionar distância
    final restaurantesComDistancia = restaurantes
        .map((restaurante) {
          final distancia = calcularDistancia(
            userLat,
            userLng,
            getLatitude(restaurante),
            getLongitude(restaurante),
          );
          return _RestauranteComDistanciaHelper<T>(restaurante, distancia);
        })
        .where((item) => item.distancia <= raioKm)
        .toList();

    // Ordenar por distância
    restaurantesComDistancia.sort((a, b) => a.distancia.compareTo(b.distancia));

    // Retornar apenas os restaurantes ordenados
    return restaurantesComDistancia.map((item) => item.restaurante).toList();
  }
}

/// Classe para informações de distância
class DistanciaInfo {
  final Color cor;
  final String icone;
  final String descricao;

  const DistanciaInfo({
    required this.cor,
    required this.icone,
    required this.descricao,
  });
}

/// Classe auxiliar interna para ordenação por distância
class _RestauranteComDistanciaHelper<T> {
  final T restaurante;
  final double distancia;

  const _RestauranteComDistanciaHelper(this.restaurante, this.distancia);
}

/// Enum para status de permissão/localização
enum StatusLocalizacao {
  inicial,
  desconhecido,
  obtendo,
  obtida,
  negada,
  negadaPermanentemente,
  servicoDesabilitado,
  erro,
  fallback,
}