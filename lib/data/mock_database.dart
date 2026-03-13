import 'package:flutter/material.dart';

class MockDatabase {
  // 👇 1. Database sekarang menyimpan Map (objek) berisi nama, email, dan password
  static final Map<String, Map<String, dynamic>> _users = {
    'rudolph.bg@email.com': {
      'name': 'RUDOLPH BENJAMIN GASPERSZ',
      'email': 'rudolph.bg@email.com',
      'password': '123456',
    },
    'admin@vip.com': {
      'name': 'ADMINISTRATOR VIP',
      'email': 'admin@vip.com',
      'password': 'admin123',
    },
  };

  // 👇 2. Variabel Sesi: Menyimpan data user yang SEDANG LOGIN saat ini
  static Map<String, dynamic>? currentUser;

  // 👇 3. Fungsi Login
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email) && _users[email]?['password'] == password) {
      // Jika berhasil, simpan data user tersebut ke variabel Sesi
      currentUser = _users[email];
      return true;
    }
    return false;
  }

  // 👇 4. Fungsi Register (Sekarang menerima parameter NAMA)
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email)) {
      return false; // Email sudah ada
    }

    // Simpan data lengkap user baru
    _users[email] = {
      'name': name.toUpperCase(), // Kita buat kapital agar seragam di Navbar
      'email': email,
      'password': password,
    };
    return true;
  }

  // 👇 5. Fungsi Logout untuk menghapus Sesi
  static void logout() {
    currentUser = null;
  }
}
