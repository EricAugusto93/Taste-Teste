class Usuario {
  final String id;
  final String email;
  final String? nome;
  final List<String> favoritos;
  final DateTime? createdAt;

  const Usuario({
    required this.id,
    required this.email,
    this.nome,
    required this.favoritos,
    this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      email: json['email'] as String,
      nome: json['nome'] as String?,
      favoritos: List<String>.from(json['favoritos'] as List? ?? []),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'email': email,
      'nome': nome,
      'favoritos': favoritos,
    };
    
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    
    return map;
  }

  Usuario copyWith({
    String? id,
    String? email,
    String? nome,
    List<String>? favoritos,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      favoritos: favoritos ?? this.favoritos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 