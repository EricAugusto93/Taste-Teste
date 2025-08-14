import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/services/onboarding_service.dart';

void main() {
  group('OnboardingService Tests', () {
    group('Service Class', () {
      test('should have OnboardingService class available', () {
        // Verificar que a classe existe através do import
        expect(OnboardingService, isNotNull);
      });

      test('should have static methods available', () {
        // Verificar que os métodos estáticos existem
        expect(OnboardingService.isOnboardingCompleted, isA<Function>());
        expect(OnboardingService.setOnboardingCompleted, isA<Function>());
        expect(OnboardingService.isFirstLaunch, isA<Function>());
        expect(OnboardingService.resetOnboarding, isA<Function>());
        expect(OnboardingService.shouldShowOnboarding, isA<Function>());
      });
    });
  });
}