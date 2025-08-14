import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/restaurante.dart';
import '../config/app_theme.dart';
import '../widgets/header_bar.dart';
import '../widgets/restaurante_card_modern.dart';
import '../widgets/filtro_slider.dart';
import '../widgets/tag_chip.dart';
import '../services/localizacao_service.dart';
import '../utils/providers.dart';

class ResultadosScreenModern extends ConsumerStatefulWidget {
  final List<Restaurante> restaurantes;
  final String buscaOriginal;
  final Map<String, dynamic>? analiseIA;

  const ResultadosScreenModern({
    super.key,
    required this.restaurantes,
    required this.buscaOriginal,
    this.analiseIA,
  });

  @override
  ConsumerState<ResultadosScreenModern> createState() => _ResultadosScreenModernState();
}

class _ResultadosScreenModernState extends ConsumerState<ResultadosScreenModern>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _mostrarCirculoDistancia = true;
  bool _showFilters = false;
  
  // Estado dos filtros
  Set<String> _selectedTags = {};
  String _selectedType = '';
  double _minPrice = 10;
  double _maxPrice = 200;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _criarMarkers();
    _atualizarCirculoDistancia();
    _inicializarFiltros();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupControllers() {
    _tabController = TabController(length: 2, vsync: this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  void _inicializarFiltros() {
    // Extrair tags únicas dos restaurantes
    final allTags = <String>{};
    for (final restaurante in widget.restaurantes) {
      allTags.addAll(restaurante.tags);
    }
    
    // Se há análise da IA, pré-selecionar filtros relevantes
    if (widget.analiseIA != null) {
      final aiTags = widget.analiseIA!['tags']?.cast<String>() ?? <String>[];
      _selectedTags = allTags.intersection(aiTags.toSet());
      _selectedType = widget.analiseIA!['tipo'] ?? '';
    }
  }

  void _criarMarkers() {
    _markers = widget.restaurantes.map((restaurante) {
      return Marker(
        markerId: MarkerId(restaurante.id),
        position: LatLng(restaurante.latitude, restaurante.longitude),
        infoWindow: InfoWindow(
          title: restaurante.nome,
          snippet: restaurante.tipo,
          onTap: () => _mostrarPreviewRestaurante(restaurante),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }).toSet();
  }

  void _atualizarCirculoDistancia() {
    final localizacao = ref.read(localizacaoAtualProvider);
    final configuracao = ref.read(configuracaoDistanciaProvider);
    
    if (localizacao != null && _mostrarCirculoDistancia) {
      _circles = {
        Circle(
          circleId: const CircleId('raio_distancia'),
          center: LatLng(localizacao.latitude, localizacao.longitude),
          radius: configuracao.raioAtual * 1000,
          fillColor: AppTheme.mostarda.withOpacity(0.1),
          strokeColor: AppTheme.mostarda.withOpacity(0.5),
          strokeWidth: 2,
        ),
      };
    } else {
      _circles = {};
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    
    if (_showFilters) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _mostrarPreviewRestaurante(Restaurante restaurante) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RestaurantePreview(
        restaurante: restaurante,
        onDetailsPressed: () {
          Navigator.of(context).pop();
          _verDetalhes(restaurante);
        },
      ),
    );
  }

  void _verDetalhes(Restaurante restaurante) {
    // TODO: Navegar para tela de detalhes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo detalhes de ${restaurante.nome}'),
        backgroundColor: AppTheme.mostarda,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        ),
      ),
    );
  }

  List<Restaurante> _getFilteredRestaurantes() {
    final restaurantesFiltrados = ref.watch(
      restaurantesFiltradosPorDistanciaProvider(widget.restaurantes),
    );

    return restaurantesFiltrados.where((restaurante) {
      // Filtro por tipo
      if (_selectedType.isNotEmpty && restaurante.tipo != _selectedType) {
        return false;
      }
      
      // Filtro por tags
      if (_selectedTags.isNotEmpty) {
        final hasMatchingTag = restaurante.tags.any((tag) => _selectedTags.contains(tag));
        if (!hasMatchingTag) return false;
      }
      
      return true;
    }).toList();
  }

  LatLng _obterCentroMapa() {
    final localizacao = ref.read(localizacaoAtualProvider);
    
    if (widget.restaurantes.isEmpty) {
      final posicao = localizacao ?? LocalizacaoService.posicaoPadrao;
      return LatLng(posicao.latitude, posicao.longitude);
    }

    if (localizacao != null) {
      return LatLng(localizacao.latitude, localizacao.longitude);
    }

    double latSum = 0;
    double lngSum = 0;
    for (var restaurante in widget.restaurantes) {
      latSum += restaurante.latitude;
      lngSum += restaurante.longitude;
    }
    
    return LatLng(
      latSum / widget.restaurantes.length,
      lngSum / widget.restaurantes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final configuracao = ref.watch(configuracaoDistanciaProvider);
    final statusLocalizacao = ref.watch(statusLocalizacaoProvider);
    final restaurantesFiltrados = _getFilteredRestaurantes();
    
    return Scaffold(
      backgroundColor: AppTheme.cinzaClaro,
      body: Column(
        children: [
          // Header moderno com busca
          FadeTransition(
            opacity: _fadeAnimation,
            child: SearchHeader(
              initialQuery: widget.buscaOriginal,
              hasActiveFilters: _selectedTags.isNotEmpty || _selectedType.isNotEmpty,
              onFilterTap: _toggleFilters,
            ),
          ),

          // Análise da IA (se disponível)
          if (widget.analiseIA != null && widget.analiseIA!['input_original'] != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildAnaliseIA(),
            ),

          // Filtros deslizantes
          SlideTransition(
            position: _slideAnimation,
            child: _showFilters ? _buildFiltersPanel() : const SizedBox.shrink(),
          ),

          // Tabs
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildTabBar(),
          ),

          // Conteúdo das tabs
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(restaurantesFiltrados),
                  _buildMapView(restaurantesFiltrados),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnaliseIA() {
    final analise = widget.analiseIA!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
      padding: const EdgeInsets.all(AppTheme.espacoGrande),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.customColors['info']!.withOpacity(0.1),
            AppTheme.customColors['info']!.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        border: Border.all(
          color: AppTheme.customColors['info']!.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.customColors['info'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.espacoMedio),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análise da IA',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.customColors['info'],
                  ),
                ),
                Text(
                  'Busquei por: ${analise['tipo'] ?? 'qualquer tipo'}'
                  '${analise['tags']?.isNotEmpty == true ? ' • ${analise['tags'].join(', ')}' : ''}'
                  '${analise['localizacao'] != null ? ' • ${analise['localizacao']}' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.customColors['info'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    // Extrair tipos únicos
    final allTypes = widget.restaurantes.map((r) => r.tipo).toSet().toList();
    // Extrair tags únicas
    final allTags = <String>{};
    for (final restaurante in widget.restaurantes) {
      allTags.addAll(restaurante.tags);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
      padding: const EdgeInsets.all(AppTheme.espacoGrande),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: AppTheme.sombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dos filtros
          Row(
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.cinzaEscuro,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTags.clear();
                    _selectedType = '';
                  });
                },
                child: const Text('Limpar'),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.espacoMedio),

          // Filtro por distância
          DistanceSlider(
            distance: configuracao.raioAtual,
            onChanged: (value) {
              ref.read(configuracaoDistanciaProvider.notifier).update(
                (state) => state.copyWith(raioAtual: value),
              );
              _atualizarCirculoDistancia();
            },
          ),

          const SizedBox(height: AppTheme.espacoGrande),

          // Filtro por tipo
          Text(
            'Tipo de culinária',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.cinzaEscuro,
            ),
          ),
          const SizedBox(height: AppTheme.espacoPequeno),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTypes.map((type) {
              return CuisineTypeChip(
                type: type,
                isSelected: _selectedType == type,
                onTap: () {
                  setState(() {
                    _selectedType = _selectedType == type ? '' : type;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.espacoGrande),

          // Filtro por tags
          Text(
            'Características',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.cinzaEscuro,
            ),
          ),
          const SizedBox(height: AppTheme.espacoPequeno),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTags.map((tag) {
              return FilterChip(
                label: tag,
                isSelected: _selectedTags.contains(tag),
                onTap: () {
                  setState(() {
                    if (_selectedTags.contains(tag)) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.espacoGrande),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: AppTheme.sombraCard,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.cinzaEscuro,
        indicator: BoxDecoration(
          gradient: AppTheme.gradientPrimario,
          borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.list, size: 20),
                const SizedBox(width: 8),
                Text('Lista (${widget.restaurantes.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 20),
                const SizedBox(width: 8),
                const Text('Mapa'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Restaurante> restaurantes) {
    if (restaurantes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppTheme.espacoGrande),
      itemCount: restaurantes.length,
      itemBuilder: (context, index) {
        final restaurante = restaurantes[index];
        return RestauranteCardModern(
          restaurante: restaurante,
          onTap: () => _verDetalhes(restaurante),
        );
      },
    );
  }

  Widget _buildMapView(List<Restaurante> restaurantes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: AppTheme.sombraCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _obterCentroMapa(),
            zoom: 14.0,
          ),
          markers: _markers,
          circles: _circles,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacoExtraGrande),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.mostardaClara.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.filter_list_off,
                size: 40,
                color: AppTheme.mostarda,
              ),
            ),
            const SizedBox(height: AppTheme.espacoGrande),
            Text(
              'Nenhum restaurante encontrado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.cinzaEscuro,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.espacoPequeno),
            Text(
              'Tente ajustar os filtros ou aumentar a distância',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.cinzaMedio,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.espacoGrande),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedTags.clear();
                  _selectedType = '';
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantePreview extends ConsumerWidget {
  final Restaurante restaurante;
  final VoidCallback onDetailsPressed;

  const _RestaurantePreview({
    required this.restaurante,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.espacoGrande),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraGrande),
        boxShadow: AppTheme.sombraElevada,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle do modal
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppTheme.espacoMedio),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.cinzaMedio.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.espacoGrande),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurante.nome,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.cinzaEscuro,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.gradientPrimario,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              restaurante.tipo.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Toggle favorito
                      },
                      icon: const Icon(
                        Icons.favorite_border,
                        color: AppTheme.cinzaMedio,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.cinzaClaro,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.espacoMedio),

                Text(
                  restaurante.descricao,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.cinzaMedio,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.espacoGrande),

                // Botão Ver Detalhes removido
              ],
            ),
          ),
        ],
      ),
    );
  }
}