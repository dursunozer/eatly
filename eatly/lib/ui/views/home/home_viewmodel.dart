import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../core/models/daily_summary.dart';

class HomeViewModel extends BaseViewModel {
  final DailySummary todaySummary = DailySummary(
    date: DateTime.now(),
    foods: [],
  );

  String get formattedDate =>
      DateFormat('dd MMMM yyyy', 'tr_TR').format(DateTime.now());

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydınnnn! ☀️';
    if (hour < 17) return 'İyi Öğlenlerr! 🌤️';
    return 'İyi Akşamlar! 🌙';
  }
}
