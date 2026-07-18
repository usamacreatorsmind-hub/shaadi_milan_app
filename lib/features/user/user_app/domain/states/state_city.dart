import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_translation_service.dart';
import '../../../../translitration/models/bilingual_value.dart';

class StateCityModel {
  final String name;
  final List<CityModel> cities;

  StateCityModel({required this.name, required this.cities});
}

class CityModel {
  final String id;
  final String name;

  CityModel({required this.id, required this.name});
}

final locationJsonProvider = FutureProvider<List<StateCityModel>>((ref) async {
  final locale = ref.watch(localeProvider);
  final langCode = locale.languageCode;

  final string = await rootBundle.loadString(
    'assets/data/location_$langCode.json',
  );
  final List<dynamic> jsonList = json.decode(string);

  final Map<String, List<CityModel>> stateCityMap = {};

  // Group cities by state
  for (var cityData in jsonList) {
    final state = cityData['state'] as String;
    final city = cityData['name'] as String;
    final id = cityData['id'] as String;
    stateCityMap
        .putIfAbsent(state, () => [])
        .add(CityModel(id: id, name: city));
  }

  // Convert map to list of StateCityModel and sort
  final states =
      stateCityMap.entries.map((entry) {
        entry.value.sort(
          (a, b) => a.name.compareTo(b.name),
        ); // Sort cities alphabetically
        return StateCityModel(name: entry.key, cities: entry.value);
      }).toList()..sort(
        (a, b) => a.name.compareTo(b.name),
      ); // Sort states alphabetically

  return states;
});

final bilingualLocationProvider =
    FutureProvider<Map<String, Map<String, BilingualValue>>>((ref) async {
      final enString = await rootBundle.loadString(
        'assets/data/location_en.json',
      );
      final hiString = await rootBundle.loadString(
        'assets/data/location_hi.json',
      );

      final List<dynamic> enList = json.decode(enString);
      final List<dynamic> hiList = json.decode(hiString);

      final Map<String, BilingualValue> states = {};
      final Map<String, BilingualValue> cities = {};

      for (var item in enList) {
        final id = item['id'] as String;
        final stateName = item['state'] as String;
        final cityName = item['name'] as String;

        final hiItem = hiList.firstWhere(
          (element) => element['id'] == id,
          orElse: () => null,
        );
        final hiStateName = hiItem?['state'] ?? stateName;
        final hiCityName = hiItem?['name'] ?? cityName;

        // Use stateName (en) as key for states since it's the primary identifier in the app logic
        states[stateName] = BilingualValue(en: stateName, hi: hiStateName);
        cities[id] = BilingualValue(en: cityName, hi: hiCityName);
      }

      return {'states': states, 'cities': cities};
    });
