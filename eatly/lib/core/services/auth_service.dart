import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static String? get currentUserId => _client.auth.currentUser?.id;

  static Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return res.user?.id;
  }

  static Future<String?> signUpWithPassword({
    required String email,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? metadata,
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: emailRedirectTo,
      data: metadata,
    );
    return res.user?.id;
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}


