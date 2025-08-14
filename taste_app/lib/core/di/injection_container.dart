import 'package:get_it/get_it.dart';
import '../../data/services/location_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/onboarding_service.dart';
import '../../data/services/search_service.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/datasources/restaurant_remote_datasource.dart';
import '../services/cache_service.dart';

/// Container de injeção de dependência usando GetIt
final GetIt getIt = GetIt.instance;

/// Configuração de todas as dependências do aplicativo
class InjectionContainer {
  /// Inicializa todas as dependências
  static Future<void> init() async {
    // ============================================================================
    // SERVICES (Singletons)
    // ============================================================================
    
    // Location Service
    getIt.registerLazySingleton<LocationService>(
      () => LocationService.instance,
    );
    
    // Auth Service
    getIt.registerLazySingleton<AuthService>(
      () => AuthService.instance,
    );
    
    // Connectivity Service
    getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService.instance,
    );
    
    // Onboarding Service
    getIt.registerLazySingleton<OnboardingService>(
      () => OnboardingService(),
    );
    
    // Search Service
    getIt.registerLazySingleton<SearchService>(
      () => SearchService.instance,
    );
    
    // Cache Service
    getIt.registerLazySingleton<CacheService>(
      () => CacheService(),
    );
    
    // ============================================================================
    // DATA SOURCES
    // ============================================================================
    
    // Remote Data Sources
    getIt.registerLazySingleton<RestaurantRemoteDataSource>(
      () => RestaurantRemoteDataSourceImpl(),
    );
    
    // ============================================================================
    // REPOSITORIES
    // ============================================================================
    
    // Location Repository
    getIt.registerLazySingleton<LocationRepository>(
      () => LocationRepository.instance,
    );
    
    // Search Repository
    getIt.registerLazySingleton<SearchRepository>(
       () => SearchRepositoryImpl(
         getIt<SearchService>(),
         locationService: getIt<LocationService>(),
       ),
     );
    
    // Restaurant Repository
      getIt.registerLazySingleton<RestaurantRepository>(
        () => RestaurantRepository(),
      );
  }
  
  /// Limpa todas as dependências registradas
  static Future<void> reset() async {
    await getIt.reset();
  }
  
  /// Verifica se uma dependência está registrada
  static bool isRegistered<T extends Object>() {
    return getIt.isRegistered<T>();
  }
  
  /// Obtém uma instância de uma dependência
  static T get<T extends Object>() {
    return getIt.get<T>();
  }
  
  /// Registra uma dependência manualmente (para testes)
  static void registerTestDependency<T extends Object>(T instance) {
    if (getIt.isRegistered<T>()) {
      getIt.unregister<T>();
    }
    getIt.registerSingleton<T>(instance);
  }
  
  /// Remove uma dependência específica
  static Future<void> unregister<T extends Object>() async {
    if (getIt.isRegistered<T>()) {
      await getIt.unregister<T>();
    }
  }
}

/// Extension para facilitar o acesso às dependências
extension GetItExtension on GetIt {
  /// Obtém o LocationRepository
  LocationRepository get locationRepository => get<LocationRepository>();
  
  /// Obtém o RestaurantRepository
  RestaurantRepository get restaurantRepository => get<RestaurantRepository>();
  

  
  /// Obtém o LocationService
  LocationService get locationService => get<LocationService>();
  
  /// Obtém o AuthService
  AuthService get authService => get<AuthService>();
  
  /// Obtém o ConnectivityService
  ConnectivityService get connectivityService => get<ConnectivityService>();
  
  /// Obtém o OnboardingService
  OnboardingService get onboardingService => get<OnboardingService>();
  
  /// Obtém o SearchService
  SearchService get searchService => get<SearchService>();
  
  /// Obtém o CacheService
  CacheService get cacheService => get<CacheService>();
}