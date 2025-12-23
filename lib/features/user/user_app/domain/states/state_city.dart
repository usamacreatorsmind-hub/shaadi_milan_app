import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateCityModel {
  final String name;
  final List<String> cities;

  StateCityModel({required this.name, required this.cities});
}

final locationJsonProvider = FutureProvider<List<StateCityModel>>((ref) async {
  final string = await rootBundle.loadString('assets/data/location.json');
  final List<dynamic> jsonList = json.decode(string);

  final Map<String, List<String>> stateCityMap = {};

  // Group cities by state
  for (var cityData in jsonList) {
    final state = cityData['state'] as String;
    final city = cityData['name'] as String;
    stateCityMap.putIfAbsent(state, () => []).add(city);
  }

  // Convert map to list of StateCityModel and sort
  final states =
      stateCityMap.entries.map((entry) {
        entry.value.sort(); // Sort cities alphabetically
        return StateCityModel(name: entry.key, cities: entry.value);
      }).toList()..sort(
        (a, b) => a.name.compareTo(b.name),
      ); // Sort states alphabetically

  return states;
});
