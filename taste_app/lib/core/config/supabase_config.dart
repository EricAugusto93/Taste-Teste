import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuração do Supabase
class SupabaseConfig {
  static const String _urlKey = 'SUPABASE_URL';
  static const String _anonKeyKey = 'SUPABASE_ANON_KEY';
  static bool _isInitialized = false;

  /// URL do projeto Supabase
  static String get url {
    final url = dotenv.env[_urlKey];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL não encontrada no arquivo .env');
    }
    return url;
  }

  /// Chave anônima do Supabase
  static String get anonKey {
    final key = dotenv.env[_anonKeyKey];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY não encontrada no arquivo .env');
    }
    return key;
  }

  /// Verifica se o Supabase foi inicializado
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: false, // Mude para true durante desenvolvimento se necessário
    );
    _isInitialized = true;
  }

  /// Cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Cliente de autenticação
  static GoTrueClient get auth => client.auth;

  /// Cliente de banco de dados
  static PostgrestClient get database => client.rest;
}

/// Classe para facilitar o acesso às tabelas
class SupabaseDatabase {
  /// Tabela de categorias
  static PostgrestQueryBuilder get categories => 
      SupabaseConfig.client.from('categories');

  /// Tabela de restaurantes
  static PostgrestQueryBuilder get restaurants => 
      SupabaseConfig.client.from('restaurants');

  /// Tabela de avaliações
  static PostgrestQueryBuilder get reviews => 
      SupabaseConfig.client.from('reviews');

  /// Tabela de favoritos
  static PostgrestQueryBuilder get favorites => 
      SupabaseConfig.client.from('favorites');

  /// Tabela de histórico de busca
  static PostgrestQueryBuilder get searchHistory => 
      SupabaseConfig.client.from('search_history');
}