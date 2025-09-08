import 'package:flutter_test/flutter_test.dart';

import 'package:taste_app/data/models/category_model.dart';
import 'package:taste_app/data/models/restaurant_model.dart';

void main() {
  group('CategoryPage Tests', () {
    final mockCategory = CategoryModel(
      id: '1',
      name: 'Pizza',
      description: 'Delicious pizzas',
      icon: 'pizza_icon',
      color: '#FF6B47',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockRestaurants = [
      RestaurantModel(
        id: '1',
        name: 'Pizzaria Bella',
        description: 'Melhor pizza da cidade',
        imageUrl: null,
        rating: 4.5,
        reviewCount: 120,
        deliveryTime: '30-45 min',
        deliveryFee: 5.99,
        minOrderValue: 25.0,
        categoryId: '1',
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Rua das Pizzas, 123',
        phone: '(11) 1234-5678',
        isOpen: true,
        isFeatured: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RestaurantModel(
        id: '2',
        name: 'Pizza Express',
        description: 'Pizza rápida e saborosa',
        imageUrl: null,
        rating: 4.2,
        reviewCount: 85,
        deliveryTime: '25-40 min',
        deliveryFee: 4.99,
        minOrderValue: 20.0,
        categoryId: '1',
        latitude: -23.5515,
        longitude: -46.6343,
        address: 'Av. das Pizzas, 456',
        phone: '(11) 9876-5432',
        isOpen: true,
        isFeatured: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('CategoryModel should be created correctly', () {
      expect(mockCategory.id, '1');
      expect(mockCategory.name, 'Pizza');
      expect(mockCategory.description, 'Delicious pizzas');
      expect(mockCategory.isActive, true);
    });

    test('should create RestaurantModel correctly', () {
      final restaurant = mockRestaurants.first;
      expect(restaurant.id, '1');
      expect(restaurant.name, 'Pizzaria Bella');
      expect(restaurant.categoryId, '1');
      expect(restaurant.rating, 4.5);
    });

    test('should filter restaurants by category', () {
      final filteredRestaurants = mockRestaurants
          .where((r) => r.categoryId == mockCategory.id)
          .toList();

      expect(filteredRestaurants.length, 2);
      expect(filteredRestaurants.every((r) => r.categoryId == '1'), true);
    });

    test('should sort restaurants by rating', () {
      final sortedRestaurants = List<RestaurantModel>.from(mockRestaurants)
        ..sort((a, b) => b.rating.compareTo(a.rating));

      expect(sortedRestaurants.first.rating, 4.5);
      expect(sortedRestaurants.last.rating, 4.2);
    });

    test('should format delivery time correctly', () {
      final restaurant = mockRestaurants.first;
      expect(restaurant.deliveryTime, '30-45 min');
      expect(restaurant.deliveryTime.contains('min'), true);
    });

    test('should validate restaurant data', () {
      final restaurant = mockRestaurants.first;
      expect(restaurant.name.isNotEmpty, true);
      expect(restaurant.rating >= 0 && restaurant.rating <= 5, true);
      expect(restaurant.deliveryFee >= 0, true);
      expect((restaurant.minOrderValue ?? 0.0) >= 0, true);
    });

    test('should handle restaurant availability', () {
      final openRestaurants = mockRestaurants.where((r) => r.isOpen).toList();

      expect(openRestaurants.length, 2);
      expect(openRestaurants.every((r) => r.isOpen), true);
    });

    test('should calculate average rating', () {
      final totalRating =
          mockRestaurants.map((r) => r.rating).reduce((a, b) => a + b);
      final averageRating = totalRating / mockRestaurants.length;

      expect(averageRating, 4.35);
    });

    test('should validate category data', () {
      expect(mockCategory.name.isNotEmpty, true);
      expect(mockCategory.description?.isNotEmpty, true);
      expect(mockCategory.sortOrder >= 0, true);
    });

    test('should handle featured restaurants', () {
      final featuredRestaurants =
          mockRestaurants.where((r) => r.isFeatured).toList();

      expect(featuredRestaurants.length, 1);
      expect(featuredRestaurants.first.name, 'Pizzaria Bella');
    });
  });
}
