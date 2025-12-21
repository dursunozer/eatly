import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;
  
  User? get currentUser => _client.auth.currentUser;
  
  bool get isLoggedIn => currentUser != null;
  
  /// Kullanıcı anonim mi kontrol et
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

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

  /// Anonim oturum başlat
  Future<String?> signInAnonymously() async {
    final res = await _client.auth.signInAnonymously();
    return res.user?.id;
  }

  /// Google ile giriş yap
  Future<String?> signInWithGoogle() async {
    const webClientId = '828169428629-21s0j0sub8evfugdhegv9rjvlkgmradu.apps.googleusercontent.com'; // Google Cloud Console'dan alınacak
    
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );
    
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return null; // Kullanıcı iptal etti
    }
    
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;
    
    if (idToken == null) {
      throw Exception('Google ID token alınamadı');
    }
    
    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    
    return res.user?.id;
  }

  /// Anonim hesabı e-posta ile birleştir (link)
  Future<String?> linkWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final res = await _client.auth.updateUser(
      UserAttributes(
        email: email.trim(),
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      ),
    );
    return res.user?.id;
  }

  /// Google ile giriş yap ve hesap oluştur
  /// Not: Anonim hesap varsa önce çıkış yapılıp Google ile yeni hesap oluşturulur
  Future<String?> linkWithGoogle() async {
    const webClientId = '828169428629-21s0j0sub8evfugdhegv9rjvlkgmradu.apps.googleusercontent.com';
    
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );
    
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return null; // Kullanıcı iptal etti
    }
    
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;
    
    if (idToken == null) {
      throw Exception('Google ID token alınamadı');
    }
    
    // Anonim kullanıcıyı çıkış yaptır ve Google ile yeni hesap oluştur
    if (isAnonymous) {
      await _client.auth.signOut();
    }
    
    // Google ile giriş yap
    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
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


