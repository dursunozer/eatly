import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Auth methods
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
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
  
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }
  
  // Database methods
  SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }
  
  // Storage methods
  SupabaseStorageClient get storage => client.storage;
  
  // Real-time subscriptions
  RealtimeChannel channel(String name) {
    return client.channel(name);
  }
}
