import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'app/app.router.dart';
import 'app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'ui/views/main/main_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Bu dosya flutterfire configure ile oluştu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Oluşturulan seçenekleri kullanır
  );
  await initializeDateFormatting('tr_TR', null);
  await setupLocator();
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
      home: const MainView(),
    );
  }
}
