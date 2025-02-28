import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  UserProvider() {
    _loadUserData(); // Load user data when the provider is initialized
  }

  void setUser(String userId, String email, String name) async {
    _userId = userId;
    _email = email;
    _name = name;
    notifyListeners();

    // Save user data to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('name', name);
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? "";
    _email = prefs.getString('email') ?? "";
    _name = prefs.getString('name') ?? "";
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().login(email, password);

      if (response != null && response.containsKey('_id')) {
        _userId = response['_id'];
        _email = response['email'];
        _name = response['username'];

        // Save login data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', _userId);
        await prefs.setString('email', _email);
        await prefs.setString('name', _name);
      } else {
        throw Exception('Invalid response structure');
      }
    } catch (e) {
      print('Error during login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _userId = "";
    _email = "";
    _name = "";
    notifyListeners();

    // Clear user data from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
