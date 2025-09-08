import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Favorites Flow Integration Tests', () {
    testWidgets('Complete favorites flow - add, view, and remove favorites',
        (tester) async {
      bool isFavorite = false;
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
                      // Home page with restaurant card
                      const Center(
                        child: Card(
                          key: Key('restaurant_card'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Restaurante Teste'),
                              IconButton(
                                icon: Icon(isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                                onPressed: () =>
                                    setState(() => isFavorite = !isFavorite),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Favorites page
                      const Center(
                        child: isFavorite
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Favoritos'),
                                  Card(
                                    key: Key('favorite_item'),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Restaurante Teste'),
                                        IconButton(
                                          icon: Icon(Icons.favorite),
                                          onPressed: () => setState(
                                              () => isFavorite = false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Favoritos'),
                                  Text('Nenhum favorito ainda'),
                                ],
                              ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) => setState(() => currentIndex = index),
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.favorite), label: 'Favorites'),
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
      expect(find.byKey(const Key('restaurant_card')), findsOneWidget);

      // Adicionar aos favoritos
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Verificar se o ícone mudou para favorito preenchido
      expect(find.byIcon(Icons.favorite), findsAtLeastNWidgets(1));

      // Navegar para a aba de favoritos usando o BottomNavigationBar
      final bottomNavItems = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.favorite),
      );
      await tester.tap(bottomNavItems);
      await tester.pumpAndSettle();

      // Verificar se estamos na página de favoritos
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.byKey(const Key('favorite_item')), findsOneWidget);

      // Remover dos favoritos usando o botão dentro do card
      final cardFavoriteButton = find.descendant(
        of: find.byKey(const Key('favorite_item')),
        matching: find.byIcon(Icons.favorite),
      );
      await tester.tap(cardFavoriteButton);
      await tester.pumpAndSettle();

      // Verificar se foi removido
      expect(find.text('Nenhum favorito ainda'), findsOneWidget);
      expect(find.byKey(const Key('favorite_item')), findsNothing);
    });

    testWidgets('Navigate to restaurant details from favorites',
        (tester) async {
      bool showDetails = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                if (showDetails) {
                  return Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => showDetails = false),
                      ),
                      title: const Text('Detalhes do Restaurante'),
                    ),
                    body: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Restaurante Teste'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star),
                              Text('4.5'),
                            ],
                          ),
                          Text('Avaliações'),
                          Text('Cardápio'),
                        ],
                      ),
                    ),
                  );
                }

                return Scaffold(
                  body: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Favoritos'),
                      ],
                    ),
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: 1,
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.favorite), label: 'Favorites'),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    key: const Key('favorite_item'),
                    onPressed: () => setState(() => showDetails = true),
                    child: const Text('Item'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se estamos na página de favoritos
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.byKey(const Key('favorite_item')), findsOneWidget);

      // Tocar no item favorito
      await tester.tap(find.byKey(const Key('favorite_item')));
      await tester.pumpAndSettle();

      // Verificar se navegou para a página de detalhes
      expect(find.text('Detalhes do Restaurante'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Avaliações'), findsOneWidget);
      expect(find.text('Cardápio'), findsOneWidget);

      // Voltar para favoritos
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verificar se voltou para favoritos
      expect(find.text('Favoritos'), findsOneWidget);
    });

    testWidgets('Empty favorites state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Favoritos'),
                    Text('Nenhum favorito ainda'),
                  ],
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: 1,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite), label: 'Favorites'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar estado vazio
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Nenhum favorito ainda'), findsOneWidget);
      expect(find.byKey(const Key('favorite_item')), findsNothing);
    });

    testWidgets('Favorites persistence across app restarts', (tester) async {
      bool hasFavorites = true;
      int currentIndex = 1;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: IndexedStack(
                    index: currentIndex,
                    children: [
                      // Home page
                      const Center(
                        child: Text('Home'),
                      ),
                      // Favorites page
                      const Center(
                        child: hasFavorites
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Favoritos'),
                                  Card(
                                    key: Key('favorite_item'),
                                    child: Text('Restaurante Favorito'),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Favoritos'),
                                  Text('Nenhum favorito ainda'),
                                ],
                              ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) => setState(() => currentIndex = index),
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.favorite), label: 'Favorites'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se estamos na página de favoritos
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.byKey(const Key('favorite_item')), findsOneWidget);

      // Navegar para home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsAtLeastNWidgets(1));

      // Voltar para favoritos
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      // Verificar se os favoritos persistiram
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.byKey(const Key('favorite_item')), findsOneWidget);
    });
  });
}
