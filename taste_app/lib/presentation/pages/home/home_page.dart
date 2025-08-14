import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página principal (Home) conforme referência visual
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3b83), // Nova cor de fundo solicitada
      body: SafeArea(
        child: Column(
          children: [
            // Logo centralizada no topo
            _buildLogoHeader(),
            
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Mapa
                    _buildMapSection(),
                    
                    // Seção "Descubra por clima, ocasião ou desejo"
                    _buildMoodSection(),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Logo
          Center(
            child: Image.asset(
              'assets/images/logo_tt2.png',
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          // Texto "Qual a sua vibe hoje?"
          const Text(
            'Qual a sua vibe hoje?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Botão laranja
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              'um ramen quentinho no Bom Fim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Texto pequeno abaixo do botão
          const Text(
            'Vou direto e só mando qual é bom.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  

  
  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.grey[200],
          child: Stack(
            children: [
              // Placeholder do mapa com ícones simulados
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                ),
                child: Stack(
                  children: [
                    // Simulação de ruas
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.grey[400],
                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.grey[400],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 80,
                      child: Container(
                        width: 2,
                        color: Colors.grey[400],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 60,
                      child: Container(
                        width: 2,
                        color: Colors.grey[400],
                      ),
                    ),
                    // Ícones de restaurantes
                    const Positioned(
                      top: 30,
                      left: 60,
                      child: Icon(
                        Icons.restaurant,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                    const Positioned(
                      top: 80,
                      right: 80,
                      child: Icon(
                        Icons.local_pizza,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                    const Positioned(
                      bottom: 40,
                      left: 100,
                      child: Icon(
                        Icons.fastfood,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                    const Positioned(
                      top: 60,
                      right: 40,
                      child: Icon(
                        Icons.coffee,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                    // Parques simulados
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.green[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Hyde Park',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  
  Widget _buildMoodSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2c3b83), // Nova cor de fundo solicitada
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descubra por clima,',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'ocasião ou desejo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4, // Mudança para 4 colunas
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.2, // Ajuste da proporção para 4 colunas menores
            children: [
              _buildMoodCard('Date night', const Color(0xFFFFA726), 'pizza'),
              _buildMoodCard('Para curar\na ressaca', const Color(0xFFFF7043), 'burger'),
              _buildMoodCard('Com vibe\nleve', const Color(0xFF42A5F5), 'healthy'),
              _buildMoodCard('Clássicos\nPOA', const Color(0xFF5C6BC0), 'pizza'),
              _buildMoodCard('Vontade\nde doce', const Color(0xFF9C27B0), 'dessert'),
              _buildMoodCard('Almoço\nde domingo', const Color(0xFFFFCA28), 'pizza'),
              _buildMoodCard('Happy hour\nde firma', const Color(0xFF26C6DA), 'burger'),
              _buildMoodCard('Para\ncomemorar\naniversário', const Color(0xFFFF5722), 'dessert'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodCard(String text, Color color, String categoryId) {
    return GestureDetector(
      onTap: () {
        context.go('/discovery?category=$categoryId');
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.crimsonText(
            textStyle: TextStyle(
              color: Color(0xFF2c3b83),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem('Descubra', true),
              _buildBottomNavItem('Mapa', false),
              _buildBottomNavItem('Perfil', false),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavItem(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomNavTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  void _onBottomNavTap(String label) {
    switch (label) {
      case 'Descubra':
        context.go('/discovery?category=todos');
        break;
      case 'Mapa':
        context.go('/search');
        break;
      case 'Perfil':
        context.go('/profile');
        break;
    }
  }
}