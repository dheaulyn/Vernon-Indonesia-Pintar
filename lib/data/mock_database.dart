// ==========================================
// 1. MODEL DATA (Struktur data yang dibutuhkan)
// ==========================================

class DonationHistory {
  final String id;
  final String programName;
  final int amount;
  final DateTime date;
  final String status; // 'Sukses' atau 'Pending'

  DonationHistory({
    required this.id,
    required this.programName,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class ImpactUpdate {
  final String id;
  final String programName;
  final DateTime date;
  final String title;
  final String content;
  final String imageUrl;

  ImpactUpdate({
    required this.id,
    required this.programName,
    required this.date,
    required this.title,
    required this.content,
    required this.imageUrl,
  });
}

class SavedProgram {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final double progress; // Presentase dana terkumpul (0.0 - 1.0)

  SavedProgram({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.progress,
  });
}

// ==========================================
// 2. MOCK DATABASE (Simulasi Database)
// ==========================================

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
    'donatur@mail.com': {
      'name': 'BAPAK DONATUR',
      'email': 'donatur@mail.com',
      'password': 'donatur',
      'role': 'donatur',
    },
  };

  static Map<String, dynamic>? currentUser;

  // 👇 PERBAIKAN: Menjadikan data histori donasi sebagai List statis di dalam class
  // agar datanya bisa bertambah saat fungsi addDonation dipanggil.
  static final List<DonationHistory> _donationHistory = [
    DonationHistory(
      id: 'd1',
      programName: 'Beasiswa Vokasi 10 Bulan',
      amount: 500000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: 'Sukses',
    ),
    DonationHistory(
      id: 'd2',
      programName: 'Bantuan Alat Belajar',
      amount: 150000,
      date: DateTime.now().subtract(const Duration(days: 30)),
      status: 'Sukses',
    ),
    DonationHistory(
      id: 'd3',
      programName: 'Renovasi Panti Asuhan Vernon',
      amount: 250000,
      date: DateTime.now(),
      status: 'Pending',
    ),
  ];

  // --- FITUR AUTENTIKASI ---
  static Future<String?> loginRole(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email) && _users[email]?['password'] == password) {
      currentUser = _users[email];
      return currentUser?['role'] as String?;
    }
    return null;
  }

  static Future<bool> register(
    String name,
    String email,
    String password, [
    String role = 'siswa',
  ]) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email)) {
      return false;
    }

    _users[email] = {
      'name': name.toUpperCase(),
      'email': email,
      'password': password,
      'role': role,
    };
    return true;
  }

  static void logout() {
    currentUser = null;
  }

  // ==========================================
  // FITUR DATA PORTAL DONATUR
  // ==========================================

  static List<DonationHistory> getDonationHistory(String email) {
    // Mengambil dari list statis yang ada di atas
    return List.from(_donationHistory);
  }

  // 👇 PERBAIKAN: Fungsi untuk simulasi menambah data donasi
  static void addDonation(String email, String programName, int amount) {
    _donationHistory.add(
      DonationHistory(
        id: 'd${_donationHistory.length + 1}', // Otomatis generate ID (d4, d5, dst)
        programName: programName,
        date: DateTime.now(),
        amount: amount,
        status: 'Sukses',
      ),
    );
  }

  static List<ImpactUpdate> getImpactUpdates() {
    return [
      ImpactUpdate(
        id: 'i1',
        programName: 'Beasiswa Vokasi 10 Bulan',
        date: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Penyaluran Laptop untuk Batch 1 💻',
        content:
            'Berkat donasi Anda, 10 siswa vokasi kini memiliki laptop baru untuk belajar pemrograman. Mereka sangat antusias memulai kelas minggu depan!',
        imageUrl:
            'https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=600&auto=format&fit=crop',
      ),
      ImpactUpdate(
        id: 'i2',
        programName: 'Bantuan Alat Belajar',
        date: DateTime.now().subtract(const Duration(days: 15)),
        title: 'Buku & Seragam Telah Diterima! 🎒',
        content:
            'Bantuan alat tulis, buku, dan seragam telah berhasil disalurkan ke 50 anak di daerah Malang. Senyum mereka adalah bukti kebaikanmu!',
        imageUrl:
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=600&auto=format&fit=crop',
      ),
    ];
  }

  static List<SavedProgram> getSavedPrograms() {
    return [
      SavedProgram(
        id: 'p1',
        title: 'Beasiswa Penuh Sarjana (S1) Angkatan 2026',
        category: 'Pendidikan',
        imageUrl:
            'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=600&auto=format&fit=crop',
        progress: 0.75,
      ),
      SavedProgram(
        id: 'p2',
        title: 'Bantuan Seragam Sekolah Anak Pelosok',
        category: 'Bantuan Sosial',
        imageUrl:
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=600&auto=format&fit=crop',
        progress: 0.30,
      ),
    ];
  }
}
