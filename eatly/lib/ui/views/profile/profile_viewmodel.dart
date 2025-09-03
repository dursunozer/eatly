import 'package:stacked/stacked.dart';

class ProfileViewModel extends BaseViewModel {
  String name = 'Kullanıcı';
  int age = 25;
  double weight = 70;
  double height = 170;
  String gender = 'Erkek';
  String activity = 'Orta Aktif';
  String goal = 'Kilo Koruma';

  double get bmi => weight / ((height / 100) * (height / 100));
}


