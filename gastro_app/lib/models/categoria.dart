import 'package:flutter/material.dart';
import '../config/app_theme.dart';

enum TipoLocal {
  restaurante('Restaurante'),
  cafe('Café'),
  bar('Bar'),
  lanchonete('Lanchonete'),
  sorveteria('Sorveteria'),
  padaria('Padaria'),
  bistro('Bistrô'),
  pizzaria('Pizzaria'),
  hamburgueria('Hamburgueria'),
  doceria('Doceria');

  const TipoLocal(this.nome);
  final String nome;
}

class Categoria {
  final String id;
  final String nome;
  final String emoji;
  final IconData icone;
  final Color iconeColor;
  final TipoLocal tipoLocal;
  final String queryBusca;
  final String descricao;
  final List<String> tags;
  final LinearGradient gradient;
  final Color primaryColor;
  final String? imagemUrl;

  const Categoria({
    required this.id,
    required this.nome,
    required this.emoji,
    required this.icone,
    required this.iconeColor,
    required this.tipoLocal,
    required this.queryBusca,
    required this.descricao,
    required this.tags,
    required this.gradient,
    required this.primaryColor,
    this.imagemUrl,
  });
}

class CategoriasData {
  static const List<Categoria> categorias = [
    Categoria(
      id: 'jantar_romantico',
      nome: 'Jantar Romântico',
      emoji: '🍷',
      icone: Icons.restaurant_menu,
      iconeColor: Color(0xFFE91E63),
      tipoLocal: TipoLocal.restaurante,
      queryBusca: 'lugar romântico para jantar a dois com ambiente intimista',
      descricao: 'Ambiente perfeito para momentos especiais',
      tags: ['romântico', 'intimista', 'especial', 'jantar'],
      gradient: LinearGradient(
        colors: [Color(0xFF8B4A6B), Color(0xFFE07A5F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF8B4A6B),
    ),
    
    Categoria(
      id: 'cafes_tranquilos',
      nome: 'Cafés Tranquilos',
      emoji: '☕',
      icone: Icons.local_cafe,
      iconeColor: Color(0xFF8B4513),
      tipoLocal: TipoLocal.cafe,
      queryBusca: 'café tranquilo para trabalhar ou conversar',
      descricao: 'Para trabalhar ou relaxar com um bom café',
      tags: ['café', 'tranquilo', 'trabalho', 'wi-fi'],
      gradient: LinearGradient(
        colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF8B4513),
    ),
    
    Categoria(
      id: 'classicos_cidade',
      nome: 'Clássicos da Cidade',
      emoji: '🍝',
      icone: Icons.account_balance,
      iconeColor: Color(0xFFB8860B),
      tipoLocal: TipoLocal.restaurante,
      queryBusca: 'restaurantes tradicionais e clássicos da cidade',
      descricao: 'Tradições culinárias que marcaram a cidade',
      tags: ['tradicional', 'clássico', 'história', 'família'],
      gradient: LinearGradient(
        colors: [Color(0xFFB8860B), Color(0xFFF4A460)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFB8860B),
    ),
    
    Categoria(
      id: 'mata_fome_rapido',
      nome: 'Mata-Fome Rápido',
      emoji: '🍔',
      icone: Icons.fastfood,
      iconeColor: Color(0xFFFF6B35),
      tipoLocal: TipoLocal.lanchonete,
      queryBusca: 'comida rápida e saborosa para matar a fome',
      descricao: 'Solução rápida para a fome do dia a dia',
      tags: ['rápido', 'delivery', 'fast-food', 'prático'],
      gradient: LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFFF6B35),
    ),
    
    Categoria(
      id: 'doces_sobremesas',
      nome: 'Doces & Sobremesas',
      emoji: '🍦',
      icone: Icons.icecream,
      iconeColor: Color(0xFFE91E63),
      tipoLocal: TipoLocal.sorveteria,
      queryBusca: 'lugar para comer sobremesa doce e deliciosa',
      descricao: 'Para satisfazer aquela vontade de doce',
      tags: ['doce', 'sobremesa', 'açaí', 'sorvete', 'torta'],
      gradient: LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFFFC1CC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFE91E63),
    ),
    
    Categoria(
      id: 'brunch_domingo',
      nome: 'Brunch de Domingo',
      emoji: '🍳',
      icone: Icons.brunch_dining,
      iconeColor: Color(0xFFFFC107),
      tipoLocal: TipoLocal.bistro,
      queryBusca: 'brunch delicioso para domingo relaxante',
      descricao: 'Domingo perfeito com brunch caprichado',
      tags: ['brunch', 'domingo', 'café da manhã', 'ovos'],
      gradient: LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFFFFF3C4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFFFC107),
    ),
    
    Categoria(
      id: 'beber_amigos',
      nome: 'Para Beber com os Amigos',
      emoji: '🍻',
      icone: Icons.sports_bar,
      iconeColor: Color(0xFF4CAF50),
      tipoLocal: TipoLocal.bar,
      queryBusca: 'bar descontraído para beber com os amigos',
      descricao: 'Ambiente ideal para se divertir com a galera',
      tags: ['bar', 'amigos', 'bebida', 'descontraído', 'happy hour'],
      gradient: LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF4CAF50),
    ),
    
    Categoria(
      id: 'pet_friendly',
      nome: 'Pet Friendly',
      emoji: '🐶',
      icone: Icons.pets,
      iconeColor: Color(0xFF9C27B0),
      tipoLocal: TipoLocal.restaurante,
      queryBusca: 'restaurante que aceita pets e animais de estimação',
      descricao: 'Lugares que recebem você e seu melhor amigo',
      tags: ['pet friendly', 'cachorro', 'gato', 'animais'],
      gradient: LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF9C27B0),
    ),
    
    Categoria(
      id: 'vegetariano_vegano',
      nome: 'Vegetarianos/Veganos',
      emoji: '🥗',
      icone: Icons.local_florist,
      iconeColor: Color(0xFF4CAF50),
      tipoLocal: TipoLocal.restaurante,
      queryBusca: 'comida vegetariana e vegana saudável',
      descricao: 'Opções deliciosas para quem não come carne',
      tags: ['vegetariano', 'vegano', 'saudável', 'orgânico'],
      gradient: LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF4CAF50),
    ),
  ];

  // Métodos utilitários
  static Categoria? obterPorId(String id) {
    try {
      return categorias.firstWhere((categoria) => categoria.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Categoria> obterPorTag(String tag) {
    return categorias.where((categoria) => 
      categoria.tags.any((t) => t.toLowerCase().contains(tag.toLowerCase()))
    ).toList();
  }

  static List<Categoria> obterPopulares({int limite = 6}) {
    // Por enquanto retorna as primeiras, mas pode ser baseado em analytics
    return categorias.take(limite).toList();
  }

  static List<Categoria> obterRecomendadas({
    required String? tipoPreferido,
    required Set<String> tagsPreferidas,
    int limite = 4,
  }) {
    // Lógica simples de recomendação baseada em preferências
    final recomendadas = <Categoria>[];
    
    // Primeiro, categorias que atendem às tags preferidas
    for (final categoria in categorias) {
      final pontuacao = categoria.tags
          .where((tag) => tagsPreferidas.contains(tag))
          .length;
      
      if (pontuacao > 0) {
        recomendadas.add(categoria);
      }
    }
    
    // Se não temos o suficiente, adicionar outras populares
    if (recomendadas.length < limite) {
      final restantes = categorias
          .where((c) => !recomendadas.contains(c))
          .take(limite - recomendadas.length);
      recomendadas.addAll(restantes);
    }
    
    return recomendadas.take(limite).toList();
  }
}

// Enum para diferentes tipos de exibição das categorias
enum CategoriaDisplayMode {
  carrossel,
  grid,
  lista,
}

// Configurações para personalização da exibição
class CategoriaConfig {
  final CategoriaDisplayMode displayMode;
  final bool mostrarDescricao;
  final bool mostrarEmoji;
  final double cardWidth;
  final double cardHeight;
  final EdgeInsets margin;
  final bool enableAnimations;

  const CategoriaConfig({
    this.displayMode = CategoriaDisplayMode.carrossel,
    this.mostrarDescricao = true,
    this.mostrarEmoji = true,
    this.cardWidth = 160,
    this.cardHeight = 120,
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
    this.enableAnimations = true,
  });

  CategoriaConfig copyWith({
    CategoriaDisplayMode? displayMode,
    bool? mostrarDescricao,
    bool? mostrarEmoji,
    double? cardWidth,
    double? cardHeight,
    EdgeInsets? margin,
    bool? enableAnimations,
  }) {
    return CategoriaConfig(
      displayMode: displayMode ?? this.displayMode,
      mostrarDescricao: mostrarDescricao ?? this.mostrarDescricao,
      mostrarEmoji: mostrarEmoji ?? this.mostrarEmoji,
      cardWidth: cardWidth ?? this.cardWidth,
      cardHeight: cardHeight ?? this.cardHeight,
      margin: margin ?? this.margin,
      enableAnimations: enableAnimations ?? this.enableAnimations,
    );
  }
}