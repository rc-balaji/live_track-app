// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<dynamic> login(String email, String password) async {
    print('Logging in with email: $email');

    final response = await http.post(
      Uri.parse(Constants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('Login response: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<dynamic> fetchLocations(String userId) async {
    print('Fetching locations for user ID: $userId');
    final response = await http.get(
      Uri.parse('${Constants.fetchLocationsEndpoint}?user_id=$userId'),
    );
    print('Fetch locations response: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<dynamic> addLocation(String userId, String name) async {
    print('Adding location for user ID: $userId with name: $name');
    final response = await http.post(
      Uri.parse('${Constants.addLocationEndpoint}?user_id=$userId&name=$name'),
    );
    print('Add location response: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<dynamic> updateLocation(String locationId, double latitude,
      double longitude, String userId) async {
    print(
        'Updating location ID: $locationId with lat: $latitude, long: $longitude for user ID: $userId');
    final response = await http.post(
      Uri.parse(
          '${Constants.updateLocationEndpoint}?location_id=$locationId&latitude=$latitude&longitude=$longitude&user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Update location response: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<dynamic> stopTracking(String locationId) async {
    print('Stopping tracking for location ID: $locationId');
    final response = await http.post(
      Uri.parse(Constants.stopTrackingEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'location_id': locationId}),
    );
    print('Stop tracking response: ${response.body}');
    return jsonDecode(response.body);
  }
}
