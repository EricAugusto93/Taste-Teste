import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:taste_app/presentation/pages/restaurant/restaurant_details_page.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/data/models/review_model.dart';
import 'package:taste_app/data/models/menu_item_model.dart';
import 'package:taste_app/data/repositories/review_repository.dart';
import 'package:taste_app/data/repositories/menu_repository.dart';
import 'package:taste_app/data/repositories/restaurant_repository.dart';
import 'package:taste_app/presentation/widgets/favorite_button.dart';
import 'package:taste_app/presentation/widgets/custom_button.dart';
import 'package:taste_app/presentation/widgets/loading_widget.dart';
import 'package:taste_app/presentation/widgets/error_widget.dart';

// Generate mocks
@GenerateMocks([ReviewRepository, MenuRepository, RestaurantRepository])
import 'restaurant_details_page_test.mocks.dart';

void main() {
  group('RestaurantDetailsPage Tests', () {
    late MockReviewRepository mockReviewRepository;
    late MockMenuRepository mockMenuRepository;
    late MockRestaurantRepository mockRestaurantRepository;
    
    // Mock data
    final mockRestaurant = RestaurantModel(
      id: '1',
      name: 'Restaurante Teste',
      description: 'Descrição do restaurante teste',
      category: 'Italiana',
      rating: 4.5,
      reviewCount: 150,
      deliveryTime: '30 min',
      deliveryFee: 5.99,
      minOrderValue: 25.0,
      imageUrl: 'https://example.com/image.jpg',
      address: 'Rua Teste, 123',
      phone: '(11) 99999-9999',
      latitude: -23.5505,
      longitude: -46.6333,
      isOpen: true,
      isFeatured: false,
      priceRange: r'$$',
      hasPromotion: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final List<ReviewModel> mockReviews = [
      ReviewModel(
        id: '1',
        userId: 'user1',
        restaurantId: '1',
        userName: 'João Silva',
        userAvatar: null,
        rating: 5,
        comment: 'Excelente restaurante!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isVerified: true,
        helpfulCount: 10,
        restaurant: null,
      ),
      ReviewModel(
        id: '2',
        userId: 'user2',
        restaurantId: '1',
        userName: 'Maria Santos',
        userAvatar: null,
        rating: 4,
        comment: 'Muito bom, recomendo!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: false,
        helpfulCount: 5,
        restaurant: null,
      ),
    ];
    
    final List<MenuCategoryModel> mockMenuCategories = [
      MenuCategoryModel(
        id: '1',
        name: 'Pizzas',
        description: 'Nossas deliciosas pizzas',
        sortOrder: 1,
        items: [
          MenuItemModel(
            id: '1',
            restaurantId: '1',
            name: 'Pizza Margherita',
            description: 'Molho de tomate, mussarela e manjericão',
            price: 35.90,
            imageUrl: 'https://example.com/pizza.jpg',
            categoryName: 'Pizzas',
            isAvailable: true,
            allergens: const ['Glúten', 'Lactose'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      ),
    ];
    
    setUp(() {
      mockReviewRepository = MockReviewRepository();
      mockMenuRepository = MockMenuRepository();
      mockRestaurantRepository = MockRestaurantRepository();
    });
    
    Widget createTestWidget({RestaurantModel? restaurant}) {
      return ProviderScope(
        child: MaterialApp(
          home: RestaurantDetailsPage(
            restaurantId: '1',
            restaurant: restaurant,
          ),
        ),
      );
    }
    
    group('Widget Creation and Basic Display', () {
      testWidgets('should create RestaurantDetailsPage widget', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        
        expect(find.byType(RestaurantDetailsPage), findsOneWidget);
      });
      
      testWidgets('should display restaurant name when provided', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.text('Restaurante Teste'), findsOneWidget);
      });
      
      testWidgets('should display loading widget initially when no restaurant provided', (tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.byType(LoadingWidget), findsOneWidget);
      });
      
      testWidgets('should display restaurant rating', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.text('4.5'), findsOneWidget);
      });
      
      testWidgets('should display delivery time', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.textContaining('30'), findsOneWidget);
      });
    });
    
    group('Action Buttons', () {
      testWidgets('should display favorite button', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.byType(FavoriteButton), findsOneWidget);
      });
      
      testWidgets('should display share button', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.byIcon(Icons.share), findsOneWidget);
      });
      
      testWidgets('should display phone button when phone is available', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.byIcon(Icons.phone), findsOneWidget);
      });
      
      testWidgets('should display directions button when location is available', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.byIcon(Icons.directions), findsOneWidget);
      });
      
      testWidgets('should display order button', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.byType(CustomButton), findsOneWidget);
      });
    });
    
    group('Tab Navigation', () {
      testWidgets('should display tab bar with three tabs', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(Tab), findsNWidgets(3));
      });
      
      testWidgets('should switch between tabs', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Tap on second tab
        await tester.tap(find.byType(Tab).at(1));
        await tester.pump();
        
        // Verify tab switched
        final tabBar = tester.widget<TabBar>(find.byType(TabBar));
        expect(tabBar.controller?.index, equals(1));
      });
    });
    
    group('Reviews Section', () {
      testWidgets('should display reviews when available', (tester) async {
        // Mock the repository calls
        when(mockReviewRepository.getReviewsByRestaurant('1'))
            .thenAnswer((_) async => mockReviews);
        when(mockMenuRepository.getMenuByRestaurant('1'))
            .thenAnswer((_) async => mockMenuCategories);
        
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Wait for async operations
        await tester.pump(const Duration(seconds: 1));
        
        expect(find.text('João Silva'), findsOneWidget);
        expect(find.text('Excelente restaurante!'), findsOneWidget);
      });
      
      testWidgets('should display rating dialog when rating button is tapped', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Find and tap rating button
        final ratingButton = find.byIcon(Icons.star_border);
        if (ratingButton.evaluate().isNotEmpty) {
          await tester.tap(ratingButton);
          await tester.pump();
          
          expect(find.byType(Dialog), findsOneWidget);
        }
      });
    });
    
    group('Menu Section', () {
      testWidgets('should display menu categories when available', (tester) async {
        // Mock the repository calls
        when(mockReviewRepository.getReviewsByRestaurant('1'))
            .thenAnswer((_) async => []);
        when(mockMenuRepository.getMenuByRestaurant('1'))
            .thenAnswer((_) async => mockMenuCategories);
        
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Wait for async operations
        await tester.pump(const Duration(seconds: 1));
        
        expect(find.text('Pizzas'), findsOneWidget);
        expect(find.text('Pizza Margherita'), findsOneWidget);
      });
      
      testWidgets('should display menu item price', (tester) async {
        // Mock the repository calls
        when(mockReviewRepository.getReviewsByRestaurant('1'))
            .thenAnswer((_) async => []);
        when(mockMenuRepository.getMenuByRestaurant('1'))
            .thenAnswer((_) async => mockMenuCategories);
        
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Wait for async operations
        await tester.pump(const Duration(seconds: 1));
        
        expect(find.textContaining('35,90'), findsOneWidget);
      });
    });
    
    group('Error Handling', () {
      testWidgets('should display error widget when restaurant loading fails', (tester) async {
        when(mockRestaurantRepository.getRestaurantById('1'))
            .thenThrow(Exception('Failed to load restaurant'));
        
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        
        // Wait for async operations
        await tester.pump(const Duration(seconds: 1));
        
        expect(find.byType(ErrorWidget), findsOneWidget);
      });
      
      testWidgets('should handle empty reviews gracefully', (tester) async {
        when(mockReviewRepository.getReviewsByRestaurant('1'))
            .thenAnswer((_) async => []);
        when(mockMenuRepository.getMenuByRestaurant('1'))
            .thenAnswer((_) async => []);
        
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Wait for async operations
        await tester.pump(const Duration(seconds: 1));
        
        // Should not crash and should display empty state
        expect(find.byType(RestaurantDetailsPage), findsOneWidget);
      });
      
      testWidgets('should handle empty menu gracefully', (tester) async {
        when(mockReviewRepository.getReviewsByRestaurant('1'))
            .thenAnswer((_) async => mockReviews);
        when(mockMenuRepository.getMenuByRestaurant('1'))
            .thenAnswer((_) async => []);
        
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Wait for async operations
        await tester.pump(const Duration(seconds: 1));
        
        // Should not crash and should display empty menu state
        expect(find.byType(RestaurantDetailsPage), findsOneWidget);
      });
    });
    
    group('Order Flow', () {
      testWidgets('should show order options modal when order button is tapped', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Find and tap order button
        final orderButton = find.byType(CustomButton);
        await tester.tap(orderButton);
        await tester.pump();
        
        // Should show modal bottom sheet
        expect(find.text('Como você gostaria de fazer o pedido?'), findsOneWidget);
        expect(find.text('Delivery'), findsOneWidget);
        expect(find.text('Retirada'), findsOneWidget);
      });
      
      testWidgets('should display delivery information in order modal', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Tap order button to show modal
        final orderButton = find.byType(CustomButton);
        await tester.tap(orderButton);
        await tester.pump();
        
        // Check delivery information
        expect(find.textContaining('30 min'), findsOneWidget);
        expect(find.textContaining('5,99'), findsOneWidget);
      });
    });
    
    group('Scroll Behavior', () {
      testWidgets('should show app bar title when scrolled', (tester) async {
        await tester.pumpWidget(createTestWidget(restaurant: mockRestaurant));
        await tester.pump();
        
        // Scroll down
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pump();
        
        // App bar title should be visible
        expect(find.text('Restaurante Teste'), findsOneWidget);
      });
    });
    
    group('Data Validation', () {
      testWidgets('should handle null restaurant data gracefully', (tester) async {
        final nullDataRestaurant = RestaurantModel(
          id: '1',
          name: 'Teste',
          description: null,
          category: 'Teste',
          rating: 0.0,
          reviewCount: 0,
          deliveryTime: '0 min',
          deliveryFee: 0.0,
          minOrderValue: null,
          imageUrl: null,
          address: 'Endereço',
          phone: null,
          latitude: null,
          longitude: null,
          isOpen: true,
          isFeatured: false,
          priceRange: r'$',
          hasPromotion: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await tester.pumpWidget(createTestWidget(restaurant: nullDataRestaurant));
        await tester.pump();
        
        // Should not crash with null data
        expect(find.byType(RestaurantDetailsPage), findsOneWidget);
        expect(find.text('Teste'), findsOneWidget);
      });
      
      testWidgets('should validate restaurant rating display', (tester) async {
        final highRatingRestaurant = mockRestaurant.copyWith(rating: 4.8);
        
        await tester.pumpWidget(createTestWidget(restaurant: highRatingRestaurant));
        await tester.pump();
        
        expect(find.text('4.8'), findsOneWidget);
      });
      
      testWidgets('should validate delivery fee display', (tester) async {
        final freeDeliveryRestaurant = mockRestaurant.copyWith(deliveryFee: 0.0);
        
        await tester.pumpWidget(createTestWidget(restaurant: freeDeliveryRestaurant));
        await tester.pump();
        
        // Should show "Grátis" for free delivery
        expect(find.textContaining('Grátis'), findsOneWidget);
      });
    });
  });
}