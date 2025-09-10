import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'app/app.router.dart';
import 'app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/powersync_service.dart';
import 'core/services/uploader_service.dart';
import 'package:flutter/foundation.dart';
import 'core/services/daily_cleanup_service.dart';
import 'core/services/timezone_service.dart';
import 'core/services/profile_service.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await setupLocator();
  await Supabase.initialize(
    url: 'https://rlttyysmwrgpwjexggdg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsdHR5eXNtd3JncHdqZXhnZ2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNTk4MzEsImV4cCI6MjA3MjYzNTgzMX0.iC7UTOc3UqxfeMsibag_43-bp5jhx2JNbSi8fF9pdnU',
  );
  // PowerSync'i web'de devre dışı bırakıyoruz (wasm/worker kısıtları nedeniyle)
  if (!kIsWeb) {
    // Kullanıcı saat dilimini profiline yaz (ilk çalıştırmada)
    try {
      final tz = await TimezoneService.getLocalTimezone();
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        await ProfileService.upsertProfile(uid: uid, timezone: tz);
      }
    } catch (_) {}
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
      //home: const MainView(),
    );
  }
}
