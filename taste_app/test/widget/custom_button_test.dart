import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/presentation/widgets/custom_button.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_dimensions.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('should render basic elevated button correctly', (tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );
      
      // Verifica se o botão é renderizado
      expect(find.byType(CustomButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Testa o callback onPressed
      await tester.tap(find.byType(ElevatedButton));
      expect(wasPressed, isTrue);
    });
    
    testWidgets('should render outlined button when isOutlined is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Outlined Button',
              isOutlined: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Outlined Button'), findsOneWidget);
    });
    
    testWidgets('should render text button when isSecondary is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Secondary Button',
              isSecondary: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Secondary Button'), findsOneWidget);
    });
    
    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });
    
    testWidgets('should disable button when isLoading is true', (tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );
      
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(elevatedButton.onPressed, isNull);
      
      await tester.tap(find.byType(ElevatedButton));
      expect(wasPressed, isFalse);
    });
    
    testWidgets('should disable button when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );
      
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(elevatedButton.onPressed, isNull);
    });
    
    testWidgets('should render button with icon when icon is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Icon Button',
              icon: Icons.star,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Icon Button'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });
    
    testWidgets('should apply custom width and height', (tester) async {
      const customWidth = 200.0;
      const customHeight = 60.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Size',
              width: customWidth,
              height: customHeight,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, customWidth);
      expect(container.constraints?.maxHeight, customHeight);
    });
    
    testWidgets('should apply custom padding', (tester) async {
      const customPadding = EdgeInsets.all(20.0);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Padding',
              padding: customPadding,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, customPadding);
    });
    
    testWidgets('should use default height when not specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Default Height',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, AppDimensions.buttonHeight);
    });
    
    testWidgets('should handle outlined button with loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Outlined Loading',
              isOutlined: true,
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final outlinedButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(outlinedButton.onPressed, isNull);
    });
    
    testWidgets('should handle secondary button with loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Secondary Loading',
              isSecondary: true,
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final textButton = tester.widget<TextButton>(find.byType(TextButton));
      expect(textButton.onPressed, isNull);
    });
    
    testWidgets('should handle icon with outlined button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Outlined Icon',
              icon: Icons.favorite,
              isOutlined: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Outlined Icon'), findsOneWidget);
    });
    
    testWidgets('should handle icon with secondary button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Secondary Icon',
              icon: Icons.share,
              isSecondary: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.text('Secondary Icon'), findsOneWidget);
    });
    
    testWidgets('should prioritize outlined over secondary when both are true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Both Flags',
              isOutlined: true,
              isSecondary: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Deve renderizar OutlinedButton, não TextButton
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });
    
    testWidgets('should show loading indicator with correct properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Test',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      expect(progressIndicator.strokeWidth, 2);
      expect(progressIndicator.valueColor?.value, AppColors.textPrimary);
      
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );
      
      expect(sizedBox.width, AppDimensions.iconMedium);
      expect(sizedBox.height, AppDimensions.iconMedium);
    });
  });
}