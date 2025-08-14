/// Classe para representar filtros de busca
class SearchFilters {
  final String? categoryId;
  final double? maxDistance;
  final double? minRating;
  final bool? isOpen;
  final double? latitude;
  final double? longitude;
  final String? sortBy;

  const SearchFilters({
    this.categoryId,
    this.maxDistance,
    this.minRating,
    this.isOpen,
    this.latitude,
    this.longitude,
    this.sortBy,
  });

  SearchFilters copyWith({
    String? categoryId,
    double? maxDistance,
    double? minRating,
    bool? isOpen,
    double? latitude,
    double? longitude,
    String? sortBy,
  }) {
    return SearchFilters(
      categoryId: categoryId ?? this.categoryId,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      isOpen: isOpen ?? this.isOpen,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return categoryId != null ||
           maxDistance != null ||
           minRating != null ||
           isOpen != null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (categoryId != null) count++;
    if (maxDistance != null) count++;
    if (minRating != null) count++;
    if (isOpen != null) count++;
    return count;
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'maxDistance': maxDistance,
      'minRating': minRating,
      'isOpen': isOpen,
      'latitude': latitude,
      'longitude': longitude,
      'sortBy': sortBy,
    };
  }

  factory SearchFilters.fromMap(Map<String, dynamic> map) {
    return SearchFilters(
      categoryId: map['categoryId'],
      maxDistance: map['maxDistance']?.toDouble(),
      minRating: map['minRating']?.toDouble(),
      isOpen: map['isOpen'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      sortBy: map['sortBy'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilters &&
        other.categoryId == categoryId &&
        other.maxDistance == maxDistance &&
        other.minRating == minRating &&
        other.isOpen == isOpen &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode {
    return categoryId.hashCode ^
        maxDistance.hashCode ^
        minRating.hashCode ^
        isOpen.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        sortBy.hashCode;
  }

  @override
  String toString() {
    return 'SearchFilters(categoryId: $categoryId, maxDistance: $maxDistance, minRating: $minRating, isOpen: $isOpen, latitude: $latitude, longitude: $longitude, sortBy: $sortBy)';
  }
}