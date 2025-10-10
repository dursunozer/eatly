import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'uploader_service.dart';
import 'analysis_service.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isOnline = true; // Varsayılan: online kabul et

  bool get isOnline => _isOnline;

  Future<void> start() async {
    try {
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      _handle(results);
    } catch (_) {}

    await _sub?.cancel();
    _sub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _handle(results);
    });
  }

  void _handle(List<ConnectivityResult> results) {
    final bool nowOnline = results.any((r) => r != ConnectivityResult.none);
    if (kDebugMode) {
      debugPrint('Connectivity changed: $results (online=$nowOnline)');
    }
    if (nowOnline && !_isOnline) {
      // Offline -> Online geçişi
      // Kullanıcı oturum açmışsa senkronizasyon yap
      if (Supabase.instance.client.auth.currentUser != null) {
        if (kDebugMode) {
          debugPrint('🔄 [Connectivity] Kullanıcı oturum açmış, uploader senkronizasyonu başlatılıyor');
        }
        UploaderService.instance.syncOnce();
      } else {
        if (kDebugMode) {
          debugPrint('⏭️ [Connectivity] Kullanıcı oturum açmamış, uploader senkronizasyonu atlanıyor');
        }
      }
      AnalysisService.instance.syncOnce();
    }
    _isOnline = nowOnline;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}