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
    String? current = await _fetchUserPolicyVersion();
    if (current == null) {
      // Fallback: auth metadata'dan ilk onayı çekip veritabanına upsert etmeyi dene
      final meta = _client.auth.currentUser?.userMetadata ?? {};
      final bool? metaKvkk = meta['kvkk_accepted'] as bool?;
      final bool? metaHealth = meta['healthdata_accepted'] as bool?;
      final String? metaVersion = meta['policy_version'] as String?;
      if (metaKvkk == true && metaHealth == true && metaVersion != null) {
        try {
          await _client.from('user_consents').upsert({
            'user_id': _client.auth.currentUser!.id,
            'kvkk_accepted': metaKvkk,
            'healthdata_accepted': metaHealth,
            'policy_version': metaVersion,
            'accepted_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'user_id');
          current = metaVersion;
        } catch (_) {}
      }
    }
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


