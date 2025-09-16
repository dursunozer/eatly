import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;
  
  User? get currentUser => _client.auth.currentUser;
  
  bool get isLoggedIn => currentUser != null;

  Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return res.user?.id;
  }

  Future<String?> signUpWithPassword({
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

  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;
}


