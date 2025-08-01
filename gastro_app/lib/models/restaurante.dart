class Restaurante {
  final String id;
  final String nome;
  final String tipo;
  final String descricao;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final String? imagemUrl;
  final double avaliacaoMedia;
  final int totalAvaliacoes;
  final String? endereco;
  final String? telefone;
  final String? site;
  final Map<String, dynamic>? horarioFuncionamento;
  final double? precoMedio;
  final bool isAberto;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Restaurante({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.tags,
    this.imagemUrl,
    this.avaliacaoMedia = 0.0,
    this.totalAvaliacoes = 0,
    this.endereco,
    this.telefone,
    this.site,
    this.horarioFuncionamento,
    this.precoMedio,
    this.isAberto = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Restaurante.fromJson(Map<String, dynamic> json) {
    return Restaurante(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      descricao: json['descricao'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      tags: List<String>.from(json['tags'] as List),
      imagemUrl: json['imagem_url'] as String?,
      avaliacaoMedia: (json['avaliacao_media'] as num?)?.toDouble() ?? 0.0,
      totalAvaliacoes: json['total_avaliacoes'] as int? ?? 0,
      endereco: json['endereco'] as String?,
      telefone: json['telefone'] as String?,
      site: json['site'] as String?,
      horarioFuncionamento: json['horario_funcionamento'] as Map<String, dynamic>?,
      precoMedio: (json['preco_medio'] as num?)?.toDouble(),
      isAberto: json['is_aberto'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'imagem_url': imagemUrl,
      'avaliacao_media': avaliacaoMedia,
      'total_avaliacoes': totalAvaliacoes,
      'endereco': endereco,
      'telefone': telefone,
      'site': site,
      'horario_funcionamento': horarioFuncionamento,
      'preco_medio': precoMedio,
      'is_aberto': isAberto,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Restaurante copyWith({
    String? id,
    String? nome,
    String? tipo,
    String? descricao,
    double? latitude,
    double? longitude,
    List<String>? tags,
    String? imagemUrl,
    double? avaliacaoMedia,
    int? totalAvaliacoes,
    String? endereco,
    String? telefone,
    String? site,
    Map<String, dynamic>? horarioFuncionamento,
    double? precoMedio,
    bool? isAberto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Restaurante(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      avaliacaoMedia: avaliacaoMedia ?? this.avaliacaoMedia,
      totalAvaliacoes: totalAvaliacoes ?? this.totalAvaliacoes,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      site: site ?? this.site,
      horarioFuncionamento: horarioFuncionamento ?? this.horarioFuncionamento,
      precoMedio: precoMedio ?? this.precoMedio,
      isAberto: isAberto ?? this.isAberto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 