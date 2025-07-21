import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../config/app_theme.dart';

class CategoriaCard extends StatefulWidget {
  final Categoria categoria;
  final VoidCallback onTap;
  final CategoriaConfig config;
  final bool isSelected;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onTap,
    this.config = const CategoriaConfig(),
    this.isSelected = false,
  });

  @override
  State<CategoriaCard> createState() => _CategoriaCardState();
}

class _CategoriaCardState extends State<CategoriaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.config.enableAnimations) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.config.enableAnimations) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.config.enableAnimations) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.config.cardWidth,
            height: widget.config.cardHeight,
            margin: widget.config.margin,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: () {
                _animationController.reverse();
                widget.onTap();
              },
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.categoria.gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: [
          BoxShadow(
            color: widget.categoria.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          ...AppTheme.sombraCard,
        ],
        border: widget.isSelected
            ? Border.all(
                color: Colors.white,
                width: 3,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Overlay com efeito shine
          if (widget.config.enableAnimations)
            AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2 * _shineAnimation.value),
                        Colors.transparent,
                        Colors.white.withOpacity(0.1 * _shineAnimation.value),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(AppTheme.espacoMedio),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Emoji e indicador de seleção
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.config.mostrarEmoji)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            widget.categoria.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    
                    if (widget.isSelected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: widget.categoria.primaryColor,
                        ),
                      ),
                  ],
                ),

                // Nome da categoria
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoria.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (widget.config.mostrarDescricao) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.categoria.descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Overlay de toque
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
              onTap: widget.onTap,
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

// Card compacto para usar em grids ou listas menores
class CategoriaCardCompact extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoriaCardCompact({
    super.key,
    required this.categoria,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return CategoriaCard(
      categoria: categoria,
      onTap: onTap,
      isSelected: isSelected,
      config: const CategoriaConfig(
        cardWidth: 120,
        cardHeight: 80,
        mostrarDescricao: false,
        margin: EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

// Card para modo lista
class CategoriaCardLista extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoriaCardLista({
    super.key,
    required this.categoria,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.espacoGrande,
        vertical: AppTheme.espacoPequeno,
      ),
      decoration: BoxDecoration(
        gradient: categoria.gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        boxShadow: AppTheme.sombraCard,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.espacoGrande),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      categoria.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppTheme.espacoGrande),
                
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoria.descricao,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Seta
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Card especial para categoria em destaque
class CategoriaCardDestaque extends StatefulWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const CategoriaCardDestaque({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  @override
  State<CategoriaCardDestaque> createState() => _CategoriaCardDestaqueState();
}

class _CategoriaCardDestaqueState extends State<CategoriaCardDestaque>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: CategoriaCard(
            categoria: widget.categoria,
            onTap: widget.onTap,
            config: const CategoriaConfig(
              cardWidth: 200,
              cardHeight: 140,
              enableAnimations: true,
            ),
          ),
        );
      },
    );
  }
} 