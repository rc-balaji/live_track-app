// lib/constants.dart
class Constants {
  static const String apiHost = "https://kt-track.vercel.app";
  static const String loginEndpoint = "$apiHost/api/auth/login";
  static const String fetchLocationsEndpoint = "$apiHost/api/location/fetch";
  static const String addLocationEndpoint = "$apiHost/api/location/add";
  static const String updateLocationEndpoint = "$apiHost/api/location/update";
  static const String stopTrackingEndpoint = "$apiHost/api/location/stop";
}
