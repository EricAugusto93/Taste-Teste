import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

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
    data: (state) {
      final user = state.session?.user;
      print('👤 [currentUserProvider] AuthState data - User: ${user?.id ?? 'null'}');
      return user;
    },
    loading: () {
      print('⏳ [currentUserProvider] AuthState loading');
      return null;
    },
    error: (error, stack) {
      print('❌ [currentUserProvider] AuthState error: $error');
      return null;
    },
  );
});

/// Provider para verificar se usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final isAuth = user != null;
  print('🔐 [isAuthenticatedProvider] User: ${user?.id ?? 'null'}, isAuth: $isAuth');
  return isAuth;
});

/// Provider para dados completos do usuário atual (da tabela usuarios)
final usuarioAtualProvider = FutureProvider<Usuario?>((ref) async {
  final authUser = ref.watch(currentUserProvider);
  if (authUser == null) return null;
  
  try {
    // Tentar obter usuário existente
    var usuario = await UsuarioService.obterUsuarioAtual();
    
    // Se não existe, sincronizar automaticamente
    if (usuario == null) {
      debugPrint('🔄 Usuário não encontrado na tabela, sincronizando...');
      usuario = await UsuarioService.sincronizarUsuario();
      debugPrint('✅ Usuário sincronizado: ${usuario.email}');
    }
    
    return usuario;
  } catch (e) {
    debugPrint('❌ Erro no usuarioAtualProvider: $e');
    
    // Tentar sincronizar como fallback
    try {
      debugPrint('🔄 Tentando sincronização de emergência...');
      final usuario = await UsuarioService.sincronizarUsuario();
      debugPrint('✅ Sincronização de emergência bem-sucedida');
      return usuario;
    } catch (syncError) {
      debugPrint('❌ Erro na sincronização de emergência: $syncError');
      return null;
    }
  }
});

// ============================================
// PROVIDERS DE GEOLOCALIZAÇÃO
// ============================================

/// Provider para status da localização
final statusLocalizacaoProvider = StateProvider<StatusLocalizacao>((ref) => StatusLocalizacao.inicial);

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
  static const double _distanciaMinimaMudanca = 0.1; // 100 metros
  
  static Future<void> inicializarLocalizacao(WidgetRef ref) async {
    try {
      final statusAtual = ref.read(statusLocalizacaoProvider);
      
      // Evitar re-inicialização se já está obtendo
      if (statusAtual == StatusLocalizacao.obtendo) {
        return;
      }
      
      ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.obtendo;
      
      final position = await LocalizacaoService.getCurrentPosition();
      
      if (position != null) {
        final novaLocalizacao = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
        
        // Verificar se a localização mudou significativamente
        final localizacaoAtual = ref.read(localizacaoAtualProvider);
        bool deveAtualizar = true;
        
        if (localizacaoAtual != null) {
          final distancia = LocalizacaoService.calcularDistancia(
            localizacaoAtual['latitude']!,
            localizacaoAtual['longitude']!,
            position.latitude,
            position.longitude,
          );
          
          // Só atualizar se a mudança for significativa
          deveAtualizar = distancia >= _distanciaMinimaMudanca;
        }
        
        try {
          if (deveAtualizar) {
            ref.read(localizacaoAtualProvider.notifier).state = novaLocalizacao;
          }
          ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.obtida;
          ref.read(usandoFallbackProvider.notifier).state = false;
        } catch (e) {
          // Widget foi disposed durante a operação, ignora silenciosamente
          return;
        }
      } else {
        final fallbackLocation = LocalizacaoService.getFallbackLocation();
        try {
          ref.read(localizacaoAtualProvider.notifier).state = fallbackLocation;
          ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.fallback;
          ref.read(usandoFallbackProvider.notifier).state = true;
        } catch (e) {
          // Widget foi disposed durante a operação, ignora silenciosamente
          return;
        }
      }
    } catch (e) {
      try {
        final fallbackLocation = LocalizacaoService.getFallbackLocation();
        ref.read(localizacaoAtualProvider.notifier).state = fallbackLocation;
        ref.read(statusLocalizacaoProvider.notifier).state = StatusLocalizacao.erro;
        ref.read(usandoFallbackProvider.notifier).state = true;
      } catch (e) {
        // Widget foi disposed durante a operação, ignora silenciosamente
        return;
      }
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

/// Provider para todos os restaurantes
final todosRestaurantesProvider = FutureProvider<List<Restaurante>>((ref) async {
  print('🔍 [todosRestaurantesProvider] Iniciando busca de restaurantes...');
  try {
    final restaurantes = await RestauranteService.obterTodos();
    print('🔍 [todosRestaurantesProvider] Restaurantes carregados: ${restaurantes.length}');
    return restaurantes;
  } catch (e) {
    print('🔍 [todosRestaurantesProvider] Erro ao carregar restaurantes: $e');
    rethrow;
  }
});

/// Provider para todos os restaurantes com distância calculada (cache)
final restaurantesComDistanciaProvider = FutureProvider<List<RestauranteComDistancia>>((ref) async {
  final localizacao = ref.watch(localizacaoAtualProvider);
  final todosRestaurantesAsync = ref.watch(todosRestaurantesProvider);
  
  print('🔍 [restaurantesComDistanciaProvider] Localização: $localizacao');
  
  // Se não tem localização, usar fallback
  final localizacaoFinal = localizacao ?? LocalizacaoService.getFallbackLocation();
  
  print('🔍 [restaurantesComDistanciaProvider] Localização final: $localizacaoFinal');
  
  return todosRestaurantesAsync.when(
    data: (todosRestaurantes) {
      try {
        print('🔍 [restaurantesComDistanciaProvider] Todos os restaurantes: ${todosRestaurantes.length}');
        
        // Calcular distância uma vez e cachear
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
            .toList();

        // Ordenar por distância uma vez
        restaurantesComDistancia.sort((a, b) => a.distancia.compareTo(b.distancia));
        
        print('🔍 [restaurantesComDistanciaProvider] Restaurantes com distância calculada: ${restaurantesComDistancia.length}');
        
        return restaurantesComDistancia;
      } catch (e) {
        print('🔍 [restaurantesComDistanciaProvider] Erro: $e');
        debugPrint('Erro em restaurantesComDistanciaProvider: $e');
        return <RestauranteComDistancia>[];
      }
    },
    loading: () {
      print('🔍 [restaurantesComDistanciaProvider] Estado: Loading');
      return <RestauranteComDistancia>[];
    },
    error: (error, stack) {
      print('🔍 [restaurantesComDistanciaProvider] Erro: $error');
      return <RestauranteComDistancia>[];
    },
  );
});

/// Provider para restaurantes próximos filtrados por raio (otimizado)
final restaurantesProximosProvider = Provider<AsyncValue<List<RestauranteComDistancia>>>((ref) {
  final raio = ref.watch(raioBuscaProvider);
  final restaurantesComDistanciaAsync = ref.watch(restaurantesComDistanciaProvider);
  
  print('🔍 [restaurantesProximosProvider] Raio atual: ${raio}km');
  
  return restaurantesComDistanciaAsync.when(
    data: (restaurantesComDistancia) {
      print('🔍 [restaurantesProximosProvider] Restaurantes com distância: ${restaurantesComDistancia.length}');
      
      // Filtrar apenas por raio (sem recalcular distâncias)
      final restaurantesFiltrados = restaurantesComDistancia
          .where((item) => item.distancia <= raio)
          .toList();
      
      print('🔍 [restaurantesProximosProvider] Após filtro por raio (${raio}km): ${restaurantesFiltrados.length}');
      
      // Log das primeiras 3 distâncias para debug
      if (restaurantesComDistancia.isNotEmpty) {
        print('🔍 [restaurantesProximosProvider] Primeiras distâncias:');
        for (int i = 0; i < math.min(3, restaurantesComDistancia.length); i++) {
          final item = restaurantesComDistancia[i];
          print('  - ${item.restaurante.nome}: ${item.distancia.toStringAsFixed(2)}km');
        }
      }
      
      return AsyncValue.data(restaurantesFiltrados);
    },
    loading: () {
      print('🔍 [restaurantesProximosProvider] Estado: Loading');
      return const AsyncValue.loading();
    },
    error: (error, stack) {
      print('🔍 [restaurantesProximosProvider] Erro: $error');
      return AsyncValue.error(error, stack);
    },
  );
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

/// Provider para conjunto de IDs de restaurantes favoritos do usuário
final favoritosProvider = StateProvider<Set<String>>((ref) {
  return <String>{};
});

/// Provider para carregar favoritos do usuário autenticado
final carregarFavoritosProvider = FutureProvider<Set<String>>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) {
    return <String>{};
  }
  
  try {
    final favoritos = await UsuarioService.obterFavoritos();
    return favoritos.toSet();
  } catch (e) {
    debugPrint('Erro ao carregar favoritos: $e');
    return <String>{};
  }
});

/// Provider para favoritos do usuário (atualizado automaticamente)
final favoritosAtualizadosProvider = Provider<Set<String>>((ref) {
  final favoritosCarregados = ref.watch(carregarFavoritosProvider);
  return favoritosCarregados.when(
    data: (favoritos) => favoritos,
    loading: () => <String>{},
    error: (_, __) => <String>{},
  );
});

/// Provider para ações de favoritos (adicionar/remover)
final favoritosActionsProvider = Provider<FavoritosActions>((ref) {
  return FavoritosActions(ref);
});

/// Classe para gerenciar ações de favoritos
class FavoritosActions {
  final ProviderRef ref;
  
  FavoritosActions(this.ref);
  
  Future<void> toggleFavorito(String restauranteId) async {
    try {
      final usuarioAtual = ref.read(usuarioAtualProvider);
      final usuario = usuarioAtual.value;
      
      if (usuario == null) {
        throw Exception('Usuário não autenticado');
      }
      
      final favoritos = ref.read(favoritosAtualizadosProvider);
      
      if (favoritos.contains(restauranteId)) {
        await UsuarioService.removerFavorito(usuario.id, restauranteId);
      } else {
        await UsuarioService.adicionarFavorito(usuario.id, restauranteId);
      }
      
      // Invalidar providers para recarregar dados
      ref.invalidate(carregarFavoritosProvider);
      ref.invalidate(restaurantesFavoritosProvider);
    } catch (e) {
      debugPrint('Erro ao alterar favorito: $e');
      rethrow;
    }
  }
  
  Future<void> adicionarFavorito(String restauranteId) async {
    try {
      final usuarioAtual = ref.read(usuarioAtualProvider);
      final usuario = usuarioAtual.value;
      
      if (usuario == null) {
        throw Exception('Usuário não autenticado');
      }
      
      await UsuarioService.adicionarFavorito(usuario.id, restauranteId);
      ref.invalidate(carregarFavoritosProvider);
      ref.invalidate(restaurantesFavoritosProvider);
    } catch (e) {
      debugPrint('Erro ao adicionar favorito: $e');
      rethrow;
    }
  }
  
  Future<void> removerFavorito(String restauranteId) async {
    try {
      final usuarioAtual = ref.read(usuarioAtualProvider);
      final usuario = usuarioAtual.value;
      
      if (usuario == null) {
        throw Exception('Usuário não autenticado');
      }
      
      await UsuarioService.removerFavorito(usuario.id, restauranteId);
      ref.invalidate(carregarFavoritosProvider);
      ref.invalidate(restaurantesFavoritosProvider);
    } catch (e) {
      debugPrint('Erro ao remover favorito: $e');
      rethrow;
    }
  }
}

/// Provider para lista de restaurantes favoritos
final restaurantesFavoritosProvider = FutureProvider<List<Restaurante>>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return <Restaurante>[];
  
  try {
    // Obter IDs dos favoritos
    final favoritosIds = await UsuarioService.obterFavoritos();
    if (favoritosIds.isEmpty) return <Restaurante>[];
    
    // Buscar restaurantes pelos IDs
    return await RestauranteService.obterPorIds(favoritosIds.toList());
  } catch (e) {
    debugPrint('Erro ao carregar restaurantes favoritos: $e');
    return <Restaurante>[];
  }
});

/// Provider para verificar se um restaurante específico é favorito
final isFavoritoProvider = Provider.family<bool, String>((ref, restauranteId) {
  try {
    final favoritos = ref.watch(favoritosAtualizadosProvider);
    return favoritos.contains(restauranteId);
  } catch (e) {
    debugPrint('Erro ao verificar favorito: $e');
    return false;
  }
});

/// Provider para controle de loading de favoritos
final loadingFavoritoProvider = StateProvider.family<bool, String>((ref, restauranteId) => false);

// ============================================
// PROVIDERS DE EXPERIÊNCIAS (PROTEGIDOS)
// ============================================

/// Provider para experiências do usuário
final experienciasUsuarioProvider = FutureProvider<List<dynamic>>((ref) async {
  print('🔄 [experienciasUsuarioProvider] Carregando experiências...');
  print('⏰ [experienciasUsuarioProvider] Timestamp: ${DateTime.now()}');
  
  final isAuth = ref.watch(isAuthenticatedProvider);
  print('🔐 [experienciasUsuarioProvider] isAuthenticated: $isAuth');
  
  if (!isAuth) {
    print('❌ [experienciasUsuarioProvider] Usuário não autenticado');
    return [];
  }
  
  try {
    print('🚀 [experienciasUsuarioProvider] Iniciando busca de experiências...');
    final experiencias = await ExperienciaService.obterExperienciasUsuario();
    print('✅ [experienciasUsuarioProvider] Experiências carregadas: ${experiencias.length}');
    
    // Log detalhado das experiências
    for (int i = 0; i < experiencias.length; i++) {
      final exp = experiencias[i];
      print('📋 [experienciasUsuarioProvider] Exp $i: ${exp.experiencia?.emoji ?? 'N/A'} - ${exp.restaurante?.nome ?? 'N/A'}');
    }
    
    return experiencias;
  } catch (e, stackTrace) {
    print('❌ [experienciasUsuarioProvider] Erro ao carregar experiências: $e');
    print('🔍 [experienciasUsuarioProvider] Stack: $stackTrace');
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
  final experiencias = ref.watch(experienciasUsuarioProvider);
  return experiencias.when(
    data: (data) => data,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider para contagem de restaurantes por faixa de distância (otimizado)
final estatisticasProximidadeProvider = Provider<Map<String, int>>((ref) {
  final restaurantesProximosAsync = ref.watch(restaurantesProximosProvider);
  
  return restaurantesProximosAsync.when(
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

/// Provider para sugestões próximas (versão otimizada)
final sugestoesProximasProvider = Provider<AsyncValue<List<Restaurante>>>((ref) {
  try {
    // Usar os restaurantes com distância já calculados
    final restaurantesComDistanciaAsync = ref.watch(restaurantesComDistanciaProvider);
    
    return restaurantesComDistanciaAsync.when(
      data: (restaurantesComDistancia) {
        // Pegar os 10 mais próximos (já estão ordenados por distância)
        final sugestoes = restaurantesComDistancia
            .take(10)
            .map((item) => item.restaurante)
            .toList();
        return AsyncValue.data(sugestoes);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  } catch (e) {
    debugPrint('Erro em sugestoesProximasProvider: $e');
    return AsyncValue.error(e, StackTrace.current);
  }
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