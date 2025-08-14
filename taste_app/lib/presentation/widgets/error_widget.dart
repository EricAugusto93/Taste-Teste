import 'package:flutter/material.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/presentation/widgets/custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String emoji;
  final String? buttonText;
  final VoidCallback? onRetry;
  final Color? backgroundColor;

  const CustomErrorWidget({
    super.key,
    required this.title,
    required this.message,
    required this.emoji,
    this.buttonText,
    this.onRetry,
    this.backgroundColor,
  });

  // Factory para erro de conexão
  factory CustomErrorWidget.network({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Sem conexão',
      message: 'Verifique sua conexão com a internet e tente novamente.',
      emoji: '📡',
      buttonText: 'Tentar novamente',
      onRetry: onRetry,
    );
  }

  // Factory para erro geral
  factory CustomErrorWidget.general({
    String? message,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Ops! Algo deu errado',
      message: message ?? 'Ocorreu um erro inesperado. Tente novamente.',
      emoji: '😵',
      buttonText: 'Tentar novamente',
      onRetry: onRetry,
    );
  }

  // Factory para erro de localização
  factory CustomErrorWidget.location({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Localização indisponível',
      message: 'Não foi possível acessar sua localização. Verifique as permissões.',
      emoji: '📍',
      buttonText: 'Configurar',
      onRetry: onRetry,
    );
  }

  // Factory para erro de servidor
  factory CustomErrorWidget.server({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Servidor indisponível',
      message: 'Nossos servidores estão temporariamente indisponíveis.',
      emoji: '🔧',
      buttonText: 'Tentar novamente',
      onRetry: onRetry,
    );
  }

  // Factory para timeout
  factory CustomErrorWidget.timeout({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Tempo esgotado',
      message: 'A operação demorou mais que o esperado.',
      emoji: '⏰',
      buttonText: 'Tentar novamente',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          
          // Título
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Mensagem
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Botão (se fornecido)
          if (buttonText != null && onRetry != null) ...{
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: buttonText!,
                onPressed: onRetry!,
              ),
            ),
          },
        ],
      ),
    );
  }
}

// Widget para exibir erro em tela cheia
class FullScreenErrorWidget extends StatelessWidget {
  final CustomErrorWidget errorWidget;
  final bool showAppBar;
  final String? appBarTitle;

  const FullScreenErrorWidget({
    super.key,
    required this.errorWidget,
    this.showAppBar = true,
    this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: Text(appBarTitle ?? 'Erro'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: errorWidget,
        ),
      ),
    );
  }
}

// Widget para exibir erro inline (dentro de listas, etc.)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final double? height;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 120,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...{
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Tentar novamente',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}