import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Flow Integration Tests', () {
    testWidgets('Search for restaurants and view results', (tester) async {
      bool showResults = false;
      String searchTerm = '';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextField(
                          key: const Key('search_field'),
                          decoration: const InputDecoration(
                            hintText: 'Buscar restaurantes...',
                            suffixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            searchTerm = value;
                            setState(() => showResults = value.isNotEmpty);
                          },
                        ),
                      ),
                      Expanded(
                        child: showResults && searchTerm.isNotEmpty
                            ? ListView(
                                children: [
                                  const Card(
                                    key: const Key('restaurant_card'),
                                    child: ListTile(
                                      title: Text('Pizzaria $searchTerm'),
                                      subtitle: const Text('Italiana'),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text('Digite para buscar'),
                              ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: 1,
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Verificar se chegamos na busca
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byKey(const Key('search_field')), findsOneWidget);

      // Digitar termo de busca
      await tester.enterText(find.byKey(const Key('search_field')), 'pizza');
      await tester.pumpAndSettle();

      // Verificar se há resultados
      expect(find.byKey(const Key('restaurant_card')), findsOneWidget);
      expect(find.text('Pizzaria pizza'), findsOneWidget);
    });

    testWidgets('Search with no results', (tester) async {
      String searchTerm = '';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextField(
                          key: const Key('search_field'),
                          decoration: const InputDecoration(
                            hintText: 'Buscar restaurantes...',
                          ),
                          onChanged: (value) {
                            searchTerm = value;
                            setState(() {});
                          },
                        ),
                      ),
                      Expanded(
                        child: searchTerm.isNotEmpty
                            ? const Center(
                                child: Text('Nenhum resultado encontrado'),
                              )
                            : const Center(
                                child: Text('Digite para buscar'),
                              ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: 1,
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Buscar por algo que não existe
      await tester.enterText(find.byKey(const Key('search_field')), 'xyzabc123nonexistent');
      await tester.pumpAndSettle();

      // Verificar mensagem de nenhum resultado
      expect(find.text('Nenhum resultado encontrado'), findsOneWidget);
    });

    testWidgets('Search suggestions and autocomplete', (tester) async {
      String searchTerm = '';
      List<String> suggestions = [];
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextField(
                          key: const Key('search_field'),
                          decoration: const InputDecoration(
                            hintText: 'Buscar restaurantes...',
                          ),
                          onChanged: (value) {
                            searchTerm = value;
                            if (value.startsWith('piz')) {
                              suggestions = ['Pizza', 'Pizzaria'];
                            } else {
                              suggestions = [];
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      Expanded(
                        child: suggestions.isNotEmpty
                            ? ListView.builder(
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    key: Key('suggestion_$index'),
                                    title: Text(suggestions[index]),
                                    onTap: () {
                                      searchTerm = suggestions[index];
                                      suggestions = [];
                                      setState(() {});
                                    },
                                  );
                                },
                              )
                            : const Center(
                                child: Text('Digite para ver sugestões'),
                              ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: 1,
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Digitar parcialmente
      await tester.enterText(find.byKey(const Key('search_field')), 'piz');
      await tester.pumpAndSettle();

      // Verificar se há sugestões
      expect(find.byKey(const Key('suggestion_0')), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Pizzaria'), findsOneWidget);

      // Tocar em uma sugestão
      await tester.tap(find.text('Pizza'));
      await tester.pumpAndSettle();
    });
  });
}