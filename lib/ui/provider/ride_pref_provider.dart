import 'package:flutter/material.dart';
import 'package:week_3_blabla_project/Data/repository/ride_preferences_repository.dart';
import 'package:week_3_blabla_project/Domain/model/ride/ride_pref.dart';


class RidesPreferencesProvider extends ChangeNotifier {
  final RidePreferencesRepository repository;
  RidePreference? _currentPreference;
  List<RidePreference> _pastPreferences = [];
  bool _isLoading = false;
  bool _hasError = false;

  RidesPreferencesProvider({required this.repository}) {
    fetchPastPreferences();
  }

  Future<void> fetchPastPreferences() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _pastPreferences = await repository.getPastPreferences();
      
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _hasError = true;
      notifyListeners();
      debugPrint("Error fetching preferences: $error");
    }
  }

  Future<void> setCurrentPreference(RidePreference pref) async {
    try {
      await repository.addPreference(pref);
      await fetchPastPreferences();
      _currentPreference = pref;
      notifyListeners();
    } catch (error) {
      debugPrint("Error saving preference: $error");
      rethrow;
    }
  }

  // Getters
  RidePreference? get currentPreference => _currentPreference;
  List<RidePreference> get pastPreferences => _pastPreferences;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
}