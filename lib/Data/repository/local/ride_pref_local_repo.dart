import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:week_3_blabla_project/Data/DTO/ride_pref_dto.dart';
import 'package:week_3_blabla_project/Domain/model/ride/ride_pref.dart';
import '../ride_preferences_repository.dart';


class LocalRidePreferencesRepository implements RidePreferencesRepository {
  static const String _preferencesKey = "ride_preferences";

  @override
  Future<List<RidePreference>> getPastPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsList = prefs.getStringList(_preferencesKey) ?? [];
    return prefsList.map((json) => 
      RidePreferenceDto.fromJson(jsonDecode(json))
    ).toList();
  }

  @override
  Future<void> addPreference(RidePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getPastPreferences();
    final updated = [...existing, preference];
    await prefs.setStringList(
      _preferencesKey,
      updated.map((pref) => jsonEncode(RidePreferenceDto.toJson(pref))).toList(),
    );
  }
}