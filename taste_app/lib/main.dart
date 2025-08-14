import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    // Inicializar Hive
    await Hive.initFlutter();
    
    // Registrar adapters do Hive
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CacheItemAdapter());
    }
    
    // Inicializar configurações de ambiente
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
    await InjectionContainer.get<CacheService>().initialize();
    
    // Log de debug apenas em desenvolvimento
    if (EnvironmentConfig.isDevelopment) {
      debugPrint('🚀 Taste App iniciado em modo ${EnvironmentConfig.currentEnvironment.name}');
      debugPrint('📊 Configurações: ${EnvironmentConfig.getDebugInfo()}');
    }
    
    runApp(const ProviderScope(child: TasteApp()));
  } catch (e) {
    // Em caso de erro na inicialização, ainda executa o app
    debugPrint('❌ Erro na inicialização: $e');
    runApp(const ProviderScope(child: TasteApp()));
  }
}

class TasteApp extends ConsumerWidget {
  const TasteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}