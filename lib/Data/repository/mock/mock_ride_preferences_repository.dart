import '../../../Domain/model/ride/ride_pref.dart';
import '../ride_preferences_repository.dart';
import '../../../Domain/dummy_data/dummy_data.dart';

class MockRidePreferencesRepository implements RidePreferencesRepository {
  final List<RidePreference> _pastPreferences = fakeRidePrefs;

  @override
  Future<List<RidePreference>> getPastPreferences() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return _pastPreferences;
  }

  @override
  Future<void> addPreference(RidePreference preference) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    _pastPreferences.add(preference);
  }
}