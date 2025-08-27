import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'core/config/app_config.dart';
import 'core/config/environment_config.dart';
import 'core/config/google_maps_config.dart';
import 'core/router/app_router.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/cache_service.dart';
import 'core/models/cache_item.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Configurar URL strategy para Web (evita # e facilita refresh/roteamento)
    if (kIsWeb) {
      setPathUrlStrategy();
    }

    // Inicializar todas as dependências críticas de uma vez
    await _initializeApp();
    
    runApp(const ProviderScope(child: TasteApp()));
  } catch (e) {
    // Em caso de erro na inicialização, ainda executa o app
    debugPrint('❌ Erro na inicialização: $e');
    runApp(const ProviderScope(child: TasteApp()));
  }
}

/// Inicializa todas as dependências críticas do app
Future<void> _initializeApp() async {
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adapters do Hive
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CacheItemAdapter());
  }
  
  // Inicializar configurações de ambiente (apenas uma vez)
  await EnvironmentConfig.initialize();
  
  // Inicializar Google Maps
  await GoogleMapsConfig.initialize();
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar deep links
  await DeepLinkService.instance.initialize();
  
  // Inicializar injeção de dependência
  await InjectionContainer.init();
  
  // Inicializar cache service
  await getIt<CacheService>().initialize();
  
  // Inicializar router notifier
  await RouterNotifier.instance.initialize();
  
  // Log de debug apenas em desenvolvimento
  if (EnvironmentConfig.isDevelopment) {
    debugPrint('🚀 Taste App inicializado completamente em modo ${EnvironmentConfig.currentEnvironment.name}');
  }
}

class TasteApp extends ConsumerWidget {
  const TasteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Renderizar app diretamente - todas as dependências foram inicializadas no main()
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}