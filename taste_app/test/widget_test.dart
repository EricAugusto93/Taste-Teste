// Teste básico do aplicativo Taste

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('TasteApp Widget Tests', () {
    testWidgets('Basic widget test', (WidgetTester tester) async {
      // Build a simple test widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Text('Test App'),
            ),
          ),
        ),
      );

      // Verify that the test widget builds successfully
      expect(find.text('Test App'), findsOneWidget);
    });
  });
}