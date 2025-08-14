import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/location_utils.dart';
import '../../../data/models/restaurant_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/enhanced_map_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/restaurant_card.dart';

/// Página de mapa completa
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
  bool _showRestaurantList = false;
  final PageController _pageController = PageController();

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
    _pageController.dispose();
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

  void _toggleRestaurantList() {
    setState(() {
      _showRestaurantList = !_showRestaurantList;
    });
  }

  void _navigateToRestaurant(RestaurantModel restaurant) {
    context.push('/restaurant/${restaurant.id}');
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final restaurantsAsync = ref.watch(nearbyRestaurantsProvider({
      'latitude': locationState.currentLocation?.latitude ?? 0.0,
      'longitude': locationState.currentLocation?.longitude ?? 0.0,
      'maxDistance': 5.0,
    }));

    return Scaffold(
      body: Stack(
        children: [
          // Mapa principal
          restaurantsAsync.when(
            data: (restaurants) => EnhancedMapWidget(
              userLocation: locationState.currentLocation,
              restaurants: restaurants,
              onRestaurantTap: _onRestaurantTap,
              height: MediaQuery.of(context).size.height,
              showUserLocation: true,
              enableInteraction: true,
              selectedRestaurantId: _selectedRestaurant?.id,
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            error: (error, stack) => Center(
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
                    error.toString(),
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(nearbyRestaurantsProvider({
                      'latitude': locationState.currentLocation?.latitude ?? 0.0,
                      'longitude': locationState.currentLocation?.longitude ?? 0.0,
                      'maxDistance': 5.0,
                    })),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),

          // AppBar customizada
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Botão voltar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Título
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Restaurantes próximos',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Botão lista
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _toggleRestaurantList,
                      icon: Icon(
                        _showRestaurantList ? Icons.map : Icons.list,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de restaurantes (slide up)
          if (_showRestaurantList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Restaurantes',
                            style: AppTextStyles.h3,
                          ),
                          IconButton(
                            onPressed: () {
                              // Primeiro fecha a lista
                              setState(() {
                                _showRestaurantList = false;
                              });
                              // Depois volta para a página anterior
                              context.pop();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista
                    Expanded(
                      child: restaurantsAsync.when(
                        data: (restaurants) => ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RestaurantCard(
                                restaurant: restaurant,
                                onTap: () => _navigateToRestaurant(restaurant),
                                showDistance: true,
                              ),
                            );
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'Erro ao carregar restaurantes',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom sheet do restaurante selecionado
          if (_selectedRestaurant != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _bottomSheetAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      (1 - _bottomSheetAnimation.value) * 300,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Card do restaurante
                          RestaurantCard(
                            restaurant: _selectedRestaurant!,
                            onTap: () => _navigateToRestaurant(_selectedRestaurant!),
                            showDistance: true,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Botões de ação
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _closeBottomSheet,
                                  child: const Text('Fechar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _navigateToRestaurant(_selectedRestaurant!),
                                  child: const Text('Ver detalhes'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Barra de navegação
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem('Descubra', false),
              _buildBottomNavItem('Mapa', true),
              _buildBottomNavItem('Perfil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomNavTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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
}