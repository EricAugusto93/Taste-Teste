import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cache_item.g.dart';

/// Modelo para itens de cache com suporte a TTL e estatísticas
@HiveType(typeId: 0)
@JsonSerializable()
class CacheItem {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final dynamic data;

  @HiveField(2)
  final DateTime? expirationTime;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime lastAccessed;

  @HiveField(5)
  final String? dataType;

  @HiveField(6)
  final int? version;

  CacheItem({
    required this.key,
    required this.data,
    this.expirationTime,
    DateTime? createdAt,
    DateTime? lastAccessed,
    this.dataType,
    this.version = 1,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastAccessed = lastAccessed ?? DateTime.now();

  /// Verifica se o item de cache expirou
  bool isExpired() {
    if (expirationTime == null) return false;
    return DateTime.now().isAfter(expirationTime!);
  }

  /// Atualiza o timestamp de último acesso
  void updateLastAccessed() {
    lastAccessed = DateTime.now();
  }

  /// Cria uma cópia do item com novos valores
  CacheItem copyWith({
    String? key,
    dynamic data,
    DateTime? expirationTime,
    DateTime? createdAt,
    DateTime? lastAccessed,
    String? dataType,
    int? version,
  }) {
    return CacheItem(
      key: key ?? this.key,
      data: data ?? this.data,
      expirationTime: expirationTime ?? this.expirationTime,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      dataType: dataType ?? this.dataType,
      version: version ?? this.version,
    );
  }

  /// Calcula a idade do item em cache
  Duration get age => DateTime.now().difference(createdAt);

  /// Calcula o tempo desde o último acesso
  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessed);

  /// Verifica se o item está próximo do vencimento (últimos 10% do TTL)
  bool isNearExpiration() {
    if (expirationTime == null) return false;
    
    final totalTtl = expirationTime!.difference(createdAt);
    final timeLeft = expirationTime!.difference(DateTime.now());
    
    return timeLeft.inMilliseconds <= (totalTtl.inMilliseconds * 0.1);
  }

  /// Serialização JSON
  factory CacheItem.fromJson(Map<String, dynamic> json) => _$CacheItemFromJson(json);
  Map<String, dynamic> toJson() => _$CacheItemToJson(this);

  @override
  String toString() {
    return 'CacheItem(key: $key, dataType: $dataType, age: ${age.inMinutes}min, expired: ${isExpired()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheItem &&
        other.key == key &&
        other.version == version;
  }

  @override
  int get hashCode => key.hashCode ^ version.hashCode;
}

/// Enum para tipos de dados em cache
enum CacheDataType {
  restaurant('restaurant'),
  user('user'),
  category('category'),
  review('review'),
  image('image'),
  search('search'),
  location('location');

  const CacheDataType(this.value);
  final String value;

  /// TTL padrão para cada tipo de dados
  Duration get defaultTtl {
    switch (this) {
      case CacheDataType.restaurant:
        return const Duration(minutes: 15);
      case CacheDataType.user:
        return const Duration(minutes: 30);
      case CacheDataType.category:
        return const Duration(hours: 1);
      case CacheDataType.review:
        return const Duration(minutes: 20);
      case CacheDataType.image:
        return const Duration(hours: 24);
      case CacheDataType.search:
        return const Duration(minutes: 10);
      case CacheDataType.location:
        return const Duration(hours: 2);
    }
  }

  static CacheDataType? fromString(String? value) {
    if (value == null) return null;
    return CacheDataType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CacheDataType.restaurant,
    );
  }
}

/// Estatísticas de cache
class CacheStats {
  final int totalItems;
  final int expiredItems;
  final int hitCount;
  final int missCount;
  final double hitRatio;
  final int totalSize;
  final Map<String, int> itemsByType;

  const CacheStats({
    required this.totalItems,
    required this.expiredItems,
    required this.hitCount,
    required this.missCount,
    required this.hitRatio,
    required this.totalSize,
    required this.itemsByType,
  });

  @override
  String toString() {
    return 'CacheStats(items: $totalItems, expired: $expiredItems, hit ratio: ${(hitRatio * 100).toStringAsFixed(1)}%)';
  }
}