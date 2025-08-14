import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/loading_widget.dart';
import '../../../core/utils/auth_validators.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      await authNotifier.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        // Navegar para a página principal após login bem-sucedido
        context.go('/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: authState.isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.paddingXXLarge),
                      
                      // Logo e título
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/images/logo_bege.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.restaurant,
                                      size: 40,
                                      color: AppColors.primary,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingLarge),
                            Text(
                              'Bem-vindo de volta!',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Text(
                              'Entre na sua conta para continuar',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingXXLarge),
                      
                      // Formulário de login
                      AuthTextField(
                        label: 'E-mail',
                        hint: 'Digite seu e-mail',
                        controller: _emailController,
                        isEmail: true,
                        validator: AuthValidators.email,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                        autofocus: true,
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      AuthTextField(
                        label: 'Senha',
                        hint: 'Digite sua senha',
                        controller: _passwordController,
                        isPassword: true,
                        validator: AuthValidators.password,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Lembrar-me e esqueceu senha
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              Text(
                                'Lembrar-me',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          AuthTextButton(
                            text: 'Esqueceu a senha?',
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingXXLarge),
                      
                      // Botão de login
                      AuthButton(
                        text: 'Entrar',
                        onPressed: _handleLogin,
                        isLoading: authState.isLoading,
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Login social (Google)
                      SocialAuthButton(
                        text: 'Continuar com Google',
                        icon: Icon(
                          Icons.g_mobiledata,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        onPressed: () {
                          // TODO: Implementar login com Google
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login com Google em desenvolvimento'),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingXXLarge),
                      
                      // Link para registro
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem uma conta? ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            AuthTextButton(
                              text: 'Cadastre-se',
                              onPressed: () {
                                context.push('/register');
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}