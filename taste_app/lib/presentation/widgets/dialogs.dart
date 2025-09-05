import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/utils/navigation_helper.dart';
import 'package:taste_app/presentation/widgets/custom_button.dart';

// Dialog de confirmação genérico
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
  });

  // Factory para confirmação de exclusão
  factory ConfirmationDialog.delete({
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog(
      title: title,
      message: message,
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmColor: Colors.red,
      icon: Icons.delete_outline,
    );
  }

  // Factory para sair do app
  factory ConfirmationDialog.exit({
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog(
      title: 'Sair do aplicativo',
      message: 'Tem certeza que deseja sair?',
      confirmText: 'Sair',
      cancelText: 'Cancelar',
      onConfirm: onConfirm,
      onCancel: onCancel,
      icon: Icons.exit_to_app,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone (se fornecido)
            if (icon != null) ...{
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (confirmColor ?? AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: confirmColor ?? AppColors.primary,
                ),
              ),
              SizedBox(height: 16),
            },
            
            // Título
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            
            // Mensagem
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: cancelText,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop(false);
                      }
                      onCancel?.call();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    onPressed: () {
                      NavigationHelper.safeGoBack(context);
                      onConfirm?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método estático para mostrar o dialog
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }
}

// Dialog de avaliação
class RatingDialog extends StatefulWidget {
  final String restaurantName;
  final Function(int rating, String comment)? onSubmit;

  const RatingDialog({
    super.key,
    required this.restaurantName,
    this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  DateTime? _lastSubmitAttempt;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'Avaliar ${widget.restaurantName}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            
            // Estrelas de avaliação
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            
            // Texto da avaliação
            if (_rating > 0) ...{
              Text(
                _getRatingText(_rating),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
            },
            
            // Campo de comentário
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deixe um comentário (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    onPressed: () {
                      NavigationHelper.safeGoBack(context);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _isSubmitting ? 'Enviando...' : 'Enviar',
                    onPressed: _rating > 0 && !_isSubmitting
                        ? () async {
                            await _handleSubmit();
                          }
                        : null,
                    isLoading: _isSubmitting,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Debounce: prevenir múltiplos cliques em menos de 2 segundos
    final now = DateTime.now();
    if (_lastSubmitAttempt != null && 
        now.difference(_lastSubmitAttempt!).inSeconds < 2) {
      return;
    }

    if (_isSubmitting) return; // Dupla verificação

    setState(() {
      _isSubmitting = true;
      _lastSubmitAttempt = now;
    });

    try {
      // Aguardar um pouco para dar feedback visual
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Chamar callback se fornecido
      if (widget.onSubmit != null) {
        await widget.onSubmit!(_rating, _commentController.text);
      }
      
      // Fechar dialog somente após sucesso
      if (mounted) {
        NavigationHelper.safeGoBack(context);
      }
    } catch (e) {
      // Em caso de erro, resetar estado e manter dialog aberto
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        // Mostrar erro via SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar avaliação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  // Método estático para mostrar o dialog
  static Future<void> show(
    BuildContext context, {
    required String restaurantName,
    Function(int rating, String comment)? onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RatingDialog(
        restaurantName: restaurantName,
        onSubmit: onSubmit,
      ),
    );
  }
}

// Dialog de permissão de localização
class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback? onOpenSettings;
  final VoidCallback? onCancel;

  const LocationPermissionDialog({
    super.key,
    this.onOpenSettings,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16),
            
            // Título
            Text(
              'Permissão de Localização',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            
            // Mensagem
            Text(
              'Para encontrar os melhores restaurantes próximos a você, precisamos acessar sua localização.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Agora não',
                    onPressed: () {
                      NavigationHelper.safeGoBack(context);
                      onCancel?.call();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Configurar',
                    onPressed: () {
                      NavigationHelper.safeGoBack(context);
                      onOpenSettings?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método estático para mostrar o dialog
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onOpenSettings,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => LocationPermissionDialog(
        onOpenSettings: onOpenSettings,
        onCancel: onCancel,
      ),
    );
  }
}