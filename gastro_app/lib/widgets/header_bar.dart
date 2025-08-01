import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import 'taste_test_logo.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? elevation;

  const HeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.brancoQuente,
        boxShadow: elevation != null && elevation! > 0 ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation! * 2,
            offset: Offset(0, elevation!),
          ),
        ] : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.espacoMedio,
            vertical: AppTheme.espacoPequeno,
          ),
          child: Row(
            children: [
              // Leading widget ou botão de voltar
              if (showBackButton || leading != null) ...[
                leading ?? _buildBackButton(context),
                const SizedBox(width: AppTheme.espacoMedio),
              ],
              
              // Título e subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: centerTitle 
                    ? CrossAxisAlignment.center 
                    : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.cinzaEscuro,
                      ),
                      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.cinzaMedio,
                        ),
                        textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              if (actions != null) ...[
                const SizedBox(width: AppTheme.espacoMedio),
                ...actions!.map((action) => Padding(
                  padding: const EdgeInsets.only(left: AppTheme.espacoPequeno),
                  child: action,
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_ios),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.mostarda,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(40, 40),
      ),
    );
  }
}

// Headers especializados para diferentes telas
class WelcomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.onProfileTap,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientSuave,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.espacoGrande),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Taste Test no topo
              Center(
                child: TasteTestLogo.medium(
                  showSubtitle: false,
                ),
              ),
              
              const SizedBox(height: AppTheme.espacoGrande),
              
              // Header com perfil e notificações
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $userName! 👋',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cinzaEscuro,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'O que você gostaria de comer hoje?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.cinzaMedio,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botão de notificações
                  if (onNotificationTap != null) ...[
                    IconButton(
                      onPressed: onNotificationTap,
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.cinzaEscuro,
                            size: 24,
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: AppTheme.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    notificationCount > 9 ? '9+' : '$notificationCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: AppTheme.espacoPequeno),
                  ],
                  
                  // Botão de logout
                  _buildLogoutButton(context),
                  
                  const SizedBox(width: AppTheme.espacoPequeno),
                  
                  // Avatar do usuário
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientPrimario,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.mostarda.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showLogoutDialog(context),
      icon: const Icon(
        Icons.logout,
        color: AppTheme.cinzaEscuro,
        size: 24,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.8),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
      ),
      tooltip: 'Sair da conta',
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppTheme.danger,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sair da Conta',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.cinzaMedio,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Fechar dialog
              
              // Fazer logout
              final success = await AuthService.signOut();
              
              if (success && context.mounted) {
                // Mostrar mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Logout realizado com sucesso!'),
                    backgroundColor: AppTheme.customColors['success'],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHeader extends StatefulWidget {
  final String? initialQuery;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onBackPressed;
  final bool hasActiveFilters;

  const SearchHeader({
    super.key,
    this.initialQuery,
    this.onSearchChanged,
    this.onFilterTap,
    this.onBackPressed,
    this.hasActiveFilters = false,
  });

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocus = FocusNode();
    
    // Adicionar listener seguro para mudanças de focus
    _searchFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _disposed = true;
    _searchFocus.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_disposed || !mounted) return;
    
    try {
      // Processar mudanças de focus de forma segura
      if (_searchFocus.hasFocus) {
        debugPrint('🎯 Campo de busca header ganhou foco');
      } else {
        debugPrint('🎯 Campo de busca header perdeu foco');
      }
    } catch (e) {
      debugPrint('Erro ao processar mudança de foco no header: $e');
    }
  }

  void _safeFocusOperation(VoidCallback operation) {
    if (_disposed || !mounted) return;
    
    try {
      operation();
    } catch (e) {
      debugPrint('Erro em operação de foco no header: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.brancoQuente,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.espacoMedio),
          child: Row(
            children: [
              // Botão voltar
              IconButton(
                onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.mostarda,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
              
              const SizedBox(width: AppTheme.espacoPequeno),
              
              // Campo de busca
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPequeno),
                    border: Border.all(
                      color: AppTheme.bordoSuave,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: 'Buscar restaurantes...',
                      hintStyle: TextStyle(
                        color: AppTheme.cinzaMedio.withOpacity(0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.cinzaMedio,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppTheme.cinzaMedio,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged?.call('');
                            },
                          )
                        : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.espacoMedio,
                        vertical: AppTheme.espacoMedio,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.cinzaEscuro,
                    ),
                    onChanged: widget.onSearchChanged,
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
              
              const SizedBox(width: AppTheme.espacoPequeno),
              
              // Botão de filtros
              IconButton(
                onPressed: widget.onFilterTap,
                icon: Stack(
                  children: [
                    const Icon(Icons.tune),
                    if (widget.hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.mostarda,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.mostarda,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 