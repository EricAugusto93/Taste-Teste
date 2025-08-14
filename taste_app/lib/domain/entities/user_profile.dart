/// Entidade que representa o perfil de um usuário
class UserProfile {
  final String id;
  final String fullName;
  final String? phone;
  final DateTime? birthDate;
  final String? city;
  final String? bio;
  final String? avatarUrl;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.phone,
    this.birthDate,
    this.city,
    this.bio,
    this.avatarUrl,
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma cópia do perfil com novos valores
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phone,
    DateTime? birthDate,
    String? city,
    String? bio,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'city': city,
      'bio': bio,
      'avatar_url': avatarUrl,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria a partir de JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      city: json['city'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Obtém as iniciais do nome para avatar
  String get initials {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  /// Obtém a idade baseada na data de nascimento
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Verifica se o perfil está completo
  bool get isComplete {
    return fullName.isNotEmpty && 
           phone != null && 
           phone!.isNotEmpty &&
           city != null && 
           city!.isNotEmpty;
  }

  /// Obtém o nome de exibição (primeiro nome)
  String get displayName {
    final names = fullName.trim().split(' ');
    return names.isNotEmpty ? names[0] : fullName;
  }

  /// Obtém preferência específica
  T? getPreference<T>(String key, [T? defaultValue]) {
    final value = preferences[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Define uma preferência
  UserProfile setPreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences[key] = value;
    return copyWith(preferences: newPreferences);
  }

  /// Remove uma preferência
  UserProfile removePreference(String key) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences.remove(key);
    return copyWith(preferences: newPreferences);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.fullName == fullName &&
        other.phone == phone &&
        other.birthDate == birthDate &&
        other.city == city &&
        other.bio == bio &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      fullName,
      phone,
      birthDate,
      city,
      bio,
      avatarUrl,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, phone: $phone, city: $city)';
  }
}

/// Preferências comuns do usuário
class UserPreferences {
  static const String theme = 'theme';
  static const String language = 'language';
  static const String notifications = 'notifications';
  static const String location = 'location';
  static const String dietaryRestrictions = 'dietary_restrictions';
  static const String favoriteCategories = 'favorite_categories';
  static const String maxDistance = 'max_distance';
  static const String priceRange = 'price_range';
}

/// Valores para tema
class ThemePreference {
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
}

/// Valores para idioma
class LanguagePreference {
  static const String portuguese = 'pt';
  static const String english = 'en';
  static const String spanish = 'es';
}