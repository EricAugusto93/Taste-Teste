import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../data/models/cart_item_model.dart';

/// Widget para exibir um item do carrinho
class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;
  final bool isEditable;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem do produto
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.primary.withOpacity(0.1),
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.fastfood,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.fastfood,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),

          // Informações do produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          // Controles de quantidade
          if (isEditable) ...[
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onDecrease,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 32,
                      alignment: Alignment.center,
                      child: Text(
                        item.quantity.toString(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onIncrease,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (onRemove != null)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            // Apenas mostra a quantidade se não for editável
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.quantity}x',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
