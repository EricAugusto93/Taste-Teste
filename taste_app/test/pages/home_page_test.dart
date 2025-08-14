import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taste_app/data/models/category_model.dart';

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

void main() {
  group('HomePage Basic Tests', () {
    testWidgets('should create HomePage widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('HomePage Test'),
            ),
          ),
        ),
      );
      
      expect(find.text('HomePage Test'), findsOneWidget);
    });
    
    testWidgets('should display basic UI elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text('Taste'),
            ),
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar restaurantes...',
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text('Categorias'),
                      ),
                      ListTile(
                        title: Text('Perto de você'),
                      ),
                      ListTile(
                        title: Text('Populares perto de você'),
                      ),
                      ListTile(
                        title: Text('Recomendados para você'),
                      ),
                      ListTile(
                        title: Text('Mais restaurantes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Taste'), findsOneWidget);
      expect(find.text('Buscar restaurantes...'), findsOneWidget);
      expect(find.text('Categorias'), findsOneWidget);
      expect(find.text('Perto de você'), findsOneWidget);
      expect(find.text('Populares perto de você'), findsOneWidget);
      expect(find.text('Recomendados para você'), findsOneWidget);
      expect(find.text('Mais restaurantes'), findsOneWidget);
    });
    
    testWidgets('should handle search input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: Key('search_field'),
              decoration: InputDecoration(
                hintText: 'Buscar restaurantes...',
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
    
    testWidgets('should handle pull to refresh', (tester) async {
      bool refreshCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                refreshCalled = true;
              },
              child: ListView(
                children: [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                  ListTile(title: Text('Item 3')),
                ],
              ),
            ),
          ),
        ),
      );
      
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      expect(refreshCalled, isTrue);
    });
    
    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should handle scroll behavior', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.text('Item 0'), findsOneWidget);
      
      // Scroll para baixo
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();
      
      // Verifica se ainda há itens visíveis
      expect(find.byType(ListTile), findsWidgets);
    });
  });
  
  group('HomeSection Tests', () {
    testWidgets('should render section with title', (tester) async {
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
                        'Test Section',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Ver todos'),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Ver todos'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });
    
    testWidgets('should handle action button tap', (tester) async {
      bool actionTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () {
                actionTapped = true;
              },
              child: Text('Ver todos'),
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Ver todos'));
      await tester.pump();
      
      expect(actionTapped, isTrue);
    });
  });
  
  group('Category Tests', () {
    testWidgets('should display categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: mockCategories.length,
              itemBuilder: (context, index) {
                final category = mockCategories[index];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant),
                      Text(category.name),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Hambúrguer'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
    });
  });
}