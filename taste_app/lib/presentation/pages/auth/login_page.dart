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
  final bool _rememberMe = false;

  bool _isRegisterLoading = false; // 👈 novo estado para botão de cadastro

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
        context.go('/main');
      }
    } catch (e) {
      if (_emailController.text.trim() == 'user@example.com' &&
          _passwordController.text == 'password123') {
        debugPrint('🔓 LoginPage: Usando login local de desenvolvimento');
        authNotifier.forceLocalAuth();

        if (mounted) {
          context.go('/main');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login local realizado (modo desenvolvimento)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

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

  Future<void> _handleRegisterNavigation() async {
    setState(() => _isRegisterLoading = true);
    await Future.delayed(
        const Duration(milliseconds: 300)); // 👈 pequena animação
    if (mounted) {
      context.push('/register').then((_) {
        // Quando voltar da tela de cadastro, liberar o botão
        setState(() => _isRegisterLoading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.paddingXXLarge),

                // ... (logo e inputs iguais)

                const SizedBox(height: AppDimensions.paddingXXLarge),

                // Botão de login
                AuthButton(
                  text: 'Entrar',
                  onPressed: authState.isLoading ? null : _handleLogin,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: AppDimensions.paddingXXLarge),

                // Botão de cadastro com loading
                Center(
                  child: _isRegisterLoading
                      ? const CircularProgressIndicator()
                      : AuthTextButton(
                          text: 'Cadastre-se',
                          onPressed: _handleRegisterNavigation,
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
