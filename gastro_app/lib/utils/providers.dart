import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/restaurante.dart';
import '../models/usuario.dart';
import '../models/estatisticas_restaurante.dart';
import '../services/restaurante_service.dart';
import '../services/usuario_service.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import '../services/experiencia_service.dart';
import '../services/localizacao_service.dart';
import '../services/estatisticas_service.dart';

// ============================================
// ENUMS E TIPOS AUXILIARES
// ============================================

// NOTA: StatusLocalizacao e DistanciaInfo são importados de localizacao_service.dart
typedef LocalizacaoStatus = StatusLocalizacao;

/// Classe para encapsular restaurante com sua distância calculada
class RestauranteComDistancia {
  final Restaurante restaurante;
  final double distancia;

  const RestauranteComDistancia(this.restaurante, this.distancia);
  
  /// Retorna informações de distância formatadas
  DistanciaInfo get distanciaInfo => LocalizacaoService.getDistanciaInfo(distancia);
  
  /// Retorna distância formatada para exibição
  String get distanciaFormatada => LocalizacaoService.formatarDistancia(distancia);
}

// ============================================
// PROVIDERS DE AUTENTICAÇÃO
// ============================================

/// Provider para o estado de autenticação (stream do Supabase)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateChanges;
});

/// Provider para o usuário atual autenticado
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider para verificar se usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Provider para dados completos do usuário atual (da tabela usuarios)
final usuarioAtualProvider = FutureProvider<Usuario?>((ref) async {
  final authUser = ref.watch(currentUserProvider);
  if (authUser == null) return null;
  
  try {
    return await UsuarioService.obterUsuarioAtual();
  } catch (e) {
    return null;
  }
});

// ============================================
// PROVIDERS DE GEOLOCALIZAÇÃO
// ============================================

/// Provider para status da localização
final statusLocalizacaoProvider = StateProvider<StatusLocalizacao>((ref) => StatusLocalizacao.desconhecido);

/// Provider para localização atual do usuário
final localizacaoAtualProvider = StateProvider<Map<String, double>?>((ref) => null);

/// Provider para raio de busca selecionado pelo usuário (em km)
final raioBuscaProvider = StateProvider<double>((ref) => 5.0);

/// Provider para verificar se está usando localização fallback
final usandoFallbackProvider = StateProvider<bool>((ref) => false);

/// Provider para obter localização (atual ou fallback) - SIMPLIFICADO
final obterLocalizacaoProvider = FutureProvider<Map<String, double>>((ref) async {
  try {
    final position = await LocalizacaoService.getCurrentPosition();
    
    if (position != null) {
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } else {
      // Usar fallback sem modificar outros providers
      return LocalizacaoService.getFallbackLocation();
    }
  } catch (e) {
    // Em caso de erro, usar fallback
    return LocalizacaoService.getFallbackLocation();
  }
});

/// Helper para inicializar localização de forma segura
class LocalizacaoManager {
  static Future<void> inicializarLocalizacao(WidgetRef ref) async {
    ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.obtendo;
    
    try {
      final position = await LocalizacaoService.getCurrentPosition();
      
      if (position != null) {
        final location = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
        
        ref.read(localizacaoAtualProvider.notifier).state = location;
        ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.obtida;
        ref.read(usandoFallbackProvider.notifier).state = false;
      } else {
        final fallbackLocation = LocalizacaoService.getFallbackLocation();
        ref.read(localizacaoAtualProvider.notifier).state = fallbackLocation;
        ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.fallback;
        ref.read(usandoFallbackProvider.notifier).state = true;
      }
    } catch (e) {
      final fallbackLocation = LocalizacaoService.getFallbackLocation();
      ref.read(localizacaoAtualProvider.notifier).state = fallbackLocation;
      ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.erro;
      ref.read(usandoFallbackProvider.notifier).state = true;
    }
  }
}

/// Provider para configurações de distância (NOVO - corrige erro)
final configuracaoDistanciaProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'raioMaximo': 10.0,
    'unidade': 'km',
    'mostrarCirculo': true,
  };
});

// ============================================
// PROVIDERS DE RESTAURANTES  
// ============================================

/// Provider para todos os restaurantes disponíveis
final todosRestaurantesProvider = FutureProvider<List<Restaurante>>((ref) async {
  return await RestauranteService.obterTodos();
});

/// Provider para restaurantes próximos baseado na localização e raio
final restaurantesProximosProvider = FutureProvider<List<RestauranteComDistancia>>((ref) async {
  final localizacao = ref.watch(localizacaoAtualProvider);
  final raio = ref.watch(raioBuscaProvider);
  
  // Se não tem localização, usar fallback
  final localizacaoFinal = localizacao ?? LocalizacaoService.getFallbackLocation();
  
  try {
    // Buscar todos os restaurantes
    final todosRestaurantes = await RestauranteService.obterTodos();
    
    // Filtrar e ordenar por proximidade
    final restaurantesComDistancia = todosRestaurantes
        .map((restaurante) {
          final distancia = LocalizacaoService.calcularDistancia(
            localizacaoFinal['latitude']!,
            localizacaoFinal['longitude']!,
            restaurante.latitude,
            restaurante.longitude,
          );
          return RestauranteComDistancia(restaurante, distancia);
        })
        .where((item) => item.distancia <= raio)
        .toList();

    // Ordenar por distância
    restaurantesComDistancia.sort((a, b) => a.distancia.compareTo(b.distancia));
    
    return restaurantesComDistancia;
  } catch (e) {
    return [];
  }
});

/// Provider para restaurantes filtrados por distância (NOVO - corrige erro)
final restaurantesFiltradosPorDistanciaProvider = Provider.family<List<Restaurante>, List<Restaurante>>((ref, restaurantes) {
  final configuracao = ref.watch(configuracaoDistanciaProvider);
  final localizacao = ref.watch(localizacaoAtualProvider);
  final raioMaximo = configuracao['raioMaximo'] as double;
  
  if (localizacao == null) return restaurantes;
  
  return restaurantes.where((restaurante) {
    final distancia = LocalizacaoService.calcularDistancia(
      localizacao['latitude']!,
      localizacao['longitude']!,
      restaurante.latitude,
      restaurante.longitude,
    );
    return distancia <= raioMaximo;
  }).toList();
});

/// Provider para restaurantes com filtros aplicados
final restaurantesFiltradosProvider = FutureProvider<List<Restaurante>>((ref) async {
  final filtros = ref.watch(filtrosBuscaProvider);
  final localizacao = ref.watch(localizacaoAtualProvider);
  
  return await RestauranteService.buscarComFiltros(
    categoria: filtros['categoria'],
    distanciaMaxima: filtros['distanciaMaxima'],
    latitude: localizacao?['latitude'],
    longitude: localizacao?['longitude'],
    precoMin: filtros['precoMin'],
    precoMax: filtros['precoMax'],
    avaliacaoMinima: filtros['avaliacao'],
    tags: filtros['tags'],
  );
});

/// Provider para restaurantes filtrados por categoria
final restaurantesCategoriaProvider = FutureProvider.family<List<Restaurante>, String>((ref, categoria) async {
  return await RestauranteService.buscarComFiltros(categoria: categoria);
});

/// Provider para filtros de busca
final filtrosBuscaProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'categoria': null,
    'distanciaMaxima': 10.0,
    'precoMin': null,
    'precoMax': null,
    'avaliacao': null,
    'tags': null,
  };
});

// ============================================
// PROVIDERS DE FAVORITOS (PROTEGIDOS)
// ============================================

/// Provider para controle de estado local dos favoritos (StateProvider)
final favoritosProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Provider para IDs dos restaurantes favoritos do usuário
final favoritosIdsProvider = FutureProvider<Set<String>>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return <String>{};
  
  try {
    return await UsuarioService.obterFavoritos();
  } catch (e) {
    return <String>{};
  }
});

/// Provider para lista completa dos restaurantes favoritos
final restaurantesFavoritosProvider = FutureProvider<List<Restaurante>>((ref) async {
  final favoritosIds = await ref.watch(favoritosIdsProvider.future);
  if (favoritosIds.isEmpty) return <Restaurante>[];
  
  try {
    return await RestauranteService.obterPorIds(favoritosIds.toList());
  } catch (e) {
    return <Restaurante>[];
  }
});

/// Provider para verificar se um restaurante específico é favorito
final isFavoritoProvider = Provider.family<bool, String>((ref, restauranteId) {
  final favoritos = ref.watch(favoritosProvider);
  return favoritos.contains(restauranteId);
});

/// Provider para controle de loading de favoritos
final loadingFavoritoProvider = StateProvider.family<bool, String>((ref, restauranteId) => false);

// ============================================
// PROVIDERS DE EXPERIÊNCIAS (PROTEGIDOS)
// ============================================

/// Provider para experiências do usuário
final experienciasUsuarioProvider = FutureProvider<List<dynamic>>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return [];
  
  try {
    return await ExperienciaService.obterExperienciasUsuario();
  } catch (e) {
    return [];
  }
});

/// Provider para experiência específica de um restaurante
final experienciaRestauranteProvider = FutureProvider.family<dynamic, String>((ref, restauranteId) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return null;
  
  try {
    return await ExperienciaService.obterExperienciaRestaurante(restauranteId);
  } catch (e) {
    return null;
  }
});

/// Provider para experiências recentes
final experienciasRecentesProvider = FutureProvider<List<dynamic>>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return [];
  
  try {
    return await ExperienciaService.obterExperienciasUsuario();
  } catch (e) {
    return [];
  }
});

// ============================================
// PROVIDERS DE ESTATÍSTICAS DE RESTAURANTES
// ============================================

/// Provider para estatísticas de um restaurante específico
final estatisticasRestauranteProvider = FutureProvider.family<EstatisticasRestaurante, String>((ref, restauranteId) async {
  return await EstatisticasService.obterEstatisticas(restauranteId);
});

/// Provider para estatísticas globais do app
final estatisticasGlobaisProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await EstatisticasService.obterEstatisticasGlobais();
});

// ============================================
// PROVIDERS DE BUSCA SIMPLIFICADA
// ============================================

/// Provider para estado da busca (SIMPLIFICADO)
final estadoBuscaProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'loading': false,
    'resultados': <Restaurante>[],
    'temResultados': false,
    'buscaFeita': false,
    'erro': null,
  };
});

/// Provider para análise de IA da busca (SIMPLIFICADO)
final analiseIAProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider para histórico de buscas
final historicoBuscasProvider = StateProvider<List<String>>((ref) {
  return [];
});

/// Provider para sugestões de busca
final sugestoesBuscaProvider = StateProvider<List<String>>((ref) {
  return [
    'Restaurante romântico para jantar',
    'Comida japonesa próxima',
    'Café para trabalhar',
    'Brunch no domingo',
    'Pizza delivery',
    'Comida saudável',
  ];
});

// ============================================
// PROVIDERS DE CONFIGURAÇÃO
// ============================================

/// Provider para configurações gerais
final configuracoesProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'raioAtual': 10.0,
    'unidadeDistancia': 'km',
    'ordemPadrao': 'distancia',
    'mostrarApenasAbertos': false,
  };
});

// ============================================
// PROVIDERS DE SERVIÇOS SIMPLIFICADOS
// ============================================

/// Provider para serviço de usuário
final usuarioServiceProvider = Provider<UsuarioService>((ref) => UsuarioService());

/// Provider para serviço de experiências (alias para compatibilidade)  
final experienciasProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(experienciasUsuarioProvider.future);
});

/// Provider para contagem de restaurantes por faixa de distância
final estatisticasProximidadeProvider = Provider<Map<String, int>>((ref) {
  final restaurantesProximos = ref.watch(restaurantesProximosProvider);
  
  return restaurantesProximos.when(
    data: (restaurantes) {
      int muitoProximo = 0; // <= 1km
      int proximo = 0; // 1-3km  
      int distante = 0; // > 3km
      
      for (final item in restaurantes) {
        if (item.distancia <= 1.0) {
          muitoProximo++;
        } else if (item.distancia <= 3.0) {
          proximo++;
        } else {
          distante++;
        }
      }
      
      return {
        'muitoProximo': muitoProximo,
        'proximo': proximo,
        'distante': distante,
        'total': restaurantes.length,
      };
    },
    loading: () => {
      'muitoProximo': 0,
      'proximo': 0,
      'distante': 0,
      'total': 0,
    },
    error: (_, __) => {
      'muitoProximo': 0,
      'proximo': 0,
      'distante': 0,
      'total': 0,
    },
  );
}); 

// ============================================
// PROVIDERS PARA COMPATIBILIDADE (CORREÇÃO DOS ERROS)
// ============================================

/// Provider para atualizar estatísticas (compatibilidade)
final atualizarEstatisticasProvider = Provider<Future<void> Function(String, String, String)>((ref) {
  return (String restauranteId, String emoji, String comentario) async {
    // Atualizar estatísticas do restaurante
    ref.invalidate(estatisticasRestauranteProvider);
    // Invalidar providers relacionados
    ref.invalidate(experienciaRestauranteProvider(restauranteId));
  };
});

/// Provider para invalidar estatísticas (compatibilidade)  
final invalidarEstatisticasProvider = Provider<void Function(String)>((ref) {
  return (String restauranteId) {
    // Invalidar estatísticas do restaurante específico
    ref.invalidate(estatisticasRestauranteProvider);
    ref.invalidate(experienciaRestauranteProvider(restauranteId));
  };
}); 