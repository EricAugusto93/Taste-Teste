import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'utils/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Valores padrão para configuração
  String supabaseUrl = 'https://gnosarnyuiyrbcdwkfto.supabase.co';
  String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ';
  
  // Tentar carregar variáveis de ambiente
  try {
    await dotenv.load(fileName: ".env");
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? supabaseUrl;
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseAnonKey;
    debugPrint('Arquivo .env carregado com sucesso');
  } catch (e) {
    debugPrint('Arquivo .env não encontrado, usando valores padrão');
  }
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: GastroApp()));
}

class GastroApp extends StatelessWidget {
  const GastroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taste Test - Gastro Experience',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
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
          ? const GastroHomeScreen() 
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
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Carregando...',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => const AuthScreen(),
    );
  }
} 