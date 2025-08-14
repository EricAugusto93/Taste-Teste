import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/models/address_model.dart';
import '../providers/checkout_provider.dart';
import 'widgets.dart';

class AddressSelectionWidget extends ConsumerStatefulWidget {
  final Function(AddressModel) onAddressSelected;
  
  const AddressSelectionWidget({
    super.key,
    required this.onAddressSelected,
  });

  @override
  ConsumerState<AddressSelectionWidget> createState() => _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState extends ConsumerState<AddressSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final addresses = checkoutState.addresses;

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
                  'Selecionar endereço',
                  style: AppTextStyles.headingMedium,
                ),
                TextButton(
                  onPressed: _showAddAddressDialog,
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
          
          // Lista de endereços
          Flexible(
            child: addresses.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                    ),
                    itemCount: addresses.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: AppDimensions.paddingSmall,
                    ),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final isSelected = checkoutState.selectedAddress?.id == address.id;
                      
                      return _buildAddressCard(address, isSelected);
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
            AppIcons.location,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'Nenhum endereço cadastrado',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Adicione um endereço para continuar',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          CustomButton(
            text: 'Adicionar endereço',
            onPressed: _showAddAddressDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onAddressSelected(address),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone do tipo de endereço
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                _getAddressIcon(address.type),
                color: isSelected ? AppColors.primary : AppColors.textLight,
                size: AppDimensions.iconMedium,
              ),
            ),
            
            const SizedBox(width: AppDimensions.paddingMedium),
            
            // Informações do endereço
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Text(
                            'Padrão',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.shortAddress,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Botão de editar/remover
            PopupMenuButton<String>(
              icon: Icon(
                AppIcons.moreVertical,
                color: AppColors.textLight,
                size: AppDimensions.iconSmall,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditAddressDialog(address);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(address);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(AppIcons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(AppIcons.delete, size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Remover', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
            
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

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AddressFormDialog(
        onSave: (address) async {
          try {
            await ref.read(checkoutNotifierProvider.notifier)
                .addAddress(address);
            if (mounted) {
              NavigationHelper.safeGoBack(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Endereço adicionado com sucesso'),
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

  void _showEditAddressDialog(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AddressFormDialog(
        address: address,
        onSave: (updatedAddress) async {
          try {
            await ref.read(checkoutNotifierProvider.notifier)
                .addAddress(updatedAddress);
            if (mounted) {
              NavigationHelper.safeGoBack(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Endereço atualizado com sucesso'),
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

  void _showDeleteConfirmation(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover endereço'),
        content: Text('Deseja remover o endereço "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.safeGoBack(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(checkoutNotifierProvider.notifier)
                    .removeAddress(address.id);
                if (mounted) {
                  NavigationHelper.safeGoBack(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Endereço removido com sucesso'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  NavigationHelper.safeGoBack(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: AppColors.error),
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
}

/// Dialog para adicionar/editar endereço
class AddressFormDialog extends StatefulWidget {
  final AddressModel? address;
  final Function(AddressModel) onSave;
  
  const AddressFormDialog({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _referenceController = TextEditingController();
  
  String _selectedType = AddressType.home;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _populateFields(widget.address!);
    }
  }

  void _populateFields(AddressModel address) {
    _labelController.text = address.label;
    _streetController.text = address.street;
    _numberController.text = address.number;
    _complementController.text = address.complement ?? '';
    _neighborhoodController.text = address.neighborhood;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _zipCodeController.text = address.zipCode;
    _referenceController.text = address.reference ?? '';
    _selectedType = address.type;
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.address == null ? 'Adicionar endereço' : 'Editar endereço'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label e tipo
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _labelController,
                        labelText: 'Nome do endereço',
                        hintText: 'Ex: Casa, Trabalho',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    DropdownButton<String>(
                      value: _selectedType,
                      items: AddressType.all.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(AddressType.getLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.paddingMedium),
                
                // Rua e número
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: _streetController,
                        labelText: 'Rua',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: CustomTextField(
                        controller: _numberController,
                        labelText: 'Número',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.paddingMedium),
                
                // Complemento
                CustomTextField(
                  controller: _complementController,
                  labelText: 'Complemento (opcional)',
                  hintText: 'Apto, bloco, etc.',
                ),
                
                const SizedBox(height: AppDimensions.paddingMedium),
                
                // Bairro
                CustomTextField(
                  controller: _neighborhoodController,
                  labelText: 'Bairro',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppDimensions.paddingMedium),
                
                // Cidade e estado
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _cityController,
                        labelText: 'Cidade',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: CustomTextField(
                        controller: _stateController,
                        labelText: 'Estado',
                        hintText: 'SP',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.paddingMedium),
                
                // CEP
                CustomTextField(
                  controller: _zipCodeController,
                  labelText: 'CEP',
                  hintText: '00000-000',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppDimensions.paddingMedium),
                
                // Referência
                CustomTextField(
                  controller: _referenceController,
                  labelText: 'Ponto de referência (opcional)',
                  hintText: 'Próximo ao mercado',
                ),
                
                const SizedBox(height: AppDimensions.paddingMedium),
                
                // Endereço padrão
                CheckboxListTile(
                  title: const Text('Definir como endereço padrão'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => NavigationHelper.safeGoBack(context),
          child: const Text('Cancelar'),
        ),
        CustomButton(
          text: _isLoading ? 'Salvando...' : 'Salvar',
          onPressed: _isLoading ? null : _saveAddress,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final now = DateTime.now();
      final address = AddressModel(
        id: widget.address?.id ?? '',
        userId: widget.address?.userId ?? 'user_123',
        label: _labelController.text.trim(),
        type: _selectedType,
        street: _streetController.text.trim(),
        number: _numberController.text.trim(),
        complement: _complementController.text.trim().isEmpty 
            ? null 
            : _complementController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        reference: _referenceController.text.trim().isEmpty 
            ? null 
            : _referenceController.text.trim(),
        isDefault: _isDefault,
        createdAt: widget.address?.createdAt ?? now,
        updatedAt: now,
      );
      
      widget.onSave(address);
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
}