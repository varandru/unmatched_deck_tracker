// TODO здесь будут все настройки, с которыми я заморочусь.
// Пока что только проверка первого запуска

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unmatched_deck_tracker/card.dart';

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

// Если в настройках ещё нет сортировки, делаем по имени
Future<CardSortType> getCardSortType() async {
  final SharedPreferences settings = await SharedPreferences.getInstance();
  return intToCardSortType(settings.getInt('cardSortType') ?? 0);
}

Future<bool> setCardSortType(CardSortType type) async {
  final SharedPreferences settings = await SharedPreferences.getInstance();
  return settings.setInt('cardSortType', cardSortTypeToInt(type));
}

// Если в настройках ещё нет сортировки, делаем по имени
Future<bool> getTwoPlayerMode() async {
  final SharedPreferences settings = await SharedPreferences.getInstance();
  return settings.getBool('isTwoPlayerMode') ?? true;
}

Future<bool> setTwoPlayerMode(bool isTwoPlayerMode) async {
  final SharedPreferences settings = await SharedPreferences.getInstance();
  return settings.setBool('isTwoPlayerMode', isTwoPlayerMode);
}
