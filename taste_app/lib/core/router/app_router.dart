import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/navigation_helper.dart';
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
import '../../data/services/auth_service.dart';
import '../services/deep_link_service.dart';
import '../config/environment_config.dart';
import '../guards/auth_guard.dart';
import 'navigation_service.dart';

/// Providers temporários para onboarding e auth
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  return await OnboardingService.isOnboardingCompleted();
});

final authStateProvider = Provider<AuthService>((ref) => AuthService.instance);

/// Provider do GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider).value ?? false;
  final authService = ref.watch(authStateProvider);

  final router = GoRouter(
    debugLogDiagnostics: EnvironmentConfig.isDevelopment,
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.uri.path;
      
      // Se está na splash, deixa continuar
      if (location == '/') {
        return null;
      }
      
      // Se não completou onboarding, redireciona
      if (!onboardingCompleted && location != '/onboarding') {
        return '/onboarding';
      }
      
      // Se completou onboarding, aplica AuthGuard
      if (onboardingCompleted) {
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
              final query = state.uri.queryParameters['q'] ?? '';
              return SearchPage(initialQuery: query);
            },
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          
          // Main route redirect
          GoRoute(
            path: '/main',
            name: 'main',
            builder: (context, state) => const HomePage(),
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
          
          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          

          
          // User Profile
          GoRoute(
            path: '/user/:userId',
            name: 'user_profile',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return UserProfilePage(userId: userId);
            },
          ),
          
          // Restaurant Menu
          GoRoute(
            path: '/restaurant/:id/menu',
            name: 'restaurant_menu',
            builder: (context, state) {
              final restaurantId = state.pathParameters['id']!;
              return RestaurantMenuPage(restaurantId: restaurantId);
            },
          ),
          
          // Restaurant Reviews
          GoRoute(
            path: '/restaurant/:id/reviews',
            name: 'restaurant_reviews',
            builder: (context, state) {
              final restaurantId = state.pathParameters['id']!;
              return RestaurantReviewsPage(restaurantId: restaurantId);
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

/// Configuração de rotas do aplicativo com go_router
class AppRouter {
  static GoRouter get router => throw UnimplementedError(
    'Use goRouterProvider instead of AppRouter.router'
  );
}

/// Páginas temporárias para as rotas que ainda não foram implementadas

class CategoryDetailsPage extends StatelessWidget {
  final String categoryId;
  
  const CategoryDetailsPage({super.key, required this.categoryId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categoria'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 64),
            const SizedBox(height: 16),
            Text('Categoria ID: $categoryId'),
            const SizedBox(height: 8),
            const Text('Página em desenvolvimento'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => NavigationHelper.safeGoBack(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}



// FavoritesPage agora é importada de favorites/favorites_page.dart

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64),
            SizedBox(height: 16),
            Text('Configurações do aplicativo'),
            SizedBox(height: 8),
            Text('Página em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  final String initialQuery;
  
  const SearchPage({super.key, required this.initialQuery});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64),
            const SizedBox(height: 16),
            if (initialQuery.isNotEmpty)
              Text('Buscando por: "$initialQuery"')
            else
              const Text('Buscar restaurantes'),
            const SizedBox(height: 8),
            const Text('Página em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}

class UserProfilePage extends StatelessWidget {
  final String userId;
  
  const UserProfilePage({super.key, required this.userId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64),
            const SizedBox(height: 16),
            Text('Usuário ID: $userId'),
            const SizedBox(height: 8),
            const Text('Página em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}

class RestaurantMenuPage extends StatelessWidget {
  final String restaurantId;
  
  const RestaurantMenuPage({super.key, required this.restaurantId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 64),
            const SizedBox(height: 16),
            Text('Menu do Restaurante: $restaurantId'),
            const SizedBox(height: 8),
            const Text('Página em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}

class RestaurantReviewsPage extends StatelessWidget {
  final String restaurantId;
  
  const RestaurantReviewsPage({super.key, required this.restaurantId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Avaliações do Restaurante: $restaurantId'),
            const SizedBox(height: 8),
            const Text('Página em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}


