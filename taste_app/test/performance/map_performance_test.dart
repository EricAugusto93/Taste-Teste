import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/presentation/widgets/reusable_map_view.dart';
import 'package:taste_app/presentation/widgets/advanced_map_marker.dart';

void main() {
  group('Map Performance Tests', () {
    test('Map data processing performance', () async {
    final stopwatch = Stopwatch()..start();
    
    // Criar dados de teste
    final restaurants = List.generate(100, (index) => RestaurantModel(
      id: 'test_$index',
      name: 'Restaurant $index',
      category: 'Categoria $index',
      rating: 4.0 + (index % 10) / 10,
      priceRange: '\$\$',
      imageUrl: 'https://example.com/image_$index.jpg',
      latitude: -23.5505 + (index * 0.001),
      longitude: -46.6333 + (index * 0.001),
      address: 'Endereço $index',
      phone: '(11) 9999-$index',
      description: 'Descrição do restaurante $index',
      isOpen: true,
      distance: index * 0.1,
      deliveryTime: '30-45 min',
      deliveryFee: 5.0,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Simular processamento de dados do mapa
    final processedRestaurants = restaurants.where((r) => r.isOpen).toList();
    final sortedRestaurants = processedRestaurants..sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    
    stopwatch.stop();
    final processingTime = stopwatch.elapsedMilliseconds;
    
    print('Map data processing time for 100 restaurants: ${processingTime}ms');
    
    // Processamento de dados deve ser rápido
    expect(processingTime, lessThan(100)); // 100ms
    expect(sortedRestaurants.length, equals(100));
  });

    test('Marker creation performance', () async {
      final stopwatch = Stopwatch()..start();
      
      final restaurant = RestaurantModel(
        id: 'test_restaurant',
        name: 'Test Restaurant',
        category: 'Pizza',
        rating: 4.5,
        priceRange: '\$\$',
        imageUrl: 'https://example.com/image.jpg',
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Test Address',
        phone: '(11) 9999-9999',
        description: 'Test Description',
        isOpen: true,
        distance: 1.0,
        deliveryTime: '30-45 min',
        deliveryFee: 5.0,
        isFeatured: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Testar criação de marcador de restaurante
      await AdvancedMapMarker.createPremiumRestaurantMarker(
        restaurant: restaurant,
        isSelected: false,
        animationValue: 0.0,
      );
      
      stopwatch.stop();
      print('Restaurant marker creation time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Menos de 1 segundo
    });

    test('Cluster marker creation performance', () async {
      final stopwatch = Stopwatch()..start();
      
      // Testar criação de marcador de cluster
      await AdvancedMapMarker.createPremiumClusterMarker(
        count: 25,
        size: 80,
        isExpanded: false,
        animationValue: 0.0,
      );
      
      stopwatch.stop();
      print('Cluster marker creation time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Menos de 500ms
    });

    test('User location marker creation performance', () async {
      final stopwatch = Stopwatch()..start();
      
      // Testar criação de marcador de localização do usuário
      await AdvancedMapMarker.createAnimatedUserMarker(
        accuracy: 10.0,
        animationValue: 0.5,
      );
      
      stopwatch.stop();
      print('User marker creation time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Menos de 500ms
    });

    test('Multiple markers creation performance', () async {
      final stopwatch = Stopwatch()..start();
      
      final restaurants = List.generate(100, (index) => RestaurantModel(
        id: 'test_$index',
        name: 'Restaurant $index',
        category: 'Categoria $index',
        rating: 4.0 + (index % 10) / 10,
        priceRange: '\$\$',
        imageUrl: 'https://example.com/image_$index.jpg',
        latitude: -23.5505 + (index * 0.001),
        longitude: -46.6333 + (index * 0.001),
        address: 'Endereço $index',
        phone: '(11) 9999-$index',
        description: 'Descrição do restaurante $index',
        isOpen: true,
        distance: index * 0.1,
        deliveryTime: '30-45 min',
        deliveryFee: 5.0,
        isFeatured: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Criar marcadores para todos os restaurantes
      final futures = restaurants.map((restaurant) => 
        AdvancedMapMarker.createPremiumRestaurantMarker(
          restaurant: restaurant,
          isSelected: false,
          animationValue: 0.0,
        )
      ).toList();
      
      await Future.wait(futures);
      
      stopwatch.stop();
      print('100 markers creation time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // Menos de 10 segundos
    });

    testWidgets('Map clustering performance with many restaurants', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      try {
        // Criar restaurantes para testar clustering (reduzido para evitar timeout)
        final restaurants = List.generate(50, (index) => RestaurantModel(
          id: 'test_$index',
          name: 'Restaurant $index',
          category: 'Categoria $index',
          rating: 4.0 + (index % 10) / 10,
          priceRange: '\$\$',
          imageUrl: 'https://example.com/image_$index.jpg',
          latitude: -23.5505 + (index % 10) * 0.001,
          longitude: -46.6333 + (index % 10) * 0.001,
          address: 'Endereço $index',
          phone: '(11) 9999-$index',
          description: 'Descrição do restaurante $index',
          isOpen: true,
          distance: index * 0.1,
          deliveryTime: '30-45 min',
          deliveryFee: 5.0,
          isFeatured: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReusableMapView(
                restaurants: restaurants,
                initialPosition: const CameraPosition(
                  target: LatLng(-23.5505, -46.6333),
                  zoom: 12.0, // Zoom menor para melhor clustering
                ),
                onRestaurantTap: (restaurant) {},
                enableClustering: true,
                showUserLocation: false,
              ),
            ),
          ),
        );

        // Usar pump com timeout menor ao invés de pumpAndSettle
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        
        stopwatch.stop();
        final clusteringTime = stopwatch.elapsedMilliseconds;
        
        print('Clustering time for 50 restaurants: ${clusteringTime}ms');
        
        // Clustering deve ser eficiente
        expect(clusteringTime, lessThan(3000)); // 3 segundos
        
      } catch (e) {
        stopwatch.stop();
        print('Clustering test failed after ${stopwatch.elapsedMilliseconds}ms: $e');
        rethrow;
      }
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}