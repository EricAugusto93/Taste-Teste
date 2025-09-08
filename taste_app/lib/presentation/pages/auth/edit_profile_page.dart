import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/auth_validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/loading_widget.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;
  bool _hasChanges = false;
  Timer? _fieldChangeDebounceTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _fieldChangeDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadUserProfile() async {
    // Carrega o perfil do usuário
    await ref.read(userProfileProvider.notifier).loadCurrentUserProfile();

    final profileState = ref.read(userProfileProvider);
    final profile = profileState.profile;

    if (profile != null) {
      setState(() {
        _nameController.text = profile.fullName;
        _phoneController.text = profile.phone ?? '';
        _bioController.text = profile.bio ?? '';
        _cityController.text = profile.city ?? '';
      });
    }

    // Adicionar listeners para detectar mudanças
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    _fieldChangeDebounceTimer?.cancel();
    _fieldChangeDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_hasChanges) {
        setState(() {
          _hasChanges = true;
        });
      }
    });
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      NavigationHelper.safeGoBack(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await ref.read(userProfileProvider.notifier).updateProfile(
                fullName: _nameController.text.trim(),
                phone: _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
                bio: _bioController.text.trim().isEmpty
                    ? null
                    : _bioController.text.trim(),
                city: _cityController.text.trim().isEmpty
                    ? null
                    : _cityController.text.trim(),
              );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );

          setState(() {
            _hasChanges = false;
          });

          // Atualiza o perfil original
          final updatedProfile = ref.read(userProfileProvider).profile;
          if (updatedProfile != null) {}

          NavigationHelper.safeGoBack(context);
        } else {
          final error =
              ref.read(userProfileProvider).error ?? 'Erro desconhecido';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar perfil: $error'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'Você tem alterações não salvas. Deseja descartá-las?',
        ),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.safeGoBack(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => NavigationHelper.safeGoBack(context),
            child: const Text(
              'Descartar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            NavigationHelper.safeGoBack(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  NavigationHelper.safeGoBack(context);
                }
              } else {
                NavigationHelper.safeGoBack(context);
              }
            },
          ),
          title: Text(
            'Editar Perfil',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _handleSaveProfile,
                child: Text(
                  'Salvar',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: authState.isLoading || _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar section
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: AppColors.textPrimary,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        // TODO: Implementar upload de foto
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Upload de foto em desenvolvimento'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Text(
                              'Alterar foto do perfil',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Informações pessoais
                      Text(
                        'Informações Pessoais',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      AuthTextField(
                        label: 'Nome completo',
                        hint: 'Digite seu nome completo',
                        controller: _nameController,
                        validator: AuthValidators.name,
                        onChanged: (_) => _onFieldChanged(),
                        prefixIcon: const Icon(
                          Icons.person_outline,
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
                        onChanged: (_) => _onFieldChanged(),
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      AuthTextField(
                        label: 'Cidade',
                        hint: 'Sua cidade atual',
                        controller: _cityController,
                        onChanged: (_) => _onFieldChanged(),
                        prefixIcon: const Icon(
                          Icons.location_city,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      AuthTextField(
                        label: 'Bio',
                        hint: 'Conte um pouco sobre você...',
                        controller: _bioController,
                        maxLines: 3,
                        onChanged: (_) => _onFieldChanged(),
                        prefixIcon: const Icon(
                          Icons.info_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Seção de segurança
                      Text(
                        'Segurança',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Alterar senha
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.lock_outline,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            'Alterar Senha',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Altere sua senha de acesso',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          onTap: () {
                            // TODO: Implementar alteração de senha
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Alteração de senha em desenvolvimento'),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Botão de salvar (se houver mudanças)
                      if (_hasChanges) ...[
                        AuthButton(
                          text: 'Salvar Alterações',
                          onPressed: _handleSaveProfile,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        AuthButton(
                          text: 'Cancelar',
                          onPressed: () async {
                            final shouldDiscard = await _onWillPop();
                            if (shouldDiscard && mounted) {
                              NavigationHelper.safeGoBack(context);
                            }
                          },
                          isSecondary: true,
                        ),
                      ],

                      const SizedBox(height: AppDimensions.paddingLarge),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
