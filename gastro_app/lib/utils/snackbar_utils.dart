import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum SnackBarType { success, error, info, warning }

class SnackBarUtils {
  static void showThemedSnackBar(
    BuildContext context,
    String message,
    SnackBarType type, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final (color, icon) = _getThemeData(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        elevation: 8,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                onPressed: onActionPressed ?? () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }

  static (Color, String) _getThemeData(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return (AppColors.azulProfundo, '✅');
      case SnackBarType.error:
        return (AppColors.vermelhoTelha, '❌');
      case SnackBarType.info:
        return (AppColors.amareloMostarda, 'ℹ️');
      case SnackBarType.warning:
        return (AppColors.mostardaEscura, '⚠️');
    }
  }

  // Métodos de conveniência
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    showThemedSnackBar(context, message, SnackBarType.success, duration: duration ?? const Duration(seconds: 3));
  }

  static void showError(BuildContext context, String message, {Duration? duration}) {
    showThemedSnackBar(context, message, SnackBarType.error, duration: duration ?? const Duration(seconds: 4));
  }

  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    showThemedSnackBar(context, message, SnackBarType.info, duration: duration ?? const Duration(seconds: 3));
  }

  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    showThemedSnackBar(context, message, SnackBarType.warning, duration: duration ?? const Duration(seconds: 3));
  }

  // SnackBars específicos para contextos comuns
  static void showFavoriteAdded(BuildContext context, String restauranteName) {
    showSuccess(context, '$restauranteName adicionado aos favoritos!');
  }

  static void showFavoriteRemoved(BuildContext context, String restauranteName) {
    showInfo(context, '$restauranteName removido dos favoritos');
  }

  static void showLocationError(BuildContext context) {
    showError(
      context,
      'Não foi possível obter sua localização. Usando localização padrão.',
      duration: const Duration(seconds: 4),
    );
  }

  static void showLocationUpdated(BuildContext context) {
    showSuccess(context, 'Localização atualizada com sucesso!');
  }

  static void showSearchEmpty(BuildContext context) {
    showWarning(context, 'Nenhum restaurante encontrado para sua busca');
  }

  static void showNetworkError(BuildContext context) {
    showError(
      context,
      'Erro de conexão. Verifique sua internet e tente novamente.',
      duration: const Duration(seconds: 4),
    );
  }
} 