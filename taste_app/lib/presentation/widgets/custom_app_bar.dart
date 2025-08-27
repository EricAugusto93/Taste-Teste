import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/navigation_helper.dart';

/// AppBar customizada do aplicativo Taste
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottom,
  });
  
  /// Factory para AppBar transparente (usado na home)
  factory CustomAppBar.transparent({
    Key? key,
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }
  
  /// Factory para AppBar com gradiente
  factory CustomAppBar.gradient({
    Key? key,
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    
    if (showBackButton && leadingWidget == null) {
      leadingWidget = IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: AppDimensions.iconMedium,
        ),
        onPressed: onBackPressed ?? () {
          NavigationHelper.safeGoBack(context);
        },
      );
    }
    
    Widget? titleContent = titleWidget;
    if (titleContent == null && title != null) {
      titleContent = Text(
        title!,
        style: AppTextStyles.h2,
      );
    }
    
    return Container(
      decoration: backgroundColor == Colors.transparent
          ? const BoxDecoration(
              color: AppColors.background,
            )
          : null,
      child: AppBar(
        title: titleContent,
        actions: actions,
        leading: leadingWidget,
        automaticallyImplyLeading: automaticallyImplyLeading,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor ?? AppColors.background,
        foregroundColor: foregroundColor ?? AppColors.textPrimary,
        elevation: elevation ?? 0,
        bottom: bottom,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconMedium,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconMedium,
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    AppDimensions.appBarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// AppBar específica para a home com saudação
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  
  const HomeAppBar({
    super.key,
    required this.userName,
    this.onProfileTap,
    this.onNotificationTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            children: [
              // Avatar do usuário
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: AppDimensions.avatarMedium,
                  height: AppDimensions.avatarMedium,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.paddingMedium),
              
              // Saudação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Olá, $userName!',
                      style: AppTextStyles.greeting,
                    ),
                    Text(
                      'O que você gostaria de comer hoje?',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              // Botão de notificação
              IconButton(
                onPressed: onNotificationTap,
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: AppDimensions.iconLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(100);
}