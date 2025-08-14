class Experiencia {
  final String id;
  final String userId;
  final String restauranteId;
  final String emoji;
  final String? comentario;
  final DateTime dataVisita;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Experiencia({
    required this.id,
    required this.userId,
    required this.restauranteId,
    required this.emoji,
    this.comentario,
    required this.dataVisita,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Experiencia.fromJson(Map<String, dynamic> json) {
    return Experiencia(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restauranteId: json['restaurante_id'] as String,
      emoji: json['emoji'] as String,
      comentario: json['comentario'] as String?,
      dataVisita: DateTime.parse(json['data_visita'] as String),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurante_id': restauranteId,
      'emoji': emoji,
      'comentario': comentario,
      'data_visita': dataVisita.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Experiencia copyWith({
    String? id,
    String? userId,
    String? restauranteId,
    String? emoji,
    String? comentario,
    DateTime? dataVisita,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Experiencia(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restauranteId: restauranteId ?? this.restauranteId,
      emoji: emoji ?? this.emoji,
      comentario: comentario ?? this.comentario,
      dataVisita: dataVisita ?? this.dataVisita,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}