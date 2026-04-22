class MockDatabase {
  static final Map<String, Map<String, dynamic>> _users = {
    'tes@mail.com': {
      'name': 'TES',
      'email': 'tes@mail.com',
      'password': 'tes',
      'role': 'siswa', 
    },
    'admin@vip.com': {
      'name': 'ADMINISTRATOR VIP',
      'email': 'admin@vip.com',
      'password': 'admin',
      'role': 'admin', 
    },
  };

  static Map<String, dynamic>? currentUser;

  // 👇 UBAH FUNGSI INI: Sekarang mengembalikan String (role-nya), bukan bool.
  static Future<String?> loginRole(String email, String password) async {
    // Simulasi loading agar terasa seperti mengambil data dari internet asli
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email) && _users[email]?['password'] == password) {
      currentUser = _users[email];
      return currentUser?['role'] as String?; // Kembalikan string 'admin' atau 'siswa'
    }
    return null; // Kembalikan null jika kombinasi email & password salah
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email)) {
      return false; // Email sudah ada, tolak pendaftaran
    }

    _users[email] = {
      'name': name.toUpperCase(), 
      'email': email,
      'password': password,
      'role': 'siswa', // 👇 Setiap akun yang baru mendaftar OTOMATIS menjadi siswa
    };
    return true;
  }
  
  static void logout() {
    currentUser = null;
  }
}