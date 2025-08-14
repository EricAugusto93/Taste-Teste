import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import 'auth_provider.dart';

/// Estado do perfil do usuário
class UserProfileState {
  final UserProfile? profile;
  final UserStats? stats;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.profile,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    UserStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gerenciar o estado do perfil do usuário
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileRepository _repository;
  final Ref _ref;

  UserProfileNotifier(this._repository, this._ref) : super(const UserProfileState());

  /// Carrega o perfil do usuário atual
  Future<void> loadCurrentUserProfile() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _repository.getCurrentUserProfile();
      final stats = await _repository.getUserStats();
      
      state = state.copyWith(
        profile: profile,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar perfil: $e',
      );
    }
  }

  /// Atualiza o perfil do usuário
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    DateTime? birthDate,
    String? city,
    String? bio,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedProfile = await _repository.updateCurrentUserProfile(
        fullName: fullName,
        phone: phone,
        birthDate: birthDate,
        city: city,
        bio: bio,
        avatarUrl: avatarUrl,
        preferences: preferences,
      );

      if (updatedProfile != null) {
        state = state.copyWith(
          profile: updatedProfile,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao atualizar perfil',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao atualizar perfil: $e',
      );
      return false;
    }
  }

  /// Cria um novo perfil
  Future<bool> createProfile({
    required String fullName,
    String? phone,
    DateTime? birthDate,
    String? city,
    String? bio,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    final authState = _ref.read(authProvider);
    final userId = authState.user?.id;
    
    if (userId == null) {
      state = state.copyWith(error: 'Usuário não autenticado');
      return false;
    }

    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newProfile = await _repository.createUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        birthDate: birthDate,
        city: city,
        bio: bio,
        avatarUrl: avatarUrl,
        preferences: preferences,
      );

      if (newProfile != null) {
        state = state.copyWith(
          profile: newProfile,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao criar perfil',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erro ao criar perfil: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao criar perfil: $e',
      );
      return false;
    }
  }

  /// Atualiza uma preferência específica
  Future<bool> updatePreference(String key, dynamic value) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return false;

    final newPreferences = Map<String, dynamic>.from(currentProfile.preferences);
    newPreferences[key] = value;

    return await updateProfile(preferences: newPreferences);
  }

  /// Remove uma preferência específica
  Future<bool> removePreference(String key) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return false;

    final newPreferences = Map<String, dynamic>.from(currentProfile.preferences);
    newPreferences.remove(key);

    return await updateProfile(preferences: newPreferences);
  }

  /// Recarrega as estatísticas do usuário
  Future<void> refreshStats() async {
    try {
      final stats = await _repository.getUserStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      debugPrint('❌ Erro ao recarregar estatísticas: $e');
    }
  }

  /// Limpa o estado do perfil
  void clearProfile() {
    state = const UserProfileState();
  }

  /// Limpa apenas o erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider do repositório de perfil
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository.instance;
});

/// Provider do notifier de perfil
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UserProfileNotifier(repository, ref);
});

/// Provider para verificar se o perfil existe
final profileExistsProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  
  if (userId == null) return false;
  
  final repository = ref.watch(userProfileRepositoryProvider);
  return await repository.profileExists(userId);
});

/// Provider para buscar perfil de um usuário específico
final userProfileByIdProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  return await repository.getUserProfile(userId);
});

/// Provider para buscar perfis por nome
final searchProfilesProvider = FutureProvider.family<List<UserProfile>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  
  final repository = ref.watch(userProfileRepositoryProvider);
  return await repository.searchProfiles(query);
});

/// Provider para verificar se o perfil está completo
final isProfileCompleteProvider = Provider<bool>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.profile?.isComplete ?? false;
});

/// Provider para obter preferência específica
final userPreferenceProvider = Provider.family<dynamic, String>((ref, key) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.profile?.getPreference(key);
});