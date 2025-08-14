import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Classe para operações de banco de dados com Supabase
class SupabaseDatabase {
  static SupabaseDatabase? _instance;
  static SupabaseDatabase get instance => _instance ??= SupabaseDatabase._();
  
  SupabaseDatabase._();
  
  /// Cliente Supabase
  SupabaseClient get client => SupabaseService.instance.client;
  
  /// Executar query SELECT
  PostgrestFilterBuilder select(String table) {
    return client.from(table).select();
  }
  
  /// Executar query INSERT
  PostgrestFilterBuilder insert(String table, Map<String, dynamic> data) {
    return client.from(table).insert(data);
  }
  
  /// Executar query UPDATE
  PostgrestFilterBuilder update(String table, Map<String, dynamic> data) {
    return client.from(table).update(data);
  }
  
  /// Executar query DELETE
  PostgrestFilterBuilder delete(String table) {
    return client.from(table).delete();
  }
  
  /// Executar RPC (Remote Procedure Call)
  PostgrestFilterBuilder rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }
  
  /// Executar query customizada
  PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }
}