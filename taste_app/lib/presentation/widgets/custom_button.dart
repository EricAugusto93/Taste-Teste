import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Botão customizado do aplicativo Taste
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return _buildOutlinedButton();
    }
    
    if (isSecondary) {
      return _buildTextButton();
    }
    
    return _buildElevatedButton();
  }
  
  Widget _buildElevatedButton() {
    final bool isEnabled = !isLoading && onPressed != null;
    
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width,
        height: height ?? AppDimensions.buttonHeight,
        padding: padding,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            elevation: isEnabled ? AppDimensions.elevationMedium : 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.buttonRadius)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
          ),
          child: _buildButtonContent(),
        ),
      ),
    );
  }
  
  Widget _buildTextButton() {
    final bool isEnabled = !isLoading && onPressed != null;
    
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width,
        height: height ?? AppDimensions.buttonHeight,
        padding: padding,
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.buttonRadius)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
          ),
          child: _buildButtonContent(),
        ),
      ),
    );
  }
  
  Widget _buildOutlinedButton() {
    final bool isEnabled = !isLoading && onPressed != null;
    
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width,
        height: height ?? AppDimensions.buttonHeight,
        padding: padding,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: isEnabled ? AppColors.primary : AppColors.primary.withOpacity(0.6), 
              width: 2
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.buttonRadius)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
          ),
          child: _buildButtonContent(),
        ),
      ),
    );
  }
  
  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: AppDimensions.iconMedium,
        height: AppDimensions.iconMedium,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconMedium,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            text,
            style: isSecondary || isOutlined 
                ? AppTextStyles.buttonTextSecondary 
                : AppTextStyles.buttonText,
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: isSecondary || isOutlined 
          ? AppTextStyles.buttonTextSecondary 
          : AppTextStyles.buttonText,
    );
  }
}