import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurante.dart';
import '../config/app_theme.dart';
import '../utils/providers.dart';
import 'tag_chip.dart';
import 'emoji_selector.dart';
import 'animated_favorite_button.dart';
import 'themed_snackbar.dart';

class RestauranteCardModern extends ConsumerStatefulWidget {
  final Restaurante restaurante;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool showRatingButton;

  const RestauranteCardModern({
    super.key,
    required this.restaurante,
    this.onTap,
    this.showFavoriteButton = true,
    this.showRatingButton = true,
  });

  @override
  ConsumerState<RestauranteCardModern> createState() => _RestauranteCardModernState();
}

class _RestauranteCardModernState extends ConsumerState<RestauranteCardModern>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _favoriteController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _favoriteAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _toggleFavorite() async {
    try {
      final favoritosActions = ref.read(favoritosActionsProvider);
      final favoritos = ref.read(favoritosAtualizadosProvider);
      final isFavoriteNow = favoritos.contains(widget.restaurante.id);
      
      await favoritosActions.toggleFavorito(widget.restaurante.id);

      // Mostrar feedback
      if (mounted) {
        ThemedSnackBar.showFavorite(
          context,
          widget.restaurante.nome,
          !isFavoriteNow,
        );
      }
    } catch (e) {
      debugPrint('Erro ao alterar favorito: $e');
      if (mounted) {
        ThemedSnackBar.showError(
          context,
          'Erro ao alterar favorito. Tente novamente.',
        );
      }
    }
  }

  void _showRatingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiSelector(
        restauranteId: widget.restaurante.id,
        onRated: () {
          ref.invalidate(experienciasProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = ref.watch(favoritosAtualizadosProvider);
    final isFavorite = favoritos.contains(widget.restaurante.id);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: () {
              _scaleController.reverse();
              widget.onTap?.call();
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 600 
                    ? AppTheme.espacoPequeno 
                    : AppTheme.espacoMedio,
                vertical: AppTheme.espacoPequeno,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width < 600 
                    ? double.infinity 
                    : 380,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
                boxShadow: AppTheme.sombraCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem de capa
                  _buildImageHeader(isFavorite),
                  
                  // Conteúdo do card
                  Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 600 
                          ? AppTheme.espacoPequeno 
                          : AppTheme.espacoMedio
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome e tipo
                        _buildTitleSection(),
                        
                        const SizedBox(height: AppTheme.espacoPequeno),
                        
                        // Descrição
                        _buildDescription(),
                        
                        const SizedBox(height: AppTheme.espacoMedio),
                        
                        // Tags
                        _buildTags(),
                        
                        const SizedBox(height: AppTheme.espacoMedio),
                        
                        // Informações adicionais e ações
                        _buildFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageHeader(bool isFavorite) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusGrande),
        ),
        gradient: widget.restaurante.imagemUrl != null
            ? null
            : AppTheme.gradientPrimario,
      ),
      child: Stack(
        children: [
          // Imagem ou placeholder
          if (widget.restaurante.imagemUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusGrande),
              ),
              child: Image.network(
                widget.restaurante.imagemUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            )
          else
            _buildImagePlaceholder(),
          
          // Overlay gradiente
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusGrande),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Botões de ação
          Positioned(
            top: AppTheme.espacoMedio,
            right: AppTheme.espacoMedio,
            child: Row(
              children: [
                if (widget.showFavoriteButton) _buildFavoriteButton(isFavorite),
                if (widget.showRatingButton) ...[
                  const SizedBox(width: AppTheme.espacoPequeno),
                  _buildRatingButton(),
                ],
              ],
            ),
          ),
          
          // Tipo do restaurante
          Positioned(
            bottom: AppTheme.espacoMedio,
            left: AppTheme.espacoMedio,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.mostarda.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.restaurante.tipo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientPrimario,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusGrande),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 48,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              '🍽️',
              style: TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(bool isFavorite) {
    return AnimatedFavoriteButton(
      isFavorite: isFavorite,
      onTap: _toggleFavorite,
      size: 20,
    );
  }

  Widget _buildRatingButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: _showRatingModal,
        icon: const Text(
          '😋',
          style: TextStyle(fontSize: 18),
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.restaurante.nome,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.cinzaEscuro,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.mostarda,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.cinzaMedio,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.restaurante.descricao,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.cinzaMedio,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: widget.restaurante.tags.take(4).map((tag) {
        return TagChip(
          label: tag,
          isSelected: false,
          onTap: null,
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Toque para ver detalhes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mostarda,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.mostarda,
        ),
      ],
    );
  }

  String _formatDistance() {
    // Aqui você pode calcular a distância real baseada na localização
    // Por enquanto, vamos usar um placeholder
    return "~500m";
  }
}