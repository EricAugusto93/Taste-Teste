import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../widgets/widgets.dart';
import '../../../data/services/onboarding_service.dart';

/// Página de onboarding idêntica à primeira imagem de referência
class OnboardingPage extends StatefulWidget {
  final VoidCallback? onCompleted;
  
  const OnboardingPage({
    super.key,
    this.onCompleted,
  });
  
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Router está garantidamente inicializado - removendo verificações desnecessárias
  
  @override
  void initState() {
    super.initState();
    // Router já foi inicializado no main.dart - não precisamos de delays
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2c3b83),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo da aplicação
                Container(
                  height: 80,
                  width: 200,
                  child: Image.asset(
                    'assets/images/logo_bege.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'taste',
                        style: TextStyle(
                          fontFamily: 'Dancing Script',
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: AppDimensions.paddingLarge),
                
                // Subtítulo principal
                Text(
                  'Sua curadoria de experiências.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Segunda linha do subtítulo em amarelo/dourado
                Text(
                  'Tudo em um só lugar',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 18,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppDimensions.paddingXLarge),
                
                // Imagem de comida centralizada
                Container(
                  height: 200,
                  width: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: AppDimensions.paddingXLarge),
                
                // Seção "Busca inteligente"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Busca inteligente',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      'Você diz o que quer. A gente entende.\nEx: "um jantar romântico no Morumbi" e pronto —\nsugestões com a sua cara.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 2),
                
                // Três pontos indicadores
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.paddingLarge),
                
                // Botões Login e Cadastro divididos verticalmente
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Login',
                        onPressed: () => _navigateToLogin(),
                      ),
                    ),
                    SizedBox(width: 1),
                    Expanded(
                      child: CustomButton(
                        text: 'Cadastro',
                        onPressed: () => _navigateToRegister(),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Navega para a página de login
  void _navigateToLogin() {
    _markOnboardingCompleted();
    context.go('/login');
  }
  
  /// Navega para a página de cadastro
  void _navigateToRegister() {
    _markOnboardingCompleted();
    context.go('/register');
  }
  
  void _markOnboardingCompleted() async {
    await OnboardingService.setOnboardingCompleted();
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    }
  }
}