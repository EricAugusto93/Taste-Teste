import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Campo de texto customizado do aplicativo Taste
class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool isSearchField;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final double? borderRadius;

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
    this.isSearchField = false,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
  });

  /// Factory para campo de busca específico
  factory CustomTextField.search({
    Key? key,
    String? hintText,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return CustomTextField(
      key: key,
      hintText: hintText ?? 'Buscar restaurantes...',
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      prefixIcon: prefixIcon ??
          const Icon(
            Icons.search,
            color: AppColors.textLight,
            size: AppDimensions.iconMedium,
          ),
      suffixIcon: suffixIcon,
      isSearchField: true,
      fillColor: AppColors.surface,
      borderRadius: AppDimensions.searchFieldRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: isSearchField
          ? AppTextStyles.searchPlaceholder.copyWith(color: AppColors.textDark)
          : AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? AppColors.surface,
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildFocusedBorder(),
        errorBorder: _buildErrorBorder(),
        focusedErrorBorder: _buildErrorBorder(),
        hintStyle: AppTextStyles.searchPlaceholder,
        labelStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(
              horizontal: isSearchField
                  ? AppDimensions.paddingLarge
                  : AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingMedium,
            ),
      ),
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ??
          (isSearchField
              ? AppDimensions.searchFieldRadius
              : AppDimensions.mediumRadius)),
      borderSide: BorderSide.none,
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ??
          (isSearchField
              ? AppDimensions.searchFieldRadius
              : AppDimensions.mediumRadius)),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ??
          (isSearchField
              ? AppDimensions.searchFieldRadius
              : AppDimensions.mediumRadius)),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 2,
      ),
    );
  }
}

/// Widget específico para campo de busca da home
class SearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const SearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: AppDimensions.searchFieldMaxWidth,
      ),
      child: CustomTextField.search(
        hintText: hintText ?? 'Buscar restaurantes...',
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textLight,
          size: AppDimensions.iconMedium,
        ),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.textLight,
                  size: AppDimensions.iconMedium,
                ),
                onPressed: () {
                  controller?.clear();
                  onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}
