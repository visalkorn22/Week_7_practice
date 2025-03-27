import 'package:week_3_blabla_project/Data/DTO/location_dto.dart';
import 'package:week_3_blabla_project/Domain/model/ride/ride_pref.dart';


class RidePreferenceDto {
  static Map<String, dynamic> toJson(RidePreference pref) {
    return {
      'departure': LocationDto.toJson(pref.departure),
      'arrival': LocationDto.toJson(pref.arrival),
      'date': pref.departureDate.toIso8601String(),
      'seats': pref.requestedSeats,
    };
  }

  static RidePreference fromJson(Map<String, dynamic> json) {
    return RidePreference(
      departure: LocationDto.fromJson(json['departure']),
      arrival: LocationDto.fromJson(json['arrival']),
      departureDate: DateTime.parse(json['date']),
      requestedSeats: json['seats'],
    );
  }
}