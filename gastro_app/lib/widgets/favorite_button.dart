import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../utils/providers.dart';
import '../screens/auth_screen.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String restauranteId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showLabel;
  final String? tooltip;

  const FavoriteButton({
    super.key,
    required this.restauranteId,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.showLabel = false,
    this.tooltip,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteToggle() async {
    // Verificar se usuário está autenticado
    final isAuth = ref.read(isAuthenticatedProvider);
    if (!isAuth) {
      _showLoginModal();
      return;
    }

    // Verificar se já está carregando
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        _showErrorMessage('Erro de autenticação. Faça login novamente.');
        return;
      }

      // Animar botão
      await _animationController.forward();
      
      // Toggle favorito
      final foiAdicionado = await UsuarioService.toggleFavorito(
        user.id,
        widget.restauranteId,
      );

      // Atualizar providers
      ref.invalidate(carregarFavoritosProvider);
      ref.invalidate(restaurantesFavoritosProvider);

      // Mostrar feedback
      if (mounted) {
        _showSuccessMessage(
          foiAdicionado
              ? '❤️ Adicionado aos favoritos!'
              : '💔 Removido dos favoritos',
        );
      }

      // Reset animação
      await _animationController.reverse();
    } catch (e) {
      _showErrorMessage('Erro ao atualizar favoritos: ${e.toString()}');
      await _animationController.reverse();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLoginModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red.shade400,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Login necessário',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3985),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para adicionar restaurantes aos seus favoritos, você precisa estar logado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Auth Screen
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: AuthScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritosIds = ref.watch(favoritosAtualizadosProvider);
    final isFavorited = favoritosIds.contains(widget.restauranteId);

    final activeColor = widget.activeColor ?? Colors.red.shade600;
    final inactiveColor = widget.inactiveColor ?? Colors.grey.shade400;

    if (widget.showLabel) {
      return _buildButtonWithLabel(isFavorited, activeColor, inactiveColor);
    } else {
      return _buildIconButton(isFavorited, activeColor, inactiveColor);
    }
  }

  Widget _buildIconButton(bool isFavorited, Color activeColor, Color inactiveColor) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: IconButton(
          onPressed: _isLoading ? null : _handleFavoriteToggle,
          tooltip: widget.tooltip ?? (isFavorited ? 'Remover dos favoritos' : 'Adicionar aos favoritos'),
          icon: _isLoading
              ? SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: activeColor,
                  ),
                )
              : Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? activeColor : inactiveColor,
                  size: widget.size,
                ),
        ),
      ),
    );
  }

  Widget _buildButtonWithLabel(bool isFavorited, Color activeColor, Color inactiveColor) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : _handleFavoriteToggle,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: activeColor,
                  ),
                )
              : Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? activeColor : inactiveColor,
                  size: 16,
                ),
          label: Text(
            isFavorited ? 'Favoritado' : 'Favoritar',
            style: TextStyle(
              color: isFavorited ? activeColor : inactiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isFavorited ? activeColor : inactiveColor,
            ),
            backgroundColor: isFavorited ? activeColor.withOpacity(0.1) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}