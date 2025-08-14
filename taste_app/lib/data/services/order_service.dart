import 'dart:async';
import 'dart:math';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';
import '../models/restaurant_model.dart';

/// Serviço para gerenciar pedidos
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // Simulação de banco de dados local
  final List<OrderModel> _orders = [];
  final StreamController<List<OrderModel>> _ordersController = 
      StreamController<List<OrderModel>>.broadcast();
  final StreamController<OrderModel> _orderUpdatesController = 
      StreamController<OrderModel>.broadcast();

  // Streams públicos
  Stream<List<OrderModel>> get ordersStream => _ordersController.stream;
  Stream<OrderModel> get orderUpdatesStream => _orderUpdatesController.stream;

  /// Criar um novo pedido a partir do carrinho
  Future<OrderModel> createOrder({
    required CartModel cart,
    required AddressModel deliveryAddress,
    required PaymentMethodModel paymentMethod,
    String? notes,
  }) async {
    try {
      // Simular delay de processamento
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Validações
      if (cart.items.isEmpty) {
        throw Exception('Carrinho está vazio');
      }
      
      if (cart.restaurant == null) {
        throw Exception('Restaurante não encontrado');
      }
      
      // Verificar se o restaurante está aberto
      if (!cart.restaurant!.isOpen) {
        throw Exception('Restaurante está fechado no momento');
      }
      
      // Verificar valor mínimo
      if (cart.restaurant!.minOrderValue != null && cart.subtotal < cart.restaurant!.minOrderValue!) {
        throw Exception(
          'Valor mínimo do pedido é R\$ ${cart.restaurant!.minOrderValue!.toStringAsFixed(2)}'
        );
      }
      
      // Processamento do pagamento (removido falha ocasional para testes determinísticos)
      
      final now = DateTime.now();
      final orderId = _generateOrderId();
      
      // Calcular tempo estimado de entrega
      final estimatedDeliveryTime = _calculateEstimatedDeliveryTime(
        cart.restaurant!,
        deliveryAddress,
      );
      
      final order = OrderModel(
        id: orderId,
        userId: 'user_123', // Em uma implementação real, viria da autenticação
        restaurant: cart.restaurant!,
        items: cart.items,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        serviceFee: cart.serviceFee,
        discount: cart.discount,
        total: cart.total,
        notes: notes,
        promoCode: cart.promoCode,
        status: OrderStatus.pending,
        createdAt: now,
        estimatedDeliveryTime: estimatedDeliveryTime,
        trackingCode: _generateTrackingCode(),
      );
      
      // Adicionar à lista de pedidos
      _orders.insert(0, order);
      _ordersController.add(List.from(_orders));
      
      // Simular processamento automático do pedido
      _simulateOrderProcessing(order);
      
      return order;
    } catch (e) {
      throw Exception('Erro ao criar pedido: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
  
  /// Obter todos os pedidos do usuário
  Future<List<OrderModel>> getUserOrders({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filtrar por usuário se especificado
    if (userId != null) {
      return _orders.where((order) => order.userId == userId).toList();
    }
    
    return List.from(_orders);
  }
  
  /// Obter pedido por ID
  Future<OrderModel?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
  
  /// Cancelar pedido
  Future<OrderModel> cancelOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Pedido não encontrado');
    }
    
    final order = _orders[orderIndex];
    
    // Verificar se o pedido pode ser cancelado
    if (order.status != OrderStatus.pending && order.status != OrderStatus.confirmed) {
      throw Exception('Este pedido não pode mais ser cancelado');
    }
    
    final updatedOrder = order.copyWith(
      status: OrderStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancellationReason: reason,
    );
    
    _orders[orderIndex] = updatedOrder;
    _ordersController.add(List.from(_orders));
    _orderUpdatesController.add(updatedOrder);
    
    return updatedOrder;
  }
  
  /// Atualizar status do pedido
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Pedido não encontrado');
    }
    
    final order = _orders[orderIndex];
    final now = DateTime.now();
    
    OrderModel updatedOrder;
    
    switch (newStatus) {
      case OrderStatus.confirmed:
        updatedOrder = order.copyWith(
          status: newStatus,
          confirmedAt: now,
        );
        break;
      case OrderStatus.preparing:
        updatedOrder = order.copyWith(
          status: newStatus,
          preparedAt: now,
        );
        break;
      case OrderStatus.ready:
        updatedOrder = order.copyWith(
          status: newStatus,
        );
        break;
      case OrderStatus.outForDelivery:
        updatedOrder = order.copyWith(
          status: newStatus,
        );
        break;
      case OrderStatus.delivered:
        updatedOrder = order.copyWith(
          status: newStatus,
          deliveredAt: now,
        );
        break;
      default:
        updatedOrder = order.copyWith(status: newStatus);
    }
    
    _orders[orderIndex] = updatedOrder;
    _ordersController.add(List.from(_orders));
    _orderUpdatesController.add(updatedOrder);
    
    return updatedOrder;
  }
  
  /// Obter pedidos por status
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _orders.where((order) => order.status == status).toList();
  }
  
  /// Obter pedidos ativos (não finalizados)
  Future<List<OrderModel>> getActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    const activeStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.outForDelivery,
    ];
    
    return _orders.where((order) => activeStatuses.contains(order.status)).toList();
  }
  
  /// Obter histórico de pedidos
  Future<List<OrderModel>> getOrderHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    const finishedStatuses = [
      OrderStatus.delivered,
      OrderStatus.cancelled,
      OrderStatus.refunded,
    ];
    
    return _orders.where((order) => finishedStatuses.contains(order.status)).toList();
  }
  
  /// Rastrear pedido
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Pedido não encontrado');
    }
    
    return {
      'orderId': order.id,
      'status': order.status.name,
      'trackingCode': order.trackingCode,
      'estimatedDeliveryTime': order.estimatedDeliveryTime?.toIso8601String(),
      'currentLocation': 'Em trânsito',
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }
  
  /// Gerar ID único para o pedido
  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'ORD$timestamp$random';
  }
  
  /// Gerar código de rastreamento
  String _generateTrackingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
  
  /// Calcular tempo estimado de entrega
  DateTime _calculateEstimatedDeliveryTime(
    RestaurantModel restaurant,
    AddressModel deliveryAddress,
  ) {
    final now = DateTime.now();
    final preparationTime = 30; // Tempo padrão de preparo
    final deliveryTime = 20; // Tempo base de entrega
    
    return now.add(Duration(minutes: preparationTime + deliveryTime));
  }
  
  /// Simular processamento automático do pedido
  void _simulateOrderProcessing(OrderModel order) {
    Timer(const Duration(seconds: 30), () {
      updateOrderStatus(order.id, OrderStatus.confirmed);
    });
    
    Timer(const Duration(minutes: 2), () {
      updateOrderStatus(order.id, OrderStatus.preparing);
    });
    
    Timer(const Duration(minutes: 15), () {
      updateOrderStatus(order.id, OrderStatus.ready);
    });
    
    Timer(const Duration(minutes: 20), () {
      updateOrderStatus(order.id, OrderStatus.outForDelivery);
    });
    
    Timer(const Duration(minutes: 35), () {
      updateOrderStatus(order.id, OrderStatus.delivered);
    });
  }
  
  /// Limpar recursos
  void dispose() {
    _ordersController.close();
    _orderUpdatesController.close();
  }
}