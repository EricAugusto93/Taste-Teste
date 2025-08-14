import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    
    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      if (isSecondary) {
        return isEnabled ? AppColors.surface : AppColors.surface.withOpacity(0.5);
      }
      return isEnabled ? AppColors.primary : AppColors.primary.withOpacity(0.5);
    }

    Color getTextColor() {
      if (textColor != null) return textColor!;
      if (isSecondary) {
        return isEnabled ? AppColors.primary : AppColors.textSecondary;
      }
      return isEnabled ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.7);
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          elevation: isSecondary ? 0 : (isEnabled ? 2 : 0),
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusMedium),
            side: isSecondary
                ? BorderSide(
                    color: isEnabled ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppDimensions.paddingSmall),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonText.copyWith(
                      color: getTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Botão específico para login social (Google, Apple, etc.)
class SocialAuthButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.surface,
          foregroundColor: textColor ?? AppColors.textPrimary,
          side: BorderSide(
            color: borderColor ?? AppColors.border,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Text(
                    text,
                    style: AppTextStyles.buttonText.copyWith(
                      color: textColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Botão de texto para ações secundárias
class AuthTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final TextStyle? textStyle;
  final bool underline;

  const AuthTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.textStyle,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingXSmall,
        ),
      ),
      child: Text(
        text,
        style: textStyle ??
            AppTextStyles.bodyMedium.copyWith(
              color: textColor ?? AppColors.primary,
              fontWeight: FontWeight.w500,
              decoration: underline ? TextDecoration.underline : null,
            ),
      ),
    );
  }
}