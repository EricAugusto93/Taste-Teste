import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Getter para facilitar acesso ao cliente
  static SupabaseClient get supabase => client;
  
  // Serviços de autenticação
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  // Getter para usuário atual
  static User? get currentUser => client.auth.currentUser;
  
  // Stream para mudanças de autenticação
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
} 