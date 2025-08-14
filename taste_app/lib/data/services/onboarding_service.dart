import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _firstLaunchKey = 'first_launch';

  // Verificar se o onboarding foi concluído
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Marcar onboarding como concluído
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  // Verificar se é o primeiro lançamento do app
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(_firstLaunchKey) ?? true;
    
    if (isFirst) {
      await prefs.setBool(_firstLaunchKey, false);
    }
    
    return isFirst;
  }

  // Resetar onboarding (para testes)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_firstLaunchKey);
  }

  // Verificar se deve mostrar o onboarding
  static Future<bool> shouldShowOnboarding() async {
    final isCompleted = await isOnboardingCompleted();
    return !isCompleted;
  }
}