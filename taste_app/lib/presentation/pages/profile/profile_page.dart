import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/navigation_helper.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart' as custom;
import '../../widgets/auth_button.dart';

/// Página de perfil conforme referência visual
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Carrega o perfil quando a página é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadCurrentUserProfile();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(userProfileProvider);
    final isLoading = profileState.isLoading;
    final error = profileState.error;

    // Se não estiver autenticado, mostra tela de login
    if (!authState.isAuthenticated) {
      return _buildGuestProfile();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF4A5FBF), // Fundo azul da referência
      body: SafeArea(
        child: isLoading && profileState.profile == null
            ? const LoadingWidget()
            : error != null
                ? custom.CustomErrorWidget.general(
                    message: error,
                    onRetry: () {
                      ref.read(userProfileProvider.notifier).loadCurrentUserProfile();
                    },
                  )
                : _buildProfileContent(profileState.profile, authState.user),
      ),
    );
  }

  /// Tela para usuários não autenticados
  Widget _buildGuestProfile() {
    return Scaffold(
      backgroundColor: const Color(0xFF4A5FBF), // Fundo azul da referência
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Acesse sua conta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Faça login para acessar seu perfil, favoritos e muito mais',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              AuthButton(
                text: 'Fazer Login',
                onPressed: () {
                  context.push('/login');
                },
                isLoading: false,
              ),
              const SizedBox(height: 16),
              AuthTextButton(
                text: 'Criar conta',
                onPressed: () {
                  context.push('/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Layout da página de perfil conforme referência visual
  Widget _buildProfileContent(profile, user) {
    final displayName = profile?.fullName ?? 
                       user?.userMetadata?['full_name'] ?? 
                       user?.userMetadata?['display_name'] ??
                       'Luisa';
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF4A5FBF), // Fundo azul da referência
      ),
      child: Stack(
        children: [
          // Ondas decorativas no fundo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5DC), // Cor bege das ondas
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          
          // Botão de voltar no canto superior esquerdo - área clicável expandida
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                NavigationHelper.safeGoBack(context);
              },
              child: Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          // Botão de logout no canto superior direito
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _handleLogout,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
          
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80), // Aumentado para dar espaço aos botões
                
                // Saudação personalizada
                Text(
                  'Olá, $displayName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Texto explicativo
                const Text(
                  'Aqui ficam os seus lugares favoritos, experiências salvas e descobertas que você quer viver.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Organize do seu jeito e volte quando quiser — o Taste Test guarda tudo pra você. ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Seção "Minhas listas"
                const Text(
                  'Minhas listas:',
                  style: TextStyle(
                    color: Color(0xFFFFB366), // Cor laranja da referência
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Lista de opções com espaçamento ajustado
                Expanded(
                  child: Column(
                    children: [
                      _buildListOption(
                        Icons.restaurant_menu,
                        const Color(0xFFFF8C00), // Laranja/dourado
                        'Quero conhecer',
                        () => context.push('/want-to-know'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildListOption(
                        Icons.favorite,
                        const Color(0xFFFFD700), // Amarelo/dourado
                        'Meus favoritos',
                        () => context.push('/favorites'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildListOption(
                        Icons.sentiment_neutral,
                        const Color(0xFF87CEEB), // Azul claro
                        'Não sei se eu volto',
                        () => context.push('/not-sure-return'),
                      ),
                      
                      const SizedBox(height: 40), // Espaço para não sobrepor a área bege
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de navegação
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
        ],
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
              _buildBottomNavItem('Descubra', false),
              _buildBottomNavItem('Mapa', false),
              _buildBottomNavItem('Perfil', true),
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
        context.go('/');
        break;
      case 'Mapa':
        context.go('/search');
        break;
      case 'Perfil':
        // Já está no perfil, não faz nada
        break;
    }
  }
  
  /// Constrói uma opção da lista
  Widget _buildListOption(IconData icon, Color iconColor, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.dancingScript(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Mostra mensagem de "em breve" para funcionalidades não implementadas
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Em breve!'),
        backgroundColor: const Color(0xFF4A5FBF),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Realiza o logout do usuário
  void _handleLogout() async {
    try {
      // Mostra dialog de confirmação
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Sair da conta',
            style: TextStyle(color: Colors.black87),
          ),
          content: const Text(
            'Tem certeza que deseja sair da sua conta?',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      
      if (shouldLogout == true) {
        // Realiza o logout
        await ref.read(authProvider.notifier).signOut();
        
        // Navega para a tela de login
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      // Mostra erro se houver problema no logout
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}