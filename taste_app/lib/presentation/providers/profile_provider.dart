import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/profile_repository.dart';
import '../../core/config/supabase_config.dart';
import 'auth_provider.dart';

/// Provider do ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(SupabaseConfig.client);
});

/// Estado do perfil do usuário
class ProfileState {
  final UserStats? stats;
  final UserSettings? settings;
  final List<UserActivity> activities;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.stats,
    this.settings,
    this.activities = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserStats? stats,
    UserSettings? settings,
    List<UserActivity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier para gerenciar o estado do perfil
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(const ProfileState());

  /// Carrega os dados do perfil
  Future<void> loadProfile() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.getUserStats(user.id),
        _repository.getUserSettings(user.id),
        _repository.getUserActivities(user.id, limit: 10),
      ]);

      state = ProfileState(
        stats: results[0] as UserStats,
        settings: results[1] as UserSettings,
        activities: results[2] as List<UserActivity>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar perfil: $e',
      );
    }
  }

  /// Atualiza o perfil do usuário
  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await _repository.updateUserProfile(
        userId: user.id,
        displayName: displayName,
        avatarUrl: avatarUrl,
        metadata: metadata,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erro ao atualizar perfil: $e');
      return false;
    }
  }

  /// Atualiza as configurações do usuário
  Future<bool> updateSettings(UserSettings settings) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await _repository.updateUserSettings(user.id, settings);
      state = state.copyWith(settings: settings);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erro ao atualizar configurações: $e');
      return false;
    }
  }

  /// Atualiza uma configuração específica
  Future<bool> updateSetting(String key, dynamic value) async {
    final currentSettings = state.settings ?? const UserSettings();
    UserSettings newSettings;

    switch (key) {
      case 'notifications_enabled':
        newSettings = currentSettings.copyWith(notificationsEnabled: value);
        break;
      case 'email_notifications':
        newSettings = currentSettings.copyWith(emailNotifications: value);
        break;
      case 'push_notifications':
        newSettings = currentSettings.copyWith(pushNotifications: value);
        break;
      case 'location_enabled':
        newSettings = currentSettings.copyWith(locationEnabled: value);
        break;
      case 'theme':
        newSettings = currentSettings.copyWith(theme: value);
        break;
      case 'language':
        newSettings = currentSettings.copyWith(language: value);
        break;
      default:
        return false;
    }

    return await updateSettings(newSettings);
  }

  /// Carrega mais atividades
  Future<void> loadMoreActivities() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final newActivities = await _repository.getUserActivities(
        user.id,
        limit: 10,
        offset: state.activities.length,
      );

      state = state.copyWith(
        activities: [...state.activities, ...newActivities],
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao carregar atividades: $e');
    }
  }

  /// Deleta a conta do usuário
  Future<bool> deleteAccount() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await _repository.deleteUserAccount(user.id);
      // O logout será feito automaticamente pelo AuthProvider
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erro ao deletar conta: $e');
      return false;
    }
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Recarrega as estatísticas
  Future<void> refreshStats() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final stats = await _repository.getUserStats(user.id);
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao atualizar estatísticas: $e');
    }
  }
}

/// Provider principal do perfil
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository, ref);
});

/// Provider para as estatísticas do usuário
final userStatsProvider = Provider<UserStats?>((ref) {
  final profileState = ref.watch(profileProvider);
  return profileState.stats;
});

/// Provider para as configurações do usuário
final userSettingsProvider = Provider<UserSettings?>((ref) {
  final profileState = ref.watch(profileProvider);
  return profileState.settings;
});

/// Provider para as atividades do usuário
final userActivitiesProvider = Provider<List<UserActivity>>((ref) {
  final profileState = ref.watch(profileProvider);
  return profileState.activities;
});

/// Provider para verificar se o perfil está carregando
final profileLoadingProvider = Provider<bool>((ref) {
  final profileState = ref.watch(profileProvider);
  return profileState.isLoading;
});

/// Provider para o erro do perfil
final profileErrorProvider = Provider<String?>((ref) {
  final profileState = ref.watch(profileProvider);
  return profileState.error;
});

/// Provider para configuração específica
final settingProvider = Provider.family<dynamic, String>((ref, key) {
  final settings = ref.watch(userSettingsProvider);
  if (settings == null) return null;

  switch (key) {
    case 'notifications_enabled':
      return settings.notificationsEnabled;
    case 'email_notifications':
      return settings.emailNotifications;
    case 'push_notifications':
      return settings.pushNotifications;
    case 'location_enabled':
      return settings.locationEnabled;
    case 'theme':
      return settings.theme;
    case 'language':
      return settings.language;
    default:
      return null;
  }
});