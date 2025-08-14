import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/restaurante.dart';
import '../widgets/restaurante_card.dart';
import '../services/localizacao_service.dart';
import '../utils/providers.dart';

class ResultadosScreen extends ConsumerStatefulWidget {
  final List<Restaurante> restaurantes;
  final String buscaOriginal;
  final Map<String, dynamic>? analiseIA;

  const ResultadosScreen({
    super.key,
    required this.restaurantes,
    required this.buscaOriginal,
    this.analiseIA,
  });

  @override
  ConsumerState<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends ConsumerState<ResultadosScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _mostrarCirculoDistancia = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _criarMarkers();
    _atualizarCirculoDistancia();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          radius: configuracao.raioAtual * 1000, // converter para metros
          fillColor: Colors.deepOrange.withOpacity(0.1),
          strokeColor: Colors.deepOrange.withOpacity(0.5),
          strokeWidth: 2,
        ),
      };
    } else {
      _circles = {};
    }
  }

  void _mostrarPreviewRestaurante(Restaurante restaurante) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle do modal
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurante.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurante.tipo.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleFavorito(restaurante),
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              restaurante.descricao,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            // Botão Ver Detalhes removido
          ],
        ),
      ),
    );
  }

  LatLng _obterCentroMapa() {
    final localizacao = ref.read(localizacaoAtualProvider);
    
    if (widget.restaurantes.isEmpty) {
      final posicao = localizacao ?? LocalizacaoService.posicaoPadrao;
      return LatLng(posicao.latitude, posicao.longitude);
    }

    // Se tem localização real, usar como centro
    if (localizacao != null) {
      return LatLng(localizacao.latitude, localizacao.longitude);
    }

    // Calcular centro baseado nos restaurantes
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

  void _toggleFavorito(Restaurante restaurante) {
    // TODO: Implementar lógica de favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${restaurante.nome} adicionado aos favoritos!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _verDetalhes(Restaurante restaurante) {
    // TODO: Navegar para tela de detalhes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo detalhes de ${restaurante.nome}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getReferenciaLocalizacao(LocalizacaoStatus status) {
    switch (status) {
      case LocalizacaoStatus.permitida:
        return 'de você';
      case LocalizacaoStatus.negada:
      case LocalizacaoStatus.negadaPermanente:
      case LocalizacaoStatus.servicoDesabilitado:
      case LocalizacaoStatus.erro:
        return 'do centro de SP';
      default:
        return 'da região';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizacao = ref.watch(localizacaoAtualProvider);
    final configuracao = ref.watch(configuracaoDistanciaProvider);
    final statusLocalizacao = ref.watch(statusLocalizacaoProvider);
    
    // Filtrar restaurantes por distância usando o provider
    final restaurantesFiltrados = ref.watch(
      restaurantesFiltradosPorDistanciaProvider(widget.restaurantes),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '"${widget.buscaOriginal}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(
              icon: Icon(Icons.list),
              text: 'Lista',
            ),
            Tab(
              icon: Icon(Icons.map),
              text: 'Mapa',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtro de distância
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.deepOrange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exibindo lugares até ${LocalizacaoService.formatarDistancia(configuracao.raioAtual)} ${_getReferenciaLocalizacao(statusLocalizacao)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${restaurantesFiltrados.length} local${restaurantesFiltrados.length != 1 ? 'is' : ''} encontrado${restaurantesFiltrados.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Toggle para mostrar/ocultar círculo no mapa
                    if (localizacao != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarCirculoDistancia = !_mostrarCirculoDistancia;
                            _atualizarCirculoDistancia();
                          });
                        },
                        icon: Icon(
                          _mostrarCirculoDistancia ? Icons.visibility : Icons.visibility_off,
                          color: Colors.deepOrange.shade600,
                          size: 20,
                        ),
                        tooltip: _mostrarCirculoDistancia ? 'Ocultar raio' : 'Mostrar raio',
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Slider de distância
                Row(
                  children: [
                    Text(
                      '1km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: configuracao.raioAtual,
                        min: 1.0,
                        max: 20.0,
                        divisions: 19,
                        activeColor: Colors.deepOrange,
                        onChanged: (value) {
                          ref.read(configuracaoDistanciaProvider.notifier).update(
                            (state) => state.copyWith(raioAtual: value),
                          );
                          _atualizarCirculoDistancia();
                        },
                      ),
                    ),
                    Text(
                      '20km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListaAba(restaurantesFiltrados),
                _buildMapaAba(restaurantesFiltrados),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaAba(List<Restaurante> restaurantes) {
    if (restaurantes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum restaurante encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tente aumentar a distância ou refinar sua busca',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: restaurantes.length,
      itemBuilder: (context, index) {
        final restaurante = restaurantes[index];
        return RestauranteCard(
          restaurante: restaurante,
          onTap: () => _verDetalhes(restaurante),
          onFavorite: () => _toggleFavorito(restaurante),
          isFavorito: false, // TODO: Implementar lógica real
        );
      },
    );
  }

  Widget _buildMapaAba(List<Restaurante> restaurantes) {
    if (restaurantes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum local para mostrar no mapa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajuste os filtros para ver restaurantes próximos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _obterCentroMapa(),
            zoom: 14.0,
          ),
          markers: restaurantes.map((restaurante) {
            return Marker(
              markerId: MarkerId(restaurante.id),
              position: LatLng(restaurante.latitude, restaurante.longitude),
              infoWindow: InfoWindow(
                title: restaurante.nome,
                snippet: restaurante.tipo,
                onTap: () => _mostrarPreviewRestaurante(restaurante),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            );
          }).toSet(),
          circles: _circles,
          myLocationEnabled: localizacao != null,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        
        // Botão de atualizar resultados
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () {
              // TODO: Implementar atualização baseada na posição do mapa
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Atualizando resultados...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepOrange,
            child: const Icon(Icons.refresh),
          ),
        ),
        
        // Indicador de status de localização
        if (statusLocalizacao == LocalizacaoStatus.solicitando)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Obtendo localização...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}