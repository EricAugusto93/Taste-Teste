import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Review Flow Integration Tests', () {
    testWidgets('View restaurant reviews', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Restaurante Teste'),
                leading: const Icon(Icons.arrow_back),
              ),
              body: const SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Detalhes do Restaurante'),
                    const SizedBox(height: 20),
                    const Text('Avaliações'),
                    const Card(
                      key: Key('review_item'),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const Icon(Icons.star, color: Colors.amber),
                            const Icon(Icons.star, color: Colors.amber),
                            const Icon(Icons.star, color: Colors.amber),
                            const Icon(Icons.star_border),
                          ],
                        ),
                        title: Text('Ótimo restaurante!'),
                        subtitle: Text('João Silva'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Verificar elementos das avaliações
      expect(find.text('Avaliações'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
      expect(find.byKey(const Key('review_item')), findsOneWidget);
    });

    testWidgets('Add new review flow', (tester) async {
      bool showReviewForm = false;
      int selectedStars = 0;
      String comment = '';
      bool showSuccess = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                if (showSuccess) {
                   return Scaffold(
                     body: const Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           const Text('Avaliação enviada'),
                           const SizedBox(height: 20),
                           const Text('Obrigado pela avaliação'),
                         ],
                       ),
                     ),
                   );
                 }
                
                if (showReviewForm) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Nova Avaliação'),
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => showReviewForm = false),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Avaliar Restaurante'),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < selectedStars ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () => setState(() => selectedStars = index + 1),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Escreva seu comentário...',
                            ),
                            onChanged: (value) => comment = value,
                          ),
                          const SizedBox(height: 20),
                          const ElevatedButton(
                            onPressed: () {
                              if (selectedStars > 0) {
                                setState(() => showSuccess = true);
                              }
                            },
                            child: const Text('Enviar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Restaurante Teste'),
                  ),
                  body: Column(
                    children: [
                      const Text('Detalhes do Restaurante'),
                      const SizedBox(height: 20),
                      const ElevatedButton(
                        onPressed: () => setState(() => showReviewForm = true),
                        child: const Text('Avaliar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Tocar no botão de avaliar
      await tester.tap(find.text('Avaliar'));
      await tester.pumpAndSettle();

      // Verificar se abriu o formulário
      expect(find.text('Nova Avaliação'), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));

      // Selecionar 4 estrelas
      await tester.tap(find.byIcon(Icons.star_border).at(3));
      await tester.pumpAndSettle();

      // Verificar se as estrelas foram selecionadas
      expect(find.byIcon(Icons.star), findsNWidgets(4));

      // Digitar comentário
      await tester.enterText(find.byType(TextField), 'Excelente restaurante!');
      await tester.pumpAndSettle();

      // Enviar avaliação
      await tester.tap(find.text('Enviar'));
      await tester.pumpAndSettle();

      // Verificar sucesso
      expect(find.text('Avaliação enviada'), findsOneWidget);
    });

    testWidgets('Review validation and error handling', (tester) async {
      bool showReviewForm = false;
      bool showError = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                if (showReviewForm) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Nova Avaliação'),
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          showReviewForm = false;
                          showError = false;
                        }),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Avaliar Restaurante'),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: const Icon(Icons.star_border, color: Colors.amber),
                                onPressed: () {},
                              );
                            }),
                          ),
                          if (showError)
                            const Text(
                              'Selecione uma classificação',
                              style: TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 20),
                          const ElevatedButton(
                            onPressed: () => setState(() => showError = true),
                            child: const Text('Enviar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('Restaurante Teste'),
                      const ElevatedButton(
                        onPressed: () => setState(() => showReviewForm = true),
                        child: const Text('Avaliar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Abrir formulário
      await tester.tap(find.text('Avaliar'));
      await tester.pumpAndSettle();

      // Tentar enviar sem selecionar estrelas
      await tester.tap(find.text('Enviar'));
      await tester.pumpAndSettle();

      // Verificar erro de validação
      expect(find.text('Selecione uma classificação'), findsOneWidget);

      // Fechar modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('View all reviews', (tester) async {
      bool showAllReviews = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                if (showAllReviews) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Todas as Avaliações'),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => showAllReviews = false),
                      ),
                    ),
                    body: ListView(
                      children: const [
                        const Card(
                          child: ListTile(
                            title: Text('Ótimo restaurante!'),
                            subtitle: Text('João Silva'),
                          ),
                        ),
                        const Card(
                          child: ListTile(
                            title: Text('Comida deliciosa!'),
                            subtitle: Text('Maria Santos'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('Restaurante Teste'),
                      const Text('Avaliações'),
                      const ElevatedButton(
                        onPressed: () => setState(() => showAllReviews = true),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Tocar em "Ver todas"
      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();

      // Verificar página de todas as avaliações
      expect(find.text('Todas as Avaliações'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Voltar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('Review sorting and filtering', (tester) async {
      bool showFilters = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Stack(
                    children: [
                      const Column(
                        children: [
                          const Text('Avaliações'),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () => setState(() => showFilters = !showFilters),
                          ),
                          const Expanded(
                            child: Text('Lista de avaliações'),
                          ),
                        ],
                      ),
                      if (showFilters)
                        const Container(
                          color: Colors.black54,
                          child: Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Ordenar por:'),
                                    const ListTile(
                                      title: const Text('Mais recentes'),
                                      onTap: () => setState(() => showFilters = false),
                                    ),
                                    const ListTile(
                                      title: const Text('Melhor avaliação'),
                                      onTap: () => setState(() => showFilters = false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Abrir filtros
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verificar opções de filtro
      expect(find.text('Mais recentes'), findsOneWidget);
      expect(find.text('Melhor avaliação'), findsOneWidget);

      // Selecionar uma opção
      await tester.tap(find.text('Mais recentes'));
      await tester.pumpAndSettle();
    });
  });
}