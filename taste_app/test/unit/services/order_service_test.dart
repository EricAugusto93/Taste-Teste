import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/services/cart/order_service.dart';
import 'package:taste_app/data/models/order_model.dart';
import 'package:taste_app/data/models/cart_model.dart';
import 'package:taste_app/data/models/cart_item_model.dart';
import 'package:taste_app/data/models/menu_item_model.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/data/models/address_model.dart';
import 'package:taste_app/data/models/payment_method_model.dart';
import '../../test_helpers.dart';

/// Helper method to create a mock MenuItemModel
MenuItemModel _createMockMenuItem({
  String? id,
  String? name,
  double? price,
  String? restaurantId,
}) {
  return MenuItemModel(
    id: id ?? 'menu_item_1',
    name: name ?? 'Pizza Margherita',
    description: 'Delicious pizza with tomato and mozzarella',
    price: price ?? 25.0,
    restaurantId: restaurantId ?? 'rest1',
    categoryName: 'Pizza',
    isAvailable: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Helper method to create a mock CartModel
CartModel _createMockCart({
  String? id,
  RestaurantModel? restaurant,
  List<CartItemModel>? items,
  double? subtotal,
  double? deliveryFee,
  double? total,
  bool isEmpty = false,
}) {
  List<CartItemModel> mockItems;
  
  if (isEmpty) {
    mockItems = <CartItemModel>[];
  } else {
    mockItems = items ?? [
      CartItemModel.fromMenuItem(
        menuItem: _createMockMenuItem(
          restaurantId: restaurant?.id ?? 'rest1',
        ),
        quantity: 2,
      ),
    ];
  }
  
  final mockSubtotal = subtotal ?? (isEmpty ? 0.0 : 50.0);
  final mockDeliveryFee = deliveryFee ?? 5.0;
  final mockTotal = total ?? (mockSubtotal + mockDeliveryFee);
  
  return CartModel(
    id: id ?? 'mock_cart',
    items: mockItems,
    restaurant: restaurant,
    restaurantId: restaurant?.id,
    subtotal: mockSubtotal,
    deliveryFee: mockDeliveryFee,
    total: mockTotal,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Helper method to create a mock AddressModel
AddressModel _createMockAddress({
  String? id,
  String? street,
  String? city,
}) {
  final now = DateTime.now();
  return AddressModel(
    id: id ?? 'addr1',
    userId: 'user_1',
    label: 'Casa',
    type: 'home',
    street: street ?? 'Rua das Flores',
    number: '123',
    complement: 'Apto 45',
    neighborhood: 'Centro',
    city: city ?? 'São Paulo',
    state: 'SP',
    zipCode: '01234-567',
    latitude: -23.5505,
    longitude: -46.6333,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );
}

/// Helper method to create a mock PaymentMethodModel
PaymentMethodModel _createMockPaymentMethod({
  String? id,
  String? type,
}) {
  final now = DateTime.now();
  return PaymentMethodModel(
    id: id ?? 'payment1',
    type: type ?? 'credit_card',
    name: 'Cartão de Crédito',
    description: 'Visa terminado em 1234',
    icon: 'credit_card',
    isEnabled: true,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('OrderService', () {
    late OrderService orderService;
    late RestaurantModel mockRestaurant;
    late CartModel mockCart;
    late AddressModel mockAddress;
    late PaymentMethodModel mockPaymentMethod;
    
    setUp(() {
      orderService = OrderService();
      
      mockRestaurant = TestHelpers.createMockRestaurant(
        id: 'rest1',
        name: 'Pizza Palace',
        isOpen: true,
      );
      
      mockCart = _createMockCart(
        restaurant: mockRestaurant,
        subtotal: 50.0,
      );
      
      mockAddress = _createMockAddress();
      mockPaymentMethod = _createMockPaymentMethod();
    });
    
    group('Singleton Pattern', () {
      test('should return the same instance', () {
        final instance1 = OrderService();
        final instance2 = OrderService();
        expect(instance1, same(instance2));
      });
    });
    
    group('Order Creation', () {
      test('should create order successfully with valid data', () async {
        // Act
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
          notes: 'Test order',
        );
        
        // Assert
        expect(order.id, isNotEmpty);
        expect(order.restaurant.id, equals(mockRestaurant.id));
        expect(order.items.length, equals(mockCart.items.length));
        expect(order.deliveryAddress.id, equals(mockAddress.id));
        expect(order.paymentMethod.id, equals(mockPaymentMethod.id));
        expect(order.subtotal, equals(mockCart.subtotal));
        expect(order.total, equals(mockCart.total));
        expect(order.notes, equals('Test order'));
        expect(order.status, equals(OrderStatus.pending));
        expect(order.trackingCode, isNotEmpty);
        expect(order.estimatedDeliveryTime, isNotNull);
      });
      
      test('should throw exception for empty cart', () async {
        // Arrange
        final emptyCart = _createMockCart(
          restaurant: mockRestaurant,
          isEmpty: true,
        );
        
        // Act & Assert
        expect(
          () => orderService.createOrder(
            cart: emptyCart,
            deliveryAddress: mockAddress,
            paymentMethod: mockPaymentMethod,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Carrinho está vazio'),
          )),
        );
      });
      
      test('should throw exception for cart without restaurant', () async {
        // Arrange
        final cartWithoutRestaurant = _createMockCart(restaurant: null);
        
        // Act & Assert
        expect(
          () => orderService.createOrder(
            cart: cartWithoutRestaurant,
            deliveryAddress: mockAddress,
            paymentMethod: mockPaymentMethod,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Restaurante não encontrado'),
          )),
        );
      });
      
      test('should throw exception for closed restaurant', () async {
        // Arrange
        final closedRestaurant = TestHelpers.createMockRestaurant(
          id: 'rest2',
          isOpen: false,
        );
        final cartWithClosedRestaurant = _createMockCart(
          restaurant: closedRestaurant,
        );
        
        // Act & Assert
        expect(
          () => orderService.createOrder(
            cart: cartWithClosedRestaurant,
            deliveryAddress: mockAddress,
            paymentMethod: mockPaymentMethod,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Restaurante está fechado'),
          )),
        );
      });
      
      test('should throw exception for order below minimum', () async {
        // Arrange
        final restaurantWithMinOrder = TestHelpers.createMockRestaurant(
          id: 'rest2',
          isOpen: true,
        ).copyWith(minOrderValue: 20.0);
        
        final cartBelowMinimum = _createMockCart(
          restaurant: restaurantWithMinOrder,
          subtotal: 10.0, // Below minimum of 20.0
        );
        
        // Act & Assert
        expect(
          () => orderService.createOrder(
            cart: cartBelowMinimum,
            deliveryAddress: mockAddress,
            paymentMethod: mockPaymentMethod,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Valor mínimo do pedido'),
          )),
        );
      });
    });
    
    group('Order Retrieval', () {
      test('should get user orders', () async {
        // Arrange
        await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act
        final orders = await orderService.getUserOrders();
        
        // Assert
        expect(orders, isNotEmpty);
        expect(orders.first.restaurant.id, equals(mockRestaurant.id));
      });
      
      test('should get order by ID', () async {
        // Arrange
        final createdOrder = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act
        final foundOrder = await orderService.getOrderById(createdOrder.id);
        
        // Assert
        expect(foundOrder, isNotNull);
        expect(foundOrder!.id, equals(createdOrder.id));
      });
      
      test('should return null for non-existent order ID', () async {
        // Act
        final foundOrder = await orderService.getOrderById('non_existent_id');
        
        // Assert
        expect(foundOrder, isNull);
      });
      
      test('should get orders by status', () async {
        // Arrange
        await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act
        final pendingOrders = await orderService.getOrdersByStatus(OrderStatus.pending);
        
        // Assert
        expect(pendingOrders, isNotEmpty);
        expect(pendingOrders.every((order) => order.status == OrderStatus.pending), isTrue);
      });
      
      test('should get active orders', () async {
        // Arrange
        await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act
        final activeOrders = await orderService.getActiveOrders();
        
        // Assert
        expect(activeOrders, isNotEmpty);
        const activeStatuses = [
          OrderStatus.pending,
          OrderStatus.confirmed,
          OrderStatus.preparing,
          OrderStatus.ready,
          OrderStatus.outForDelivery,
        ];
        expect(
          activeOrders.every((order) => activeStatuses.contains(order.status)),
          isTrue,
        );
      });
      
      test('should get order history', () async {
        // Arrange
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Update to delivered status
        await orderService.updateOrderStatus(order.id, OrderStatus.delivered);
        
        // Act
        final history = await orderService.getOrderHistory();
        
        // Assert
        expect(history, isNotEmpty);
        const finishedStatuses = [
          OrderStatus.delivered,
          OrderStatus.cancelled,
          OrderStatus.refunded,
        ];
        expect(
          history.every((order) => finishedStatuses.contains(order.status)),
          isTrue,
        );
      });
    });
    
    group('Order Status Management', () {
      test('should update order status successfully', () async {
        // Arrange
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act
        final updatedOrder = await orderService.updateOrderStatus(
          order.id,
          OrderStatus.confirmed,
        );
        
        // Assert
        expect(updatedOrder.status, equals(OrderStatus.confirmed));
        expect(updatedOrder.confirmedAt, isNotNull);
      });
      
      test('should throw exception for non-existent order', () async {
        // Act & Assert
        expect(
          () => orderService.updateOrderStatus(
            'non_existent_id',
            OrderStatus.confirmed,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Pedido não encontrado'),
          )),
        );
      });
      
      test('should set correct timestamps for different statuses', () async {
        // Arrange
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act & Assert - Confirmed
        final confirmedOrder = await orderService.updateOrderStatus(
          order.id,
          OrderStatus.confirmed,
        );
        expect(confirmedOrder.confirmedAt, isNotNull);
        
        // Act & Assert - Preparing
        final preparingOrder = await orderService.updateOrderStatus(
          order.id,
          OrderStatus.preparing,
        );
        expect(preparingOrder.preparedAt, isNotNull);
        
        // Act & Assert - Delivered
        final deliveredOrder = await orderService.updateOrderStatus(
          order.id,
          OrderStatus.delivered,
        );
        expect(deliveredOrder.deliveredAt, isNotNull);
      });
    });
    
    group('Order Cancellation', () {
      test('should cancel order successfully', () async {
        // Arrange
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act
        final cancelledOrder = await orderService.cancelOrder(
          order.id,
          'Changed my mind',
        );
        
        // Assert
        expect(cancelledOrder.status, equals(OrderStatus.cancelled));
        expect(cancelledOrder.cancelledAt, isNotNull);
        expect(cancelledOrder.cancellationReason, equals('Changed my mind'));
      });
      
      test('should throw exception for non-existent order', () async {
        // Act & Assert
        expect(
          () => orderService.cancelOrder('non_existent_id', 'Test reason'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Pedido não encontrado'),
          )),
        );
      });
    });
    
    group('Order Tracking', () {
      test('should track order successfully', () async {
        // Arrange
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Act
        final trackingInfo = await orderService.trackOrder(order.id);
        
        // Assert
        expect(trackingInfo['orderId'], equals(order.id));
        expect(trackingInfo['status'], equals(order.status.name));
        expect(trackingInfo['trackingCode'], equals(order.trackingCode));
        expect(trackingInfo['estimatedDeliveryTime'], isNotNull);
        expect(trackingInfo['currentLocation'], isNotNull);
        expect(trackingInfo['lastUpdate'], isNotNull);
      });
      
      test('should throw exception for non-existent order', () async {
        // Act & Assert
        expect(
          () => orderService.trackOrder('non_existent_id'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Pedido não encontrado'),
          )),
        );
      });
    });
    
    group('Streams', () {
      test('should emit orders through stream', () async {
        // Arrange
        final streamFuture = orderService.ordersStream.first;
        
        // Act
        await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Assert
        final orders = await streamFuture;
        expect(orders, isNotEmpty);
      });
      
      test('should emit order updates through stream', () async {
        // Arrange
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        final streamFuture = orderService.orderUpdatesStream.first;
        
        // Act
        await orderService.updateOrderStatus(order.id, OrderStatus.confirmed);
        
        // Assert
        final updatedOrder = await streamFuture;
        expect(updatedOrder.status, equals(OrderStatus.confirmed));
      });
    });
    
    group('Edge Cases', () {
      test('should handle multiple orders correctly', () async {
        // Arrange & Act
        final order1 = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        final order2 = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Assert
        expect(order1.id, isNot(equals(order2.id)));
        
        final allOrders = await orderService.getUserOrders();
        expect(allOrders.length, greaterThanOrEqualTo(2));
      });
      
      test('should generate unique order IDs', () async {
        // Act
        final order1 = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        final order2 = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Assert
        expect(order1.id, isNot(equals(order2.id)));
        expect(order1.trackingCode, isNot(equals(order2.trackingCode)));
      });
      
      test('should calculate estimated delivery time correctly', () async {
        // Act
        final order = await orderService.createOrder(
          cart: mockCart,
          deliveryAddress: mockAddress,
          paymentMethod: mockPaymentMethod,
        );
        
        // Assert
        expect(order.estimatedDeliveryTime, isNotNull);
        expect(
          order.estimatedDeliveryTime!.isAfter(DateTime.now()),
          isTrue,
        );
      });
    });
  });
}