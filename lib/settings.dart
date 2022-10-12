// TODO здесь будут все настройки, с которыми я заморочусь.
// Пока что только проверка первого запуска

import 'package:shared_preferences/shared_preferences.dart';

/// Если в настройках ещё нет записи, то это точно первый запуск
Future<bool> getFirstLaunch() async {
  final SharedPreferences settings = await SharedPreferences.getInstance();
  return settings.getBool('isFirstLaunch') ?? true;
}

Future<bool> setFirstLaunch() async {
  final SharedPreferences settings = await SharedPreferences.getInstance();
  bool? settingSet = settings.getBool('isFirstLaunch');
  if (settingSet == null || settingSet == true) {
    await settings.setBool('isFirstLaunch', false);
    return true;
  } else {
    return false;
  }
}
