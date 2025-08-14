class EstatisticasRestaurante {
  final String restauranteId;
  final int total;
  final Map<String, int> stats;
  final String topEmoji;
  final List<ComentarioRecente> comentariosRecentes;
  final DateTime? ultimaAtualizacao;

  const EstatisticasRestaurante({
    required this.restauranteId,
    required this.total,
    required this.stats,
    required this.topEmoji,
    required this.comentariosRecentes,
    this.ultimaAtualizacao,
  });

  factory EstatisticasRestaurante.fromJson(Map<String, dynamic> json) {
    final stats = Map<String, int>.from(json['stats'] ?? {});
    
    return EstatisticasRestaurante(
      restauranteId: json['restaurante_id'] as String,
      total: json['total'] as int? ?? 0,
      stats: stats,
      topEmoji: json['top_emoji'] as String? ?? '',
      comentariosRecentes: (json['comentarios_recentes'] as List<dynamic>? ?? [])
          .map((c) => ComentarioRecente.fromJson(c))
          .toList(),
      ultimaAtualizacao: json['ultima_atualizacao'] != null 
          ? DateTime.parse(json['ultima_atualizacao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurante_id': restauranteId,
      'total': total,
      'stats': stats,
      'top_emoji': topEmoji,
      'comentarios_recentes': comentariosRecentes.map((c) => c.toJson()).toList(),
      'ultima_atualizacao': ultimaAtualizacao?.toIso8601String(),
    };
  }

  /// Retorna o percentual de um emoji específico
  double getPercentual(String emoji) {
    if (total == 0) return 0.0;
    final count = stats[emoji] ?? 0;
    return (count / total) * 100;
  }

  /// Retorna a lista de emojis ordenados por popularidade
  List<MapEntry<String, int>> get emojisOrdenados {
    final entries = stats.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Retorna uma descrição textual da avaliação geral
  String get descricaoGeral {
    if (total == 0) return 'Nenhuma avaliação ainda';
    
    final percentualTop = getPercentual(topEmoji);
    
    if (percentualTop >= 70) {
      return _getDescricaoEmoji(topEmoji, 'excelente');
    } else if (percentualTop >= 50) {
      return _getDescricaoEmoji(topEmoji, 'boa');
    } else if (percentualTop >= 30) {
      return _getDescricaoEmoji(topEmoji, 'variada');
    } else {
      return 'Opiniões bem divididas';
    }
  }

  String _getDescricaoEmoji(String emoji, String intensidade) {
    switch (emoji) {
      case '😋':
        return 'Comida $intensidade';
      case '❤️':
        return 'Experiência $intensidade';
      case '😐':
        return 'Avaliação neutra predominante';
      case '🤢':
        return 'Experiência ruim frequente';
      default:
        return 'Avaliação $intensidade';
    }
  }

  /// Retorna a cor associada ao emoji mais votado
  String get corTopEmoji {
    switch (topEmoji) {
      case '😋':
        return '#4CAF50'; // Verde
      case '❤️':
        return '#E91E63'; // Rosa
      case '😐':
        return '#FF9800'; // Laranja
      case '🤢':
        return '#F44336'; // Vermelho
      default:
        return '#9E9E9E'; // Cinza
    }
  }

  /// Verifica se tem avaliações suficientes para ser confiável
  bool get isConfiavel => total >= 3;

  /// Cria uma instância vazia
  factory EstatisticasRestaurante.vazia(String restauranteId) {
    return EstatisticasRestaurante(
      restauranteId: restauranteId,
      total: 0,
      stats: {},
      topEmoji: '',
      comentariosRecentes: [],
    );
  }

  /// Cria uma cópia com novos valores
  EstatisticasRestaurante copyWith({
    String? restauranteId,
    int? total,
    Map<String, int>? stats,
    String? topEmoji,
    List<ComentarioRecente>? comentariosRecentes,
    DateTime? ultimaAtualizacao,
  }) {
    return EstatisticasRestaurante(
      restauranteId: restauranteId ?? this.restauranteId,
      total: total ?? this.total,
      stats: stats ?? this.stats,
      topEmoji: topEmoji ?? this.topEmoji,
      comentariosRecentes: comentariosRecentes ?? this.comentariosRecentes,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }
}

class ComentarioRecente {
  final String id;
  final String comentario;
  final String emoji;
  final String? nomeUsuario;
  final DateTime dataVisita;

  const ComentarioRecente({
    required this.id,
    required this.comentario,
    required this.emoji,
    this.nomeUsuario,
    required this.dataVisita,
  });

  factory ComentarioRecente.fromJson(Map<String, dynamic> json) {
    return ComentarioRecente(
      id: json['id'] as String,
      comentario: json['comentario'] as String,
      emoji: json['emoji'] as String,
      nomeUsuario: json['nome_usuario'] as String?,
      dataVisita: DateTime.parse(json['data_visita'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comentario': comentario,
      'emoji': emoji,
      'nome_usuario': nomeUsuario,
      'data_visita': dataVisita.toIso8601String(),
    };
  }

  /// Retorna tempo relativo da visita (ex: "há 2 dias")
  String get tempoRelativo {
    final agora = DateTime.now();
    final diferenca = agora.difference(dataVisita);

    if (diferenca.inDays > 30) {
      final meses = (diferenca.inDays / 30).floor();
      return 'há ${meses} ${meses == 1 ? 'mês' : 'meses'}';
    } else if (diferenca.inDays > 7) {
      final semanas = (diferenca.inDays / 7).floor();
      return 'há ${semanas} ${semanas == 1 ? 'semana' : 'semanas'}';
    } else if (diferenca.inDays > 0) {
      return 'há ${diferenca.inDays} ${diferenca.inDays == 1 ? 'dia' : 'dias'}';
    } else if (diferenca.inHours > 0) {
      return 'há ${diferenca.inHours} ${diferenca.inHours == 1 ? 'hora' : 'horas'}';
    } else {
      return 'há poucos minutos';
    }
  }
} 