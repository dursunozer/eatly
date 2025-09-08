import 'package:eatly/ui/views/main/main_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'app/app.router.dart';
import 'app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
