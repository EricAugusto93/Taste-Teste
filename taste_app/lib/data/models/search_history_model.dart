/// Modelo para histórico de buscas
class SearchHistoryModel {
  final String id;
  final String userId;
  final String query;
  final int? resultsCount;
  final DateTime searchedAt;

  SearchHistoryModel({
    required this.id,
    required this.userId,
    required this.query,
    this.resultsCount,
    required this.searchedAt,
  });

  /// Getter para compatibilidade com timestamp
  DateTime get timestamp => searchedAt;

  /// Criar instância a partir de JSON
  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      query: json['query'] as String,
      resultsCount: json['results_count'] as int?,
      searchedAt: DateTime.parse(json['searched_at'] as String),
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'query': query,
      'results_count': resultsCount,
      'searched_at': searchedAt.toIso8601String(),
    };
  }

  /// Alias para toJson para compatibilidade
  Map<String, dynamic> toMap() => toJson();

  /// Factory constructor para compatibilidade
  factory SearchHistoryModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryModel.fromJson(map);
  }

  /// Criar cópia com modificações
  SearchHistoryModel copyWith({
    String? id,
    String? userId,
    String? query,
    int? resultsCount,
    DateTime? searchedAt,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      query: query ?? this.query,
      resultsCount: resultsCount ?? this.resultsCount,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchHistoryModel &&
        other.id == id &&
        other.userId == userId &&
        other.query == query &&
        other.resultsCount == resultsCount &&
        other.searchedAt == searchedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      query,
      resultsCount,
      searchedAt,
    );
  }

  @override
  String toString() {
    return 'SearchHistoryModel(id: $id, userId: $userId, query: $query, resultsCount: $resultsCount, searchedAt: $searchedAt)';
  }
}