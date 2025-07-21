import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../utils/providers.dart';
import '../config/app_theme.dart';
import '../widgets/taste_test_logo.dart';
import 'favoritos_screen.dart';
import 'experiencias_screen.dart';
import 'proximidade_screen.dart';

class GastroHomeScreen extends ConsumerStatefulWidget {
  const GastroHomeScreen({super.key});

  @override
  ConsumerState<GastroHomeScreen> createState() => _GastroHomeScreenState();
}

class _GastroHomeScreenState extends ConsumerState<GastroHomeScreen> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        ),
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final success = await AuthService.signOut();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logout realizado com sucesso'),
            backgroundColor: AppTheme.customColors['success'],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
            ),
          ),
        );
      }
    }
  }

  void _handleProtectedAction(String action) {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    
    if (!isAuthenticated) {
      _showAuthRequiredDialog(action);
      return;
    }
    
    switch (action) {
      case 'favoritos':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const FavoritosScreen()),
        );
        break;
      case 'experiencias':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienciasScreen()),
        );
        break;
      case 'proximidade':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProximidadeScreen()),
        );
        break;
    }
  }

  void _showAuthRequiredDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Login necessário'),
          ],
        ),
        content: Text('Para ${_getActionDescription(action)}, você precisa estar logado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Sair forçado para mostrar tela de login
              AuthService.signOut();
            },
            child: const Text('Fazer Login'),
          ),
        ],
      ),
    );
  }

  String _getActionDescription(String action) {
    switch (action) {
      case 'favoritos':
        return 'ver seus favoritos';
      case 'experiencias':
        return 'ver suas experiências';
      case 'proximidade':
        return 'descobrir restaurantes próximos';
      default:
        return 'usar esta funcionalidade';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gradientFundo,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Header Clean
                    _buildCleanHeader(user),
                    
                    const SizedBox(height: 32),
                    
                    // Banner Demo (como na segunda imagem)
                    _buildDemoBanner(),
                    
                    const SizedBox(height: 32),
                    
                    // Busca por IA
                    _buildSearchSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Grid de Navegação (2 colunas)
                    _buildNavigationGrid(),
                    
                    const SizedBox(height: 32),
                    
                    // Grid de Categorias Clean (2 colunas)
                    _buildCleanCategoriesGrid(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: AppTheme.sombraCard,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Menu Button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.azulSuave,
              borderRadius: BorderRadius.circular(AppTheme.radiusPequeno),
            ),
            child: IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu_rounded, color: AppTheme.primary),
              iconSize: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Logo
          TasteTestLogo.medium(showSubtitle: false),
          
          const Spacer(),
          
          // User Avatar/Menu
          GestureDetector(
            onTap: _handleLogout,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimario,
                borderRadius: BorderRadius.circular(AppTheme.radiusPequeno),
                boxShadow: AppTheme.sombraCard,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user?.email?.split('@').first ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.expand_more,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary.withOpacity(0.1),
            AppTheme.mostardaSuave,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusPequeno),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🧪 Demo Funcional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Esta é uma demonstração das funcionalidades implementadas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.cinzaMedio,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        boxShadow: AppTheme.sombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🤖 Busca Inteligente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Ex: comida vegana barata...',
              hintStyle: TextStyle(
                color: AppTheme.cinzaMedio.withOpacity(0.7),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid() {
    final navigationItems = [
      {'icon': Icons.near_me_rounded, 'title': 'Próximos', 'action': 'proximidade', 'color': Colors.blue},
      {'icon': Icons.favorite_rounded, 'title': 'Favoritos', 'action': 'favoritos', 'color': Colors.red},
      {'icon': Icons.star_rounded, 'title': 'Experiências', 'action': 'experiencias', 'color': Colors.purple},
      {'icon': Icons.explore_rounded, 'title': 'Explorar', 'action': 'explorar', 'color': Colors.green},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        return _buildNavigationCard(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          color: item['color'] as Color,
          onTap: () => _handleProtectedAction(item['action'] as String),
        );
      },
    );
  }

  Widget _buildNavigationCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
          boxShadow: AppTheme.sombraCard,
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusPequeno),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanCategoriesGrid() {
    final categories = [
      {'icon': '💕', 'title': 'Jantar Romântico'},
      {'icon': '☕', 'title': 'Cafés Tranquilos'},
      {'icon': '🏛️', 'title': 'Clássicos da Cidade'},
      {'icon': '🍔', 'title': 'Mata-Fome'},
      {'icon': '🍰', 'title': 'Doces & Sobremesas'},
      {'icon': '🥐', 'title': 'Brunch Domingo'},
      {'icon': '🍹', 'title': 'Para Beber'},
      {'icon': '🐕', 'title': 'Pet Friendly'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            '🏷️ Explore por Categorias',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(
              emoji: category['icon'] as String,
              title: category['title'] as String,
              onTap: () {
                // TODO: Implementar navegação para categoria
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String emoji,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
          boxShadow: AppTheme.sombraCard,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 