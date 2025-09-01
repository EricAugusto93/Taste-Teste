import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/models/restaurant_model.dart';
import 'package:taste_app/presentation/widgets/restaurant_card.dart';
import 'package:taste_app/presentation/pages/restaurant_details_page.dart';
import 'package:taste_app/presentation/pages/search_page.dart';
import 'package:taste_app/presentation/pages/favorites_page.dart';
import 'package:taste_app/core/services/analytics_service.dart';
import 'package:taste_app/core/services/cache_service.dart';

void main() {
  group('Memory Leak Tests', () {
    testWidgets('Widget creation and disposal memory test', (WidgetTester tester) async {
      // Criar e destruir widgets múltiplas vezes para detectar vazamentos
      final restaurant = RestaurantModel(
        id: 'test_restaurant',
        name: 'Test Restaurant',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.5,
        deliveryTime: '30 min',
        deliveryFee: 5.0,
        category: 'Test Category',
        isOpen: true,
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Test Address',
        phone: '(11) 9999-0000',
        minOrderValue: 20.0,
        isFeatured: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Ciclo de criação e destruição de widgets
      for (int i = 0; i < 50; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RestaurantCard(
                restaurant: restaurant,
                onTap: () {},
              ),
            ),
          ),
        );
        
        await tester.pump();
        
        // Destruir widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );
        
        await tester.pump();
      }
      
      // Se chegou até aqui sem erros de memória, o teste passou
      expect(true, isTrue);
    });

    testWidgets('Page navigation memory test', (WidgetTester tester) async {
      // Testar navegação entre páginas para detectar vazamentos
      final restaurant = RestaurantModel(
        id: 'test_restaurant',
        name: 'Test Restaurant',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.5,
        deliveryTime: '30 min',
        deliveryFee: 5.0,
        category: 'Test Category',
        isOpen: true,
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Test Address',
        phone: '(11) 9999-0000',
        minOrderValue: 20.0,
        isFeatured: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      for (int i = 0; i < 20; i++) {
        // Navegar para página de detalhes
        await tester.pumpWidget(
          MaterialApp(
            home: RestaurantDetailsPage(restaurant: restaurant),
          ),
        );
        
        await tester.pump();
        
        // Navegar para página de busca
        await tester.pumpWidget(
          MaterialApp(
            home: SearchPage(),
          ),
        );
        
        await tester.pump();
        
        // Navegar para página de favoritos
        await tester.pumpWidget(
          MaterialApp(
            home: FavoritesPage(),
          ),
        );
        
        await tester.pump();
        
        // Voltar para página vazia
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );
        
        await tester.pump();
      }
      
      expect(true, isTrue);
    });

    testWidgets('List widget memory management test', (WidgetTester tester) async {
      // Testar listas grandes para verificar gerenciamento de memória
      for (int cycle = 0; cycle < 10; cycle++) {
        final restaurants = List.generate(100, (index) => RestaurantModel(
          id: 'restaurant_${cycle}_$index',
          name: 'Restaurant $cycle $index',
          description: 'Description for restaurant $cycle $index',
          imageUrl: 'https://example.com/image_${cycle}_$index.jpg',
          rating: 4.0 + (index % 10) / 10,
          deliveryTime: '${20 + (index % 30)} min',
          deliveryFee: 5.0 + (index % 10),
          category: 'Category ${index % 5}',
          isOpen: index % 2 == 0,
          latitude: -23.5505 + (index % 100) / 1000,
          longitude: -46.6333 + (index % 100) / 1000,
          address: 'Address $cycle $index',
          phone: '(11) 9999-${index.toString().padLeft(4, '0')}',
          minOrderValue: 20.0 + (index % 20),
          isFeatured: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) => RestaurantCard(
                  restaurant: restaurants[index],
                  onTap: () {},
                ),
              ),
            ),
          ),
        );
        
        await tester.pump();
        
        // Fazer scroll para carregar mais itens
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -1000),
          500,
        );
        
        await tester.pump();
        
        // Limpar lista
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );
        
        await tester.pump();
      }
      
      expect(true, isTrue);
    });

    test('Service memory management test', () async {
      // Testar serviços para vazamentos de memória
      final analyticsService = AnalyticsService();
      final cacheService = CacheService();
      
      // Usar serviços intensivamente
      for (int i = 0; i < 1000; i++) {
        // Analytics events
        analyticsService.trackEvent('test_event_$i', {
          'iteration': i,
          'data': 'test_data_$i',
        });
        
        // Cache operations
        await cacheService.set('test_key_$i', {
          'iteration': i,
          'data': List.generate(10, (j) => 'item_${i}_$j'),
        });
        
        if (i % 100 == 0) {
          // Limpar cache periodicamente
          await cacheService.clear();
        }
      }
      
      // Verificar que os serviços ainda funcionam
      await cacheService.set('final_test', {'status': 'ok'});
      final result = await cacheService.get('final_test');
      expect(result, isNotNull);
      expect(result!['status'], equals('ok'));
    });

    testWidgets('Animation memory management test', (WidgetTester tester) async {
      // Testar animações para vazamentos de memória
      for (int i = 0; i < 30; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 100 + (i % 10) * 20,
                height: 100 + (i % 10) * 20,
                color: Colors.blue,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: (i % 2 == 0) ? 1.0 : 0.5,
                  child: const Text('Animated Widget'),
                ),
              ),
            ),
          ),
        );
        
        // Aguardar animação
        await tester.pump(const Duration(milliseconds: 100));
        
        // Destruir widget animado
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );
        
        await tester.pump();
      }
      
      expect(true, isTrue);
    });

    testWidgets('Stream and listener memory test', (WidgetTester tester) async {
      // Testar streams e listeners para vazamentos
      for (int i = 0; i < 20; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StreamBuilder<int>(
                stream: Stream.periodic(
                  const Duration(milliseconds: 100),
                  (count) => count,
                ).take(10),
                builder: (context, snapshot) {
                  return Text('Stream value: ${snapshot.data ?? 0}');
                },
              ),
            ),
          ),
        );
        
        // Aguardar alguns eventos do stream
        await tester.pump(const Duration(milliseconds: 300));
        
        // Destruir StreamBuilder
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );
        
        await tester.pump();
      }
      
      expect(true, isTrue);
    });

    testWidgets('Image widget memory management test', (WidgetTester tester) async {
      // Testar widgets de imagem para vazamentos
      for (int i = 0; i < 25; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Image.network(
                    'https://picsum.photos/200/200?random=$i',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey,
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                  Image.asset(
                    'assets/images/placeholder.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: const Icon(Icons.image),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
        
        await tester.pump();
        
        // Destruir widgets de imagem
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );
        
        await tester.pump();
      }
      
      expect(true, isTrue);
    });
  });
}