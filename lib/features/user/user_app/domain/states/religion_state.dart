import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// =====================================================
/// MODEL
/// =====================================================
class ReligionModel {
  final String id;
  final String name;
  final List<String> castes;

  ReligionModel({required this.id, required this.name, required this.castes});

  factory ReligionModel.fromJson(Map<String, dynamic> json) {
    return ReligionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      castes: List<String>.from(json['castes'] ?? []),
    );
  }
}

/// =====================================================
/// STATE
/// =====================================================
class ReligionState {
  final String religion;
  final String caste;

  ReligionState({required this.religion, required this.caste});

  ReligionState copyWith({String? religion, String? caste}) {
    return ReligionState(
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
    );
  }

  factory ReligionState.empty() {
    return ReligionState(religion: '', caste: '');
  }
}

/// =====================================================
/// CONTROLLER
/// =====================================================
class ReligionController extends StateNotifier<ReligionState> {
  ReligionController() : super(ReligionState.empty());

  void setReligion(String religion) {
    state = state.copyWith(religion: religion, caste: '');
  }

  void setCaste(String caste) {
    state = state.copyWith(caste: caste);
  }
}

/// =====================================================
/// DATA LOADER (ASSET JSON)
/// =====================================================
class ReligionDataLoader {
  static const _assetPath = 'assets/data/religion_caste.json';

  Future<List<ReligionModel>> loadReligions() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> decoded = json.decode(jsonString);

    final List list = decoded['religions'] ?? [];
    return list.map((e) => ReligionModel.fromJson(e)).toList();
  }
}

/// =====================================================
/// PROVIDERS (RIVERPOD LEGACY)
/// =====================================================

// Controller provider
final religionControllerProvider =
    StateNotifierProvider<ReligionController, ReligionState>(
      (ref) => ReligionController(),
    );

// Data loader provider
final religionDataLoaderProvider = Provider<ReligionDataLoader>(
  (ref) => ReligionDataLoader(),
);

// All religions provider
final religionsProvider = FutureProvider<List<ReligionModel>>((ref) async {
  return ref.read(religionDataLoaderProvider).loadReligions();
});

// Castes by selected religion provider
final castesByReligionProvider = FutureProvider.family<List<String>, String>((
  ref,
  religionName,
) async {
  final religions = await ref.read(religionDataLoaderProvider).loadReligions();

  final religion = religions.firstWhere(
    (r) => r.name == religionName,
    orElse: () => ReligionModel(id: '', name: '', castes: []),
  );

  return religion.castes;
});
