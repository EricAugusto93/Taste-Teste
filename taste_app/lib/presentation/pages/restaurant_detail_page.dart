import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/navigation_helper.dart';
import '../widgets/rating_stars_widget.dart';
import '../widgets/error_widget.dart';

/// Página de detalhes do restaurante
class RestaurantDetailPage extends StatefulWidget {
  final RestaurantModel restaurant;
  final LocationModel? userLocation;
  final LocationRepository? locationRepository;

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
    this.userLocation,
    this.locationRepository,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScale;
  
  bool _isHeaderCollapsed = false;
  bool _isFavorite = false;
  String? _distance;
  
  static const double _headerHeight = 300.0;
  static const double _collapsedHeaderHeight = 100.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollController();
    _calculateDistance();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _headerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fabScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _fabAnimationController.forward();
  }

  void _setupScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    const threshold = _headerHeight - _collapsedHeaderHeight;
    final offset = _scrollController.offset;
    
    if (offset > threshold && !_isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = true;
      });
      _headerAnimationController.forward();
    } else if (offset <= threshold && _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = false;
      });
      _headerAnimationController.reverse();
    }
  }

  Future<void> _calculateDistance() async {
    if (widget.locationRepository == null || 
        widget.userLocation == null ||
        widget.restaurant.latitude == null ||
        widget.restaurant.longitude == null) {
      return;
    }

    try {
      final restaurantLocation = LocationModel(
        latitude: widget.restaurant.latitude!,
        longitude: widget.restaurant.longitude!,
      );
      
      final distance = await widget.locationRepository!.calculateDistance(
        widget.userLocation!,
        restaurantLocation,
      );
      
      final formattedDistance = widget.locationRepository!.formatDistance(distance);
      final estimatedTime = _calculateEstimatedTime(distance);
      
      if (mounted) {
        setState(() {
          _distance = formattedDistance;
          _estimatedTime = estimatedTime;
        });
      }
    } catch (e) {
      Logger.error('Erro ao calcular distância: $e');
    }
  }

  String _calculateEstimatedTime(double distanceInKm) {
    final timeInHours = distanceInKm / 30.0;
    final timeInMinutes = (timeInHours * 60).round();
    
    if (timeInMinutes < 60) {
      return '${timeInMinutes} min';
    } else {
      final hours = timeInMinutes ~/ 60;
      final minutes = timeInMinutes % 60;
      return '${hours}h ${minutes}min';
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    HapticFeedback.lightImpact();
    
    _fabAnimationController.reverse().then((_) {
      _fabAnimationController.forward();
    });
    
    try {
      Logger.info('Restaurante ${_isFavorite ? "adicionado aos" : "removido dos"} favoritos');
    } catch (e) {
      Logger.error('Erro ao alterar favorito: $e');
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  Future<void> _openDirections() async {
    if (widget.restaurant.latitude == null || widget.restaurant.longitude == null) {
      _showSnackBar('Localização do restaurante não disponível');
      return;
    }
    
    try {
      final lat = widget.restaurant.latitude!;
      final lng = widget.restaurant.longitude!;
      final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Não foi possível abrir o mapa');
      }
    } catch (e) {
      Logger.error('Erro ao abrir direções: $e');
      _showSnackBar('Erro ao abrir direções');
    }
  }

  Future<void> _makePhoneCall() async {
    if (widget.restaurant.phone == null || widget.restaurant.phone!.isEmpty) {
      _showSnackBar('Telefone não disponível');
      return;
    }
    
    try {
      final phoneUrl = 'tel:${widget.restaurant.phone}';
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        _showSnackBar('Não foi possível fazer a ligação');
      }
    } catch (e) {
      Logger.error('Erro ao fazer ligação: $e');
      _showSnackBar('Erro ao fazer ligação');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
      ),
    );
  }

  String _getRestaurantEmoji(String? categoryId) {
    switch (categoryId?.toLowerCase()) {
      case 'pizza':
        return '🍕';
      case 'burger':
      case 'hamburguer':
        return '🍔';
      case 'sushi':
      case 'japonesa':
        return '🍣';
      case 'italiana':
        return '🍝';
      case 'chinesa':
        return '🥡';
      case 'mexicana':
        return '🌮';
      case 'brasileira':
        return '🍖';
      case 'doces':
      case 'sobremesa':
        return '🍰';
      case 'bebidas':
        return '🥤';
      case 'cafe':
        return '☕';
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildContent(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _headerHeight,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeGoBack(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _showSnackBar('Funcionalidade de compartilhamento em desenvolvimento');
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary,
                  ],
                ),
              ),
              child: widget.restaurant.imageUrl != null
                  ? Image.network(
                      widget.restaurant.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary,
                          child: Center(
                            child: Text(
                              _getRestaurantEmoji(widget.restaurant.categoryId),
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        _getRestaurantEmoji(widget.restaurant.categoryId),
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (widget.restaurant.description != null)
                    Text(
                      widget.restaurant.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      RatingStarsWidget(
                        rating: widget.restaurant.rating,
                        size: 20,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.restaurant.rating.toStringAsFixed(1),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 16),
                      if (_distance != null) ...[
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(width: 4),
                        Text(
                          _distance!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (widget.restaurant.deliveryTime != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.restaurant.deliveryTime} min',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            _buildInfoSection(),
            _buildMapSection(),
            _buildMenuSection(),
            _buildReviewsSection(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.padding),
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
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
          Text(
            'Informações',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            'Status',
            widget.restaurant.isOpen ? 'Aberto agora' : 'Fechado',
            valueColor: widget.restaurant.isOpen ? AppColors.success : AppColors.error,
          ),
          if (widget.restaurant.deliveryTime != null)
            _buildInfoRow(
              Icons.delivery_dining,
              'Tempo de entrega',
              '${widget.restaurant.deliveryTime} min',
            ),
          if (widget.restaurant.deliveryFee != null)
            _buildInfoRow(
              Icons.attach_money,
              'Taxa de entrega',
              widget.restaurant.deliveryFee! > 0
                  ? 'R\$ ${widget.restaurant.deliveryFee!.toStringAsFixed(2)}'
                  : 'Grátis',
              valueColor: widget.restaurant.deliveryFee! > 0 ? null : AppColors.success,
            ),
          if (widget.restaurant.minimumOrder != null)
            _buildInfoRow(
              Icons.shopping_cart,
              'Pedido mínimo',
              'R\$ ${widget.restaurant.minimumOrder!.toStringAsFixed(2)}',
            ),
          if (widget.restaurant.phone != null && widget.restaurant.phone!.isNotEmpty)
            _buildInfoRow(
              Icons.phone,
              'Telefone',
              widget.restaurant.phone!,
              onTap: _makePhoneCall,
            ),
          if (widget.restaurant.address != null)
            _buildInfoRow(
              Icons.location_on,
              'Endereço',
              widget.restaurant.address!,
              onTap: _openDirections,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: valueColor ?? AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding,
        vertical: AppDimensions.paddingSmall,
      ),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.background,
              child: const Center(
                child: Text(
                  'Mapa do Restaurante\n(Implementação futura)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding,
        vertical: AppDimensions.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cardápio',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navegar para página completa do cardápio
                },
                child: Text('Ver tudo'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Cardápio completo disponível em breve',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding,
        vertical: AppDimensions.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avaliações',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navegar para página de avaliações
                },
                child: Text('Ver todas'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              RatingStarsWidget(
                rating: widget.restaurant.rating,
                size: 24,
                color: AppColors.warning,
              ),
              SizedBox(width: 8),
              Text(
                widget.restaurant.rating.toStringAsFixed(1),
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(${widget.restaurant.reviewCount ?? 0} avaliações)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Avaliações detalhadas disponíveis em breve',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _fabScale,
          child: FloatingActionButton(
            heroTag: 'favorite',
            onPressed: _toggleFavorite,
            backgroundColor: _isFavorite ? AppColors.error : AppColors.surface,
            foregroundColor: _isFavorite ? Colors.white : AppColors.textPrimary,
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ),
        SizedBox(height: 16),
        ScaleTransition(
          scale: _fabScale,
          child: FloatingActionButton.extended(
            heroTag: 'order',
            onPressed: () {
              // TODO: Implementar navegação para carrinho/pedido
              _showSnackBar('Funcionalidade de pedido em desenvolvimento');
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icon(Icons.shopping_cart),
            label: Text('Pedir'),
          ),
        ),
      ],
    );
  }
}