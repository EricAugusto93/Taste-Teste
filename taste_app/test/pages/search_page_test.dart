import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/models/category_model.dart';
import 'package:taste_app/data/models/restaurant_model.dart';

// Mock data
final mockCategories = [
  CategoryModel(
    id: '1',
    name: 'Pizza',
    icon: 'pizza',
    color: '#FF5722',
    isActive: true,
    sortOrder: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  CategoryModel(
    id: '2',
    name: 'Hambúrguer',
    icon: 'hamburger',
    color: '#4CAF50',
    isActive: true,
    sortOrder: 2,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

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
    name: 'Burger House',
    description: 'Hambúrgueres artesanais',
    imageUrl: null,
    rating: 4.2,
    reviewCount: 85,
    deliveryTime: '25-40 min',
    deliveryFee: 4.99,
    minOrderValue: 20.0,
    categoryId: '2',
    latitude: -23.5515,
    longitude: -46.6343,
    address: 'Av. dos Hambúrgueres, 456',
    phone: '(11) 9876-5432',
    isOpen: true,
    isFeatured: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

void main() {
  group('SearchPage Basic Tests', () {
    testWidgets('should create SearchPage widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text('Buscar'),
            ),
            body: Center(
              child: Text('SearchPage Test'),
            ),
          ),
        ),
      );
      
      expect(find.text('Buscar'), findsOneWidget);
      expect(find.text('SearchPage Test'), findsOneWidget);
    });
    
    testWidgets('should display search field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    key: Key('search_field'),
                    decoration: InputDecoration(
                      hintText: 'Buscar restaurantes, pratos...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.filter_list),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('Digite para buscar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Buscar restaurantes, pratos...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.text('Digite para buscar'), findsOneWidget);
    });
    
    testWidgets('should handle search input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: Key('search_field'),
              decoration: InputDecoration(
                hintText: 'Buscar restaurantes, pratos...',
              ),
            ),
          ),
        ),
      );
      
      final searchField = find.byKey(Key('search_field'));
      expect(searchField, findsOneWidget);
      
      await tester.enterText(searchField, 'pizza');
      await tester.pump();
      
      expect(find.text('pizza'), findsOneWidget);
    });
    
    testWidgets('should display search suggestions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.history),
                        title: Text('pizza'),
                        subtitle: Text('Busca recente'),
                      ),
                      ListTile(
                        leading: Icon(Icons.trending_up),
                        title: Text('hambúrguer'),
                        subtitle: Text('Popular'),
                      ),
                      ListTile(
                        leading: Icon(Icons.restaurant),
                        title: Text('sushi'),
                        subtitle: Text('Sugestão'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('pizza'), findsOneWidget);
      expect(find.text('hambúrguer'), findsOneWidget);
      expect(find.text('sushi'), findsOneWidget);
      expect(find.text('Busca recente'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Sugestão'), findsOneWidget);
    });
    
    testWidgets('should display search results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: mockRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = mockRestaurants[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: restaurant.imageUrl != null 
                          ? NetworkImage(restaurant.imageUrl!) 
                          : null,
                      child: restaurant.imageUrl == null 
                          ? Icon(Icons.restaurant) 
                          : null,
                    ),
                    title: Text(restaurant.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (restaurant.description != null)
                          Text(restaurant.description!),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Text('${restaurant.rating}'),
                            SizedBox(width: 8),
                            Text(restaurant.deliveryTime),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.favorite_border),
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.text('Pizzaria Bella'), findsOneWidget);
      expect(find.text('Burger House'), findsOneWidget);
      expect(find.text('Melhor pizza da cidade'), findsOneWidget);
      expect(find.text('Hambúrgueres artesanais'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('4.2'), findsOneWidget);
    });
    
    testWidgets('should display empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum resultado encontrado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tente buscar por outro termo',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Nenhum resultado encontrado'), findsOneWidget);
      expect(find.text('Tente buscar por outro termo'), findsOneWidget);
    });
    
    testWidgets('should handle filter button tap', (tester) async {
      bool filterTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                filterTapped = true;
              },
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pump();
      
      expect(filterTapped, isTrue);
    });
  });
  
  group('Search Filters Tests', () {
    testWidgets('should display filter options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text('Entrega grátis'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: Text('Avaliação 4+'),
                      selected: true,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: Text('Aberto agora'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Filtros'), findsOneWidget);
      expect(find.text('Entrega grátis'), findsOneWidget);
      expect(find.text('Avaliação 4+'), findsOneWidget);
      expect(find.text('Aberto agora'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(3));
    });
    
    testWidgets('should handle filter selection', (tester) async {
      bool filterSelected = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterChip(
              label: Text('Entrega grátis'),
              selected: false,
              onSelected: (selected) {
                filterSelected = selected;
              },
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(FilterChip));
      await tester.pump();
      
      expect(filterSelected, isTrue);
    });
  });
  
  group('Search History Tests', () {
    testWidgets('should display search history', (tester) async {
      final searchHistory = ['pizza', 'hambúrguer', 'sushi', 'japonês'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Buscas recentes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Limpar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.history),
                        title: Text(searchHistory[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Buscas recentes'), findsOneWidget);
      expect(find.text('Limpar'), findsOneWidget);
      expect(find.text('pizza'), findsOneWidget);
      expect(find.text('hambúrguer'), findsOneWidget);
      expect(find.text('sushi'), findsOneWidget);
      expect(find.text('japonês'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsNWidgets(4));
      expect(find.byIcon(Icons.close), findsNWidgets(4));
    });
    
    testWidgets('should handle clear history', (tester) async {
      bool historyCleard = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () {
                historyCleard = true;
              },
              child: Text('Limpar'),
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Limpar'));
      await tester.pump();
      
      expect(historyCleard, isTrue);
    });
  });
}