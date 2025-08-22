import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/address_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/order_model.dart';
import '../../data/services/checkout_service.dart';
import '../../data/services/auth_service.dart';
import 'cart_provider.dart';

/// Estado do checkout
class CheckoutState {
  final AddressModel? selectedAddress;
  final PaymentMethodModel? selectedPaymentMethod;
  final String? orderNotes;
  final bool isPlacingOrder;
  final String? error;
  final List<AddressModel> addresses;
  final List<PaymentMethodModel> paymentMethods;

  const CheckoutState({
    this.selectedAddress,
    this.selectedPaymentMethod,
    this.orderNotes,
    this.isPlacingOrder = false,
    this.error,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  CheckoutState copyWith({
    AddressModel? selectedAddress,
    PaymentMethodModel? selectedPaymentMethod,
    String? orderNotes,
    bool? isPlacingOrder,
    String? error,
    List<AddressModel>? addresses,
    List<PaymentMethodModel>? paymentMethods,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      orderNotes: orderNotes ?? this.orderNotes,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      error: error,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

/// Notifier para gerenciar o estado do checkout
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CheckoutService _checkoutService;
  final Ref _ref;

  CheckoutNotifier(this._checkoutService, this._ref) : super(const CheckoutState()) {
    _loadInitialData();
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    try {
      final addresses = await _checkoutService.getUserAddresses();
      final paymentMethods = await _checkoutService.getPaymentMethods();
      
      state = state.copyWith(
        addresses: addresses,
        paymentMethods: paymentMethods,
        selectedAddress: addresses.isNotEmpty ? addresses.first : null,
        selectedPaymentMethod: paymentMethods.isNotEmpty ? paymentMethods.first : null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Seleciona um endereço
  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address, error: null);
  }

  /// Seleciona um método de pagamento
  void selectPaymentMethod(PaymentMethodModel paymentMethod) {
    state = state.copyWith(selectedPaymentMethod: paymentMethod, error: null);
  }

  /// Atualiza as observações do pedido
  void updateOrderNotes(String notes) {
    state = state.copyWith(orderNotes: notes.isEmpty ? null : notes);
  }

  /// Adiciona um novo endereço
  Future<void> addAddress(AddressModel address) async {
    try {
      final savedAddress = await _checkoutService.saveAddress(address);
      final updatedAddresses = [...state.addresses, savedAddress];
      
      state = state.copyWith(
        addresses: updatedAddresses,
        selectedAddress: savedAddress,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Remove um endereço
  Future<void> removeAddress(String addressId) async {
    try {
      await _checkoutService.deleteAddress(addressId);
      final updatedAddresses = state.addresses
          .where((address) => address.id != addressId)
          .toList();
      
      AddressModel? newSelectedAddress = state.selectedAddress;
      if (state.selectedAddress?.id == addressId) {
        newSelectedAddress = updatedAddresses.isNotEmpty ? updatedAddresses.first : null;
      }
      
      state = state.copyWith(
        addresses: updatedAddresses,
        selectedAddress: newSelectedAddress,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Finaliza o pedido
  Future<String> placeOrder() async {
    if (state.selectedAddress == null) {
      throw Exception('Endereço de entrega não selecionado');
    }
    
    if (state.selectedPaymentMethod == null) {
      throw Exception('Método de pagamento não selecionado');
    }

    try {
      state = state.copyWith(isPlacingOrder: true, error: null);
      
      final cart = _ref.read(cartProvider);
      
      if (cart.isEmpty) {
        throw Exception('Carrinho está vazio');
      }
      
      if (!cart.meetsMinimumOrder) {
        throw Exception('Pedido não atende ao valor mínimo');
      }

      final order = OrderModel(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        userId: AuthService.instance.userId ?? 'anonymous',
        restaurant: cart.restaurant!,
        items: cart.items,
        deliveryAddress: state.selectedAddress!,
        paymentMethod: state.selectedPaymentMethod!,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        serviceFee: cart.serviceFee,
        discount: cart.discount,
        total: cart.total,
        notes: state.orderNotes,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 45)),
      );

      final orderId = await _checkoutService.placeOrder(order);
      
      state = state.copyWith(isPlacingOrder: false);
      
      return orderId;
    } catch (e) {
      state = state.copyWith(isPlacingOrder: false, error: e.toString());
      rethrow;
    }
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reseta o estado do checkout
  void reset() {
    state = const CheckoutState();
    _loadInitialData();
  }
}

/// Provider do serviço de checkout
final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService();
});

/// Provider do notifier do checkout
final checkoutNotifierProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final checkoutService = ref.watch(checkoutServiceProvider);
  return CheckoutNotifier(checkoutService, ref);
});

/// Provider para acessar apenas o endereço selecionado
final selectedAddressProvider = Provider<AddressModel?>((ref) {
  return ref.watch(checkoutNotifierProvider).selectedAddress;
});

/// Provider para acessar apenas o método de pagamento selecionado
final selectedPaymentMethodProvider = Provider<PaymentMethodModel?>((ref) {
  return ref.watch(checkoutNotifierProvider).selectedPaymentMethod;
});

/// Provider para verificar se pode finalizar o pedido
final canPlaceOrderProvider = Provider<bool>((ref) {
  final checkoutState = ref.watch(checkoutNotifierProvider);
  final cart = ref.watch(cartProvider);
  
  return checkoutState.selectedAddress != null &&
      checkoutState.selectedPaymentMethod != null &&
      cart.meetsMinimumOrder &&
      !checkoutState.isPlacingOrder;
});

/// Provider para obter a lista de endereços
final addressesProvider = Provider<List<AddressModel>>((ref) {
  return ref.watch(checkoutNotifierProvider).addresses;
});

/// Provider para obter a lista de métodos de pagamento
final paymentMethodsProvider = Provider<List<PaymentMethodModel>>((ref) {
  return ref.watch(checkoutNotifierProvider).paymentMethods;
});