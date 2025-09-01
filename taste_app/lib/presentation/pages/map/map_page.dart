import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/location_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/enhanced_map_widget.dart';

/// Página de mapa com layout da imagem de referência
class MapPage extends ConsumerStatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? restaurantId;

  const MapPage({
    super.key,
    this.initialLat,
    this.initialLng,
    this.restaurantId,
  });

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with TickerProviderStateMixin {
  late AnimationController _bottomSheetController;
  late Animation<double> _bottomSheetAnimation;
  
  RestaurantModel? _selectedRestaurant;
  gmaps.GoogleMapController? _mapController;
  Set<gmaps.Marker> _markers = {};
  bool _markersLoaded = false;
  UniqueKey _mapKey = UniqueKey(); // Key para forçar reconstrução do mapa
  
  // Cache para evitar recriar o mapa múltiplas vezes
  static gmaps.GoogleMapController? _staticMapController;
  
  // Mapeamento de categoria ID para emoji baseado no banco de dados
  final Map<String, String> _categoryEmojis = {
    '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d': '🍝', // Date night - Italiana
    '948a606b-78ff-4bcd-9d37-f14ec5654e25': '☕', // Happy Hour de Firma - Café
    '0a575266-ee8e-4c72-82e9-2a85359682cb': '🥗', // Com vibe leve - Saudável
    '875498c4-1853-4b84-aa5e-a05a3a902574': '🏛️', // Clássicos POA
    'a945c6bb-0554-4181-831c-17928864ee52': '🍰', // Vontade de Doce - Doceria
    'c9fdb068-aff4-4fe1-84ff-10974d62fba9': '🍽️', // Almoço de Domingo - Buffet
    '3b9168dc-f187-40e3-8921-7780d5195d8b': '🍻', // Happy Hour alternativo
    '1417ab7f-338c-4dd4-96d7-87bcaa8099bf': '🍣', // Sushi fresh - Japonesa
    '45a122d2-d5fd-4e20-ab17-2d1a1699c3e0': '🍔', // Para curar ressaca - Hambúrguer
    'dfadf4da-3c7b-4d85-b6da-5b0bddd60195': '🍕', // Clássicos Curitiba - Pizzaria
  };

  @override
  void initState() {
    super.initState();
    
    _bottomSheetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _bottomSheetAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bottomSheetController,
      curve: Curves.easeInOut,
    ));

    // Aguardar carregamento dos dados e então criar markers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎯🎯🎯 initState: CORREÇÃO LOCALIZAÇÃO - usando restaurantes reais...');
    });
    
    // TESTE IMEDIATO - para debug
    debugPrint('🏁 MapPage initState executado - página iniciada!');
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    super.dispose();
  }

  void _onRestaurantTap(RestaurantModel restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });
    _bottomSheetController.forward();
  }

  void _closeBottomSheet() {
    _bottomSheetController.reverse();
    setState(() {
      _selectedRestaurant = null;
    });
  }


  void _navigateToRestaurant(RestaurantModel restaurant) {
    context.push('/restaurant/${restaurant.id}');
  }





  @override
  Widget build(BuildContext context) {
    final restaurantState = ref.watch(restaurantProvider);
    
    // Usar localização fixa de Porto Alegre para consistência com os restaurantes
    final portoAlegreLocation = LocationModel(
      latitude: -30.0277,
      longitude: -51.2287,
      address: 'Porto Alegre, RS, Brasil',
    );
    
    // Sempre usar os restaurantes reais do banco de dados
    final nearbyRestaurants = restaurantState.restaurants.isNotEmpty
        ? restaurantState.restaurants
        : <RestaurantModel>[]; // Lista vazia ao invés de dados de amostra
    
    debugPrint('🗺️ MapPage: ${nearbyRestaurants.length} restaurantes disponíveis para o mapa');
    if (nearbyRestaurants.isNotEmpty) {
      debugPrint('🏪 Primeiro restaurante: ${nearbyRestaurants.first.name} (${nearbyRestaurants.first.latitude}, ${nearbyRestaurants.first.longitude})');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header azul/roxo com gradiente (reduzido para dar mais espaço ao mapa)
          Flexible(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A5FBF), // Azul
                    Color(0xFF6B73D9), // Roxo claro
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botão de voltar
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/home'),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: const EdgeInsets.all(8),
                              minimumSize: const Size(40, 40),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Texto explicativo
                      Text(
                        'Veja o que está por perto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '(ou onde você quiser).',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Text(
                        'Encontre experiências pelo mapa e descubra a cidade com mais intenção.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Campo de busca
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar restaurantes, pratos...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          onTap: () {
                            // Navegar para a página de busca
                            context.push('/search');
                          },
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Mapa (expandido para ocupar mais espaço)
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Mapa sempre visível, independente do estado dos restaurantes
                _buildDirectGoogleMap(nearbyRestaurants, portoAlegreLocation),
                
                // Overlay de carregamento de restaurantes (não bloqueia o mapa)
                if (restaurantState.isLoading)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Carregando restaurantes...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Overlay de erro (não bloqueia o mapa)
                if (restaurantState.hasError)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Erro ao carregar restaurantes: ${restaurantState.error ?? 'Erro desconhecido'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => ref.refresh(restaurantProvider),
                            child: Icon(Icons.refresh, color: Colors.red.shade600, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),


        ],
      ),
    );
  }


  /// Obter restaurantes de amostra perto da localização
  List<RestaurantModel> _getSampleRestaurants(LocationModel? userLocation) {
    // Se não há localização, usar coordenadas padrão de Porto Alegre
    final baseLat = userLocation?.latitude ?? -30.0277;
    final baseLng = userLocation?.longitude ?? -51.2287;
    
    return [
      RestaurantModel(
        id: 'sample-1',
        name: 'Maki Sushi',
        description: 'Comida japonesa autêntica',
        rating: 4.5,
        deliveryTime: '30-45 min',
        deliveryFee: 5.90,
        latitude: baseLat + 0.002,
        longitude: baseLng + 0.002,
        address: 'Rua das Flores, 123',
        emoji: '🍣',
        isOpen: true,
        isFeatured: true,
        category: 'Japonês',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: 'sample-2',
        name: 'Pizzaria Italiana',
        description: 'Pizza tradicional italiana',
        rating: 4.2,
        deliveryTime: '25-40 min',
        deliveryFee: 4.50,
        latitude: baseLat - 0.003,
        longitude: baseLng + 0.001,
        address: 'Av. Central, 456',
        emoji: '🍕',
        isOpen: true,
        isFeatured: false,
        category: 'Pizza',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: 'sample-3',
        name: 'Burguer House',
        description: 'Hambúrgueres artesanais',
        rating: 4.7,
        deliveryTime: '20-35 min',
        deliveryFee: 3.99,
        latitude: baseLat + 0.001,
        longitude: baseLng - 0.002,
        address: 'Rua dos Sabores, 789',
        emoji: '🍔',
        isOpen: true,
        isFeatured: true,
        category: 'Hambúrguer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: 'sample-4',
        name: 'Cantina do Nono',
        description: 'Comida caseira italiana',
        rating: 4.3,
        deliveryTime: '35-50 min',
        deliveryFee: 6.50,
        latitude: baseLat - 0.001,
        longitude: baseLng - 0.003,
        address: 'Praça da Saudade, 321',
        emoji: '🍝',
        isOpen: true,
        isFeatured: false,
        category: 'Italiano',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: 'sample-5',
        name: 'Açaí da Praia',
        description: 'Açaí e lanches naturais',
        rating: 4.1,
        deliveryTime: '15-25 min',
        deliveryFee: 2.99,
        latitude: baseLat + 0.003,
        longitude: baseLng - 0.001,
        address: 'Rua das Palmeiras, 654',
        emoji: '🥤',
        isOpen: true,
        isFeatured: false,
        category: 'Açaí',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Constrói um mapa Google Maps direto com tratamento de erros de rede
  Widget _buildDirectGoogleMap(List<RestaurantModel> restaurants, LocationModel? userLocation) {
    try {
      return gmaps.GoogleMap(
      key: _mapKey, // Key única para forçar reconstrução quando markers mudam
      initialCameraPosition: gmaps.CameraPosition(
        target: userLocation != null
            ? gmaps.LatLng(userLocation.latitude, userLocation.longitude)
            : const gmaps.LatLng(-30.0277, -51.2287), // Porto Alegre como fallback
        zoom: 14,
      ),
      markers: _markers,
      onMapCreated: (gmaps.GoogleMapController controller) {
        _mapController = controller;
        _staticMapController = controller;
        debugPrint('🗺️ Google Maps inicializado sem erros de rede');
        debugPrint('📊 Carregando markers para ${restaurants.length} restaurantes reais...');
        
        // Carregar markers com os restaurantes reais que foram passados
        if (restaurants.isNotEmpty) {
          _loadCustomMarkers(restaurants, userLocation);
        } else {
          debugPrint('⚠️ Nenhum restaurante disponível para criar markers');
        }
      },
      myLocationEnabled: false, // Desabilitado para evitar conflitos
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      onTap: (gmaps.LatLng position) {
        // Fechar qualquer bottom sheet aberto
        _closeBottomSheet();
      },
    );
    } catch (e) {
      debugPrint('❌ Erro ao carregar Google Maps: $e');
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Colors.grey[600]),
              SizedBox(height: 16),
              Text(
                'Erro ao carregar mapa',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Verifique sua conexão com a internet',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Obtém o emoji da categoria do restaurante
  String _getRestaurantEmoji(RestaurantModel restaurant) {
    return _categoryEmojis[restaurant.categoryId] ?? '🍽️';
  }
  
  /// Cria um ícone customizado mais simples para evitar problemas de CSP
  Future<gmaps.BitmapDescriptor> _createCustomMarkerIcon(String emoji) async {
    debugPrint('🎨 Criando ícone customizado simplificado para emoji: $emoji');
    
    // Devido a problemas de Content Security Policy com blobs no Flutter Web,
    // vamos usar uma abordagem temporária com cores diferenciadas
    // até implementarmos uma solução que funcione bem com CSP
    
    debugPrint('⚠️ Usando fallback colorido devido a restrições CSP no Flutter Web');
    
    const colorMap = {
      '🍝': gmaps.BitmapDescriptor.hueRed,      // Italiana
      '☕': gmaps.BitmapDescriptor.hueOrange,    // Café
      '🥗': gmaps.BitmapDescriptor.hueGreen,     // Saudável  
      '🏛️': gmaps.BitmapDescriptor.hueBlue,     // Clássicos POA
      '🍰': gmaps.BitmapDescriptor.hueMagenta,   // Doceria
      '🍽️': gmaps.BitmapDescriptor.hueYellow,   // Buffet
      '🍻': gmaps.BitmapDescriptor.hueViolet,    // Happy Hour
      '🍣': gmaps.BitmapDescriptor.hueAzure,     // Japonesa
      '🍔': gmaps.BitmapDescriptor.hueOrange,    // Hambúrguer
      '🍕': gmaps.BitmapDescriptor.hueRed,       // Pizza
      '📍': gmaps.BitmapDescriptor.hueCyan,      // Usuário
    };
    
    final hue = colorMap[emoji] ?? gmaps.BitmapDescriptor.hueOrange;
    debugPrint('✅ Usando marker colorido (hue: $hue) para emoji: $emoji');
    return gmaps.BitmapDescriptor.defaultMarkerWithHue(hue);
  }
  
  /// Cria marcadores para os restaurantes com ícones customizados
  Future<Set<gmaps.Marker>> _createMarkersForRestaurants(List<RestaurantModel> restaurants, LocationModel? userLocation) async {
    debugPrint('🏗️ Iniciando criação de ${restaurants.length} markers de restaurantes');
    final markers = <gmaps.Marker>{};

    // Adicionar marcador da localização do usuário (se disponível)
    if (userLocation != null) {
      debugPrint('👤 Criando marker do usuário...');
      try {
        final userIcon = await _createCustomMarkerIcon('📍');
        markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('user_location'),
            position: gmaps.LatLng(userLocation.latitude, userLocation.longitude),
            infoWindow: const gmaps.InfoWindow(
              title: '📍 Você está aqui',
              snippet: 'Sua localização atual',
            ),
            icon: userIcon,
          ),
        );
        debugPrint('✅ Marker do usuário criado');
      } catch (e) {
        debugPrint('❌ Erro ao criar marker do usuário: $e');
      }
    }

    // Adicionar marcadores dos restaurantes com emojis customizados
    for (int i = 0; i < restaurants.length; i++) {
      final restaurant = restaurants[i];
      if (restaurant.latitude != null && restaurant.longitude != null) {
        debugPrint('🍽️ Criando marker para restaurante ${i + 1}/${restaurants.length}: ${restaurant.name}');
        try {
          final emoji = _getRestaurantEmoji(restaurant);
          debugPrint('📍 Emoji selecionado: $emoji');
          
          final customIcon = await _createCustomMarkerIcon(emoji);
          
          markers.add(
            gmaps.Marker(
              markerId: gmaps.MarkerId(restaurant.id),
              position: gmaps.LatLng(restaurant.latitude!, restaurant.longitude!),
              infoWindow: gmaps.InfoWindow(
                title: '${emoji} ${restaurant.name}',
                snippet: '⭐ ${restaurant.rating?.toStringAsFixed(1) ?? 'N/A'} • ${restaurant.deliveryTime ?? 'N/A'}',
              ),
              onTap: () {
                _onRestaurantTap(restaurant);
              },
              icon: customIcon,
            ),
          );
          debugPrint('✅ Marker criado para ${restaurant.name}');
        } catch (e) {
          debugPrint('❌ Erro ao criar marker para ${restaurant.name}: $e');
        }
      } else {
        debugPrint('⚠️ Restaurante ${restaurant.name} não tem coordenadas válidas');
      }
    }

    debugPrint('🎯 Total de markers criados: ${markers.length}');
    return markers;
  }
  
  /// Carrega markers customizados de forma assíncrona
  Future<void> _loadCustomMarkers(List<RestaurantModel> restaurants, LocationModel? userLocation) async {
    debugPrint('🚀 Iniciando carregamento de markers customizados');
    debugPrint('📊 Restaurantes recebidos: ${restaurants.length}');
    debugPrint('📍 Localização do usuário: ${userLocation?.latitude}, ${userLocation?.longitude}');
    
    if (_markersLoaded) {
      debugPrint('⚠️ Markers já foram carregados, ignorando');
      return;
    }
    
    try {
      debugPrint('🔄 Criando markers customizados...');
      final markers = await _createMarkersForRestaurants(restaurants, userLocation);
      debugPrint('✅ ${markers.length} markers criados com sucesso');
      
      if (mounted) {
        debugPrint('🔄 Atualizando estado do mapa...');
        setState(() {
          _markers = markers;
          _markersLoaded = true;
          _mapKey = UniqueKey(); // Força reconstrução do GoogleMap widget
        });
        debugPrint('✅ Estado atualizado - ${_markers.length} markers agora no mapa');
        debugPrint('🔑 Nova key do mapa gerada para forçar reconstrução');
      } else {
        debugPrint('❌ Widget não está montado - não foi possível atualizar estado');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao carregar markers customizados: $e');
      debugPrint('📋 StackTrace: $stackTrace');
    }
  }
}