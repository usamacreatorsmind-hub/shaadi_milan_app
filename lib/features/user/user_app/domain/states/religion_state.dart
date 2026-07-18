import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_translation_service.dart';
import '../../../../translitration/models/bilingual_value.dart';

/// =====================================================
/// MODEL
/// =====================================================
class ReligionCasteModel {
  final String id;
  final String name;
  final List<CasteModel> castes;

  ReligionCasteModel({
    required this.id,
    required this.name,
    required this.castes,
  });
}

class CasteModel {
  final String id;
  final String name;

  CasteModel({required this.id, required this.name});
}

/// =====================================================
/// DATA PROVIDER
/// =====================================================
final religionJsonProvider = FutureProvider<List<ReligionCasteModel>>((
  ref,
) async {
  final locale = ref.watch(localeProvider);
  final langCode = locale.languageCode;

  final string = await rootBundle.loadString(
    'assets/data/religion_caste_$langCode.json',
  );
  final List<dynamic> jsonList = json.decode(string);

  final Map<String, List<CasteModel>> religionCasteMap = {};
  final Map<String, String> religionIdToName = {};

  for (var item in jsonList) {
    final id = item['id'] as String;
    final religionName = item['religion'] as String;
    final casteName = item['caste'] as String;

    // religionId is the prefix before '_' (e.g., 'hindu' from 'hindu_brahmin')
    final religionId = id.split('_').first;

    religionIdToName[religionId] = religionName;
    religionCasteMap
        .putIfAbsent(religionId, () => [])
        .add(CasteModel(name: casteName, id: id));
  }

  final religions = religionCasteMap.entries.map((entry) {
    entry.value.sort((a, b) => a.name.compareTo(b.name));
    return ReligionCasteModel(
      id: entry.key,
      name: religionIdToName[entry.key]!,
      castes: entry.value,
    );
  }).toList()..sort((a, b) => a.name.compareTo(b.name));

  return religions;
});

final bilingualReligionProvider =
    FutureProvider<Map<String, Map<String, BilingualValue>>>((ref) async {
      final enString = await rootBundle.loadString(
        'assets/data/religion_caste_en.json',
      );
      final hiString = await rootBundle.loadString(
        'assets/data/religion_caste_hi.json',
      );

      final List<dynamic> enList = json.decode(enString);
      final List<dynamic> hiList = json.decode(hiString);

      // Map to store: religionId -> religionBilingual
      final Map<String, BilingualValue> religions = {};
      // Map to store: casteId -> casteBilingual
      final Map<String, BilingualValue> castes = {};

      for (var item in enList) {
        final id = item['id'] as String;
        final religionName = item['religion'] as String;
        final casteName = item['caste'] as String;
        final religionId = id.split('_').first;

        final hiItem = hiList.firstWhere(
          (element) => element['id'] == id,
          orElse: () => null,
        );
        final hiReligionName = hiItem?['religion'] ?? religionName;
        final hiCasteName = hiItem?['caste'] ?? casteName;

        religions[religionId] = BilingualValue(
          en: religionName,
          hi: hiReligionName,
        );
        castes[id] = BilingualValue(en: casteName, hi: hiCasteName);
      }

      return {'religions': religions, 'castes': castes};
    });

/// =====================================================
/// STATE
/// =====================================================
class ReligionState {
  final String religionId;
  final String casteId;

  ReligionState({required this.religionId, required this.casteId});

  ReligionState copyWith({String? religionId, String? casteId}) {
    return ReligionState(
      religionId: religionId ?? this.religionId,
      casteId: casteId ?? this.casteId,
    );
  }

  factory ReligionState.empty() {
    return ReligionState(religionId: '', casteId: '');
  }
}

/// =====================================================
/// CONTROLLER
/// =====================================================
class ReligionController extends StateNotifier<ReligionState> {
  ReligionController() : super(ReligionState.empty());

  void setReligion(String religionId) {
    state = state.copyWith(religionId: religionId, casteId: '');
  }

  void setCaste(String casteId) {
    state = state.copyWith(casteId: casteId);
  }
}

/// =====================================================
/// PROVIDERS
/// =====================================================

final religionControllerProvider =
    StateNotifierProvider<ReligionController, ReligionState>(
      (ref) => ReligionController(),
    );

// Compatibility provider for existing UI using religionsProvider
final religionsProvider = religionJsonProvider;

// Compatibility provider for existing UI using castesByReligionProvider
final castesByReligionProvider =
    FutureProvider.family<List<CasteModel>, String>((ref, religionId) async {
      final religions = await ref.watch(religionJsonProvider.future);
      final religion = religions.firstWhere(
        (r) => r.id == religionId,
        orElse: () => ReligionCasteModel(id: '', name: '', castes: []),
      );
      return religion.castes;
    });
