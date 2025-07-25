import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'config/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'utils/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar zona de erro global para capturar erros assíncronos
  runZonedGuarded(() async {
    // Configurar tratamento de erros do Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    await _initializeApp();
  }, (error, stackTrace) {
    _handleZoneError(error, stackTrace);
  });
}

/// Trata erros do Flutter de forma centralizada
void _handleFlutterError(FlutterErrorDetails details) {
  final errorString = details.exception.toString();
  final stackString = details.stack.toString();
  
  // Lista de erros conhecidos do Flutter Web que devem ser ignorados
  final webEngineErrors = [
    'PersistedOffset',
    'PersistedSurfaceState', 
    'js_primitives.dart',
    'ScrollController',
    '_ScrollPosition',
    'RenderObject',
    'RenderBox',
    '_PersistedSurface',
  ];
  
  bool isWebEngineError = webEngineErrors.any((error) => 
    errorString.contains(error) || stackString.contains(error)
  );
  
  if (isWebEngineError) {
    debugPrint('⚠️ Flutter Web Engine Error (ignorado): ${details.exception}');
    return;
  }
  
  debugPrint('🔴 Flutter Error: ${details.exception}');
  debugPrint('Stack trace: ${details.stack}');
  
  // Em debug mode, mostrar o erro normal para outros tipos de erro
  if (kDebugMode) {
    FlutterError.presentError(details);
  }
}

/// Trata erros de zona (assíncronos) de forma centralizada
void _handleZoneError(Object error, StackTrace stackTrace) {
  final errorString = error.toString();
  final stackString = stackTrace.toString();
  
  // Lista de erros conhecidos do Flutter Web que devem ser ignorados
  final webEngineErrors = [
    'PersistedOffset',
    'PersistedSurfaceState',
    'js_primitives.dart',
    'ScrollController',
    '_ScrollPosition',
  ];
  
  bool isWebEngineError = webEngineErrors.any((errorPattern) => 
    errorString.contains(errorPattern) || stackString.contains(errorPattern)
  );
  
  if (isWebEngineError) {
    debugPrint('⚠️ Zone Error (Flutter Web Engine - ignorado): $error');
    return;
  }
  
  debugPrint('🔴 Zone Error: $error');
  debugPrint('Stack trace: $stackTrace');
}

/// Inicializa o aplicativo
Future<void> _initializeApp() async {
  // Valores padrão para configuração
  String supabaseUrl = 'https://gnosarnyuiyrbcdwkfto.supabase.co';
  String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ';
  
  // Tentar carregar variáveis de ambiente (apenas se não for web)
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? supabaseUrl;
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseAnonKey;
      debugPrint('✅ Arquivo .env carregado com sucesso');
    } catch (e) {
      debugPrint('📁 Arquivo .env não encontrado, usando valores padrão do Supabase');
      debugPrint('💡 Para personalizar: crie um arquivo .env com SUPABASE_URL e SUPABASE_ANON_KEY');
    }
  } else {
    debugPrint('🌐 Executando na web, usando configurações padrão do Supabase');
    debugPrint('💡 Para web: configure as variáveis diretamente no código ou use build-time constants');
  }
  
  // Inicializar Supabase com configurações melhoradas
  try {
    print('🔧 [MAIN] Iniciando configuração do Supabase...');
    print('🔗 [MAIN] URL: $supabaseUrl');
    print('🔑 [MAIN] Anon Key: ${supabaseAnonKey.substring(0, 20)}...');
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: false, // Evita problemas com deeplinks
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    
    print('✅ [MAIN] Supabase.initialize() concluído');
    
    // Limpar possíveis estados de auth corrompidos
    try {
      print('🔍 [MAIN] Verificando sessão atual...');
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      
      if (session != null) {
        print('👤 [MAIN] Sessão encontrada, verificando validade...');
        // Verificar se a sessão é válida
        final isValid = session.accessToken.isNotEmpty && 
                       session.expiresAt != null && 
                       DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000).isAfter(DateTime.now());
        
        if (!isValid) {
          print('🔄 [MAIN] Sessão inválida detectada, fazendo logout...');
          await client.auth.signOut();
        } else {
          print('✅ [MAIN] Sessão válida encontrada');
        }
      } else {
        print('👤 [MAIN] Nenhuma sessão ativa encontrada');
      }
      
      // Testar conectividade básica
      print('🌐 [MAIN] Testando conectividade com Supabase...');
      final response = await client.from('restaurantes').select('id').limit(1);
      print('✅ [MAIN] Conectividade testada com sucesso: ${response.length} registros');
      
    } catch (authError) {
      print('⚠️ [MAIN] Erro ao verificar sessão/conectividade: $authError');
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {
        // Ignorar erro de cleanup
      }
    }
    
    print('✅ [MAIN] Supabase inicializado com sucesso');
  } catch (e) {
    print('❌ [MAIN] Erro ao inicializar Supabase: $e');
    print('🔍 [MAIN] Stack trace: ${StackTrace.current}');
    
    // Se falhar, tentar inicialização simplificada
    try {
      print('🔄 [MAIN] Tentando inicialização simplificada...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      print('✅ [MAIN] Supabase inicializado com configuração simplificada');
    } catch (fallbackError) {
      print('❌ [MAIN] Erro crítico na inicialização do Supabase: $fallbackError');
      print('🔍 [MAIN] Fallback stack trace: ${StackTrace.current}');
    }
  }

  runApp(
    ProviderScope(
      child: GastroApp(),
    ),
  );
}

class GastroApp extends StatelessWidget {
  const GastroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taste Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SafeAuthWrapper(),
      // Configurar error widget personalizado com tratamento para PersistedOffset
      builder: (context, widget) {
        // Proteger contra erros de renderização
        Widget error = const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Erro ao carregar aplicativo'),
              ],
            ),
          ),
        );

        if (widget is Scaffold || widget is Navigator) {
          error = Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.gradientFundo,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Recarregando...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        ErrorWidget.builder = (errorDetails) {
          // Filtrar erros do Flutter Web Engine
          final errorString = errorDetails.exception.toString();
          final stackString = errorDetails.stack.toString();
          
          if (errorString.contains('PersistedOffset') || 
              errorString.contains('PersistedSurfaceState') ||
              errorString.contains('js_primitives.dart') ||
              errorString.contains('ScrollController') ||
              errorString.contains('_ScrollPosition') ||
              stackString.contains('js_primitives.dart') ||
              stackString.contains('PersistedOffset')) {
            debugPrint('⚠️ Flutter Web Engine Error Widget (ignorado): ${errorDetails.exception}');
            // Retornar widget vazio ao invés de erro para PersistedOffset
            return const SizedBox.shrink();
          }
          return error;
        };
        
        return widget ?? error;
      },
    );
  }
}

// Wrapper seguro para evitar erros de autenticação
class SafeAuthWrapper extends ConsumerWidget {
  const SafeAuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (context) {
        try {
          return const AuthWrapper();
        } catch (e) {
          debugPrint('🔴 Erro no AuthWrapper: $e');
          // Retornar tela de erro segura
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.gradientFundo,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Problema de conectividade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tentando reconectar...',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Invalidar providers e tentar novamente
                        ref.invalidate(authStateProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mostarda,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (state) => state.session != null 
          ? const AuthenticatedApp() 
          : const AuthScreen(),
      loading: () => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.gradientFundo,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.mostarda),
                SizedBox(height: 20),
                Text(
                  'Inicializando...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.gradientFundo,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  'Erro de autenticação: $error',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Tentar recarregar
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticatedApp extends ConsumerWidget {
  const AuthenticatedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Validar estado de autenticação antes de inicializar favoritos
    return FutureBuilder<bool>(
      future: AuthService.validateAndFixAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.gradientFundo,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.mostarda),
                    SizedBox(height: 20),
                    Text(
                      'Validando sessão...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        // Se validação falhou, redirecionar para login
        if (snapshot.hasData && !snapshot.data!) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.invalidate(authStateProvider);
          });
          return const AuthScreen();
        }
        
        // Carregar favoritos do usuário autenticado
        ref.watch(carregarFavoritosProvider);
        
        return const GastroHomeScreen();
      },
    );
  }
}