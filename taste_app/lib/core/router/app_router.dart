import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/restaurant/restaurant_details_page.dart';
import '../../presentation/pages/category/category_page.dart';
import '../../presentation/pages/map/map_page.dart';
import '../../presentation/pages/discovery/discovery_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/profile/want_to_know_page.dart';
import '../../presentation/pages/profile/not_sure_return_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/auth/edit_profile_page.dart';
import '../../data/services/onboarding_service.dart';
import '../config/environment_config.dart';
import '../guards/auth_guard.dart';
import 'navigation_service.dart';

/// Notifier para gerenciar o estado do router sem recriá-lo
class RouterNotifier extends ChangeNotifier {
  static final RouterNotifier _instance = RouterNotifier._internal();
  static RouterNotifier get instance => _instance;
  RouterNotifier._internal();

  bool _onboardingCompleted = false;
  bool _isInitialized = false;

  bool get onboardingCompleted => _onboardingCompleted;
  bool get isInitialized => _isInitialized;

  /// Inicializa o router notifier de forma síncrona
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Inicialização síncrona para evitar condição de corrida
      _onboardingCompleted = await OnboardingService.isOnboardingCompleted();
      _isInitialized = true;
      debugPrint('🔀 RouterNotifier inicializado - onboarding: $_onboardingCompleted');
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Erro ao inicializar RouterNotifier: $e - usando padrões');
      _onboardingCompleted = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Atualiza o estado do onboarding
  void updateOnboarding(bool completed) {
    if (_onboardingCompleted != completed) {
      _onboardingCompleted = completed;
      debugPrint('🔀 RouterNotifier: onboarding atualizado para: $completed');
      notifyListeners();
    }
  }
}

/// Provider do GoRouter (criado apenas uma vez)
final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier.instance;
  
  final router = GoRouter(
    debugLogDiagnostics: EnvironmentConfig.isDevelopment,
    initialLocation: '/',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final location = state.uri.path;
      
      // Se está na splash, deixa continuar
      if (location == '/') {
        return null;
      }
      
      // Se o router notifier não foi inicializado, força splash
      if (!routerNotifier.isInitialized) {
        return '/';
      }
      
      // Se não completou onboarding, redireciona
      if (!routerNotifier.onboardingCompleted && location != '/onboarding') {
        return '/onboarding';
      }
      
      // Se completou onboarding, aplica AuthGuard
      if (routerNotifier.onboardingCompleted) {
        return AuthGuard.redirect(context, state);
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Authentication Routes (outside shell to avoid bottom navigation)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      GoRoute(
        path: '/edit-profile',
        name: 'edit_profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      
      // Main Navigation (Shell Route para manter bottom navigation)
      ShellRoute(
        builder: (context, state, child) => MainNavigationPage(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          
          // Search
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'];
              return SearchPage(initialQuery: query);
            },
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          
          
          // Restaurant Details
          GoRoute(
            path: '/restaurant/:id',
            name: 'restaurant_details',
            builder: (context, state) {
              final restaurantId = state.pathParameters['id']!;
              return RestaurantDetailsPage(
                restaurantId: restaurantId,
              );
            },
          ),
          
          // Category Details
          GoRoute(
            path: '/category/:id',
            name: 'category_details',
            builder: (context, state) {
              final categoryId = state.pathParameters['id']!;
              final categoryName = state.uri.queryParameters['name'];
              return CategoryPage(
                categoryId: categoryId,
                categoryName: categoryName,
              );
            },
          ),
          
          // Map View
          GoRoute(
            path: '/map',
            name: 'map_view',
            builder: (context, state) {
              final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '');
              final lng = double.tryParse(state.uri.queryParameters['lng'] ?? '');
              return MapPage(initialLat: lat, initialLng: lng);
            },
          ),
          
          // Favorites
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          
          // Want to Know
          GoRoute(
            path: '/want-to-know',
            name: 'want_to_know',
            builder: (context, state) => const WantToKnowPage(),
          ),
          
          // Not Sure Return
          GoRoute(
            path: '/not-sure-return',
            name: 'not_sure_return',
            builder: (context, state) => const NotSureReturnPage(),
          ),
          
          
          // Discovery - Suporte unificado para path parameter e query parameter
          GoRoute(
            path: '/discovery/:categoryId',
            name: 'discovery',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              return DiscoveryPage(categoryId: categoryId);
            },
          ),

          // Discovery - Rota base que redireciona para categoria padrão ou específica
          GoRoute(
            path: '/discovery',
            name: 'discovery_base',
            redirect: (context, state) {
              final categoryId = state.uri.queryParameters['category'] ?? 'todos';
              return '/discovery/$categoryId';
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'A página que você está procurando não existe.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );

  
  // Configurar o NavigationService com este router
  NavigationService.instance.setRouter(router);
  
  return router;
});




