import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_icons.dart';

/// Widget para exibir informações de entrega
class DeliveryInfoWidget extends StatelessWidget {
  final String deliveryTime;
  final double deliveryFee;
  final double? minOrderValue;
  final bool isCompact;
  final bool showMinOrder;
  final Color? textColor;
  final MainAxisAlignment alignment;

  const DeliveryInfoWidget({
    super.key,
    required this.deliveryTime,
    required this.deliveryFee,
    this.minOrderValue,
    this.isCompact = false,
    this.showMinOrder = true,
    this.textColor,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactInfo();
    }
    
    return _buildFullInfo();
  }

  Widget _buildCompactInfo() {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        _buildTimeInfo(),
        const SizedBox(width: AppDimensions.paddingMedium),
        _buildFeeInfo(),
      ],
    );
  }

  Widget _buildFullInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTimeInfo(),
            const SizedBox(width: AppDimensions.paddingMedium),
            _buildFeeInfo(),
          ],
        ),
        if (showMinOrder && minOrderValue != null && minOrderValue! > 0) ...[
          const SizedBox(height: 4),
          _buildMinOrderInfo(),
        ],
      ],
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          AppIcons.clock,
          size: isCompact ? 12 : AppDimensions.iconSmall,
          color: textColor ?? AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          deliveryTime,
          style: (isCompact ? AppTextStyles.bodySmall : AppTextStyles.bodyMedium).copyWith(
            color: textColor ?? AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeInfo() {
    final isFreeFee = deliveryFee <= 0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          AppIcons.delivery,
          size: isCompact ? 12 : AppDimensions.iconSmall,
          color: isFreeFee 
              ? AppColors.success 
              : (textColor ?? AppColors.textLight),
        ),
        const SizedBox(width: 4),
        Text(
          isFreeFee 
              ? 'Grátis' 
              : 'R\$ ${deliveryFee.toStringAsFixed(2)}',
          style: (isCompact ? AppTextStyles.bodySmall : AppTextStyles.bodyMedium).copyWith(
            color: isFreeFee 
                ? AppColors.success 
                : (textColor ?? AppColors.textLight),
            fontWeight: isFreeFee ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildMinOrderInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          AppIcons.receipt,
          size: isCompact ? 10 : 12,
          color: textColor ?? AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          'Mín. R\$ ${minOrderValue!.toStringAsFixed(2)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: textColor ?? AppColors.textLight,
            fontSize: isCompact ? 10 : 12,
          ),
        ),
      ],
    );
  }
}

/// Widget para exibir informações detalhadas de entrega
class DetailedDeliveryInfoWidget extends StatelessWidget {
  final String deliveryTime;
  final double deliveryFee;
  final double? minOrderValue;
  final String? deliveryArea;
  final List<String>? paymentMethods;
  final bool isOpen;
  final String? nextOpenTime;

  const DetailedDeliveryInfoWidget({
    super.key,
    required this.deliveryTime,
    required this.deliveryFee,
    this.minOrderValue,
    this.deliveryArea,
    this.paymentMethods,
    this.isOpen = true,
    this.nextOpenTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações de Entrega',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildInfoRow(
            icon: AppIcons.clock,
            label: 'Tempo de entrega',
            value: deliveryTime,
            valueColor: isOpen ? null : AppColors.error,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildInfoRow(
            icon: AppIcons.delivery,
            label: 'Taxa de entrega',
            value: deliveryFee <= 0 
                ? 'Grátis' 
                : 'R\$ ${deliveryFee.toStringAsFixed(2)}',
            valueColor: deliveryFee <= 0 ? AppColors.success : null,
          ),
          if (minOrderValue != null && minOrderValue! > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildInfoRow(
              icon: AppIcons.receipt,
              label: 'Pedido mínimo',
              value: 'R\$ ${minOrderValue!.toStringAsFixed(2)}',
            ),
          ],
          if (deliveryArea != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildInfoRow(
              icon: AppIcons.location,
              label: 'Área de entrega',
              value: deliveryArea!,
            ),
          ],
          if (!isOpen && nextOpenTime != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildInfoRow(
              icon: AppIcons.clock,
              label: 'Próxima abertura',
              value: nextOpenTime!,
              valueColor: AppColors.warning,
            ),
          ],
          if (paymentMethods != null && paymentMethods!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildPaymentMethods(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: AppColors.textLight,
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              AppIcons.payment,
              size: AppDimensions.iconSmall,
              color: AppColors.textLight,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              'Formas de pagamento',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: paymentMethods!.map((method) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPaymentIcon(method),
                    size: 12,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    method,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'dinheiro':
        return AppIcons.money;
      case 'cartão':
      case 'cartão de crédito':
      case 'cartão de débito':
        return AppIcons.creditCard;
      case 'pix':
        return AppIcons.pix;
      case 'vale refeição':
      case 'vale alimentação':
        return AppIcons.ticket;
      default:
        return AppIcons.payment;
    }
  }
}

/// Widget para exibir status de entrega
class DeliveryStatusWidget extends StatelessWidget {
  final String status;
  final String? estimatedTime;
  final String? trackingCode;
  final VoidCallback? onTrack;

  const DeliveryStatusWidget({
    super.key,
    required this.status,
    this.estimatedTime,
    this.trackingCode,
    this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: statusConfig.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusConfig.icon,
                size: AppDimensions.iconMedium,
                color: statusConfig.iconColor,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusConfig.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: statusConfig.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (statusConfig.subtitle != null)
                      Text(
                        statusConfig.subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusConfig.textColor.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              ),
              if (onTrack != null && trackingCode != null)
                TextButton(
                  onPressed: onTrack,
                  child: Text(
                    'Rastrear',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (estimatedTime != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              children: [
                Icon(
                  AppIcons.clock,
                  size: AppDimensions.iconSmall,
                  color: statusConfig.textColor.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  'Previsão: $estimatedTime',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusConfig.textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
          if (trackingCode != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              children: [
                Icon(
                  AppIcons.receipt,
                  size: AppDimensions.iconSmall,
                  color: statusConfig.textColor.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  'Código: $trackingCode',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusConfig.textColor.withOpacity(0.8),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  DeliveryStatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'confirmado':
      case 'confirmed':
        return DeliveryStatusConfig(
          title: 'Pedido Confirmado',
          subtitle: 'Seu pedido foi confirmado pelo restaurante',
          icon: AppIcons.checkCircle,
          iconColor: AppColors.success,
          textColor: AppColors.success,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success.withOpacity(0.3),
        );
      case 'preparando':
      case 'preparing':
        return DeliveryStatusConfig(
          title: 'Preparando',
          subtitle: 'Seu pedido está sendo preparado',
          icon: AppIcons.restaurant,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning.withOpacity(0.3),
        );
      case 'saiu_para_entrega':
      case 'out_for_delivery':
        return DeliveryStatusConfig(
          title: 'Saiu para Entrega',
          subtitle: 'Seu pedido está a caminho',
          icon: AppIcons.delivery,
          iconColor: AppColors.primary,
          textColor: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          borderColor: AppColors.primary.withOpacity(0.3),
        );
      case 'entregue':
      case 'delivered':
        return DeliveryStatusConfig(
          title: 'Entregue',
          subtitle: 'Seu pedido foi entregue com sucesso',
          icon: AppIcons.checkCircle,
          iconColor: AppColors.success,
          textColor: AppColors.success,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success.withOpacity(0.3),
        );
      case 'cancelado':
      case 'cancelled':
        return DeliveryStatusConfig(
          title: 'Cancelado',
          subtitle: 'Seu pedido foi cancelado',
          icon: AppIcons.close,
          iconColor: AppColors.error,
          textColor: AppColors.error,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error.withOpacity(0.3),
        );
      default:
        return DeliveryStatusConfig(
          title: 'Aguardando',
          subtitle: 'Aguardando confirmação do restaurante',
          icon: AppIcons.clock,
          iconColor: AppColors.textLight,
          textColor: AppColors.textDark,
          backgroundColor: AppColors.background,
          borderColor: AppColors.divider,
        );
    }
  }
}

/// Configuração para status de entrega
class DeliveryStatusConfig {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const DeliveryStatusConfig({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}