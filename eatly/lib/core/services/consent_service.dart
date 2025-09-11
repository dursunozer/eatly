import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/policy_config.dart';

class ConsentService {
  ConsentService._();
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<String?> _fetchUserPolicyVersion() async {
    final String? uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final res = await _client
        .from('user_consents')
        .select('policy_version')
        .eq('user_id', uid)
        .maybeSingle();
    if (res is Map<String, dynamic>) {
      return res['policy_version'] as String?;
    }
    return null;
  }

  static Future<bool> hasAcceptedCurrentPolicy() async {
    final String? current = await _fetchUserPolicyVersion();
    return current == PolicyConfig.policyVersion;
  }

  static Future<void> saveConsent({
    required bool kvkkAccepted,
    required bool healthAccepted,
  }) async {
    final String? uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Kullanıcı oturumu bulunamadı');
    }

    await _client.from('user_consents').upsert({
      'user_id': uid,
      'kvkk_accepted': kvkkAccepted,
      'healthdata_accepted': healthAccepted,
      'policy_version': PolicyConfig.policyVersion,
      'accepted_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}


