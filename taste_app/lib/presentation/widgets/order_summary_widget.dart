import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_icons.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/payment_method_model.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import 'widgets.dart';

class OrderSummaryWidget extends ConsumerWidget {
  final VoidCallback? onEditCart;
  final VoidCallback? onEditAddress;
  final VoidCallback? onEditPayment;
  
  const OrderSummaryWidget({
    super.key,
    this.onEditCart,
    this.onEditAddress,
    this.onEditPayment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Text(
              'Resumo do pedido',
              style: AppTextStyles.headingMedium,
            ),
          ),
          
          const Divider(height: 1),
          
          // Itens do carrinho
          _buildCartItems(cart),
          
          const Divider(height: 1),
          
          // Endereço de entrega
          if (checkoutState.selectedAddress != null)
            _buildDeliveryAddress(checkoutState.selectedAddress!),
          
          // Método de pagamento
          if (checkoutState.selectedPaymentMethod != null)
            _buildPaymentMethod(checkoutState.selectedPaymentMethod!),
          
          const Divider(height: 1),
          
          // Resumo financeiro
          _buildFinancialSummary(cart),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartModel cart) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Itens (${cart.totalItems})',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onEditCart != null)
                TextButton(
                  onPressed: onEditCart,
                  child: Text(
                    'Editar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppDimensions.paddingSmall),
          
          // Lista de itens (limitada a 3 para não ocupar muito espaço)
          ...cart.items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
            child: Row(
              children: [
                // Imagem do item
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  child: Image.network(
                    item.imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 40,
                      height: 40,
                      color: AppColors.border,
                      child: Icon(
                        AppIcons.image,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: AppDimensions.paddingSmall),
                
                // Informações do item
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.observations?.isNotEmpty == true)
                        Text(
                          item.observations!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                
                // Quantidade e preço
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
          
          // Mostrar "e mais X itens" se houver mais de 3
          if (cart.items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              child: Text(
                'e mais ${cart.items.length - 3} ${cart.items.length - 3 == 1 ? 'item' : 'itens'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(AddressModel address) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Endereço de entrega',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onEditAddress != null)
                TextButton(
                  onPressed: onEditAddress,
                  child: Text(
                    'Alterar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppDimensions.paddingSmall),
          
          Row(
            children: [
              Icon(
                _getAddressIcon(address.type),
                color: AppColors.textLight,
                size: AppDimensions.iconSmall,
              ),
              SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      address.shortAddress,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
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

  Widget _buildPaymentMethod(PaymentMethodModel paymentMethod) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Forma de pagamento',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onEditPayment != null)
                TextButton(
                  onPressed: onEditPayment,
                  child: Text(
                    'Alterar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppDimensions.paddingSmall),
          
          Row(
            children: [
              Icon(
                _getPaymentMethodIcon(paymentMethod.type),
                color: AppColors.textLight,
                size: AppDimensions.iconSmall,
              ),
              SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (paymentMethod.description.isNotEmpty)
                      Text(
                        paymentMethod.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
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

  Widget _buildFinancialSummary(CartModel cart) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          // Subtotal
          _buildSummaryRow(
            'Subtotal',
            'R\$ ${cart.subtotal.toStringAsFixed(2)}',
          ),
          
          // Taxa de entrega
          _buildSummaryRow(
            'Taxa de entrega',
            cart.deliveryFee > 0 
                ? 'R\$ ${cart.deliveryFee.toStringAsFixed(2)}'
                : 'Grátis',
            valueColor: cart.deliveryFee == 0 ? AppColors.success : null,
          ),
          
          // Taxa de serviço
          if (cart.serviceFee > 0)
            _buildSummaryRow(
              'Taxa de serviço',
              'R\$ ${cart.serviceFee.toStringAsFixed(2)}',
            ),
          
          // Desconto
          if (cart.discount > 0)
            _buildSummaryRow(
              'Desconto${cart.promoCode != null ? ' (${cart.promoCode})' : ''}',
              '- R\$ ${cart.discount.toStringAsFixed(2)}',
              valueColor: AppColors.success,
            ),
          
          SizedBox(height: AppDimensions.paddingSmall),
          const Divider(),
          SizedBox(height: AppDimensions.paddingSmall),
          
          // Total
          _buildSummaryRow(
            'Total',
            'R\$ ${cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
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
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
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
                    color: valueColor ?? AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getAddressIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return AppIcons.home;
      case 'work':
        return AppIcons.work;
      default:
        return AppIcons.location;
    }
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit_card':
      case 'debit_card':
        return AppIcons.creditCard;
      case 'pix':
        return AppIcons.qrCode;
      case 'cash':
        return AppIcons.dollar;
      case 'voucher':
        return AppIcons.gift;
      default:
        return AppIcons.creditCard;
    }
  }
}

/// Widget compacto para mostrar resumo em outras telas
class CompactOrderSummary extends ConsumerWidget {
  final VoidCallback? onTap;
  
  const CompactOrderSummary({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    
    if (cart.items.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone do carrinho
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                AppIcons.shoppingBag,
                color: AppColors.primary,
                size: AppDimensions.iconMedium,
              ),
            ),
            
            SizedBox(width: AppDimensions.paddingMedium),
            
            // Informações do pedido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.totalItems} ${cart.totalItems == 1 ? 'item' : 'itens'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (cart.restaurant != null)
                    Text(
                      cart.restaurant!.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            
            // Total e seta
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${cart.total.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    AppIcons.chevronRight,
                    color: AppColors.textLight,
                    size: AppDimensions.iconSmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}