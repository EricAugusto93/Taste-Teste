import 'package:flutter/foundation.dart';

/// Configurações do aplicativo baseadas no ambiente
class AppConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Ambiente atual da aplicação
  static AppEnvironment get environment {
    switch (_environment.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }

  /// Verifica se está em modo debug
  static bool get isDebug => kDebugMode;

  /// Verifica se está em modo release
  static bool get isRelease => kReleaseMode;

  /// Verifica se está em modo profile
  static bool get isProfile => kProfileMode;

  /// Verifica se está em produção
  static bool get isProduction => environment == AppEnvironment.production;

  /// Verifica se está em desenvolvimento
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// Verifica se está em staging
  static bool get isStaging => environment == AppEnvironment.staging;

  /// Nome do aplicativo baseado no ambiente
  static String get appName {
    switch (environment) {
      case AppEnvironment.production:
        return 'Taste';
      case AppEnvironment.staging:
        return 'Taste Staging';
      case AppEnvironment.development:
        return 'Taste Dev';
    }
  }

  /// ID do aplicativo baseado no ambiente
  static String get applicationId {
    switch (environment) {
      case AppEnvironment.production:
        return 'com.taste.app';
      case AppEnvironment.staging:
        return 'com.taste.app.staging';
      case AppEnvironment.development:
        return 'com.taste.app.dev';
    }
  }

  /// URL base da API baseada no ambiente
  static String get apiBaseUrl {
    switch (environment) {
      case AppEnvironment.production:
        return 'https://api.taste.com';
      case AppEnvironment.staging:
        return 'https://staging-api.taste.com';
      case AppEnvironment.development:
        return 'https://dev-api.taste.com';
    }
  }

  /// Configurações de logging
  static bool get enableLogging {
    return isDevelopment || isStaging || isDebug;
  }

  /// Configurações de analytics
  static bool get enableAnalytics {
    return isProduction || isStaging;
  }

  /// Configurações de crash reporting
  static bool get enableCrashReporting {
    return isProduction || isStaging;
  }

  /// Timeout para requisições HTTP
  static Duration get httpTimeout {
    return isDevelopment ? const Duration(seconds: 30) : const Duration(seconds: 15);
  }

  /// Configurações de cache
  static Duration get cacheTimeout {
    return isDevelopment ? const Duration(minutes: 5) : const Duration(minutes: 30);
  }

  /// Configurações de localização
  static Duration get locationTimeout {
    return const Duration(seconds: 10);
  }

  /// Distância máxima para busca de restaurantes (em km)
  static double get maxSearchRadius {
    return 50.0;
  }

  /// Número máximo de restaurantes por página
  static int get restaurantsPerPage {
    return 20;
  }

  /// Configurações de mapa
  static double get defaultMapZoom {
    return 15.0;
  }

  /// Configurações de imagem
  static int get imageQuality {
    return isDevelopment ? 70 : 85;
  }

  /// Configurações de debug
  static bool get showDebugInfo {
    return isDevelopment && isDebug;
  }

  /// Configurações de performance
  static bool get enablePerformanceMonitoring {
    return isProduction || isStaging;
  }
}

/// Enum para os diferentes ambientes
enum AppEnvironment {
  development,
  staging,
  production,
}

/// Extensão para facilitar o uso do enum
extension AppEnvironmentExtension on AppEnvironment {
  String get name {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  String get shortName {
    switch (this) {
      case AppEnvironment.development:
        return 'dev';
      case AppEnvironment.staging:
        return 'staging';
      case AppEnvironment.production:
        return 'prod';
    }
  }

  bool get isProduction => this == AppEnvironment.production;
  bool get isDevelopment => this == AppEnvironment.development;
  bool get isStaging => this == AppEnvironment.staging;
}