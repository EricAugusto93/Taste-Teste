import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/cart_item_widget.dart';
import '../../widgets/promo_code_widget.dart';
import '../../widgets/delivery_info_widget.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _promoCodeController = TextEditingController();
  bool _showPromoCode = false;

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final cart = cartState.cart;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(cart),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? _buildEmptyCart()
              : _buildCartContent(cart),
      bottomNavigationBar: cart.isNotEmpty ? _buildBottomBar(cart) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(CartModel cart) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(AppIcons.back, color: AppColors.textPrimary),
        onPressed: () => NavigationHelper.safeGoBack(context),
      ),
      title: Text(
        'Carrinho',
        style: AppTextStyles.headingMedium,
      ),
      actions: [
        if (cart.isNotEmpty)
          TextButton(
            onPressed: _showClearCartDialog,
            child: const Text(
              'Limpar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return EmptyStateWidget.cartEmpty(
      onAddItems: () {
        context.go('/home');
      },
    );
  }

  Widget _buildCartContent(CartModel cart) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações do restaurante
                if (cart.restaurant != null)
                  _buildRestaurantInfo(cart.restaurant!),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Lista de itens
                _buildItemsList(cart.items),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Código promocional
                _buildPromoCodeSection(cart),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Informações de entrega
                DeliveryInfoWidget(
                  deliveryTime: '30-45 min',
                  deliveryFee: cart.deliveryFee,
                ),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Resumo do pedido
                _buildOrderSummary(cart),

                const SizedBox(height: 100), // Espaço para o bottom bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo(dynamic restaurant) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(
              AppIcons.restaurant,
              color: AppColors.primary,
              size: AppDimensions.iconMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name ?? 'Restaurante',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.address ?? 'Endereço não disponível',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<CartItemModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itens do pedido',
          style: AppTextStyles.headingSmall,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        ...items.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: CartItemWidget(
                item: item,
                onIncrease: () {
                  ref
                      .read(cartNotifierProvider.notifier)
                      .updateItemQuantity(item.id, item.quantity + 1);
                },
                onDecrease: () {
                  if (item.quantity > 1) {
                    ref
                        .read(cartNotifierProvider.notifier)
                        .updateItemQuantity(item.id, item.quantity - 1);
                  }
                },
                onRemove: () {
                  ref.read(cartNotifierProvider.notifier).removeItem(item.id);
                },
              ),
            )),
      ],
    );
  }

  Widget _buildPromoCodeSection(CartModel cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Código promocional',
              style: AppTextStyles.headingSmall,
            ),
            if (!_showPromoCode && cart.promoCode == null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPromoCode = true;
                  });
                },
                child: Text(
                  'Adicionar',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        if (cart.promoCode != null) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  AppIcons.checkCircle,
                  color: AppColors.success,
                  size: AppDimensions.iconSmall,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(
                    'Código ${cart.promoCode} aplicado',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(cartNotifierProvider.notifier).removePromoCode();
                  },
                  child: Text(
                    'Remover',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_showPromoCode) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          PromoCodeWidget(
            onApply: (code) async {
              try {
                await ref
                    .read(cartNotifierProvider.notifier)
                    .applyPromoCode(code);
                setState(() {
                  _showPromoCode = false;
                });
                _promoCodeController.clear();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary(CartModel cart) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do pedido',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildSummaryRow(
              'Subtotal', 'R\$ ${cart.subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow(
              'Taxa de entrega', 'R\$ ${cart.deliveryFee.toStringAsFixed(2)}'),
          _buildSummaryRow(
              'Taxa de serviço', 'R\$ ${cart.serviceFee.toStringAsFixed(2)}'),
          if (cart.discount > 0)
            _buildSummaryRow(
              'Desconto',
              '- R\$ ${cart.discount.toStringAsFixed(2)}',
              color: AppColors.success,
            ),
          const Divider(height: AppDimensions.paddingLarge),
          _buildSummaryRow(
            'Total',
            'R\$ ${cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          if (!cart.meetsMinimumOrder &&
              cart.restaurant?.minOrderValue != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(
                    AppIcons.warning,
                    color: AppColors.warning,
                    size: AppDimensions.iconSmall,
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: Text(
                      'Pedido mínimo: R\$ ${cart.restaurant!.minOrderValue!.toStringAsFixed(2)}\n'
                      'Faltam: R\$ ${cart.remainingForMinimumOrder.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                : AppTextStyles.bodyMedium.copyWith(color: color),
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartModel cart) {
    final canProceed = cart.meetsMinimumOrder && cart.allItemsAvailable;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      'R\$ ${cart.total.toStringAsFixed(2)}',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: AppDimensions.paddingMedium),
                    child: CustomButton(
                      text:
                          canProceed ? 'Finalizar Pedido' : 'Pedido Incompleto',
                      onPressed: canProceed ? _proceedToCheckout : null,
                      isLoading: ref.watch(cartSavingProvider),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout() {
    context.push('/checkout');
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar carrinho'),
        content: const Text(
          'Tem certeza que deseja remover todos os itens do carrinho?',
        ),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.safeGoBack(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              NavigationHelper.safeGoBack(context);
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            child: const Text(
              'Limpar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
