import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../core/models/daily_summary.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/auth_service.dart';

class HomeViewModel extends BaseViewModel {
  final DailySummary todaySummary = DailySummary(
    date: DateTime.now(),
    foods: [],
  );

  String? displayName;

  String get formattedDate =>
      DateFormat('dd MMMM yyyy', 'tr_TR').format(DateTime.now());

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın! ☀️';
    if (hour < 17) return 'İyi Öğlenler! 🌤️';
    return 'İyi Akşamlar! 🌙';
  }

  Future<void> init() async {
    try {
      final uid = AuthService.currentUserId;
      if (uid != null) {
        final profile = await ProfileService.fetchProfile(uid);
        final name = (profile?['display_name'] as String?)?.trim();
        displayName = (name != null && name.isNotEmpty) ? name : null;
      }
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
}
