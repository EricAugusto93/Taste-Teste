import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../config/app_theme.dart';
import 'categoria_card.dart';

class CategoriasCarrossel extends StatefulWidget {
  final String titulo;
  final List<Categoria> categorias;
  final Function(Categoria) onCategoriaSelected;
  final CategoriaDisplayMode displayMode;
  final bool mostrarTitulo;
  final String? subtitulo;
  final EdgeInsets padding;
  final double altura;

  const CategoriasCarrossel({
    super.key,
    this.titulo = 'Explore por Categorias',
    required this.categorias,
    required this.onCategoriaSelected,
    this.displayMode = CategoriaDisplayMode.carrossel,
    this.mostrarTitulo = true,
    this.subtitulo,
    this.padding = const EdgeInsets.symmetric(vertical: AppTheme.espacoGrande),
    this.altura = 200,
  });

  @override
  State<CategoriasCarrossel> createState() => _CategoriasCarrosselState();
}

class _CategoriasCarrosselState extends State<CategoriasCarrossel>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animação após um breve delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: widget.altura,
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.mostrarTitulo) _buildHeader(),
            const SizedBox(height: AppTheme.espacoGrande),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.titulo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.cores.onSurface,
                  ),
                ),
              ),
              if (widget.displayMode == CategoriaDisplayMode.carrossel)
                _buildIndicators(),
            ],
          ),
          if (widget.subtitulo != null) ...[
            const SizedBox(height: AppTheme.espacoPequeno),
            Text(
              widget.subtitulo!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.cores.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    if (widget.categorias.length <= 1) return const SizedBox.shrink();

    final totalPages = (widget.categorias.length / 2).ceil();
    
    return Row(
      children: List.generate(totalPages, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive 
                ? AppTheme.cores.primary 
                : AppTheme.cores.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildContent() {
    switch (widget.displayMode) {
      case CategoriaDisplayMode.carrossel:
        return _buildCarrossel();
      case CategoriaDisplayMode.grid:
        return _buildGrid();
      case CategoriaDisplayMode.lista:
        return _buildLista();
    }
  }

  Widget _buildCarrossel() {
    // Determinar viewport fraction baseado no tamanho da tela
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    double viewportFraction;
    int itemsPerPage;
    
    if (screenWidth > 600) {
      // Tablets e telas grandes - mostrar mais cards por vez
      viewportFraction = 0.7;
      itemsPerPage = 3;
    } else if (screenWidth > 400) {
      // Telas médias
      viewportFraction = 0.85;
      itemsPerPage = 2;
    } else {
      // Telas pequenas
      viewportFraction = 0.9;
      itemsPerPage = 2;
    }

    final pageController = PageController(viewportFraction: viewportFraction);

    return PageView.builder(
      controller: pageController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: (widget.categorias.length / itemsPerPage).ceil(),
      itemBuilder: (context, pageIndex) {
        final startIndex = pageIndex * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage).clamp(0, widget.categorias.length);
        final pageCategories = widget.categorias.sublist(startIndex, endIndex);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacoPequeno),
          child: screenWidth > 600 
              ? Row(
                  children: pageCategories.asMap().entries.map((entry) {
                    final categoria = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacoPequeno),
                        child: _buildCategoriaCard(categoria),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: pageCategories.asMap().entries.map((entry) {
                    final categoria = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.espacoPequeno),
                        child: _buildCategoriaCard(categoria),
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: AppTheme.espacoMedio,
        mainAxisSpacing: AppTheme.espacoMedio,
      ),
      itemCount: widget.categorias.length,
      itemBuilder: (context, index) {
        return _buildCategoriaCard(widget.categorias[index]);
      },
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.categorias.length,
      itemBuilder: (context, index) {
        return CategoriaCardLista(
          categoria: widget.categorias[index],
          onTap: () => widget.onCategoriaSelected(widget.categorias[index]),
        );
      },
    );
  }

  Widget _buildCategoriaCard(Categoria categoria) {
    return CategoriaCard(
      categoria: categoria,
      onTap: () => widget.onCategoriaSelected(categoria),
      config: const CategoriaConfig(
        cardWidth: double.infinity,
        cardHeight: double.infinity,
        margin: EdgeInsets.zero,
        enableAnimations: true,
      ),
    );
  }
}

// Widget especializado para seção "Hoje eu quero..."
class HojeEuQueroSection extends StatefulWidget {
  final Function(Categoria) onCategoriaSelected;
  final List<Categoria>? categoriasPersonalizadas;

  const HojeEuQueroSection({
    super.key,
    required this.onCategoriaSelected,
    this.categoriasPersonalizadas,
  });

  @override
  State<HojeEuQueroSection> createState() => _HojeEuQueroSectionState();
}

class _HojeEuQueroSectionState extends State<HojeEuQueroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;

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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final categorias = widget.categoriasPersonalizadas ?? 
                     CategoriasData.obterPopulares(limite: 6);

    _cardAnimations = List.generate(categorias.length, (index) {
      final delay = index * 0.1;
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delay,
          (delay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      ));
    });

    // Iniciar animação
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorias = widget.categoriasPersonalizadas ?? 
                      CategoriasData.obterPopulares(limite: 6);

    // Responsividade para diferentes tamanhos de tela
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    double cardWidth;
    double cardHeight;
    
    if (screenWidth > 600) {
      // Tablets - cards maiores
      cardWidth = 200;
      cardHeight = double.infinity;
    } else if (screenWidth > 400) {
      // Telas médias
      cardWidth = 160;
      cardHeight = double.infinity;
    } else {
      // Telas pequenas - cards menores
      cardWidth = 140;
      cardHeight = double.infinity;
    }

    return Container(
      height: screenWidth > 600 ? 320 : 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoje eu quero...',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.cores.onSurface,
                  ),
                ),
                const SizedBox(height: AppTheme.espacoPequeno),
                Text(
                  'Que tipo de experiência você está buscando?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.cores.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.espacoGrande),
          
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 
                    ? AppTheme.espacoExtraGrande 
                    : AppTheme.espacoGrande
              ),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _cardAnimations[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        50 * (1 - _cardAnimations[index].value),
                      ),
                      child: Opacity(
                        opacity: _cardAnimations[index].value,
                        child: CategoriaCard(
                          categoria: categorias[index],
                          onTap: () => widget.onCategoriaSelected(categorias[index]),
                          config: CategoriaConfig(
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            margin: EdgeInsets.only(
                              right: screenWidth > 600 
                                  ? AppTheme.espacoGrande 
                                  : AppTheme.espacoMedio
                            ),
                            enableAnimations: true,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para categorias em destaque
class CategoriasDestaque extends StatelessWidget {
  final List<Categoria> categorias;
  final Function(Categoria) onCategoriaSelected;
  final String titulo;

  const CategoriasDestaque({
    super.key,
    required this.categorias,
    required this.onCategoriaSelected,
    this.titulo = 'Em Destaque',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.cores.onSurface,
                  ),
                ),
                Icon(
                  Icons.star,
                  color: AppTheme.cores.primary,
                  size: 28,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.espacoGrande),
          
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                return CategoriaCardDestaque(
                  categoria: categorias[index],
                  onTap: () => onCategoriaSelected(categorias[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 