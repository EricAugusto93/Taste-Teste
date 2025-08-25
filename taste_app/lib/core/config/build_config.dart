import 'package:flutter/foundation.dart';

/// Configurações de build para diferentes ambientes
class BuildConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static const bool _isDebug = bool.fromEnvironment(
    'DEBUG',
    defaultValue: true,
  );
  
  /// Ambiente atual (development, staging, production)
  static String get environment => _environment;
  
  /// Se está em modo debug
  static bool get isDebug => _isDebug;
  
  /// Se está em modo release
  static bool get isRelease => !_isDebug;
  
  /// Se está em desenvolvimento
  static bool get isDevelopment => _environment == 'development';
  
  /// Se está em staging
  static bool get isStaging => _environment == 'staging';
  
  /// Se está em produção
  static bool get isProduction => _environment == 'production';
  
  /// URL base da API baseada no ambiente
  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://dev-api.taste.com';
      case 'staging':
        return 'https://staging-api.taste.com';
      case 'production':
        return 'https://api.taste.com';
      default:
        return 'https://dev-api.taste.com';
    }
  }
  
  /// Configurações de logging baseadas no ambiente
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
  
  /// Timeout para requests HTTP
  static Duration get httpTimeout {
    if (isDevelopment) {
      return const Duration(seconds: 30);
    }
    return const Duration(seconds: 15);
  }
  
  /// Configurações de cache
  static Duration get cacheTimeout {
    if (isDevelopment) {
      return const Duration(minutes: 5);
    }
    return const Duration(hours: 1);
  }
  
  /// Nome do app baseado no ambiente
  static String get appName {
    switch (_environment) {
      case 'development':
        return 'Taste Dev';
      case 'staging':
        return 'Taste Staging';
      case 'production':
        return 'Taste';
      default:
        return 'Taste Dev';
    }
  }
  
  /// Sufixo do package ID
  static String get packageSuffix {
    switch (_environment) {
      case 'development':
        return '.dev';
      case 'staging':
        return '.staging';
      case 'production':
        return '';
      default:
        return '.dev';
    }
  }
  
  /// Configurações de debug específicas
  static Map<String, dynamic> get debugConfig {
    return {
      'showPerformanceOverlay': isDebug && isDevelopment,
      'showSemanticsDebugger': false,
      'debugShowCheckedModeBanner': isDebug,
      'enableInspector': isDebug,
    };
  }
  
  /// Informações do build
  static Map<String, String> get buildInfo {
    return {
      'environment': environment,
      'buildMode': isDebug ? 'debug' : 'release',
      'appName': appName,
      'apiBaseUrl': apiBaseUrl,
    };
  }
  
  /// Imprime informações do build no console
  static void printBuildInfo() {
    if (enableLogging) {
      debugPrint('🏗️ Build Configuration:');
      debugPrint('   Environment: $environment');
      debugPrint('   Build Mode: ${isDebug ? 'Debug' : 'Release'}');
      debugPrint('   App Name: $appName');
      debugPrint('   API URL: $apiBaseUrl');
      debugPrint('   Logging: $enableLogging');
      debugPrint('   Analytics: $enableAnalytics');
      debugPrint('   Crash Reporting: $enableCrashReporting');
    }
  }
}

/// Enum para ambientes
enum Environment {
  development,
  staging,
  production;
  
  static Environment fromString(String value) {
    switch (value.toLowerCase()) {
      case 'development':
      case 'dev':
        return Environment.development;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'production':
      case 'prod':
        return Environment.production;
      default:
        return Environment.development;
    }
  }
}

/// Configurações específicas por flavor
class FlavorConfig {
  final Environment environment;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableAnalytics;
  
  const FlavorConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableAnalytics,
  });
  
  static const development = FlavorConfig(
    environment: Environment.development,
    appName: 'Taste Dev',
    apiBaseUrl: 'https://dev-api.taste.com',
    enableLogging: true,
    enableAnalytics: false,
  );
  
  static const staging = FlavorConfig(
    environment: Environment.staging,
    appName: 'Taste Staging',
    apiBaseUrl: 'https://staging-api.taste.com',
    enableLogging: true,
    enableAnalytics: true,
  );
  
  static const production = FlavorConfig(
    environment: Environment.production,
    appName: 'Taste',
    apiBaseUrl: 'https://api.taste.com',
    enableLogging: false,
    enableAnalytics: true,
  );
  
  static FlavorConfig get current {
    final env = Environment.fromString(BuildConfig.environment);
    switch (env) {
      case Environment.development:
        return development;
      case Environment.staging:
        return staging;
      case Environment.production:
        return production;
    }
  }
}