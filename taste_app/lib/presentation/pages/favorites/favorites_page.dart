import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../domain/entities/restaurant.dart';
import '../../../data/services/real_favorites_service.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/enhanced_error_widget.dart';
import '../../widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Página para exibir os restaurantes favoritos do usuário
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  List<Restaurant> _favorites = [];
  List<Restaurant> _allRestaurants = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Dados de fallback quando o proxy não funciona
  List<Restaurant> _getLocalFallbackRestaurants() {
    return [
      Restaurant(
        id: 'local-1',
        name: 'Maki Sushi',
        description: 'Sushis fresquinhos, toque contemporâneo e a vibe perfeita para um jantar! O Maki entrega sabor e frescor em cada peça.',
        address: 'Rua General, 285, Rio Branco, Porto Alegre',
        latitude: -30.0346,
        longitude: -51.2177,
        categoryId: '1',
        rating: 4.5,
        deliveryFee: 5.0,
        deliveryTime: '30-45 min',
        isOpen: true,
        isFeatured: true,
        imageUrl: null,
        emoji: '🍣',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Restaurant(
        id: 'local-2',
        name: 'Tangamandápio',
        description: 'Tacos autorais, drinks vibrantes e uma alma latina que não se esconde. A taqueria que começou no delivery hoje tem garagem aberta.',
        address: 'Av. Plínio Brasil Milano, 20, Auxiliadora, Porto Alegre',
        latitude: -30.0346,
        longitude: -51.2177,
        categoryId: '2',
        rating: 4.5,
        deliveryFee: 5.0,
        deliveryTime: '30-45 min',
        isOpen: true,
        isFeatured: false,
        imageUrl: null,
        emoji: '🌮',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Restaurant(
        id: 'local-3',
        name: 'A Cantina do Press',
        description: 'Clássicos italianos com pegada moderna, drinks incríveis e uma energia que faz querer voltar.',
        address: 'Av. João Wallig, 1800 - loja 2264, Passo D\'areia, Porto Alegre',
        latitude: -30.0346,
        longitude: -51.2177,
        categoryId: '3',
        rating: 4.5,
        deliveryFee: 5.0,
        deliveryTime: '30-45 min',
        isOpen: true,
        isFeatured: false,
        imageUrl: null,
        emoji: '🍝',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Restaurant(
        id: 'local-4',
        name: 'You Yi',
        description: 'Receitas típicas, sabores intensos e uma história que atravessa gerações. No You Yi, a gastronomia chinesa ganha vida.',
        address: 'Rua Cândido Silveira, 242, Auxiliadora, Porto Alegre',
        latitude: -30.0346,
        longitude: -51.2177,
        categoryId: '4',
        rating: 4.5,
        deliveryFee: 5.0,
        deliveryTime: '30-45 min',
        isOpen: true,
        isFeatured: false,
        imageUrl: null,
        emoji: '🥟',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Restaurant(
        id: 'local-5',
        name: 'Green Station',
        description: 'Saladas feitas na hora, wraps fresquinhos e praticidade sem abrir mão do sabor.',
        address: 'Rua Comendador Caminha, 358, Moinhos de Vento, Porto Alegre',
        latitude: -30.0346,
        longitude: -51.2177,
        categoryId: '5',
        rating: 4.5,
        deliveryFee: 5.0,
        deliveryTime: '30-45 min',
        isOpen: true,
        isFeatured: false,
        imageUrl: null,
        emoji: '🥗',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('🔍 Carregando dados de favoritos...');
      
      final currentUser = Supabase.instance.client.auth.currentUser;
      final String? userId = currentUser?.id;
      
      debugPrint('👤 Usuário atual: $userId');
      
      // Tentar buscar dados do proxy primeiro, com fallback para dados locais
      if (userId == null || userId == 'anonymous') {
        debugPrint('⚠️ Usuário não autenticado ou anônimo, tentando buscar amostra de restaurantes');
        try {
          _favorites = await RealFavoritesService.getSampleRestaurants(limit: 8);
          _allRestaurants = await RealFavoritesService.getAllRestaurants();
        } catch (e) {
          debugPrint('❌ Erro no proxy, usando dados de fallback locais: $e');
          _favorites = _getLocalFallbackRestaurants();
          _allRestaurants = _getLocalFallbackRestaurants();
        }
      } else {
        debugPrint('✅ Usuário autenticado, buscando favoritos reais');
        try {
          _favorites = await RealFavoritesService.getFavoritesByUser(userId);
          if (_favorites.isEmpty) {
            debugPrint('📋 Nenhum favorito real, buscando amostra');
            try {
              _favorites = await RealFavoritesService.getSampleRestaurants(limit: 8);
            } catch (e) {
              debugPrint('❌ Erro no proxy para amostra, usando dados locais: $e');
              _favorites = _getLocalFallbackRestaurants();
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao buscar favoritos reais, usando dados locais: $e');
          _favorites = _getLocalFallbackRestaurants();
        }
        
        try {
          _allRestaurants = await RealFavoritesService.getAllRestaurants();
        } catch (e) {
          debugPrint('⚠️ Erro ao buscar todos os restaurantes, usando dados locais: $e');
          _allRestaurants = _getLocalFallbackRestaurants();
        }
      }
      
      debugPrint('✅ ${_favorites.length} favoritos carregados');
      debugPrint('✅ ${_allRestaurants.length} restaurantes totais disponíveis');
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados: $e');
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A5FBF),
      appBar: AppBar(
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF4A5FBF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return EnhancedErrorWidget(
        title: 'Erro ao carregar favoritos',
        message: _error!,
        onRetry: _loadData,
        errorType: ErrorType.general,
      );
    }

    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildFavoritesList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF4A5FBF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seus favoritos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_favorites.length} restaurantes salvos',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final restaurant = _favorites[index];
        return _buildRestaurantCard(restaurant);
      },
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey[300],
              child: restaurant.imageUrl != null
                  ? Image.network(
                      restaurant.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      restaurant.emoji ?? '🍽️',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (restaurant.description != null)
                  Text(
                    restaurant.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${restaurant.rating?.toStringAsFixed(1) ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant.address ?? 'Endereço não informado',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 64,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum favorito ainda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Explore restaurantes e adicione os que você gosta aos favoritos!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.safeGoBack(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF4A5FBF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Explorar restaurantes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
