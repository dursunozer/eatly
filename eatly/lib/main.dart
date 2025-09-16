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

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tarih formatını Türkçe olarak ayarla
  await initializeDateFormatting('tr_TR', null);
  
  // Supabase'i başlat
  await Supabase.initialize(
    url: 'https://rlttyysmwrgpwjexggdg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsdHR5eXNtd3JncHdqZXhnZ2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNTk4MzEsImV4cCI6MjA3MjYzNTgzMX0.iC7UTOc3UqxfeMsibag_43-bp5jhx2JNbSi8fF9pdnU',
  );
  
  // Stacked servislerini ayarla
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  
  // PowerSync'i web'de devre dışı bırak (wasm/worker kısıtları nedeniyle)
  if (!kIsWeb) {
    // Kullanıcı saat dilimini profiline yaz (ilk çalıştırmada)
    try {
      final tz = await TimezoneService.getLocalTimezone();
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        await ProfileService.upsertProfile(uid: uid, timezone: tz);
      }
    } catch (_) {
      // Hata durumunda sessizce devam et
    }
    
    // PowerSync ve diğer servisleri başlat
    await AppPowerSync.instance.initialize();
    UploaderService.instance.start();
    DailyCleanupService.instance.start();
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
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}