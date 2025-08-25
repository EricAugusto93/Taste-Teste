import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/services/cart/cart_service.dart';

/// Estado do carrinho
class CartState {
  final CartModel cart;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  const CartState({
    required this.cart,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  CartState copyWith({
    CartModel? cart,
    bool? isLoading,
    String? error,
    bool? isSaving,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Notifier para gerenciar o estado do carrinho
class CartNotifier extends StateNotifier<CartState> {
  final CartService _cartService;

  CartNotifier(this._cartService) : super(CartState(cart: CartModel.empty())) {
    _loadCart();
  }

  /// Carrega o carrinho salvo
  Future<void> _loadCart() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final cart = await _cartService.getCart();
      state = state.copyWith(cart: cart, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao carregar carrinho: $e',
        isLoading: false,
      );
    }
  }

  /// Adiciona um item ao carrinho
  Future<void> addItem({
    required MenuItemModel menuItem,
    int quantity = 1,
    String? specialInstructions,
    List<String> selectedOptions = const [],
  }) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      // Verifica se é um novo restaurante
      if (state.cart.isNotEmpty && 
          state.cart.restaurantId != menuItem.restaurantId) {
        // Pergunta se quer limpar o carrinho
        throw Exception('DIFFERENT_RESTAURANT');
      }

      final cartItem = CartItemModel.fromMenuItem(
        menuItem: menuItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
        selectedOptions: selectedOptions,
      );

      final updatedCart = state.cart.addItem(cartItem);
      await _cartService.saveCart(updatedCart);
      
      state = state.copyWith(cart: updatedCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      rethrow;
    }
  }

  /// Remove um item do carrinho
  Future<void> removeItem(String itemId) async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      final updatedCart = state.cart.removeItem(itemId);
      await _cartService.saveCart(updatedCart);
      
      state = state.copyWith(cart: updatedCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao remover item: $e',
        isSaving: false,
      );
    }
  }

  /// Atualiza a quantidade de um item
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      final updatedCart = state.cart.updateItemQuantity(itemId, newQuantity);
      await _cartService.saveCart(updatedCart);
      
      state = state.copyWith(cart: updatedCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao atualizar quantidade: $e',
        isSaving: false,
      );
    }
  }

  /// Limpa o carrinho
  Future<void> clearCart() async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      final clearedCart = state.cart.clear();
      await _cartService.saveCart(clearedCart);
      
      state = state.copyWith(cart: clearedCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao limpar carrinho: $e',
        isSaving: false,
      );
    }
  }

  /// Inicia um novo carrinho para um restaurante
  Future<void> startNewCart(RestaurantModel restaurant) async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      final newCart = CartModel.forRestaurant(restaurant: restaurant);
      await _cartService.saveCart(newCart);
      
      state = state.copyWith(cart: newCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao iniciar novo carrinho: $e',
        isSaving: false,
      );
    }
  }

  /// Aplica um código promocional
  Future<void> applyPromoCode(String code) async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      // Simula validação do código promocional
      final discountAmount = await _cartService.validatePromoCode(code, state.cart.subtotal);
      
      final updatedCart = state.cart.applyPromoCode(code, discountAmount);
      await _cartService.saveCart(updatedCart);
      
      state = state.copyWith(cart: updatedCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao aplicar código promocional: $e',
        isSaving: false,
      );
    }
  }

  /// Remove código promocional
  Future<void> removePromoCode() async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      final updatedCart = state.cart.removePromoCode();
      await _cartService.saveCart(updatedCart);
      
      state = state.copyWith(cart: updatedCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao remover código promocional: $e',
        isSaving: false,
      );
    }
  }

  /// Atualiza as informações do restaurante no carrinho
  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      final updatedCart = state.cart.copyWith(
        restaurant: restaurant,
        restaurantId: restaurant.id,
        deliveryFee: restaurant.deliveryFee,
        updatedAt: DateTime.now(),
      );
      
      await _cartService.saveCart(updatedCart);
      state = state.copyWith(cart: updatedCart, isSaving: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao atualizar restaurante: $e',
        isSaving: false,
      );
    }
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Força o recarregamento do carrinho
  Future<void> refresh() async {
    await _loadCart();
  }
}

/// Provider do serviço de carrinho
final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

/// Provider do notifier do carrinho
final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final cartService = ref.watch(cartServiceProvider);
  return CartNotifier(cartService);
});

/// Provider para acessar apenas o carrinho
final cartProvider = Provider<CartModel>((ref) {
  return ref.watch(cartNotifierProvider).cart;
});

/// Provider para verificar se o carrinho está carregando
final cartLoadingProvider = Provider<bool>((ref) {
  return ref.watch(cartNotifierProvider).isLoading;
});

/// Provider para verificar se o carrinho está salvando
final cartSavingProvider = Provider<bool>((ref) {
  return ref.watch(cartNotifierProvider).isSaving;
});

/// Provider para acessar erros do carrinho
final cartErrorProvider = Provider<String?>((ref) {
  return ref.watch(cartNotifierProvider).error;
});

/// Provider para contar itens no carrinho
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

/// Provider para verificar se o carrinho está vazio
final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

/// Provider para verificar se atende ao pedido mínimo
final cartMeetsMinimumProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).meetsMinimumOrder;
});

/// Provider para valor restante do pedido mínimo
final cartRemainingForMinimumProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).remainingForMinimumOrder;
});
