import 'dart:convert';

/// Modelo para representar o resultado da interpretação de busca pela IA
class BuscaInterpretada {
  final String? tipo;
  final List<String> tags;
  final String? localizacao;
  final double? faixaPreco;
  final String? ambiente;
  final String? horario;
  final Map<String, dynamic> metadados;
  final double confianca;
  final String inputOriginal;

  const BuscaInterpretada({
    this.tipo,
    this.tags = const [],
    this.localizacao,
    this.faixaPreco,
    this.ambiente,
    this.horario,
    this.metadados = const {},
    this.confianca = 1.0,
    required this.inputOriginal,
  });

  /// Factory para criar instância a partir de JSON retornado pela IA
  factory BuscaInterpretada.fromJson(Map<String, dynamic> json, String inputOriginal) {
    return BuscaInterpretada(
      tipo: json['tipo']?.toString(),
      tags: _parseStringList(json['tags']),
      localizacao: json['localizacao']?.toString(),
      faixaPreco: _parseDouble(json['faixaPreco'] ?? json['faixa_preco']),
      ambiente: json['ambiente']?.toString(),
      horario: json['horario']?.toString(),
      metadados: Map<String, dynamic>.from(json['metadados'] ?? json['metadata'] ?? {}),
      confianca: _parseDouble(json['confianca'] ?? json['confidence']) ?? 1.0,
      inputOriginal: inputOriginal,
    );
  }

  /// Helper para parsing de listas de strings
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
    }
    if (value is String) {
      // Tentar fazer parse de string JSON
      try {
        final parsed = jsonDecode(value);
        if (parsed is List) {
          return parsed.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
        }
      } catch (e) {
        // Se falhar, dividir por vírgulas
        return value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
      }
    }
    return [];
  }

  /// Helper para parsing de doubles
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'tags': tags,
      'localizacao': localizacao,
      'faixaPreco': faixaPreco,
      'ambiente': ambiente,
      'horario': horario,
      'metadados': metadados,
      'confianca': confianca,
      'inputOriginal': inputOriginal,
    };
  }

  /// Criar cópia com modificações
  BuscaInterpretada copyWith({
    String? tipo,
    List<String>? tags,
    String? localizacao,
    double? faixaPreco,
    String? ambiente,
    String? horario,
    Map<String, dynamic>? metadados,
    double? confianca,
    String? inputOriginal,
  }) {
    return BuscaInterpretada(
      tipo: tipo ?? this.tipo,
      tags: tags ?? this.tags,
      localizacao: localizacao ?? this.localizacao,
      faixaPreco: faixaPreco ?? this.faixaPreco,
      ambiente: ambiente ?? this.ambiente,
      horario: horario ?? this.horario,
      metadados: metadados ?? this.metadados,
      confianca: confianca ?? this.confianca,
      inputOriginal: inputOriginal ?? this.inputOriginal,
    );
  }

  /// Verificar se a interpretação tem informações suficientes
  bool get temInformacoesSuficientes {
    return tipo != null || tags.isNotEmpty || localizacao != null;
  }

  /// Obter resumo textual da interpretação
  String get resumo {
    final partes = <String>[];
    
    if (tipo != null) partes.add('Tipo: $tipo');
    if (tags.isNotEmpty) partes.add('Tags: ${tags.join(', ')}');
    if (localizacao != null) partes.add('Local: $localizacao');
    if (ambiente != null) partes.add('Ambiente: $ambiente');
    if (faixaPreco != null) partes.add('Preço: R\$ ${faixaPreco!.toStringAsFixed(0)}');
    
    return partes.isEmpty ? 'Busca geral' : partes.join(' | ');
  }

  @override
  String toString() {
    return 'BuscaInterpretada(tipo: $tipo, tags: $tags, localizacao: $localizacao, confianca: $confianca)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is BuscaInterpretada &&
        other.tipo == tipo &&
        _listEquals(other.tags, tags) &&
        other.localizacao == localizacao &&
        other.faixaPreco == faixaPreco &&
        other.ambiente == ambiente &&
        other.horario == horario &&
        other.confianca == confianca &&
        other.inputOriginal == inputOriginal;
  }

  @override
  int get hashCode {
    return Object.hash(
      tipo,
      Object.hashAll(tags),
      localizacao,
      faixaPreco,
      ambiente,
      horario,
      confianca,
      inputOriginal,
    );
  }

  // Helper para comparação de listas
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Exceção para erros na interpretação de busca
class BuscaInterpretacaoException implements Exception {
  final String message;
  final String? inputOriginal;
  final dynamic originalError;

  const BuscaInterpretacaoException(
    this.message, {
    this.inputOriginal,
    this.originalError,
  });

  @override
  String toString() {
    return 'BuscaInterpretacaoException: $message';
  }
}

/// Enum para tipos de confiança na interpretação
enum NivelConfianca {
  baixa(0.0, 0.4, 'Interpretação incerta'),
  media(0.4, 0.7, 'Interpretação razoável'),
  alta(0.7, 1.0, 'Interpretação confiável');

  const NivelConfianca(this.min, this.max, this.descricao);

  final double min;
  final double max;
  final String descricao;

  static NivelConfianca fromValor(double valor) {
    for (final nivel in NivelConfianca.values) {
      if (valor >= nivel.min && valor <= nivel.max) {
        return nivel;
      }
    }
    return NivelConfianca.baixa;
  }
}

/// Classe para cache de interpretações
class CacheBuscaInterpretada {
  static final Map<String, BuscaInterpretada> _cache = {};
  static const int _maxCacheSize = 100;
  static const Duration _cacheDuration = Duration(minutes: 30);
  static final Map<String, DateTime> _cacheTimestamps = {};

  static void adicionar(String input, BuscaInterpretada interpretacao) {
    // Limpar cache se muito grande
    if (_cache.length >= _maxCacheSize) {
      _limparCacheAntigo();
    }

    final key = _gerarChaveCache(input);
    _cache[key] = interpretacao;
    _cacheTimestamps[key] = DateTime.now();
  }

  static BuscaInterpretada? obter(String input) {
    final key = _gerarChaveCache(input);
    final timestamp = _cacheTimestamps[key];
    
    if (timestamp == null || DateTime.now().difference(timestamp) > _cacheDuration) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _cache[key];
  }

  static void limpar() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  static String _gerarChaveCache(String input) {
    return input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static void _limparCacheAntigo() {
    final agora = DateTime.now();
    final chavesParaRemover = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (agora.difference(entry.value) > _cacheDuration) {
        chavesParaRemover.add(entry.key);
      }
    }

    for (final chave in chavesParaRemover) {
      _cache.remove(chave);
      _cacheTimestamps.remove(chave);
    }

    // Se ainda muito grande, remover os mais antigos
    if (_cache.length >= _maxCacheSize) {
      final entradasOrdenadas = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      final quantidadeRemover = _cache.length - (_maxCacheSize ~/ 2);
      for (int i = 0; i < quantidadeRemover && i < entradasOrdenadas.length; i++) {
        final chave = entradasOrdenadas[i].key;
        _cache.remove(chave);
        _cacheTimestamps.remove(chave);
      }
    }
  }

  static Map<String, dynamic> get estatisticas {
    return {
      'tamanhoCache': _cache.length,
      'maxTamanho': _maxCacheSize,
      'duracaoCache': _cacheDuration.inMinutes,
      'entradasExpiradas': _cacheTimestamps.values
          .where((timestamp) => DateTime.now().difference(timestamp) > _cacheDuration)
          .length,
    };
  }
} 