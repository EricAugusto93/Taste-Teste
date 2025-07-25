import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';

class EmailConfirmationDialog extends StatefulWidget {
  final String email;

  const EmailConfirmationDialog({
    super.key,
    required this.email,
  });

  @override
  State<EmailConfirmationDialog> createState() => _EmailConfirmationDialogState();
}

class _EmailConfirmationDialogState extends State<EmailConfirmationDialog> {
  bool _isResending = false;
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.email_outlined,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Confirme seu Email',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enviamos um link de confirmação para:',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.cinzaMedio,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
              ),
            ),
            child: Text(
              widget.email,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Clique no link do email para ativar sua conta e fazer login.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.cinzaMedio,
              height: 1.4,
            ),
          ),
          if (_emailSent) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Email reenviado com sucesso!',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Entendi',
            style: TextStyle(
              color: AppTheme.cinzaMedio,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isResending ? null : _resendConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isResending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Reenviar Email',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Future<void> _resendConfirmation() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _emailSent = false;
    });

    try {
      final success = await AuthService.resendConfirmation(widget.email);
      
      if (mounted) {
        setState(() {
          _isResending = false;
          _emailSent = success;
        });

        if (success) {
          // Ocultar mensagem de sucesso após 3 segundos
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _emailSent = false;
              });
            }
          });
        } else {
          _showErrorSnackBar('Erro ao reenviar email. Tente novamente.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _showErrorSnackBar('Erro inesperado. Tente novamente.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 