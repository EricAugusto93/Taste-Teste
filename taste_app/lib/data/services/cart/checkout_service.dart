import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';
import '../models/order_model.dart';

/// Serviço para gerenciar o checkout e pedidos
class CheckoutService {
  static const String _addressesKey = 'user_addresses';
  static const String _ordersKey = 'user_orders';
  static const String _defaultAddressKey = 'default_address';
  static const String _defaultPaymentKey = 'default_payment_method';

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
      
      // Retorna endereços de exemplo se não houver salvos
      return _getDefaultAddresses();
    } catch (e) {
      return _getDefaultAddresses();
    }
  }

  /// Salva um endereço
  Future<AddressModel> saveAddress(AddressModel address) async {
    try {
      final addresses = await getUserAddresses();
      
      // Se é o primeiro endereço ou está marcado como padrão, define como padrão
      final isDefault = addresses.isEmpty || address.isDefault;
      
      final savedAddress = address.copyWith(
        id: address.id.isEmpty ? 'addr_${DateTime.now().millisecondsSinceEpoch}' : address.id,
        userId: 'user_123', // TODO: Obter do auth
        isDefault: isDefault,
        updatedAt: DateTime.now(),
      );
      
      // Remove o endereço existente se estiver editando
      final updatedAddresses = addresses
          .where((addr) => addr.id != savedAddress.id)
          .toList();
      
      // Se este endereço é padrão, remove a flag dos outros
      if (isDefault) {
        for (int i = 0; i < updatedAddresses.length; i++) {
          updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
        }
      }
      
      updatedAddresses.add(savedAddress);
      
      await _saveAddresses(updatedAddresses);
      
      return savedAddress;
    } catch (e) {
      throw Exception('Erro ao salvar endereço: $e');
    }
  }

  /// Remove um endereço
  Future<void> deleteAddress(String addressId) async {
    try {
      final addresses = await getUserAddresses();
      final updatedAddresses = addresses
          .where((address) => address.id != addressId)
          .toList();
      
      await _saveAddresses(updatedAddresses);
    } catch (e) {
      throw Exception('Erro ao remover endereço: $e');
    }
  }

  /// Obtém os métodos de pagamento disponíveis
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    // Por enquanto, retorna métodos padrão
    // No futuro, pode buscar do servidor ou configurações do usuário
    return PaymentMethodFactory.getDefaultMethods();
  }

  /// Finaliza um pedido
  Future<String> placeOrder(OrderModel order) async {
    try {
      // Validações
      await _validateOrder(order);
      
      // Simula processamento do pagamento
      await _processPayment(order);
      
      // Salva o pedido
      await _saveOrder(order);
      
      // Simula notificação para o restaurante
      await _notifyRestaurant(order);
      
      return order.id;
    } catch (e) {
      throw Exception('Erro ao finalizar pedido: $e');
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
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Mais recentes primeiro
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtém um pedido específico
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final orders = await getUserOrders();
      return orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw Exception('Pedido não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Atualiza o status de um pedido
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, {String? reason}) async {
    try {
      final orders = await getUserOrders();
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      
      if (orderIndex == -1) {
        throw Exception('Pedido não encontrado');
      }
      
      orders[orderIndex] = orders[orderIndex].updateStatus(newStatus, reason: reason);
      
      await _saveOrders(orders);
    } catch (e) {
      throw Exception('Erro ao atualizar status do pedido: $e');
    }
  }

  /// Cancela um pedido
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final order = await getOrder(orderId);
      
      if (order == null) {
        throw Exception('Pedido não encontrado');
      }
      
      if (!order.status.canBeCancelled) {
        throw Exception('Este pedido não pode ser cancelado');
      }
      
      await updateOrderStatus(orderId, OrderStatus.cancelled, reason: reason);
    } catch (e) {
      throw Exception('Erro ao cancelar pedido: $e');
    }
  }

  /// Valida um pedido antes de finalizar
  Future<void> _validateOrder(OrderModel order) async {
    if (order.items.isEmpty) {
      throw Exception('Carrinho está vazio');
    }
    
    if (order.total <= 0) {
      throw Exception('Valor total inválido');
    }
    
    if (!order.deliveryAddress.isComplete) {
      throw Exception('Endereço de entrega incompleto');
    }
    
    // Verifica se o restaurante está aberto (simulado)
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 10 || hour > 22) {
      throw Exception('Restaurante fechado no momento');
    }
    
    // Verifica valor mínimo do pedido
    final minOrderValue = order.restaurant.minOrderValue ?? 0;
    if (order.subtotal < minOrderValue) {
      throw Exception('Valor mínimo do pedido: R\$ ${minOrderValue.toStringAsFixed(2)}');
    }
  }

  /// Simula processamento do pagamento
  Future<void> _processPayment(OrderModel order) async {
    // Simula delay do processamento
    await Future.delayed(const Duration(seconds: 2));
    
    // Simula falha de pagamento ocasional (5% de chance)
    if (DateTime.now().millisecond % 20 == 0) {
      throw Exception('Falha no processamento do pagamento. Tente novamente.');
    }
    
    // Validações específicas por tipo de pagamento
    if (order.paymentMethod.isCreditCard || order.paymentMethod.isDebitCard) {
      // Simula validação de cartão
      if (order.total > 1000) {
        throw Exception('Valor muito alto para este cartão');
      }
    }
    
    if (order.paymentMethod.isPix) {
      // PIX tem limite de horário
      final hour = DateTime.now().hour;
      if (hour < 6 || hour > 22) {
        throw Exception('PIX indisponível neste horário');
      }
    }
  }

  /// Salva um pedido
  Future<void> _saveOrder(OrderModel order) async {
    try {
      final orders = await getUserOrders();
      orders.add(order);
      await _saveOrders(orders);
    } catch (e) {
      throw Exception('Erro ao salvar pedido: $e');
    }
  }

  /// Simula notificação para o restaurante
  Future<void> _notifyRestaurant(OrderModel order) async {
    // Simula delay da notificação
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Em uma implementação real, enviaria notificação push ou webhook
    debugPrint('Pedido ${order.id} enviado para ${order.restaurant.name}');
  }

  /// Salva a lista de endereços
  Future<void> _saveAddresses(List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = jsonEncode(addresses.map((addr) => addr.toJson()).toList());
    await prefs.setString(_addressesKey, addressesJson);
  }

  /// Salva a lista de pedidos
  Future<void> _saveOrders(List<OrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = jsonEncode(orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, ordersJson);
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
}