// import 'package:flutter/material.dart';

class MockDatabase {
  static final Map<String, Map<String, dynamic>> _users = {
    'tes@mail.com': {
      'name': 'TES',
      'email': 'tes@mail.com',
      'password': 'tes',
    },
    'admin@vip.com': {
      'name': 'ADMINISTRATOR VIP',
      'email': 'admin@vip.com',
      'password': 'admin123',
    },
  };

  
  static Map<String, dynamic>? currentUser;


  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email) && _users[email]?['password'] == password) {
      currentUser = _users[email];
      return true;
    }
    return false;
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email)) {
      return false; // Email sudah ada
    }


    _users[email] = {
      'name': name.toUpperCase(), 
      'email': email,
      'password': password,
    };
    return true;
  }

  
  static void logout() {
    currentUser = null;
  }
}
