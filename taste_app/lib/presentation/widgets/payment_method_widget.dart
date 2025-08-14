import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_icons.dart';
import '../../data/models/payment_method_model.dart';
import '../providers/checkout_provider.dart';
import 'widgets.dart';

class PaymentMethodWidget extends ConsumerStatefulWidget {
  final Function(PaymentMethodModel) onPaymentMethodSelected;
  
  const PaymentMethodWidget({
    super.key,
    required this.onPaymentMethodSelected,
  });

  @override
  ConsumerState<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends ConsumerState<PaymentMethodWidget> {
  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final paymentMethods = checkoutState.paymentMethods;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Forma de pagamento',
                  style: AppTextStyles.headingMedium,
                ),
                TextButton(
                  onPressed: _showAddPaymentMethodDialog,
                  child: Text(
                    'Adicionar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de métodos de pagamento
          Flexible(
            child: paymentMethods.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                    ),
                    itemCount: paymentMethods.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: AppDimensions.paddingSmall,
                    ),
                    itemBuilder: (context, index) {
                      final paymentMethod = paymentMethods[index];
                      final isSelected = checkoutState.selectedPaymentMethod?.id == paymentMethod.id;
                      
                      return _buildPaymentMethodCard(paymentMethod, isSelected);
                    },
                  ),
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.creditCard,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'Nenhum método de pagamento',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Adicione um método de pagamento para continuar',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          CustomButton(
            text: 'Adicionar método',
            onPressed: _showAddPaymentMethodDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel paymentMethod, bool isSelected) {
    return GestureDetector(
      onTap: paymentMethod.isEnabled 
          ? () => widget.onPaymentMethodSelected(paymentMethod)
          : null,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1) 
              : paymentMethod.isEnabled 
                  ? AppColors.background 
                  : AppColors.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone do método de pagamento
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                _getPaymentMethodIcon(paymentMethod.type),
                color: isSelected 
                    ? AppColors.primary 
                    : paymentMethod.isEnabled 
                        ? AppColors.textLight 
                        : AppColors.textLight.withOpacity(0.5),
                size: AppDimensions.iconMedium,
              ),
            ),
            
            const SizedBox(width: AppDimensions.paddingMedium),
            
            // Informações do método de pagamento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentMethod.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppColors.primary 
                          : paymentMethod.isEnabled 
                              ? AppColors.textPrimary 
                              : AppColors.textLight.withOpacity(0.5),
                    ),
                  ),
                  if (paymentMethod.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      paymentMethod.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: paymentMethod.isEnabled 
                            ? AppColors.textLight 
                            : AppColors.textLight.withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (!paymentMethod.isEnabled) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Indisponível',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Informações adicionais (para cartões)
            if (paymentMethod.isCardType && paymentMethod.metadata.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (paymentMethod.metadata['lastFourDigits'] != null)
                    Text(
                      '•••• ${paymentMethod.metadata['lastFourDigits']}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                        fontFamily: 'monospace',
                      ),
                    ),
                  if (paymentMethod.metadata['brand'] != null)
                    Text(
                      paymentMethod.metadata['brand'].toString().toUpperCase(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
            ],
            
            // Indicador de seleção
            if (isSelected)
              Icon(
                AppIcons.check,
                color: AppColors.primary,
                size: AppDimensions.iconMedium,
              ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentMethodFormDialog(
        onSave: (paymentMethod) async {
          try {
            // Simular adição do método de pagamento
            // Em uma implementação real, isso seria feito através do provider
            if (mounted) {
              NavigationHelper.safeGoBack(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Método de pagamento adicionado com sucesso'),
                  backgroundColor: AppColors.success,
                ),
              );
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
        },
      ),
    );
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

/// Dialog para adicionar método de pagamento
class PaymentMethodFormDialog extends StatefulWidget {
  final Function(PaymentMethodModel) onSave;
  
  const PaymentMethodFormDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<PaymentMethodFormDialog> createState() => _PaymentMethodFormDialogState();
}

class _PaymentMethodFormDialogState extends State<PaymentMethodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  String _selectedType = PaymentMethodType.creditCard;
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Text(
              'Adicionar método de pagamento',
              style: AppTextStyles.headingMedium,
            ),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Seleção do tipo
            _buildPaymentTypeSelector(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Formulário baseado no tipo
            if (_selectedType == PaymentMethodType.creditCard || 
                _selectedType == PaymentMethodType.debitCard)
              _buildCardForm()
            else
              _buildOtherPaymentForm(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    onPressed: _isLoading ? null : () => NavigationHelper.safeGoBack(context),
                    variant: ButtonVariant.outlined,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: CustomButton(
                    text: _isLoading ? 'Salvando...' : 'Salvar',
                    onPressed: _isLoading ? null : _savePaymentMethod,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    final types = [
      PaymentMethodType.creditCard,
      PaymentMethodType.debitCard,
      PaymentMethodType.pix,
      PaymentMethodType.cash,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de pagamento',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          children: types.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPaymentMethodIcon(type),
                      size: AppDimensions.iconSmall,
                      color: isSelected ? AppColors.primary : AppColors.textLight,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      PaymentMethodType.getLabel(type),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Número do cartão
          CustomTextField(
            controller: _cardNumberController,
            labelText: 'Número do cartão',
            hintText: '0000 0000 0000 0000',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              if (value.replaceAll(' ', '').length < 16) {
                return 'Número do cartão inválido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Nome do portador
          CustomTextField(
            controller: _cardHolderController,
            labelText: 'Nome do portador',
            hintText: 'Como está no cartão',
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Data de validade e CVV
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _expiryDateController,
                  labelText: 'Validade',
                  hintText: 'MM/AA',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                      return 'Formato inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: CustomTextField(
                  controller: _cvvController,
                  labelText: 'CVV',
                  hintText: '000',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (value.length < 3) {
                      return 'CVV inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherPaymentForm() {
    String description = '';
    
    switch (_selectedType) {
      case PaymentMethodType.pix:
        description = 'PIX será processado na hora da entrega';
        break;
      case PaymentMethodType.cash:
        description = 'Pagamento em dinheiro na entrega';
        break;
      default:
        description = 'Método de pagamento será configurado';
    }
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.info,
            color: AppColors.primary,
            size: AppDimensions.iconMedium,
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePaymentMethod() async {
    // Para cartões, validar formulário
    if ((_selectedType == PaymentMethodType.creditCard || 
         _selectedType == PaymentMethodType.debitCard) &&
        !_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final paymentMethod = PaymentMethodFactory.createCustom(
        type: _selectedType,
        name: _getPaymentMethodName(),
        description: _getPaymentMethodDescription(),
        metadata: _getPaymentMethodMetadata(),
      );
      
      widget.onSave(paymentMethod);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getPaymentMethodName() {
    switch (_selectedType) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        final lastFour = cardNumber.length >= 4 
            ? cardNumber.substring(cardNumber.length - 4)
            : cardNumber;
        return '${PaymentMethodType.getLabel(_selectedType)} •••• $lastFour';
      default:
        return PaymentMethodType.getLabel(_selectedType);
    }
  }

  String _getPaymentMethodDescription() {
    switch (_selectedType) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return _cardHolderController.text.trim();
      case PaymentMethodType.pix:
        return 'Pagamento instantâneo';
      case PaymentMethodType.cash:
        return 'Dinheiro na entrega';
      default:
        return '';
    }
  }

  Map<String, dynamic> _getPaymentMethodMetadata() {
    switch (_selectedType) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        return {
          'lastFourDigits': cardNumber.length >= 4 
              ? cardNumber.substring(cardNumber.length - 4)
              : cardNumber,
          'cardHolder': _cardHolderController.text.trim(),
          'expiryDate': _expiryDateController.text.trim(),
          'brand': _detectCardBrand(cardNumber),
        };
      default:
        return {};
    }
  }

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'Amex';
    return 'Outros';
  }
}