import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/location_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/enhanced_map_widget.dart';
import '../../widgets/restaurant_card.dart';

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
  String _selectedCategory = '';

  // Categorias com cores baseadas na imagem de referência
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Date night', 'color': const Color(0xFFE67E22)},
    {'name': 'Para curar\na ressaca', 'color': const Color(0xFFE74C3C)},
    {'name': 'Com vibe\nleve', 'color': const Color(0xFF87CEEB)},
    {'name': 'Clássicos\nPOA', 'color': const Color(0xFF95A5A6)},
    {'name': 'Vontade\nde doce', 'color': const Color(0xFF9B59B6)},
    {'name': 'Almoço\nde domingo', 'color': const Color(0xFFF39C12)},
    {'name': 'Happy hour\nde firma', 'color': const Color(0xFF3498DB)},
    {'name': 'Para\ncomentar\nno insta', 'color': const Color(0xFFE67E22)},
  ];

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

  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = category;
    });
    // Aqui você pode implementar a lógica de filtro por categoria
  }

  void _navigateToRestaurant(RestaurantModel restaurant) {
    context.push('/restaurant/${restaurant.id}');
  }





  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final restaurantState = ref.watch(restaurantProvider);
    
    // Usar os restaurantes já carregados ou dados de amostra se vazio
    final nearbyRestaurants = restaurantState.restaurants.isEmpty 
        ? _getSampleRestaurants(locationState.currentLocation) 
        : restaurantState.restaurants;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header azul/roxo com gradiente
          Flexible(
            flex: 3,
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
                      // Logo/Título estilizado
                      const Center(
                        child: Text(
                          'tl',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Pergunta principal
                      const Text(
                        'Qual a sua vibe hoje?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Botão laranja
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE67E22),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'um ramen quentinho no Bom Fim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Texto pequeno
                      const Center(
                        child: Text(
                          'Veja dicas e os melhores locais da cidade',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Mapa
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                restaurantState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : restaurantState.hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar mapa',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              restaurantState.error ?? 'Erro desconhecido',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.refresh(restaurantProvider),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : EnhancedMapWidget(
                        userLocation: locationState.currentLocation,
                        restaurants: nearbyRestaurants,
                        onRestaurantTap: _onRestaurantTap,
                        height: MediaQuery.of(context).size.height,
                        showUserLocation: true,
                        enableInteraction: true,
                        selectedRestaurantId: _selectedRestaurant?.id,
                      ),



              ],
            ),
          ),
          
          // Seção de categorias
          Flexible(
            flex: 2,
            child: Container(
              color: const Color(0xFF4A5FBF),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descubra por clima',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'ocasião ou desejo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Grid de categorias
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category['name'];
                        
                        return GestureDetector(
                          onTap: () => _onCategoryTap(category['name']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: category['color'],
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected 
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                category['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Barra de navegação inferior laranja
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE67E22),
            ),
            child: SafeArea(
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem('Descubra', Icons.explore, false),
                    _buildNavItem('Mapa', Icons.map, true),
                    _buildNavItem('Perfil', Icons.person, false),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomNavTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
        // Já está no mapa, não faz nada
        break;
      case 'Perfil':
        context.go('/profile');
        break;
    }
  }

  /// Obter restaurantes de amostra perto da localização
  List<RestaurantModel> _getSampleRestaurants(LocationModel? userLocation) {
    // Se não há localização, usar coordenadas padrão de Curitiba
    final baseLat = userLocation?.latitude ?? -25.4469953;
    final baseLng = userLocation?.longitude ?? -49.1708302;
    
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
}