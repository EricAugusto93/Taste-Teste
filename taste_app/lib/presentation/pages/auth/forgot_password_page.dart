import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/auth_validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../../core/utils/auth_validators.dart';
import '../../widgets/auth_button.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(_emailController.text.trim());

      setState(() {
        _emailSent = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail de recuperação enviado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar e-mail: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.paddingXLarge),

                // Ícone e título
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusLarge),
                        ),
                        child: Icon(
                          _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      Text(
                        _emailSent ? 'E-mail Enviado!' : 'Esqueceu a Senha?',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        _emailSent
                            ? 'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.'
                            : 'Digite seu e-mail e enviaremos um link para redefinir sua senha.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXXLarge),

                if (!_emailSent) ...[
                  // Campo de e-mail
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
                    autofocus: true,
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // Botão de enviar
                  AuthButton(
                    text: 'Enviar Link de Recuperação',
                    onPressed: _handleResetPassword,
                    isLoading: _isLoading,
                  ),
                ] else ...[
                  // Instruções pós-envio
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            Text(
                              'Próximos passos:',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          '1. Verifique sua caixa de entrada\n2. Clique no link recebido\n3. Defina uma nova senha\n4. Faça login com a nova senha',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // Botão para reenviar
                  AuthButton(
                    text: 'Reenviar E-mail',
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    isSecondary: true,
                  ),
                ],

                const SizedBox(height: AppDimensions.paddingXLarge),

                // Botões de navegação
                Row(
                  children: [
                    Expanded(
                      child: AuthButton(
                        text: 'Voltar ao Login',
                        onPressed: () {
                          context.go('/login');
                        },
                        isSecondary: true,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      child: AuthButton(
                        text: 'Criar Conta',
                        onPressed: () {
                          context.push('/register');
                        },
                        isSecondary: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingXLarge),

                // Informações de suporte
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        'Precisa de ajuda?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXSmall),
                      Text(
                        'Entre em contato conosco se não receber o e-mail em alguns minutos.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      AuthTextButton(
                        text: 'Falar com Suporte',
                        onPressed: () {
                          // TODO: Implementar contato com suporte
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Suporte em desenvolvimento'),
                            ),
                          );
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
