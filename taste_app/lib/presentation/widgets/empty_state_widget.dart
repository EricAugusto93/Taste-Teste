import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import 'custom_button.dart';

/// Widget para estados vazios com emoji e mensagens específicas
class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  final bool showAction;
  final double? emojiSize;
  final EdgeInsetsGeometry? padding;
  
  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionTap,
    this.showAction = true,
    this.emojiSize,
    this.padding,
  });
  
  // Factory constructors para estados específicos
  
  /// Estado vazio para busca sem resultados
  factory EmptyStateWidget.searchEmpty({
    String? query,
    VoidCallback? onClearFilters,
  }) {
    return EmptyStateWidget(
      emoji: '🔍',
      title: 'Nenhum resultado encontrado',
      subtitle: query != null 
          ? 'Não encontramos resultados para "$query".\nTente buscar com outras palavras.'
          : 'Digite algo para buscar restaurantes,\npratos ou categorias.',
      actionText: query != null ? 'Limpar filtros' : null,
      onActionTap: onClearFilters,
      showAction: query != null,
    );
  }
  
  /// Estado vazio para favoritos
  factory EmptyStateWidget.favoritesEmpty({
    VoidCallback? onExplore,
  }) {
    return EmptyStateWidget(
      emoji: '❤️',
      title: 'Nenhum favorito ainda',
      subtitle: 'Explore restaurantes e adicione\nseus favoritos aqui.',
      actionText: 'Explorar restaurantes',
      onActionTap: onExplore,
    );
  }
  
  /// Estado vazio para pedidos
  factory EmptyStateWidget.ordersEmpty({
    VoidCallback? onStartOrder,
  }) {
    return EmptyStateWidget(
      emoji: '📦',
      title: 'Nenhum pedido ainda',
      subtitle: 'Quando você fizer seu primeiro\npedido, ele aparecerá aqui.',
      actionText: 'Fazer primeiro pedido',
      onActionTap: onStartOrder,
    );
  }
  
  /// Estado vazio para carrinho
  factory EmptyStateWidget.cartEmpty({
    VoidCallback? onAddItems,
  }) {
    return EmptyStateWidget(
      emoji: '🛒',
      title: 'Seu carrinho está vazio',
      subtitle: 'Adicione itens deliciosos\npara continuar.',
      actionText: 'Explorar cardápio',
      onActionTap: onAddItems,
    );
  }
  
  /// Estado vazio para notificações
  factory EmptyStateWidget.notificationsEmpty() {
    return const EmptyStateWidget(
      emoji: '🔔',
      title: 'Nenhuma notificação',
      subtitle: 'Você está em dia!\nNão há notificações pendentes.',
      showAction: false,
    );
  }
  
  /// Estado vazio para endereços
  factory EmptyStateWidget.addressesEmpty({
    VoidCallback? onAddAddress,
  }) {
    return EmptyStateWidget(
      emoji: '📍',
      title: 'Nenhum endereço salvo',
      subtitle: 'Adicione um endereço para\nfacilitar suas entregas.',
      actionText: 'Adicionar endereço',
      onActionTap: onAddAddress,
    );
  }
  
  /// Estado vazio para cartões de pagamento
  factory EmptyStateWidget.cardsEmpty({
    VoidCallback? onAddCard,
  }) {
    return EmptyStateWidget(
      emoji: '💳',
      title: 'Nenhum cartão salvo',
      subtitle: 'Adicione um cartão para\npagamentos mais rápidos.',
      actionText: 'Adicionar cartão',
      onActionTap: onAddCard,
    );
  }
  
  /// Estado de erro de conexão
  factory EmptyStateWidget.connectionError({
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      emoji: '📡',
      title: 'Sem conexão',
      subtitle: 'Verifique sua conexão com\na internet e tente novamente.',
      actionText: 'Tentar novamente',
      onActionTap: onRetry,
    );
  }
  
  /// Estado de erro genérico
  factory EmptyStateWidget.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      emoji: '⚠️',
      title: 'Algo deu errado',
      subtitle: message ?? 'Ocorreu um erro inesperado.\nTente novamente em alguns instantes.',
      actionText: 'Tentar novamente',
      onActionTap: onRetry,
    );
  }
  
  /// Estado de manutenção
  factory EmptyStateWidget.maintenance() {
    return const EmptyStateWidget(
      emoji: '🔧',
      title: 'Em manutenção',
      subtitle: 'Estamos trabalhando para\nmelhorar sua experiência.',
      showAction: false,
    );
  }
  
  /// Estado de localização desabilitada
  factory EmptyStateWidget.locationDisabled({
    VoidCallback? onEnableLocation,
  }) {
    return EmptyStateWidget(
      emoji: '📍',
      title: 'Localização desabilitada',
      subtitle: 'Permita o acesso à localização\npara encontrar restaurantes próximos.',
      actionText: 'Habilitar localização',
      onActionTap: onEnableLocation,
    );
  }
  
  /// Estado de restaurantes fechados
  factory EmptyStateWidget.restaurantsClosed() {
    return const EmptyStateWidget(
      emoji: '🌙',
      title: 'Restaurantes fechados',
      subtitle: 'A maioria dos restaurantes\nestá fechada neste horário.',
      showAction: false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji
          Text(
            emoji,
            style: TextStyle(
              fontSize: emojiSize ?? 64,
            ),
          ),
          
          SizedBox(height: AppDimensions.paddingLarge),
          
          // Título
          Text(
            title,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppDimensions.paddingMedium),
          
          // Subtítulo
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Botão de ação
          if (showAction && actionText != null && onActionTap != null) ...[
            SizedBox(height: AppDimensions.paddingXLarge),
            CustomButton(
              text: actionText!,
              onPressed: onActionTap,
              width: 200,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para estado de carregamento com mensagem
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final Color? indicatorColor;
  final double? indicatorSize;
  
  const LoadingStateWidget({
    super.key,
    this.message,
    this.showMessage = true,
    this.indicatorColor,
    this.indicatorSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: indicatorSize ?? 40,
            height: indicatorSize ?? 40,
            child: CircularProgressIndicator(
              color: indicatorColor ?? AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          
          if (showMessage) ...[
            SizedBox(height: AppDimensions.paddingLarge),
            Text(
              message ?? 'Carregando...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para estado de sucesso com animação
class SuccessStateWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  final bool autoHide;
  final Duration autoHideDuration;
  
  const SuccessStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionTap,
    this.autoHide = false,
    this.autoHideDuration = const Duration(seconds: 3),
  });
  
  @override
  State<SuccessStateWidget> createState() => _SuccessStateWidgetState();
}

class _SuccessStateWidgetState extends State<SuccessStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    
    if (widget.autoHide) {
      Future.delayed(widget.autoHideDuration, () {
        if (mounted) {
          _animationController.reverse();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone de sucesso animado
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: AppDimensions.paddingLarge),
          
          // Título
          Text(
            widget.title,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppDimensions.paddingMedium),
          
          // Subtítulo
          Text(
            widget.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Botão de ação
          if (widget.actionText != null && widget.onActionTap != null) ...[
            SizedBox(height: AppDimensions.paddingXLarge),
            CustomButton(
              text: widget.actionText!,
              onPressed: widget.onActionTap,
              width: 200,
            ),
          ],
        ],
      ),
    );
  }
}