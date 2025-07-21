import 'package:flutter/material.dart';
import '../config/app_theme.dart';
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
                          'O que você está com vontade de comer hoje?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.cinzaMedio,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botão de notificações
                  Stack(
                    children: [
                      IconButton(
                        onPressed: onNotificationTap,
                        icon: const Icon(Icons.notifications_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.mostarda,
                          shape: const CircleBorder(),
                        ),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              notificationCount > 9 ? '9+' : notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
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
                ),
              ),
              
              const SizedBox(width: AppTheme.espacoMedio),
              
              // Campo de busca
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar restaurantes, pratos...',
                      hintStyle: TextStyle(
                        color: AppTheme.cinzaMedio,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.mostarda,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.espacoMedio,
                        vertical: AppTheme.espacoMedio,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: AppTheme.espacoMedio),
              
              // Botão de filtros
              Stack(
                children: [
                  IconButton(
                    onPressed: widget.onFilterTap,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: widget.hasActiveFilters 
                        ? AppTheme.mostarda 
                        : Colors.white,
                      foregroundColor: widget.hasActiveFilters 
                        ? Colors.white 
                        : AppTheme.mostarda,
                      shape: const CircleBorder(),
                    ),
                  ),
                  if (widget.hasActiveFilters)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.terracota,
                          shape: BoxShape.circle,
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
} 