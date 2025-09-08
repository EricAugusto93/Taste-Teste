import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_app/data/services/cart/cart_service.dart';
import 'package:taste_app/data/models/cart_model.dart';
import 'package:taste_app/data/models/cart_item_model.dart';
import 'package:taste_app/data/models/menu_item_model.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/core/enums/delivery_type.dart';
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
    mockItems = items ??
        [
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartService Tests', () {
    late CartService cartService;
    late RestaurantModel mockRestaurant;
    late CartModel mockCart;

    setUp(() async {
      cartService = CartService();

      // Limpa SharedPreferences antes de cada teste
      SharedPreferences.setMockInitialValues({});

      // Cria dados mock
      mockRestaurant = TestHelpers.createMockRestaurant(
        id: 'rest1',
        name: 'Restaurante Teste',
        deliveryTime: '30-45 min',
      );

      mockCart = _createMockCart(
        id: 'cart1',
        restaurant: mockRestaurant,
      );
    });

    group('Cart Management', () {
      test('should return empty cart when no cart exists', () async {
        // Act
        final cart = await cartService.getCart();

        // Assert
        expect(cart.isEmpty, isTrue);
        expect(cart.items, isEmpty);
        expect(cart.subtotal, equals(0.0));
      });

      test('should save and retrieve cart successfully', () async {
        // Act
        await cartService.saveCart(mockCart);
        final retrievedCart = await cartService.getCart();

        // Assert
        expect(retrievedCart.id, equals(mockCart.id));
        expect(retrievedCart.restaurant?.id, equals(mockCart.restaurant?.id));
        expect(retrievedCart.items.length, equals(mockCart.items.length));
      });

      test('should clear cart successfully', () async {
        // Arrange
        await cartService.saveCart(mockCart);

        // Act
        await cartService.clearCart();
        final cart = await cartService.getCart();

        // Assert
        expect(cart.isEmpty, isTrue);
      });

      test('should handle save cart errors gracefully', () async {
        // Arrange
        final invalidCart = CartModel(
          id: 'invalid',
          items: const [],
          restaurant: null,
          subtotal: 0.0,
          deliveryFee: 0.0,
          total: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(() => cartService.saveCart(invalidCart), returnsNormally);
      });
    });

    group('Promo Codes', () {
      test('should validate PRIMEIRA10 promo code correctly', () async {
        // Arrange
        const subtotal = 100.0;

        // Act
        final discount =
            await cartService.validatePromoCode('PRIMEIRA10', subtotal);

        // Assert
        expect(discount, equals(10.0)); // 10% com máximo de R$ 20
      });

      test('should validate DESCONTO15 promo code correctly', () async {
        // Arrange
        const subtotal = 100.0;

        // Act
        final discount =
            await cartService.validatePromoCode('DESCONTO15', subtotal);

        // Assert
        expect(discount, equals(15.0)); // 15% com máximo de R$ 30
      });

      test('should validate BEMVINDO promo code with minimum order', () async {
        // Arrange
        const subtotal = 50.0;

        // Act
        final discount =
            await cartService.validatePromoCode('BEMVINDO', subtotal);

        // Assert
        expect(discount, equals(5.0)); // Desconto fixo de R$ 5
      });

      test('should reject BEMVINDO promo code below minimum order', () async {
        // Arrange
        const subtotal = 20.0;

        // Act & Assert
        expect(
          () => cartService.validatePromoCode('BEMVINDO', subtotal),
          throwsA(isA<Exception>()),
        );
      });

      test('should reject invalid promo code', () async {
        // Arrange
        const subtotal = 100.0;

        // Act & Assert
        expect(
          () => cartService.validatePromoCode('INVALID', subtotal),
          throwsA(isA<Exception>()),
        );
      });

      test('should identify delivery free codes correctly', () {
        // Act & Assert
        expect(cartService.isDeliveryFreeCode('FRETEGRATIS'), isTrue);
        expect(cartService.isDeliveryFreeCode('fretegratis'), isTrue);
        expect(cartService.isDeliveryFreeCode('PRIMEIRA10'), isFalse);
      });

      test('should return promo code suggestions', () {
        // Act
        final suggestions = cartService.getPromoCodeSuggestions();

        // Assert
        expect(suggestions, isNotEmpty);
        expect(suggestions, contains('PRIMEIRA10'));
        expect(suggestions, contains('DESCONTO15'));
        expect(suggestions, contains('FRETEGRATIS'));
      });
    });

    group('Delivery Calculations', () {
      test('should calculate delivery fee based on distance', () {
        // Act & Assert
        expect(cartService.calculateDeliveryFee(1.5), equals(3.0));
        expect(cartService.calculateDeliveryFee(3.0), equals(5.0));
        expect(cartService.calculateDeliveryFee(7.0), equals(8.0));
        expect(cartService.calculateDeliveryFee(15.0), equals(12.0));
        expect(cartService.calculateDeliveryFee(null), equals(5.0));
      });

      test('should calculate delivery time correctly', () {
        // Act
        final deliveryTime = cartService.calculateDeliveryTime(mockRestaurant);

        // Assert
        expect(deliveryTime, isA<String>());
        expect(deliveryTime, isNotEmpty);
      });

      test('should check if restaurant is open', () {
        // Act
        final isOpen = cartService.isRestaurantOpen(mockRestaurant);

        // Assert
        expect(isOpen, isA<bool>());
      });
    });

    group('Cart History', () {
      test('should save cart to history when cart is not empty', () async {
        // Act
        await cartService.saveCart(mockCart);
        final history = await cartService.getCartHistory();

        // Assert
        expect(history, isNotEmpty);
        expect(history.first.id, equals(mockCart.id));
      });

      test('should return empty history when no history exists', () async {
        // Act
        final history = await cartService.getCartHistory();

        // Assert
        expect(history, isEmpty);
      });

      test('should restore cart from history', () async {
        // Arrange
        await cartService.saveCart(mockCart);
        final history = await cartService.getCartHistory();

        expect(history, isNotEmpty);
        final historicalCart = history.first;

        // Act
        await cartService.restoreFromHistory(historicalCart);
        final restoredCart = await cartService.getCart();

        // Assert
        expect(
            restoredCart.restaurant?.id, equals(historicalCart.restaurant?.id));
        expect(restoredCart.items.length, equals(historicalCart.items.length));
      });
    });

    group('Item Availability', () {
      test('should check item availability', () async {
        // Act
        final unavailableItems =
            await cartService.checkItemAvailability(mockCart);

        // Assert
        expect(unavailableItems, isA<List<CartItemModel>>());
      });
    });

    group('Tax Calculations', () {
      test('should calculate total with tax correctly', () {
        // Arrange
        final cart = mockCart.copyWith(subtotal: 100.0, total: 105.0);

        // Act
        final totalWithTax = cartService.calculateTotalWithTax(cart);

        // Assert
        expect(totalWithTax, equals(110.0)); // 105 + (100 * 0.05)
      });
    });

    group('Order Processing', () {
      test('should validate if order can be processed', () async {
        // Act
        final canProcess = await cartService.canProcessOrder(mockCart);

        // Assert
        expect(canProcess, isA<bool>());
      });

      test('should reject empty cart for processing', () async {
        // Arrange
        final emptyCart = CartModel.empty();

        // Act
        final canProcess = await cartService.canProcessOrder(emptyCart);

        // Assert
        expect(canProcess, isFalse);
      });
    });

    group('Delivery Type Management', () {
      test('should set and get delivery type', () async {
        // Act
        await cartService.setDeliveryType(DeliveryType.pickup);
        final deliveryType = await cartService.getDeliveryType();

        // Assert
        expect(deliveryType, equals(DeliveryType.pickup));
        expect(cartService.currentDeliveryType, equals(DeliveryType.pickup));
      });

      test('should return default delivery type when none set', () async {
        // Act
        final deliveryType = await cartService.getDeliveryType();

        // Assert
        expect(deliveryType, equals(DeliveryType.delivery));
      });
    });

    group('Delivery Info', () {
      test('should return delivery info for valid cart', () {
        // Act
        final deliveryInfo = cartService.getDeliveryInfo(mockCart);

        // Assert
        expect(deliveryInfo, isA<Map<String, dynamic>>());
        expect(deliveryInfo.containsKey('canDeliver'), isTrue);
        expect(deliveryInfo.containsKey('estimatedTime'), isTrue);
        expect(deliveryInfo.containsKey('deliveryFee'), isTrue);
        expect(deliveryInfo.containsKey('minimumOrder'), isTrue);
        expect(deliveryInfo.containsKey('deliveryType'), isTrue);
      });

      test('should return error for cart without restaurant', () {
        // Arrange
        final cartWithoutRestaurant = _createMockCart(
          id: 'cart_no_restaurant',
          restaurant: null,
          isEmpty: true,
        );

        // Act
        final deliveryInfo = cartService.getDeliveryInfo(cartWithoutRestaurant);

        // Assert
        expect(deliveryInfo['canDeliver'], isFalse);
        expect(deliveryInfo['reason'], equals('Restaurante não selecionado'));
      });
    });

    group('Edge Cases', () {
      test('should handle malformed cart data gracefully', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_cart', 'invalid json');

        // Act
        final cart = await cartService.getCart();

        // Assert
        expect(cart.isEmpty, isTrue);
      });

      test('should handle malformed history data gracefully', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cart_history', 'invalid json');

        // Act
        final history = await cartService.getCartHistory();

        // Assert
        expect(history, isEmpty);
      });

      test('should handle promo code validation with case insensitivity',
          () async {
        // Arrange
        const subtotal = 100.0;

        // Act
        final discount1 =
            await cartService.validatePromoCode('primeira10', subtotal);
        final discount2 =
            await cartService.validatePromoCode('PRIMEIRA10', subtotal);

        // Assert
        expect(discount1, equals(discount2));
      });

      test('should handle delivery time calculation with invalid format', () {
        // Arrange
        final restaurantWithInvalidTime = mockRestaurant.copyWith(
          deliveryTime: 'invalid format',
        );

        // Act
        final deliveryTime =
            cartService.calculateDeliveryTime(restaurantWithInvalidTime);

        // Assert
        expect(deliveryTime, equals('invalid format'));
      });
    });
  });
}
