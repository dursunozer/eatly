import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class TimezoneService {
  static Future<String> getLocalTimezone() async {
    tzdata.initializeTimeZones();
    final location = tz.local;
    return location.name;
  }
}
