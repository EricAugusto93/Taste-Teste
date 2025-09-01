import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/address_model.dart';
import '../../models/payment_method_model.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/restaurant_model.dart';

/// Serviço para gerenciar o checkout e pedidos
class CheckoutService {
  static const String _addressesKey = 'user_addresses';
  static const String _ordersKey = 'user_orders';

  /// Obtém os endereços do usuário
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_addressesKey);
      
      if (addressesJson != null) {
        final addressesList = jsonDecode(addressesJson) as List<dynamic>;
        return addressesList
            .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return _getDefaultAddresses();
    } catch (e) {
      return _getDefaultAddresses();
    }
  }

  /// Salva um endereço
  Future<AddressModel> saveAddress(AddressModel address) async {
    try {
      final addresses = await getUserAddresses();
      
      final isDefault = addresses.isEmpty || address.isDefault;
      
      final savedAddress = address.copyWith(
        id: address.id.isEmpty ? 'addr_${DateTime.now().millisecondsSinceEpoch}' : address.id,
        userId: 'user_123', // TODO: Obter do auth
        isDefault: isDefault,
        updatedAt: DateTime.now(),
      );
      
      final updatedAddresses = addresses
          .where((addr) => addr.id != savedAddress.id)
          .toList();
      
      if (isDefault) {
        for (int i = 0; i < updatedAddresses.length; i++) {
          updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
        }
      }
      
      updatedAddresses.add(savedAddress);
      
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(updatedAddresses.map((addr) => addr.toJson()).toList());
      await prefs.setString(_addressesKey, addressesJson);
      
      return savedAddress;
    } catch (e) {
      throw Exception('Erro ao salvar endereço: $e');
    }
  }

  /// Remove um endereço
  Future<void> deleteAddress(String addressId) async {
    try {
      final addresses = await getUserAddresses();
      final updatedAddresses = addresses.where((addr) => addr.id != addressId).toList();
      
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(updatedAddresses.map((addr) => addr.toJson()).toList());
      await prefs.setString(_addressesKey, addressesJson);
    } catch (e) {
      throw Exception('Erro ao deletar endereço: $e');
    }
  }

  /// Define um endereço como padrão
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final addresses = await getUserAddresses();
      final updatedAddresses = addresses.map((addr) => 
          addr.copyWith(isDefault: addr.id == addressId)).toList();
      
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(updatedAddresses.map((addr) => addr.toJson()).toList());
      await prefs.setString(_addressesKey, addressesJson);
    } catch (e) {
      throw Exception('Erro ao definir endereço padrão: $e');
    }
  }

  /// Obtém os métodos de pagamento do usuário
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      // Por enquanto, retorna métodos mock
      return _getDefaultPaymentMethods();
    } catch (e) {
      return _getDefaultPaymentMethods();
    }
  }

  /// Salva um método de pagamento
  Future<PaymentMethodModel> savePaymentMethod(PaymentMethodModel paymentMethod) async {
    try {
      // TODO: Implementar salvamento real
      return paymentMethod.copyWith(
        id: paymentMethod.id.isEmpty ? 'pm_${DateTime.now().millisecondsSinceEpoch}' : paymentMethod.id,
      );
    } catch (e) {
      throw Exception('Erro ao salvar método de pagamento: $e');
    }
  }

  /// Cria um novo pedido
  Future<OrderModel> createOrder({
    required RestaurantModel restaurant,
    required List<CartItemModel> items,
    required AddressModel deliveryAddress,
    required PaymentMethodModel paymentMethod,
    required double subtotal,
    required double deliveryFee,
    required double serviceFee,
    required double discount,
    required double total,
    String? notes,
    String? promoCode,
  }) async {
    try {
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      final order = OrderModel(
        id: orderId,
        userId: 'user_123', // TODO: Obter do auth service
        restaurant: restaurant,
        items: items,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        serviceFee: serviceFee,
        discount: discount,
        total: total,
        notes: notes,
        promoCode: promoCode,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 45)),
      );
      
      await _saveOrder(order);
      return order;
    } catch (e) {
      throw Exception('Erro ao criar pedido: $e');
    }
  }

  /// Obtém os pedidos do usuário
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey);
      
      if (ordersJson != null) {
        final ordersList = jsonDecode(ordersJson) as List<dynamic>;
        return ordersList
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Salva um pedido
  Future<void> _saveOrder(OrderModel order) async {
    try {
      final orders = await getUserOrders();
      orders.add(order);
      
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(orders.map((order) => order.toJson()).toList());
      await prefs.setString(_ordersKey, ordersJson);
    } catch (e) {
      throw Exception('Erro ao salvar pedido: $e');
    }
  }

  /// Retorna endereços padrão para demonstração
  List<AddressModel> _getDefaultAddresses() {
    final now = DateTime.now();
    
    return [
      AddressModel(
        id: 'addr_home',
        userId: 'user_123',
        label: 'Casa',
        type: AddressType.home,
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 45',
        neighborhood: 'Centro',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01234-567',
        reference: 'Próximo ao mercado',
        latitude: -23.5505,
        longitude: -46.6333,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AddressModel(
        id: 'addr_work',
        userId: 'user_123',
        label: 'Trabalho',
        type: AddressType.work,
        street: 'Avenida Paulista',
        number: '1000',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
        reference: 'Edifício comercial',
        latitude: -23.5618,
        longitude: -46.6565,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Retorna métodos de pagamento padrão para demonstração
  List<PaymentMethodModel> _getDefaultPaymentMethods() {
    final now = DateTime.now();
    
    return [
      PaymentMethodModel(
        id: 'pm_card1',
        type: 'credit_card',
        name: 'Cartão de Crédito **** 1234',
        description: 'Visa',
        icon: 'credit_card',
        metadata: const {
          'cardNumber': '**** **** **** 1234',
          'cardholderName': 'João Silva',
          'expiryMonth': 12,
          'expiryYear': 2026,
          'brand': 'Visa',
          'isDefault': true,
        },
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethodModel(
        id: 'pm_pix',
        type: 'pix',
        name: 'PIX',
        description: 'Pagamento instantâneo',
        icon: 'pix',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}