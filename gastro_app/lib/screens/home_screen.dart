import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../utils/providers.dart';
import '../services/localizacao_service.dart';
import '../widgets/taste_test_logo.dart';
import 'favoritos_screen.dart';
import 'experiencias_screen.dart';
import 'proximidade_screen.dart';

class GastroHomeScreen extends ConsumerStatefulWidget {
  const GastroHomeScreen({super.key});

  @override
  ConsumerState<GastroHomeScreen> createState() => _GastroHomeScreenState();
}

class _GastroHomeScreenState extends ConsumerState<GastroHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    // Mostrar dialog de confirmação
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
          const SnackBar(
            content: Text('Logout realizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToFavoritos() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FavoritosScreen(),
      ),
    );
  }

  void _navigateToProximidade() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProximidadeScreen(),
      ),
    );
  }

  void _handleProtectedAction(String action) {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    
    if (!isAuthenticated) {
      _showAuthRequiredDialog(action);
      return;
    }
    
    switch (action) {
      case 'favoritos':
        _navigateToFavoritos();
        break;
      case 'experiencias':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienciasScreen()),
        );
        break;
      case 'proximidade':
        _navigateToProximidade();
        break;
    }
  }

  void _showAuthRequiredDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: const Color(0xFF2c3985),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Login necessário'),
          ],
        ),
        content: Text(
          'Para ${_getActionName(action)}, você precisa estar logado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navegar para tela de login ou mostrar modal
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2c3985),
              foregroundColor: Colors.white,
            ),
            child: const Text('Fazer Login'),
          ),
        ],
      ),
    );
  }

  String _getActionName(String action) {
    switch (action) {
      case 'favoritos':
        return 'acessar seus favoritos';
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
      backgroundColor: const Color(0xFFfbe9d2), // Cor de fundo areia clara
      drawer: _buildDrawer(user),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Categoria Cards
              _buildCategorySection(),

              // Botões de Navegação
              _buildNavigationButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(user) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header do drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2c3985), Color(0xFF1e2a5f)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Nome do usuário
                  Text(
                    user?.userMetadata?['name'] ?? user?.email?.split('@').first ?? 'Usuário',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Email
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Items do menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Início',
                  onTap: () => Navigator.of(context).pop(),
                ),
                _buildDrawerItem(
                  icon: Icons.favorite,
                  title: 'Favoritos',
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleProtectedAction('favoritos');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.star,
                  title: 'Minhas Experiências',
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleProtectedAction('experiencias');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Perfil',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar para perfil
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Configurações',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar para configurações
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.help,
                  title: 'Ajuda',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar para ajuda
                  },
                ),
              ],
            ),
          ),
          
          // Botão de logout
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF2c3985),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2c3985),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2c3985), Color(0xFF1e2a5f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Menu button
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 8),
              // Logo Taste Test
              TasteTestLogo.medium(
                showSubtitle: false,
                primaryColor: Colors.white,
                secondaryColor: const Color(0xFFee9d21),
              ),
              const Spacer(),
              // Notification button
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ex: pizza romântica para dois...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2c3985)),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFee9d21),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🍽️ Explore por Categorias',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3985),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildCategoryCard('💕', 'Jantar Romântico', 'Momentos especiais'),
              _buildCategoryCard('☕', 'Cafés Tranquilos', 'Relaxe e aproveite'),
              _buildCategoryCard('🍕', 'Clássicos da Cidade', 'Tradição e sabor'),
              _buildCategoryCard('🍔', 'Mata-Fome', 'Rápido e saboroso'),
              _buildCategoryCard('🧁', 'Doces & Sobremesas', 'Delícias açucaradas'),
              _buildCategoryCard('🥂', 'Brunch Domingo', 'Fim de semana perfeito'),
              _buildCategoryCard('🍷', 'Para Beber', 'Drinks e petiscos'),
              _buildCategoryCard('🐕', 'Pet Friendly', 'Traga seu amiguinho'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3985),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildNavButton(
                  '🗺️',
                  'Descobrir por\nProximidade',
                  const Color(0xFF4CAF50),
                  () => _navigateToProximidade(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNavButton(
                  '❤️',
                  'Meus\nFavoritos',
                  const Color(0xFFE91E63),
                  () => _handleProtectedAction('favoritos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNavButton(
                  '⭐',
                  'Minhas\nExperiências',
                  const Color(0xFFFF9800),
                  () => _handleProtectedAction('experiencias'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNavButton(
                  '🔍',
                  'Buscar\nRestaurantes',
                  const Color(0xFF2196F3),
                  () {
                    // TODO: Implementar busca inteligente
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Busca inteligente em breve!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String emoji, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 