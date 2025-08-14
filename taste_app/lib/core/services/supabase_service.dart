import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço centralizado para operações com Supabase
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  /// Cliente Supabase
  SupabaseClient get client => Supabase.instance.client;
  
  /// Usuário atual autenticado
  User? get currentUser => client.auth.currentUser;
  
  /// ID do usuário atual
  String? get currentUserId => currentUser?.id;
  
  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => currentUser != null;
  
  /// Stream de mudanças no estado de autenticação
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  /// Inicializar Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
  
  /// Login com email e senha
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Registro com email e senha
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }
  
  /// Logout
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Resetar senha
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }
  
  /// Atualizar perfil do usuário
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
        data: data,
      ),
    );
  }
  
  /// Executar query no banco
  PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }
  
  /// Executar RPC (Remote Procedure Call)
  PostgrestFilterBuilder rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }
  
  /// Upload de arquivo
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    final uint8List = Uint8List.fromList(bytes);
    await client.storage.from(bucket).uploadBinary(
      path,
      uint8List,
      fileOptions: FileOptions(
        contentType: contentType,
      ),
    );
    
    return client.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Deletar arquivo
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }
  
  /// Obter URL pública de um arquivo
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
}