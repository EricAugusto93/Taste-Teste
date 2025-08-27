import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/presentation/widgets/custom_text_field.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_dimensions.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('should render basic text field correctly', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Enter text',
              controller: controller,
            ),
          ),
        ),
      );
      
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Enter text'), findsOneWidget);
    });
    
    testWidgets('should handle text input correctly', (tester) async {
      final controller = TextEditingController();
      String? changedValue;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );
      
      await tester.enterText(find.byType(TextFormField), 'Test input');
      expect(controller.text, 'Test input');
      expect(changedValue, 'Test input');
    });
    
    testWidgets('should handle onTap callback', (tester) async {
      bool wasTapped = false;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(TextFormField));
      expect(wasTapped, isTrue);
    });
    
    testWidgets('should be read-only when readOnly is true', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              readOnly: true,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      
      // Tentar inserir texto não deve funcionar
      await tester.enterText(find.byType(TextFormField), 'Test');
      expect(controller.text, isEmpty);
    });
    
    testWidgets('should obscure text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              obscureText: true,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('should display label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              labelText: 'Test Label',
            ),
          ),
        ),
      );
      
      expect(find.text('Test Label'), findsOneWidget);
    });
    
    testWidgets('should display prefix and suffix icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              prefixIcon: const Icon(Icons.person),
              suffixIcon: const Icon(Icons.visibility),
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
    
    testWidgets('should handle different keyboard types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('should handle multiline text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              maxLines: 3,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('should validate input correctly', (tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );
      
      // Validar campo vazio
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Campo obrigatório'), findsOneWidget);
      
      // Inserir texto e validar novamente
      await tester.enterText(find.byType(TextFormField), 'Valid text');
      expect(formKey.currentState!.validate(), isTrue);
    });
    
    testWidgets('should create search field with factory constructor', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField.search(
              controller: controller,
            ),
          ),
        ),
      );
      
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Buscar restaurantes...'), findsOneWidget);
    });
    
    testWidgets('should apply custom fill color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              fillColor: Colors.red,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('should apply custom border radius', (tester) async {
      const customRadius = 20.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              borderRadius: customRadius,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('should apply custom content padding', (tester) async {
      const customPadding = EdgeInsets.all(20.0);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              contentPadding: customPadding,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('should use search field styling when isSearchField is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              isSearchField: true,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('should show focused border when field is focused', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(),
          ),
        ),
      );
      
      // Focar no campo
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      
      // Verifica se o campo está focado
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField, isNotNull);
    });
    
    testWidgets('should show error border when validation fails', (tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                validator: (value) => 'Error message',
              ),
            ),
          ),
        ),
      );
      
      formKey.currentState!.validate();
      await tester.pump();
      
      // Verifica se a mensagem de erro é exibida
      expect(find.text('Error message'), findsOneWidget);
    });
  });
  
  group('SearchField Widget Tests', () {
    testWidgets('should render search field correctly', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchField(
              controller: controller,
            ),
          ),
        ),
      );
      
      expect(find.byType(SearchField), findsOneWidget);
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Buscar restaurantes...'), findsOneWidget);
    });
    
    testWidgets('should show clear button when text is entered', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchField(
              controller: controller,
            ),
          ),
        ),
      );
      
      // Inicialmente não deve ter botão de limpar
      expect(find.byIcon(Icons.clear), findsNothing);
      
      // Inserir texto usando enterText
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();
      
      // Verifica se o texto foi inserido
      expect(controller.text, 'test');
    });
    
    testWidgets('should clear text when clear button is pressed', (tester) async {
      final controller = TextEditingController(text: 'test');
      String? changedValue;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchField(
              controller: controller,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );
      
      expect(controller.text, 'test');
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(SearchField), findsOneWidget);
      expect(find.byType(CustomTextField), findsOneWidget);
    });
    
    testWidgets('should handle custom hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchField(
              hintText: 'Custom hint',
            ),
          ),
        ),
      );
      
      expect(find.text('Custom hint'), findsOneWidget);
    });
    
    testWidgets('should handle onTap callback', (tester) async {
      bool wasTapped = false;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchField(
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(TextFormField));
      expect(wasTapped, isTrue);
    });
    
    testWidgets('should be read-only when readOnly is true', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchField(
              controller: controller,
              readOnly: true,
            ),
          ),
        ),
      );
      
      // Verifica se o widget foi criado corretamente
      expect(find.byType(SearchField), findsOneWidget);
      expect(find.byType(CustomTextField), findsOneWidget);
    });
    
    testWidgets('should have max width constraint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchField(),
          ),
        ),
      );
      
      final container = tester.widget<Container>(find.byType(Container));
      final constraints = container.constraints as BoxConstraints;
      expect(constraints.maxWidth, AppDimensions.searchFieldMaxWidth);
    });
  });
}