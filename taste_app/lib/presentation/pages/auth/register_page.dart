import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../../core/utils/auth_validators.dart';
import '../../widgets/auth_button.dart';

import '../../widgets/loading_widget.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _acceptTerms = false;
  bool _acceptMarketing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você deve aceitar os termos de uso'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);

    try {
      await authNotifier.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Mostrar mensagem de sucesso e navegar para verificação
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada! Verifique seu e-mail para ativar.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar conta: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    return AuthValidators.confirmPassword(value, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => NavigationHelper.safeGoBack(context),
        ),
      ),
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
                      // Título
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Criar Conta',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Text(
                              'Preencha os dados para criar sua conta',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Formulário de registro
                      AuthTextField(
                        label: 'Nome completo',
                        hint: 'Digite seu nome completo',
                        controller: _nameController,
                        validator: AuthValidators.name,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.textSecondary,
                        ),
                        autofocus: true,
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      AuthTextField(
                        label: 'E-mail',
                        hint: 'Digite seu e-mail',
                        controller: _emailController,
                        isEmail: true,
                        validator: AuthValidators.email,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      AuthTextField(
                        label: 'Telefone (opcional)',
                        hint: '(11) 99999-9999',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: AuthValidators.phoneOptional,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      AuthTextField(
                        label: 'Senha',
                        hint: 'Digite uma senha forte',
                        controller: _passwordController,
                        isPassword: true,
                        validator: AuthValidators.strongPassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Indicadores de força da senha
                      _buildPasswordStrengthIndicator(),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      AuthTextField(
                        label: 'Confirmar senha',
                        hint: 'Digite a senha novamente',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: _validateConfirmPassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Termos e condições
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptTerms = !_acceptTerms;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Eu aceito os '),
                                      TextSpan(
                                        text: 'Termos de Uso',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' e a '),
                                      TextSpan(
                                        text: 'Política de Privacidade',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Marketing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptMarketing,
                            onChanged: (value) {
                              setState(() {
                                _acceptMarketing = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptMarketing = !_acceptMarketing;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'Quero receber ofertas e novidades por e-mail',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Botão de registro
                      AuthButton(
                        text: 'Criar Conta',
                        onPressed: _handleRegister,
                        isLoading: authState.isLoading,
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Link para login
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem uma conta? ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            AuthTextButton(
                              text: 'Entrar',
                              onPressed: () {
                                NavigationHelper.safeGoBack(context);
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

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            Text(
              'Força da senha: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _getStrengthText(strength),
              style: AppTextStyles.bodySmall.copyWith(
                color: _getStrengthColor(strength),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXSmall),
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStrengthColor(strength),
          ),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'(?=.*[a-z])').hasMatch(password)) strength++;
    if (RegExp(r'(?=.*[A-Z])').hasMatch(password)) strength++;
    if (RegExp(r'(?=.*\d)').hasMatch(password)) strength++;
    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Fraca';
      case 2:
        return 'Média';
      case 3:
        return 'Boa';
      case 4:
        return 'Forte';
      default:
        return 'Fraca';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.white;
      case 4:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }
}
