import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'discovery_provider.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/loading_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DiscoveryPage extends ConsumerWidget {
  final String categoryId;

  const DiscoveryPage({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider(categoryId));
    final notifier = ref.read(discoveryProvider(categoryId).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header azul
            _buildHeader(context, state),
            
            // Conteúdo principal
            Expanded(
              child: _buildContent(context, state, notifier),
            ),
            
            // Barra de navegação inferior
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DiscoveryState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Barra superior com logo e botão voltar
          Row(
            children: [
              // Botão de voltar
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // Logo centralizado
              Expanded(
                child: Center(
                  child: Text(
                    'tt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              
              // Espaço para balancear o botão de voltar
              const SizedBox(width: 44),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Texto principal
          Text(
            'Encontramos Lugares\ncom a sua cara',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Mapa pequeno
          _buildMiniMap(state),
        ],
      ),
    );
  }

  Widget _buildMiniMap(DiscoveryState state) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: state.userLocation != null
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    state.userLocation?.latitude ?? 0.0,
                    state.userLocation?.longitude ?? 0.0,
                  ),
                  zoom: 13,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('user_location'),
                    position: LatLng(
                      state.userLocation?.latitude ?? 0.0,
                      state.userLocation?.longitude ?? 0.0,
                    ),
                    infoWindow: const InfoWindow(title: 'Sua localização'),
                  ),
                  ...state.restaurants.map(
                    (restaurant) => Marker(
                      markerId: MarkerId(restaurant.id),
                      position: LatLng(
                        restaurant.latitude ?? 0.0,
                        restaurant.longitude ?? 0.0,
                      ),
                      infoWindow: InfoWindow(title: restaurant.name),
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
              )
            : Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Localização não disponível',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DiscoveryState state, DiscoveryNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (state.error != null) {
      return _buildErrorState(state.error!, notifier);
    }

    if (!state.hasLocationPermission) {
      return _buildLocationPermissionRequest(notifier);
    }

    if (state.restaurants.isEmpty) {
              return _buildEmptyState();
            }

    return _buildRestaurantsList(context, state, notifier);
  }

  Widget _buildErrorState(String error, DiscoveryNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => notifier.retry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionRequest(DiscoveryNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.mapPin,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Precisamos da sua localização',
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Para encontrar restaurantes próximos a você, precisamos acessar sua localização.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => notifier.requestLocationPermission(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Permitir localização'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji triste
              const Text(
                '😞',
                style: TextStyle(
                  fontSize: 64,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Texto principal
              const Text(
                'Hmm... não encontramos nada\ncom esse perfil por aqui.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Texto secundário
              const Text(
                'Que tal tentar em outro bairro\nou ajustar sua busca?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantsList(BuildContext context, DiscoveryState state, DiscoveryNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informações da busca
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.all(20),
          child: Text(
            'Para você: (aqui incluir o que a pessoa procurou - COM IA)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        
        // Lista de restaurantes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = state.restaurants[index];
              final distance = notifier.getDistanceToRestaurant(restaurant);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCustomRestaurantCard(context, restaurant, distance),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRestaurantCard(BuildContext context, dynamic restaurant, double? distance) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagem do restaurante
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.white.withOpacity(0.2),
                child: restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty
                    ? Image.network(
                        restaurant.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            LucideIcons.utensils,
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      )
                    : const Icon(
                        LucideIcons.utensils,
                        color: Colors.white,
                        size: 32,
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Informações do restaurante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do restaurante
                  Text(
                    'Nome do restaurante:',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Categoria e nome
                  Text(
                    '(${restaurant.category ?? 'pnt'}) ${restaurant.name ?? 'Bairro'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Descrição
                  Text(
                    'Breve descrição (resumida do perfil)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Avaliação
                  Row(
                    children: [
                      // Estrelas
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < (restaurant.rating?.floor() ?? 4)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Nota
                      Text(
                        '${restaurant.rating?.toStringAsFixed(1) ?? '4.7'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
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
              _buildBottomNavItem(context, 'Descubra', true),
              _buildBottomNavItem(context, 'Mapa', false),
              _buildBottomNavItem(context, 'Perfil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomNavTap(context, label),
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

  void _onBottomNavTap(BuildContext context, String label) {
    switch (label) {
      case 'Descubra':
        // Já está na página de descoberta, não faz nada
        break;
      case 'Mapa':
        context.go('/search');
        break;
      case 'Perfil':
        context.go('/profile');
        break;
    }
  }
}
