import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/payment_method_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/address_selection_widget.dart';
import '../../widgets/payment_method_widget.dart';
import '../../widgets/order_summary_widget.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _notesController = TextEditingController();
  Timer? _notesDebounceTimer;
  
  @override
  void dispose() {
    _notesController.dispose();
    _notesDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final cart = cartState.cart;

    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(cart, checkoutState),
      bottomNavigationBar: _buildBottomBar(cart, checkoutState),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(AppIcons.arrowLeft, color: AppColors.textPrimary),
        onPressed: () => NavigationHelper.safeGoBack(context),
      ),
      title: Text(
        'Finalizar Pedido',
        style: AppTextStyles.headingMedium,
      ),
    );
  }

  Widget _buildBody(CartModel cart, CheckoutState checkoutState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Endereço de entrega
          _buildDeliveryAddressSection(checkoutState),
          
          SizedBox(height: AppDimensions.paddingLarge),
          
          // Método de pagamento
          _buildPaymentMethodSection(checkoutState),
          
          SizedBox(height: AppDimensions.paddingLarge),
          
          // Observações do pedido
          _buildOrderNotesSection(),
          
          SizedBox(height: AppDimensions.paddingLarge),
          
          // Resumo do pedido
          OrderSummaryWidget(
            cart: cart,
            showEditButton: true,
            onEdit: () => NavigationHelper.safeGoBack(context),
          ),
          
          SizedBox(height: 100), // Espaço para o bottom bar
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressSection(CheckoutState checkoutState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Endereço de entrega',
              style: AppTextStyles.headingSmall,
            ),
            TextButton(
              onPressed: _showAddressSelection,
              child: Text(
                checkoutState.selectedAddress == null ? 'Selecionar' : 'Alterar',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppDimensions.paddingMedium),
        
        if (checkoutState.selectedAddress != null)
          _buildAddressCard(checkoutState.selectedAddress!)
        else
          _buildSelectAddressCard(),
      ],
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              _getAddressIcon(address.type),
              color: AppColors.primary,
              size: AppDimensions.iconMedium,
            ),
          ),
          SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  address.fullAddress,
                  style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildSelectAddressCard() {
    return GestureDetector(
      onTap: _showAddressSelection,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.add,
              color: AppColors.primary,
              size: AppDimensions.iconMedium,
            ),
            SizedBox(width: AppDimensions.paddingSmall),
            Text(
              'Selecionar endereço de entrega',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(CheckoutState checkoutState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Método de pagamento',
              style: AppTextStyles.headingSmall,
            ),
            TextButton(
              onPressed: _showPaymentMethodSelection,
              child: Text(
                checkoutState.selectedPaymentMethod == null ? 'Selecionar' : 'Alterar',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppDimensions.paddingMedium),
        
        if (checkoutState.selectedPaymentMethod != null)
          _buildPaymentMethodCard(checkoutState.selectedPaymentMethod!)
        else
          _buildSelectPaymentMethodCard(),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel paymentMethod) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              _getPaymentMethodIcon(paymentMethod.type),
              color: AppColors.primary,
              size: AppDimensions.iconMedium,
            ),
          ),
          SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paymentMethod.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (paymentMethod.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    paymentMethod.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectPaymentMethodCard() {
    return GestureDetector(
      onTap: _showPaymentMethodSelection,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.add,
              color: AppColors.primary,
              size: AppDimensions.iconMedium,
            ),
            SizedBox(width: AppDimensions.paddingSmall),
            Text(
              'Selecionar método de pagamento',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações do pedido',
          style: AppTextStyles.headingSmall,
        ),
        SizedBox(height: AppDimensions.paddingMedium),
        CustomTextField(
          controller: _notesController,
          hintText: 'Alguma observação especial? (opcional)',
          maxLines: 3,
          onChanged: (value) {
            _notesDebounceTimer?.cancel();
            _notesDebounceTimer = Timer(const Duration(milliseconds: 500), () {
              ref.read(checkoutNotifierProvider.notifier)
                  .updateOrderNotes(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(CartModel cart, CheckoutState checkoutState) {
    final canPlaceOrder = checkoutState.selectedAddress != null &&
        checkoutState.selectedPaymentMethod != null &&
        cart.meetsMinimumOrder;

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
                Text(
                  'Total',
                  style: AppTextStyles.headingSmall,
                ),
                Text(
                  'R\$ ${cart.total.toStringAsFixed(2)}',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            CustomButton(
              text: checkoutState.isPlacingOrder ? 'Finalizando...' : 'Finalizar Pedido',
              onPressed: canPlaceOrder && !checkoutState.isPlacingOrder
                  ? _placeOrder
                  : null,
              isLoading: checkoutState.isPlacingOrder,
            ),
            if (!canPlaceOrder && !checkoutState.isPlacingOrder) ...[
              SizedBox(height: AppDimensions.paddingSmall),
              Text(
                _getOrderValidationMessage(cart, checkoutState),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddressSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressSelectionWidget(
        onAddressSelected: (address) {
          ref.read(checkoutNotifierProvider.notifier)
              .selectAddress(address);
          NavigationHelper.safeGoBack(context);
        },
      ),
    );
  }

  void _showPaymentMethodSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentMethodWidget(
        onPaymentMethodSelected: (paymentMethod) {
          ref.read(checkoutNotifierProvider.notifier)
              .selectPaymentMethod(paymentMethod);
          NavigationHelper.safeGoBack(context);
        },
      ),
    );
  }

  Future<void> _placeOrder() async {
    try {
      final orderId = await ref.read(checkoutNotifierProvider.notifier)
          .placeOrder();
      
      if (mounted) {
        // Limpar carrinho
        await ref.read(cartNotifierProvider.notifier).clearCart();
        
        // Navegar para página de confirmação
        context.go('/order-confirmation/$orderId');
      }
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
  }

  IconData _getAddressIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit_card':
        return Icons.credit_card;
      case 'debit_card':
        return Icons.payment;
      case 'pix':
        return Icons.pix;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getOrderValidationMessage(CartModel cart, CheckoutState checkoutState) {
    if (checkoutState.selectedAddress == null) {
      return 'Selecione um endereço de entrega';
    }
    if (checkoutState.selectedPaymentMethod == null) {
      return 'Selecione um método de pagamento';
    }
    if (!cart.meetsMinimumOrder) {
      return 'Pedido não atinge o valor mínimo';
    }
    return '';
  }
}