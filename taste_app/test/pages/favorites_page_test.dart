import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/models/favorite_model.dart';
import 'package:taste_app/data/models/restaurant_model.dart';

void main() {
  group('FavoritesPage Tests', () {
    late List<FavoriteModel> mockFavorites;
    late List<RestaurantModel> mockRestaurants;

    setUp(() {
      mockRestaurants = [
        RestaurantModel(
          id: '1',
          name: 'Pizza Palace',
          categoryId: 'italiana',
          rating: 4.5,
          deliveryTime: '30-45 min',
          deliveryFee: 5.0,
          minOrderValue: 20.0,
          isOpen: true,
          isFeatured: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        RestaurantModel(
          id: '2',
          name: 'Sushi House',
          categoryId: 'japonesa',
          rating: 4.8,
          deliveryTime: '25-35 min',
          deliveryFee: 3.0,
          minOrderValue: 25.0,
          isOpen: true,
          isFeatured: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        RestaurantModel(
          id: '3',
          name: 'Burger King',
          categoryId: 'fast_food',
          rating: 4.2,
          deliveryTime: '20-30 min',
          deliveryFee: 2.0,
          minOrderValue: 15.0,
          isOpen: false,
          isFeatured: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      mockFavorites = [
        FavoriteModel(
          id: 'fav1',
          userId: 'user1',
          restaurantId: '1',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          restaurant: mockRestaurants[0].toEntity(),
        ),
        FavoriteModel(
          id: 'fav2',
          userId: 'user1',
          restaurantId: '2',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          restaurant: mockRestaurants[1].toEntity(),
        ),
        FavoriteModel(
          id: 'fav3',
          userId: 'user1',
          restaurantId: '3',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          restaurant: mockRestaurants[2].toEntity(),
        ),
      ];
    });

    test('should create FavoriteModel correctly', () {
      final favorite = mockFavorites.first;
      expect(favorite.id, 'fav1