import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/data/models/category_model.dart';
import 'package:taste_app/data/models/favorite_model.dart';
import 'package:taste_app/data/models/review_model.dart';

/// Helper class for creating test data and utilities
class TestHelpers {
  /// Creates a mock RestaurantModel for testing
  static RestaurantModel createMockRestaurant({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    String? categoryId,
    double? rating,
    double? deliveryFee,
    String? deliveryTime,
    bool? isOpen,
    bool? isFeatured,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantModel(
      id: id ?? 'test_restaurant_1',
      name: name ?? 'Test Restaurant',
      description: description ?? 'A delicious test restaurant',
      address: address ?? '123 Test Street, Test City',
      phone: phone ?? '+1234567890',
      latitude: latitude ?? -23.5505,
      longitude: longitude ?? -46.6333,
      categoryId: categoryId ?? 'italian',
      rating: rating ?? 4,
      deliveryFee: deliveryFee ?? 5.99,
      deliveryTime: deliveryTime ?? '30-45 min',
      isOpen: isOpen ?? true,
      isFeatured: isFeatured ?? false,
      imageUrl: imageUrl ?? 'https://example.com/restaurant.jpg',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates a mock CategoryModel for testing
  static CategoryModel createMockCategory({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? 'test_category_1',
      name: name ?? 'Italian',
      description: description,
      icon: icon ?? 'restaurant',
      color: color ?? '#FF6B47',
      isActive: isActive ?? true,
      sortOrder: sortOrder ?? 0,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates a mock FavoriteModel for testing
  static FavoriteModel createMockFavorite({
    String? id,
    String? userId,
    String? restaurantId,
    DateTime? createdAt,
    RestaurantModel? restaurant,
  }) {
    return FavoriteModel(
      id: id ?? 'test_favorite_1',
      userId: userId ?? 'test_user_1',
      restaurantId: restaurantId ?? 'test_restaurant_1',
      createdAt: createdAt ?? DateTime.now(),
      restaurant: restaurant?.toEntity() ?? createMockRestaurant().toEntity(),
    );
  }

  /// Creates a mock ReviewModel for testing
  static ReviewModel createMockReview({
    String? id,
    String? userId,
    String? restaurantId,
    String? userName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    int? helpfulCount,
    RestaurantModel? restaurant,
  }) {
    return ReviewModel(
      id: id ?? 'test_review_1',
      userId: userId ?? 'test_user_1',
      restaurantId: restaurantId ?? 'test_restaurant_1',
      userName: userName ?? 'Test User',
      rating: rating ?? 4,
      comment: comment ?? 'Great restaurant with excellent food!',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isVerified: isVerified ?? false,
      helpfulCount: helpfulCount ?? 0,
      restaurant: restaurant,
    );
  }

  /// Creates a list of mock restaurants for testing
  static List<RestaurantModel> createMockRestaurantList(int count) {
    return List.generate(count, (index) {
      return createMockRestaurant(
        id: 'restaurant_$index',
        name: 'Restaurant $index',
        rating: 3.0 + (index % 3), // Ratings between 3.0 and 5.0
        isOpen: index % 2 == 0, // Alternate open/closed
        isFeatured: index % 5 == 0, // Every 5th restaurant is featured
      );
    });
  }

  /// Creates a list of mock categories for testing
  static List<CategoryModel> createMockCategoryList([int? count]) {
    if (count != null) {
      return List.generate(count, (index) {
        return createMockCategory(
          id: 'category_$index',
          name: 'Category $index',
          icon: 'restaurant',
          color: '#FF6B47',
          sortOrder: index,
        );
      });
    }
    
    return [
      createMockCategory(
        id: 'italian',
        name: 'Italian',
        icon: 'restaurant',
        color: '#FF6B47',
      ),
      createMockCategory(
        id: 'mexican',
        name: 'Mexican',
        icon: 'local_dining',
        color: '#4CAF50',
      ),
      createMockCategory(
        id: 'chinese',
        name: 'Chinese',
        icon: 'ramen_dining',
        color: '#2196F3',
      ),
      createMockCategory(
        id: 'pizza',
        name: 'Pizza',
        icon: 'local_pizza',
        color: '#FF9800',
      ),
    ];
  }

  /// Wraps a widget with MaterialApp for testing
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Wraps a widget with MaterialApp and theme for testing
  static Widget wrapWithMaterialAppAndTheme(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Poppins',
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Pumps a widget and settles all animations
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
  }

  /// Finds a widget by its text content
  static Finder findByText(String text) {
    return find.text(text);
  }

  /// Finds a widget by its icon
  static Finder findByIcon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Finds a widget by its type
  static Finder findByType<T extends Widget>() {
    return find.byType(T);
  }

  /// Taps a widget and pumps the frame
  static Future<void> tapAndPump(
    WidgetTester tester,
    Finder finder, {
    Duration? duration,
  }) async {
    await tester.tap(finder);
    await tester.pump(duration);
  }

  /// Enters text into a text field and pumps the frame
  static Future<void> enterTextAndPump(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration? duration,
  }) async {
    await tester.enterText(finder, text);
    await tester.pump(duration);
  }

  /// Scrolls a widget and pumps the frame
  static Future<void> scrollAndPump(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    Duration? duration,
  }) async {
    await tester.drag(finder, offset);
    await tester.pump(duration ?? const Duration(milliseconds: 100));
  }

  /// Verifies that a widget exists
  static void expectWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verifies that a widget does not exist
  static void expectWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Verifies that multiple widgets exist
  static void expectMultipleWidgets(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }

  /// Verifies that at least one widget exists
  static void expectAtLeastOneWidget(Finder finder) {
    expect(finder, findsAtLeastNWidgets(1));
  }
}

/// Extension methods for WidgetTester to make testing easier
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps and settles with a default duration
  Future<void> pumpAndSettleDefault([Duration? duration]) async {
    await pumpAndSettle(duration ?? const Duration(milliseconds: 100));
  }

  /// Taps and pumps with a default duration
  Future<void> tapAndPumpDefault(Finder finder, [Duration? duration]) async {
    await tap(finder);
    await pump(duration ?? const Duration(milliseconds: 100));
  }

  /// Enters text and pumps with a default duration
  Future<void> enterTextAndPumpDefault(
    Finder finder,
    String text, [
    Duration? duration,
  ]) async {
    await enterText(finder, text);
    await pump(duration ?? const Duration(milliseconds: 100));
  }
}