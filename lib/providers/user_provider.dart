// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  String _userId = "";
  String _email = "";
  String _name = '';
  bool _isLoading = false;

  String get userId => _userId;
  String get email => _email;
  String get name => _name;
  bool get isLoading => _isLoading;

  void setUser(String userId, String email, String name) {
    _userId = userId;
    _email = email;
    _name = name;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().login(email, password);

      // Ensure response is not null and contains '_id'
      if (response != null && response.containsKey('_id')) {
        _userId = response['_id']; // Access the _id directly from the response
        _email = response['email']; // Access the email from the response
        _name = response['username']; // Access the username from the response
      } else {
        // Handle the case when the response does not have the expected fields
        throw Exception('Invalid response structure');
      }
    } catch (e) {
      // Handle any exceptions that may occur during the login process
      print('Error during login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _userId = "";
    _email = "";
    _name = "";
    notifyListeners();
  }
}
