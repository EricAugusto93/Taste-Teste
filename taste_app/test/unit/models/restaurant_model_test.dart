import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/models/restaurant_model.dart';

void main() {
  group('RestaurantModel Tests', () {
    late Map<String, dynamic> mockJson;

    setUp(() {
      mockJson = {
        'id': '1',
        'name': 'Test Restaurant',
        'description': 'A test restaurant',
        'address': '123 Test St',
        'phone': '+1234567890',
        'latitude': -23.5505,
        'longitude': -46.6333,
        'category_id': 'cat1',
        'rating': 4.5,
        'delivery_fee': 5.0,
        'delivery_time': '30-45 min',
        'is_open': true,
        'is_featured': false,
        'image_url': 'https://test.com/image.jpg',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };
    });

    test('should create RestaurantModel from JSON', () {
      // Act
      final restaurant = RestaurantModel.fromJson(mockJson);

      // Assert
      expect(restaurant.id, '1');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.description, 'A test restaurant');
      expect(restaurant.address, '123 Test St');
      expect(restaurant.phone, '+1234567890');
      expect(restaurant.latitude, -23.5505);
      expect(restaurant.longitude, -46.6333);
      expect(restaurant.categoryId, 'cat1');
      expect(restaurant.rating, 4.5);
      // Price range not in current model
      expect(restaurant.deliveryFee, 5.0);
      expect(restaurant.deliveryTime, '30-45 min');
      expect(restaurant.isOpen, true);
      expect(restaurant.isFeatured, false);
      expect(restaurant.imageUrl, 'https://test.com/image.jpg');
    });

    test('should convert RestaurantModel to JSON', () {
      // Arrange
      final restaurant = RestaurantModel.fromJson(mockJson);

      // Act
      final json = restaurant.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'Test Restaurant');
      expect(json['description'], 'A test restaurant');
      expect(json['address'], '123 Test St');
      expect(json['phone'], '+1234567890');
      // Email and website not in current model
      expect(json['latitude'], -23.5505);
      expect(json['longitude'], -46.6333);
      expect(json['category_id'], 'cat1');
      expect(json['rating'], 4.5);
      // Price range not in current model
      expect(json['delivery_fee'], 5.0);
      expect(json['delivery_time'], '30-45 min');
      expect(json['is_open'], true);
      expect(json['is_featured'], false);
      expect(json['image_url'], 'https://test.com/image.jpg');
    });

    test('should create copy with modified fields', () {
      // Arrange
      final restaurant = RestaurantModel.fromJson(mockJson);

      // Act
      final modifiedRestaurant = restaurant.copyWith(
        name: 'Modified Restaurant',
        rating: 5.0,
        isOpen: false,
      );

      // Assert
      expect(modifiedRestaurant.name, 'Modified Restaurant');
      expect(modifiedRestaurant.rating, 5.0);
      expect(modifiedRestaurant.isOpen, false);
      // Other fields should remain the same
      expect(modifiedRestaurant.id, restaurant.id);
      expect(modifiedRestaurant.description, restaurant.description);
      expect(modifiedRestaurant.address, restaurant.address);
    });

    test('should check equality correctly', () {
      // Arrange
      final restaurant1 = RestaurantModel.fromJson(mockJson);
      final restaurant2 = RestaurantModel.fromJson(mockJson);
      final restaurant3 = RestaurantModel.fromJson({
        ...mockJson,
        'id': '2',
      });

      // Assert
      expect(restaurant1, equals(restaurant2));
      expect(restaurant1, isNot(equals(restaurant3)));
      expect(restaurant1.hashCode, equals(restaurant2.hashCode));
      expect(restaurant1.hashCode, isNot(equals(restaurant3.hashCode)));
    });

    // Distance calculation method not available in current model

    // Price range formatting not available in current model

    // Price range checking not available in current model

    // Good rating checking not available in current model
  });
}