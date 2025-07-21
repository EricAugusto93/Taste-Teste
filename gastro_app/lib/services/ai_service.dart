import 'dart:math';

/// Serviço de IA Simplificado para MVP
/// 
/// Versão simplificada que usa apenas lógica de palavras-chave
/// para interpretar buscas gastronômicas
class AiService {
  /// Processar busca por desejo (versão simplificada)
  static Future<Map<String, dynamic>> processarBuscaPorDesejo(String input) async {
    // Simula delay para UX consistente
    await Future.delayed(const Duration(milliseconds: 400));
    
    return _processarBuscaSimplificada(input);
  }

  /// Versão simplificada da interpretação de busca
  static Future<Map<String, dynamic>> _processarBuscaSimplificada(String input) async {
    String inputLowerCase = input.toLowerCase().trim();
    
    // Mapas de palavras-chave simplificados
    Map<String, String> tiposMap = {
      'café': 'café',
      'coffee': 'café',
      'cafeteria': 'café',
      'pizza': 'pizzaria',
      'pizzaria': 'pizzaria',
      'bar': 'bar',
      'cerveja': 'bar',
      'chopp': 'bar',
      'sushi': 'japonesa',
      'japonês': 'japonesa',
      'japonesa': 'japonesa',
      'chinês': 'chinesa',
      'chinesa': 'chinesa',
      'vegano': 'vegetariano',
      'vegetariano': 'vegetariano',
      'saudável': 'vegetariano',
      'restaurante': 'restaurante',
      'hambúrguer': 'hamburgueria',
      'hamburgueria': 'hamburgueria',
      'lanche': 'hamburgueria',
      'doce': 'sorveteria',
      'sorvete': 'sorveteria',
    };
    
    Map<String, List<String>> tagsMap = {
      'tranquilo': ['romântico', 'casual'],
      'calmo': ['romântico', 'casual'],
      'romântico': ['romântico'],
      'família': ['família'],
      'criança': ['família'],
      'ar livre': ['ao ar livre'],
      'pet': ['pet friendly'],
      'wifi': ['Wi-Fi'],
      'trabalhar': ['Wi-Fi', 'casual'],
      'estudar': ['Wi-Fi', 'casual'],
      'premium': ['premium'],
      'luxo': ['premium'],
      'caro': ['premium'],
      'barato': ['casual'],
      'artesanal': ['pizza artesanal'],
      'orgânico': ['orgânico'],
      'happy hour': ['happy hour'],
      'rápido': ['fast-food'],
    };
    
    Map<String, String> localizacaoMap = {
      'centro': 'Centro',
      'vila madalena': 'Vila Madalena',
      'pinheiros': 'Pinheiros',
      'itaim': 'Itaim',
      'jardins': 'Jardins',
      'moema': 'Moema',
      'brooklin': 'Brooklin',
      'vila olimpia': 'Vila Olímpia',
    };
    
    // Detectar tipo
    String? tipoDetectado;
    for (String palavra in tiposMap.keys) {
      if (inputLowerCase.contains(palavra)) {
        tipoDetectado = tiposMap[palavra];
        break;
      }
    }
    
    // Detectar tags
    List<String> tagsDetectadas = [];
    for (String palavra in tagsMap.keys) {
      if (inputLowerCase.contains(palavra)) {
        tagsDetectadas.addAll(tagsMap[palavra]!);
      }
    }
    
    // Detectar localização
    String? localizacaoDetectada;
    for (String palavra in localizacaoMap.keys) {
      if (inputLowerCase.contains(palavra)) {
        localizacaoDetectada = localizacaoMap[palavra];
        break;
      }
    }

    // Detectar ambiente
    String? ambienteDetectado;
    if (inputLowerCase.contains('romântico') || inputLowerCase.contains('íntimo')) {
      ambienteDetectado = 'romântico';
    } else if (inputLowerCase.contains('família') || inputLowerCase.contains('criança')) {
      ambienteDetectado = 'familiar';
    } else if (inputLowerCase.contains('tranquilo') || inputLowerCase.contains('calmo')) {
      ambienteDetectado = 'tranquilo';
    }

    // Detectar faixa de preço
    double? faixaPreco;
    if (inputLowerCase.contains('barato') || inputLowerCase.contains('econômico')) {
      faixaPreco = 25.0;
    } else if (inputLowerCase.contains('médio')) {
      faixaPreco = 50.0;
    } else if (inputLowerCase.contains('caro') || inputLowerCase.contains('premium')) {
      faixaPreco = 100.0;
    }

    // Detectar horário
    String? horarioDetectado;
    if (inputLowerCase.contains('manhã') || inputLowerCase.contains('café da manhã')) {
      horarioDetectado = 'manhã';
    } else if (inputLowerCase.contains('almoço')) {
      horarioDetectado = 'almoço';
    } else if (inputLowerCase.contains('jantar') || inputLowerCase.contains('noite')) {
      horarioDetectado = 'noite';
    }
    
    // Adicionar sugestões padrão se não detectou nada
    if (tipoDetectado == null && tagsDetectadas.isEmpty) {
      _adicionarSugestoesPadrao(inputLowerCase, tagsDetectadas);
    }
    
    // Calcular confiança baseada em detecções
    double confianca = 0.0;
    if (tipoDetectado != null) confianca += 0.4;
    if (tagsDetectadas.isNotEmpty) confianca += 0.3;
    if (localizacaoDetectada != null) confianca += 0.2;
    if (ambienteDetectado != null) confianca += 0.1;
    confianca = (confianca * 100).clamp(30.0, 95.0);
    
    return {
      'tipo': tipoDetectado,
      'tags': tagsDetectadas.toSet().toList(),
      'localizacao': localizacaoDetectada,
      'ambiente': ambienteDetectado,
      'faixaPreco': faixaPreco,
      'horario': horarioDetectado,
      'input_original': input,
      'confianca': confianca,
      'metadados': {
        'provider': 'simplificado',
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }
  
  /// Adicionar sugestões padrão baseadas no contexto
  static void _adicionarSugestoesPadrao(String input, List<String> tags) {
    // Se mencionar comida/comer, adicionar tag casual
    if (input.contains('comer') || input.contains('comida') || input.contains('fome')) {
      tags.add('casual');
    }
    
    // Se mencionar bebida, adicionar contexto social
    if (input.contains('beber') || input.contains('bebida')) {
      tags.add('social');
    }
    
    // Se mencionar encontro, adicionar contexto romântico
    if (input.contains('encontro') || input.contains('date')) {
      tags.add('romântico');
    }
  }

  /// Estatísticas simplificadas (para compatibilidade)
  static Map<String, dynamic> get estatisticas {
    return {
      'provider': 'Simplificado',
      'isConfigured': true,
      'mode': 'keyword_matching',
      'version': '1.0.0',
    };
  }

  /// Limpar estado (placeholder para compatibilidade)
  static void limparEstado() {
    // Placeholder - não há estado para limpar
  }

  /// Cancelar operações (placeholder para compatibilidade)
  static void cancelarOperacoes() {
    // Placeholder - não há operações para cancelar
  }
} 