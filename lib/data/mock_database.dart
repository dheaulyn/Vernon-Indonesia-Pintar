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
      'is_registered': false,
      'current_step': 0,
      'is_revisi': false,
      'catatan_revisi': '',
      'admin_status': 'Menunggu Review',
      // Field data tambahan
      'telepon': '',
      'domisili': '',
      'pendidikan': '',
      'nik': '',
      'asal_sekolah': '',
      'tahun_lulus': '',
      'tgl_daftar': '', 
      'jadwal_wawancara': '',
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

  static final List<DonationHistory> _donationHistory = [];

  static Future<String?> loginRole(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_users.containsKey(email) && _users[email]?['password'] == password) {
      currentUser = _users[email];
      return currentUser?['role'] as String?;
    }
    return null;
  }

  static Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_users.containsKey(email)) return false;

    _users[email] = {
      'name': name.toUpperCase(),
      'email': email,
      'password': password,
      'role': 'siswa',
      'is_registered': false,
      'current_step': 0,
      'is_revisi': false,
      'catatan_revisi': '',
      'admin_status': 'Menunggu Review',
      // Field data tambahan untuk pendaftaran
      'telepon': '',
      'domisili': '',
      'pendidikan': '',
      'nik': '',
      'asal_sekolah': '',
      'tahun_lulus': '',
      'tgl_daftar': '', 
      'jadwal_wawancara': '', 
    };
    return true;
  }

  // ==========================================
  // FUNGSI UNTUK HALAMAN ADMIN & SISWA
  // ==========================================

  // 1. Mengambil data ringkas untuk tabel list admin
  static List<Map<String, dynamic>> getAllRegisteredSiswa() {
    List<Map<String, dynamic>> result = [];
    _users.forEach((email, data) {
      if (data['role'] == 'siswa' && data['is_registered'] == true) {
        result.add({
          'id': email,
          'nama': data['name'],
          'asalSekolah': data['asal_sekolah'] ?? '-',
          'status': data['admin_status'] ?? 'Menunggu Review',
        });
      }
    });
    return result;
  }

  // 2. Mengambil seluruh data (Full) untuk Dialog Review Admin
  static List<Map<String, dynamic>> getAllRegisteredSiswaFullData() {
    List<Map<String, dynamic>> result = [];
    _users.forEach((email, data) {
      if (data['role'] == 'siswa' && data['is_registered'] == true) {
        result.add(data); // Mengirim map data asli secara utuh
      }
    });
    return result;
  }

  // 3. Menyimpan keputusan dari Admin dan menyinkronkan dengan Dashboard Siswa
  static void updateStatusSiswa(String email, String newStatus, String catatan, {String? jadwalWawancara}) {
    if (_users.containsKey(email)) {
      _users[email]!['admin_status'] = newStatus;

      if (newStatus == 'Revisi') {
        _users[email]!['is_revisi'] = true;
        _users[email]!['catatan_revisi'] = catatan;
        _users[email]!['current_step'] = 1;
      } else {
        _users[email]!['is_revisi'] = false;
        _users[email]!['catatan_revisi'] = '';

        // Sinkronisasi status admin dengan progress bar siswa
        if (newStatus == 'Menunggu Review') _users[email]!['current_step'] = 1;
        
        // Logika khusus untuk Wawancara
        if (newStatus == 'Wawancara') {
          _users[email]!['current_step'] = 2;
          if (jadwalWawancara != null && jadwalWawancara.isNotEmpty) {
            _users[email]!['jadwal_wawancara'] = jadwalWawancara;
          }
        }
        
        if (newStatus == 'Diterima') _users[email]!['current_step'] = 4; // Tahap 5
        
        // LOGIKA BARU UNTUK TAHAP PELATIHAN DAN KELULUSAN
        if (newStatus == 'Pelatihan') _users[email]!['current_step'] = 5; // Tahap 6
        if (newStatus == 'Lulus') _users[email]!['current_step'] = 6;     // Timeline full hijau (Selesai)
        
        // 👇 JIKA DITOLAK: Sengaja dibiarkan agar tidak mereset current_step kembali ke 0.
        // Data tetap aman dan UI Ditolak akan muncul di Dashboard.
        if (newStatus == 'Ditolak') {
          // Tidak melakukan apa-apa pada current_step
        }
      }
    }
  }

  // 4. FUNGSI KHUSUS UNTUK SISWA SAAT MENGIRIM REVISI
  static void submitRevisiSiswa() {
    if (currentUser != null) {
      String email = currentUser!['email'];
      
      // Mengubah paksa data di tabel utama _users
      _users[email]!['is_revisi'] = false;
      _users[email]!['catatan_revisi'] = '';
      _users[email]!['admin_status'] = 'Menunggu Review';
      _users[email]!['current_step'] = 1;

      // Sinkronkan kembali dengan sesi user saat ini
      currentUser = _users[email];
    }
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
