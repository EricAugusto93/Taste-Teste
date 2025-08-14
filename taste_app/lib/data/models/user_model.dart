import 'package:equatable/equatable.dart';

/// Modelo de dados do usuário
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserPreferences preferences;
  final UserStats stats;
  final UserAddress? defaultAddress;
  final List<UserAddress> addresses;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final UserSubscription? subscription;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
    required this.preferences,
    required this.stats,
    this.defaultAddress,
    this.addresses = const [],
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.subscription,
  });

  /// Cria uma instância a partir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      stats: UserStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
      defaultAddress: json['default_address'] != null
          ? UserAddress.fromJson(json['default_address'] as Map<String, dynamic>)
          : null,
      addresses: (json['addresses'] as List<dynamic>? ?? [])
          .map((address) => UserAddress.fromJson(address as Map<String, dynamic>))
          .toList(),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      subscription: json['subscription'] != null
          ? UserSubscription.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
      'default_address': defaultAddress?.toJson(),
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'subscription': subscription?.toJson(),
    };
  }

  /// Cria uma cópia com modificações
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    UserStats? stats,
    UserAddress? defaultAddress,
    List<UserAddress>? addresses,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    UserSubscription? subscription,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      addresses: addresses ?? this.addresses,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        createdAt,
        updatedAt,
        preferences,
        stats,
        defaultAddress,
        addresses,
        isEmailVerified,
        isPhoneVerified,
        subscription,
      ];

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phone: $phone, avatar: $avatar, createdAt: $createdAt, updatedAt: $updatedAt, preferences: $preferences, stats: $stats, defaultAddress: $defaultAddress, addresses: $addresses, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, subscription: $subscription)';
  }
}

/// Preferências do usuário
class UserPreferences extends Equatable {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool locationEnabled;
  final String language;
  final String currency;
  final String theme; // 'light', 'dark', 'system'
  final List<String> dietaryRestrictions;
  final List<String> favoriteCategories;
  final double maxDeliveryDistance;
  final bool showPromotions;
  final bool shareDataForRecommendations;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.locationEnabled = true,
    this.language = 'pt-BR',
    this.currency = 'BRL',
    this.theme = 'system',
    this.dietaryRestrictions = const [],
    this.favoriteCategories = const [],
    this.maxDeliveryDistance = 10.0,
    this.showPromotions = true,
    this.shareDataForRecommendations = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? false,
      locationEnabled: json['location_enabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'pt-BR',
      currency: json['currency'] as String? ?? 'BRL',
      theme: json['theme'] as String? ?? 'system',
      dietaryRestrictions: (json['dietary_restrictions'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      favoriteCategories: (json['favorite_categories'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      maxDeliveryDistance: (json['max_delivery_distance'] as num?)?.toDouble() ?? 10.0,
      showPromotions: json['show_promotions'] as bool? ?? true,
      shareDataForRecommendations: json['share_data_for_recommendations'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'location_enabled': locationEnabled,
      'language': language,
      'currency': currency,
      'theme': theme,
      'dietary_restrictions': dietaryRestrictions,
      'favorite_categories': favoriteCategories,
      'max_delivery_distance': maxDeliveryDistance,
      'show_promotions': showPromotions,
      'share_data_for_recommendations': shareDataForRecommendations,
    };
  }

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? locationEnabled,
    String? language,
    String? currency,
    String? theme,
    List<String>? dietaryRestrictions,
    List<String>? favoriteCategories,
    double? maxDeliveryDistance,
    bool? showPromotions,
    bool? shareDataForRecommendations,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      maxDeliveryDistance: maxDeliveryDistance ?? this.maxDeliveryDistance,
      showPromotions: showPromotions ?? this.showPromotions,
      shareDataForRecommendations: shareDataForRecommendations ?? this.shareDataForRecommendations,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        emailNotifications,
        pushNotifications,
        smsNotifications,
        locationEnabled,
        language,
        currency,
        theme,
        dietaryRestrictions,
        favoriteCategories,
        maxDeliveryDistance,
        showPromotions,
        shareDataForRecommendations,
      ];
}

/// Assinatura do usuário
class UserSubscription extends Equatable {
  final String id;
  final String planId;
  final String planName;
  final double monthlyPrice;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String status; // 'active', 'cancelled', 'expired', 'pending'
  final List<String> benefits;
  final DateTime? nextBillingDate;
  final String paymentMethod;
  final bool autoRenew;

  const UserSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.monthlyPrice,
    required this.startDate,
    this.endDate,
    this.isActive = false,
    this.status = 'pending',
    this.benefits = const [],
    this.nextBillingDate,
    this.paymentMethod = '',
    this.autoRenew = true,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      monthlyPrice: (json['monthly_price'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
      isActive: json['is_active'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      benefits: (json['benefits'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      nextBillingDate: json['next_billing_date'] != null
          ? DateTime.parse(json['next_billing_date'] as String)
          : null,
      paymentMethod: json['payment_method'] as String? ?? '',
      autoRenew: json['auto_renew'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'plan_name': planName,
      'monthly_price': monthlyPrice,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'status': status,
      'benefits': benefits,
      'next_billing_date': nextBillingDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'auto_renew': autoRenew,
    };
  }

  UserSubscription copyWith({
    String? id,
    String? planId,
    String? planName,
    double? monthlyPrice,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? status,
    List<String>? benefits,
    DateTime? nextBillingDate,
    String? paymentMethod,
    bool? autoRenew,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      benefits: benefits ?? this.benefits,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  @override
  List<Object?> get props => [
        id,
        planId,
        planName,
        monthlyPrice,
        startDate,
        endDate,
        isActive,
        status,
        benefits,
        nextBillingDate,
        paymentMethod,
        autoRenew,
      ];
}

/// Estatísticas do usuário
class UserStats extends Equatable {
  final int totalOrders;
  final double totalSpent;
  final int favoriteRestaurants;
  final int reviewsWritten;
  final double averageRating;
  final String memberSince;
  final int loyaltyPoints;
  final String preferredCategory;
  final double averageOrderValue;
  final int ordersThisMonth;

  const UserStats({
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.favoriteRestaurants = 0,
    this.reviewsWritten = 0,
    this.averageRating = 0.0,
    this.memberSince = '',
    this.loyaltyPoints = 0,
    this.preferredCategory = '',
    this.averageOrderValue = 0.0,
    this.ordersThisMonth = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOrders: json['total_orders'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      favoriteRestaurants: json['favorite_restaurants'] as int? ?? 0,
      reviewsWritten: json['reviews_written'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      memberSince: json['member_since'] as String? ?? '',
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      preferredCategory: json['preferred_category'] as String? ?? '',
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0.0,
      ordersThisMonth: json['orders_this_month'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'favorite_restaurants': favoriteRestaurants,
      'reviews_written': reviewsWritten,
      'average_rating': averageRating,
      'member_since': memberSince,
      'loyalty_points': loyaltyPoints,
      'preferred_category': preferredCategory,
      'average_order_value': averageOrderValue,
      'orders_this_month': ordersThisMonth,
    };
  }

  UserStats copyWith({
    int? totalOrders,
    double? totalSpent,
    int? favoriteRestaurants,
    int? reviewsWritten,
    double? averageRating,
    String? memberSince,
    int? loyaltyPoints,
    String? preferredCategory,
    double? averageOrderValue,
    int? ordersThisMonth,
  }) {
    return UserStats(
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
      reviewsWritten: reviewsWritten ?? this.reviewsWritten,
      averageRating: averageRating ?? this.averageRating,
      memberSince: memberSince ?? this.memberSince,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      preferredCategory: preferredCategory ?? this.preferredCategory,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      ordersThisMonth: ordersThisMonth ?? this.ordersThisMonth,
    );
  }

  @override
  List<Object?> get props => [
        totalOrders,
        totalSpent,
        favoriteRestaurants,
        reviewsWritten,
        averageRating,
        memberSince,
        loyaltyPoints,
        preferredCategory,
        averageOrderValue,
        ordersThisMonth,
      ];
}

/// Endereço do usuário
class UserAddress extends Equatable {
  final String id;
  final String label; // 'Casa', 'Trabalho', etc.
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String? instructions;

  const UserAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.instructions,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zip_code'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'instructions': instructions,
    };
  }

  UserAddress copyWith({
    String? id,
    String? label,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? instructions,
  }) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
        zipCode,
        country,
        latitude,
        longitude,
        isDefault,
        instructions,
      ];
}