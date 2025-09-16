import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserService {
  final _supabase = Supabase.instance.client;
  
  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  Future<UserProfile?> getUserProfile() async {
    if (!isLoggedIn) return null;
    
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();
      
      if (response != null) {
        return UserProfile.fromJson(response);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    
    return null;
  }
  
  Future<void> updateUserProfile(UserProfile profile) async {
    if (!isLoggedIn) return;
    
    try {
      await _supabase
          .from('profiles')
          .upsert(profile.toJson())
          .eq('id', currentUser!.id);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;
}
