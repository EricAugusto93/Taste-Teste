import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;
  static bool _isInitialized = false;
  static bool _hasBeenInitialized = false; // Flag para prevenir reinicializações

  static Environment get currentEnvironment => _currentEnvironment;
  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isInitialized => _isInitialized;

  /// Inicializa a configuração do ambiente
  static Future<void> initialize({Environment? environment}) async {
    // Previne múltiplas inicializações
    if (_hasBeenInitialized) {
      debugPrint('⚠️ EnvironmentConfig já foi inicializado, pulando...');
      return;
    }
    
    _hasBeenInitialized = true;
    
    // Determina o ambiente baseado no modo de build se não especificado
    _currentEnvironment = environment ?? _getEnvironmentFromBuildMode();
    
    // Carrega o arquivo .env apropriado
    await _loadEnvironmentFile();
    
    _isInitialized = true;
  }

  /// Determina o ambiente baseado no modo de build do Flutter
  static Environment _getEnvironmentFromBuildMode() {
    if (kReleaseMode) {
      return Environment.production;
    } else if (kProfileMode) {
      return Environment.staging;
    } else {
      return Environment.development;
    }
  }

  /// Carrega o arquivo de ambiente apropriado
  static Future<void> _loadEnvironmentFile() async {
    // Lista de arquivos de ambiente por prioridade
    List<String> envFiles;
    
    switch (_currentEnvironment) {
      case Environment.development:
        // Para web, não tentar carregar .env.local pois não existe
        envFiles = kIsWeb ? ['.env.development', '.env'] : ['.env.local', '.env.development', '.env'];
        break;
      case Environment.staging:
        envFiles = kIsWeb ? ['.env.staging', '.env'] : ['.env.local', '.env.staging', '.env'];
        break;
      case Environment.production:
        envFiles = ['.env.production', '.env'];
        break;
    }

    // Tenta carregar na ordem de prioridade
    for (String envFile in envFiles) {
      try {
        await dotenv.load(fileName: envFile);
        if (kDebugMode) {
          debugPrint('✅ Arquivo de ambiente carregado: $envFile');
        }
        return; // Sucesso, para a busca
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Não foi possível carregar $envFile: $e');
        }
        continue; // Tenta o próximo arquivo
      }
    }
    
    // Se chegou aqui, nenhum arquivo foi carregado
    if (kDebugMode) {
      debugPrint('❌ Nenhum arquivo de ambiente encontrado');
    }
  }

  // Getters para configurações específicas
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '15000') ?? 15000;
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';
  
  // Feature Flags
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  static bool get enableCrashReporting => dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';
  static bool get enablePerformanceMonitoring => dotenv.env['ENABLE_PERFORMANCE_MONITORING']?.toLowerCase() == 'true';
  
  // Cache Configuration
  static int get cacheDurationMinutes => int.tryParse(dotenv.env['CACHE_DURATION_MINUTES'] ?? '15') ?? 15;
  static int get maxCacheSizeMB => int.tryParse(dotenv.env['MAX_CACHE_SIZE_MB'] ?? '100') ?? 100;
  
  // Location Settings
  static String get locationAccuracy => dotenv.env['LOCATION_ACCURACY'] ?? 'balanced';
  static int get maxLocationAgeMinutes => int.tryParse(dotenv.env['MAX_LOCATION_AGE_MINUTES'] ?? '10') ?? 10;

  /// Método para debug - mostra configurações atuais (apenas em desenvolvimento)
  static Map<String, dynamic> getDebugInfo() {
    if (!isDevelopment) return {};
    
    return {
      'environment': _currentEnvironment.name,
      'debugMode': debugMode,
      'apiTimeout': apiTimeout,
      'logLevel': logLevel,
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'cacheDurationMinutes': cacheDurationMinutes,
      'maxCacheSizeMB': maxCacheSizeMB,
      'locationAccuracy': locationAccuracy,
      'maxLocationAgeMinutes': maxLocationAgeMinutes,
    };
  }
}