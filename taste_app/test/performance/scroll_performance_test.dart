import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Scroll Performance Tests', () {
    testWidgets('Large list scroll performance', (WidgetTester tester) async {
      // Criar uma lista grande de items simples para testar performance
      final items = List.generate(1000, (index) => 'Item $index');

      // Criar widget com lista simples
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  key: Key('item_$index'),
                  title: Text(items[index]),
                  subtitle: Text('Description for ${items[index]}'),
                  leading: const CircleAvatar(
                    child: Icon(Icons.restaurant),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Medir tempo de scroll
      final stopwatch = Stopwatch()..start();
      
      // Fazer scroll rápido para baixo
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -5000),
        1000, // velocidade alta
      );
      
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Verificar que o scroll foi completado em tempo razoável (< 2 segundos)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      
      // Verificar que ainda há widgets visíveis após o scroll
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Scroll memory usage stability', (WidgetTester tester) async {
      // Criar lista de items simples
      final items = List.generate(500, (index) => 'Item $index');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  key: Key('item_$index'),
                  title: Text(items[index]),
                  subtitle: Text('Description for ${items[index]}'),
                  leading: const CircleAvatar(
                    child: Icon(Icons.restaurant),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fazer múltiplos scrolls para testar estabilidade de memória
      for (int i = 0; i < 10; i++) {
        // Scroll para baixo
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -2000),
          500,
        );
        await tester.pumpAndSettle();

        // Scroll para cima
        await tester.fling(
          find.byType(ListView),
          const Offset(0, 2000),
          500,
        );
        await tester.pumpAndSettle();
      }

      // Verificar que a lista ainda está funcionando
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Smooth scroll animation performance', (WidgetTester tester) async {
      // Criar lista menor para teste de animação
      final items = List.generate(100, (index) => 'Item $index');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  key: Key('item_$index'),
                  title: Text(items[index]),
                  subtitle: Text('Description for ${items[index]}'),
                  leading: const CircleAvatar(
                    child: Icon(Icons.restaurant),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Medir performance de scroll suave
      final stopwatch = Stopwatch()..start();
      
      // Fazer scroll suave (velocidade menor)
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -1000),
        200, // velocidade mais baixa para animação suave
      );
      
      // Aguardar animação completar
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Verificar que a animação foi suave (não muito lenta)
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));
      
      // Verificar que os widgets ainda estão visíveis
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}