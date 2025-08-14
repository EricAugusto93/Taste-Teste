/// Parâmetros de busca
class SearchParams {
  final String? query;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final double? maxDistance; // em km
  final double? minRating;
  final bool? isOpen;
  final String sortBy;
  final int page;
  final int pageSize;
  final List<String>? tags;
  final double? minPrice;
  final double? maxPrice;
  final bool? hasPromotion;
  final List<String>? paymentMethods;

  const SearchParams({
    this.query,
    this.categoryId,
    this.latitude,
    this.longitude,
    this.maxDistance,
    this.minRating,
    this.isOpen,
    this.sortBy = 'relevance',
    this.page = 1,
    this.pageSize = 20,
    this.tags,
    this.minPrice,
    this.maxPrice,
    this.hasPromotion,
    this.paymentMethods,
  });

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'categoryId': categoryId,
      'latitude': latitude,
      'longitude': longitude,
      'maxDistance': maxDistance,
      'minRating': minRating,
      'isOpen': isOpen,
      'sortBy': sortBy,
      'page': page,
      'pageSize': pageSize,
      'tags': tags,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'hasPromotion': hasPromotion,
      'paymentMethods': paymentMethods,
    };
  }
}