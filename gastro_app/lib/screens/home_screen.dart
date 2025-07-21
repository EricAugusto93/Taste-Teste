import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../utils/providers.dart';
import '../config/app_theme.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF2c3985)),
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
    return Scaffold(
      backgroundColor: const Color(0xFFfbe9d2), // Fundo areia clara
      body: Center(
        child: Container(
          width: 400, // Largura fixa como mobile
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              // Header superior
              _buildMobileHeader(),
              
              // Conteúdo rolável
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Banner Demo Funcional
                        _buildMobileDemoBanner(),
                        
                        const SizedBox(height: 20),
                        
                        // Barra de busca
                        _buildMobileSearchBar(),
                        
                        const SizedBox(height: 20),
                        
                        // Botões rápidos
                        _buildMobileQuickButtons(),
                        
                        const SizedBox(height: 24),
                        
                        // Seção Explore por Categorias
                        _buildMobileCategoriesSection(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFee9d21), Color(0xFFfbe9d2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // Logo e nome
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFF2c3985),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Gastro App',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3985),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Subtítulo
              const Text(
                'Powered by AI • Demonstração Interativa',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDemoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D1), // Amarelo claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFee9d21).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text(
            '🧪',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Funcional',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3985),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Esta é uma demonstração das funcionalidades implementadas. Digite uma busca natural ou clique nas categorias!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Ex: comida vegana barata...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFee9d21),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
              size: 16,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileQuickButtons() {
    final buttons = [
      {
        'icon': Icons.near_me,
        'label': 'Próximos',
        'color': const Color(0xFFEF4444),
        'action': 'proximidade',
      },
      {
        'icon': Icons.favorite,
        'label': 'Favoritos',
        'color': const Color(0xFFEF4444),
        'action': 'favoritos',
      },
      {
        'icon': Icons.star,
        'label': 'Experiências',
        'color': const Color(0xFF8B5CF6),
        'action': 'experiencias',
      },
      {
        'icon': Icons.explore,
        'label': 'Explorar',
        'color': const Color(0xFF3B82F6),
        'action': 'explorar',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.0,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final button = buttons[index];
        return _buildMobileQuickButton(
          icon: button['icon'] as IconData,
          label: button['label'] as String,
          color: button['color'] as Color,
          action: button['action'] as String,
        );
      },
    );
  }

  Widget _buildMobileQuickButton({
    required IconData icon,
    required String label,
    required Color color,
    required String action,
  }) {
    return GestureDetector(
      onTap: () => _handleProtectedAction(action),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE9ECEF),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _handleProtectedAction(action),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2c3985),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Text(
                '📖',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 8),
              Text(
                'Explore por Categorias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3985),
                ),
              ),
            ],
          ),
        ),
        
        // Grid de categorias
        _buildMobileCategoriesGrid(),
      ],
    );
  }

  Widget _buildMobileCategoriesGrid() {
    final categories = [
      {'emoji': '💕', 'label': 'Jantar Romântico'},
      {'emoji': '☕', 'label': 'Cafés Tranquilos'},
      {'emoji': '🏛️', 'label': 'Clássicos da Cidade'},
      {'emoji': '🍔', 'label': 'Mata-Fome'},
      {'emoji': '🍰', 'label': 'Doces & Sobremesas'},
      {'emoji': '🥐', 'label': 'Brunch Domingo'},
      {'emoji': '🍹', 'label': 'Para Beber'},
      {'emoji': '🐕', 'label': 'Pet Friendly'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildMobileCategoryCard(
          emoji: category['emoji'] as String,
          label: category['label'] as String,
        );
      },
    );
  }

  Widget _buildMobileCategoryCard({
    required String emoji,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria "$label" em breve!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE9ECEF),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Categoria "$label" em breve!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2c3985),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 