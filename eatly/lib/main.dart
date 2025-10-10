import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'app/app.bottomsheets.dart';
import 'app/app.dialogs.dart';
import 'core/theme/app_theme.dart';
import 'core/services/powersync_service.dart';
import 'core/services/uploader_service.dart';
import 'core/services/daily_cleanup_service.dart';
import 'core/services/timezone_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/analysis_service.dart';

final supabase = Supabase.instance.client;

// Utility function to clear local photos for testing
Future<void> _clearLocalPhotos() async {
  try {
    await AppPowerSync.instance.clearLocalPhotos();
    if (kDebugMode) {
      debugPrint('✅ [Utility] Tüm yerel fotoğraflar temizlendi');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [Utility] Yerel fotoğraflar temizlenirken hata: $e');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);

  await Supabase.initialize(
    url: 'https://rlttyysmwrgpwjexggdg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsdHR5eXNtd3JncHdqZXhnZ2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNTk4MzEsImV4cCI6MjA3MjYzNTgzMX0.iC7UTOc3UqxfeMsibag_43-bp5jhx2JNbSi8fF9pdnU',
  );

  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();

  if (!kIsWeb) {
    try {
      final tz = await TimezoneService.getLocalTimezone();
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        await ProfileService.upsertProfile(uid: uid, timezone: tz);
      }
    } catch (_) {}

    await AppPowerSync.instance.initialize();
    
    // Kullanıcı oturum açmışsa uploader servisini başlat
    if (Supabase.instance.client.auth.currentUser != null) {
      if (kDebugMode) {
        debugPrint('▶️ [Main] Kullanıcı oturum açmış, uploader servisi başlatılıyor');
      }
      UploaderService.instance.start();
    } else {
      if (kDebugMode) {
        debugPrint('⏭️ [Main] Kullanıcı oturum açmamış, uploader servisi başlatılmıyor');
      }
    }
    
    // Oturum durumu değişikliklerini dinle
    Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        // Kullanıcı oturum açtıysa uploader servisini başlat
        if (kDebugMode) {
          debugPrint('▶️ [Auth] Kullanıcı oturum açtı, uploader servisi başlatılıyor');
        }
        UploaderService.instance.start();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        // Kullanıcı oturumu kapattıysa uploader servisini durdur
        if (kDebugMode) {
          debugPrint('⏹️ [Auth] Kullanıcı oturumu kapattı, uploader servisi durduruluyor');
        }
        UploaderService.instance.stop();
      }
    });
    
    DailyCleanupService.instance.start();
    AnalysisService.instance.start();
    await ConnectivityService.instance.start();
  }

  runApp(const EatlyApp());
}

class EatlyApp extends StatelessWidget {
  const EatlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eatly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}