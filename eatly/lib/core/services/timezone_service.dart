import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class TimezoneService {
  TimezoneService._();

  static Future<String> getLocalTimezone() async {
    try {
      return await FlutterNativeTimezone.getLocalTimezone();
    } catch (_) {
      return 'UTC';
    }
  }
}


