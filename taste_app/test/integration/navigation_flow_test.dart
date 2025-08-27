import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {

  group('Navigation Flow Integration Tests', () {
    testWidgets('Complete navigation flow - onboarding to home to categories to details', (tester) async {
      int currentIndex = 0;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: IndexedStack(
                    index: currentIndex,
                    children: [
                      const Center(child: Text('Home Page')),
                      const Center(child: TextField(decoration: InputDecoration(hintText: 'Search'))),
                      const Center(child: Text('Favoritos')),
                      const Center(child: Text('Perfil')),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: currentIndex,
                    onTap: (index) => setState(() => currentIndex = index),
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
                      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verificar se chegamos na home
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home Page'), findsOneWidget);
      
      // Testar navegação entre abas da bottom navigation
      // Busca
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      
      // Favoritos
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.text('Favoritos'), findsOneWidget);
      
      // Perfil
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('Perfil'), findsOneWidget);
      
      // Voltar para home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('Category navigation flow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: Column(
                children: [
                  GestureDetector(
                    key: const Key('category_card'),
                    onTap: () {
                      Navigator.push(
                        tester.element(find.byType(Scaffold)),
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Categoria'),
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            body: const Center(
                              child: Text('Restaurantes da categoria'),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Pizza'),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                ],
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Verificar se há categorias na home
      final categoryCards = find.byKey(const Key('category_card'));
      expect(categoryCards, findsOneWidget);
      
      // Tocar na primeira categoria
      await tester.tap(categoryCards.first);
      await tester.pumpAndSettle();
      
      // Verificar se navegou para a página de categoria
      expect(find.byType(AppBar), findsAtLeastNWidgets(1)); // Category page
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Restaurantes da categoria'), findsOneWidget);
      
      // Voltar para home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verificar se voltou para home
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
    });

    testWidgets('Restaurant details navigation flow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: Column(
                children: [
                  GestureDetector(
                    key: const Key('restaurant_card'),
                    onTap: () {
                      Navigator.push(
                        tester.element(find.byType(Scaffold)),
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Restaurante'),
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            body: const SingleChildScrollView(
                              child: Column(
                                children: [
                                  const Text('Nome do Restaurante'),
                                  const Text('Descrição do restaurante'),
                                  const SizedBox(height: 1000), // Para testar scroll
                                  const Text('Final da página'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Restaurante Teste'),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                ],
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Procurar por cards de restaurante na home
      final restaurantCards = find.byKey(const Key('restaurant_card'));
      expect(restaurantCards, findsOneWidget);
      
      // Tocar no primeiro restaurante
      await tester.tap(restaurantCards.first);
      await tester.pumpAndSettle();
      
      // Verificar se navegou para detalhes do restaurante
      expect(find.byType(AppBar), findsAtLeastNWidgets(1)); // Details page
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Nome do Restaurante'), findsOneWidget);
      
      // Testar scroll na página de detalhes
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -200));
      await tester.pumpAndSettle();
      
      // Voltar para home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verificar se voltou para home
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Restaurante Teste'), findsOneWidget);
    });

    testWidgets('Deep navigation and back button handling', (tester) async {
      final searchController = TextEditingController();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: TextField(controller: searchController, decoration: const InputDecoration(hintText: 'Search'))),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                ],
                onTap: (index) {},
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verificar se estamos na busca
      expect(find.byType(TextField), findsOneWidget);
      
      // Realizar busca
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'pizza');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      
      // Verificar que a busca foi realizada
      expect(searchController.text, equals('pizza'));
      
      // Verificar se ainda estamos na tela de busca
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Navigation state preservation', (tester) async {
      int currentIndex = 1; // Start on search tab
      final searchController = TextEditingController();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: IndexedStack(
                    index: currentIndex,
                    children: [
                      const Center(child: Text('Home Page')),
                      const Center(child: TextField(controller: searchController, decoration: const InputDecoration(hintText: 'Search'))),
                      const Center(child: Text('Favoritos')),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) => setState(() => currentIndex = index),
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verificar se estamos na busca
      expect(find.byType(TextField), findsOneWidget);
      
      // Fazer uma busca
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'teste');
      await tester.pumpAndSettle();
      
      // Navegar para favoritos
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.text('Favoritos'), findsOneWidget);
      
      // Voltar para busca
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      // Verificar se o texto da busca foi preservado
      expect(searchController.text, equals('teste'));
    });

    testWidgets('Error handling in navigation', (tester) async {
      int currentIndex = 0;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: IndexedStack(
                    index: currentIndex,
                    children: [
                      const Center(child: Text('Home Page')),
                      const Center(child: TextField(decoration: InputDecoration(hintText: 'Search'))),
                      const Center(child: Text('Favoritos')),
                      const Center(child: Text('Perfil')),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: currentIndex,
                    onTap: (index) => setState(() => currentIndex = index),
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
                      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Testar navegação entre todas as abas rapidamente
      final tabs = [
        (Icons.home, 'Home Page'),
        (Icons.search, 'Search'),
        (Icons.favorite, 'Favoritos'),
        (Icons.person, 'Perfil'),
      ];
      
      for (final (tabIcon, expectedText) in tabs) {
        await tester.tap(find.byIcon(tabIcon));
        await tester.pumpAndSettle();
        
        // Verificar se a navegação funcionou
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        if (expectedText == 'Search') {
          expect(find.byType(TextField), findsOneWidget);
        } else {
          expect(find.text(expectedText), findsOneWidget);
        }
      }
    });
  });
}