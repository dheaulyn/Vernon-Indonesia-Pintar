import 'package:flutter/material.dart';

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
        
        // JIKA DITOLAK: Sengaja dibiarkan agar tidak mereset current_step kembali ke 0.
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

  // ==========================================
  // DATA MEDIA (ARTIKEL & GALERI) UNTUK CMS
  // ==========================================
  static final List<Map<String, String>> _artikelList = [
    {
      "id": "A1",
      "title": "Pelatihan Barista Angkatan 1 Vernon Edu Resmi Lulus",
      "date": "10 Mei 2026",
      "desc": "Sebanyak 50 peserta program beasiswa VIP berhasil menyelesaikan pelatihan barista intensif selama 10 bulan...",
      // 👇 PERBAIKAN: Menambahkan 'content' (Isi Artikel Lengkap) ke data dummy
      "content": "Malang — Suasana haru dan bangga menyelimuti gedung pelatihan Vernon Edu pada pagi hari ini. Sebanyak 50 peserta program beasiswa Vernon Indonesia Pintar (VIP) secara resmi dinyatakan lulus dari program Pelatihan Barista Intensif Angkatan 1.\n\nSelama 10 bulan penuh, para peserta yang mayoritas berasal dari keluarga pra-sejahtera ini tidak hanya dibekali keahlian meracik kopi (brewing, latte art, dan espresso espresso base), tetapi juga dibekali materi kewirausahaan, pelayanan pelanggan, hingga literasi keuangan dasar.\n\nBapak Budi Santoso, selaku Direktur Program VIP, menyampaikan apresiasinya. 'Mereka datang ke sini dengan semangat belajar yang luar biasa. Kini mereka siap untuk diterjunkan langsung ke industri Food & Beverage yang sedang berkembang pesat,' ujarnya.\n\nSebagai langkah konkret, pihak Yayasan juga telah menjalin kerja sama dengan lebih dari 20 kedai kopi dan restoran di wilayah Jawa Timur untuk menyalurkan lulusan terbaik langsung bekerja. Semoga langkah ini menjadi awal yang cerah bagi masa depan mereka.",
      "kategori": "Berita"
    },
    {
      "id": "A2",
      "title": "VernonCorp Buka Pendaftaran Beasiswa VIP Gelombang 2",
      "date": "02 Mei 2026",
      "desc": "Program beasiswa Vernon Indonesia Pintar (VIP) kembali dibuka untuk siswa berprestasi yang kurang mampu di seluruh Indonesia.",
      // 👇 PERBAIKAN: Menambahkan 'content'
      "content": "Jakarta — Kabar gembira bagi para pemuda-pemudi inspiratif di seluruh Nusantara. Yayasan Vernon Indonesia Pintar dengan bangga mengumumkan pembukaan pendaftaran beasiswa penuh gelombang ke-2 untuk tahun ajaran 2026/2027.\n\nProgram ini secara khusus menargetkan siswa-siswi berprestasi tingkat SMA/SMK sederajat yang menghadapi kendala finansial untuk melanjutkan pendidikan atau mendapatkan keterampilan siap kerja.\n\nSyarat utama pendaftaran meliputi:\n1. Fotokopi KTP/Kartu Pelajar\n2. Surat Keterangan Tidak Mampu (SKTM) dari Kelurahan\n3. Ijazah atau SKL Terakhir\n4. Lulus seleksi administrasi dan wawancara.\n\n'Kami menargetkan menjangkau 200 anak muda pada gelombang kedua ini. Mari manfaatkan kesempatan ini sebaik-baiknya,' ungkap tim pendaftaran VIP. Pendaftaran sepenuhnya dilakukan secara online melalui portal resmi website Vernon.",
      "kategori": "Pengumuman"
    },
    {
      "id": "A3",
      "title": "Kisah Sukses: Dari Siswa SMK Menjadi Digital Marketer",
      "date": "25 April 2026",
      "desc": "Mengenal Budi, alumni VIP yang kini sukses menjadi spesialis pemasaran digital di salah satu startup terkemuka di Jakarta.",
      // 👇 PERBAIKAN: Menambahkan 'content'
      "content": "Menjadi seorang spesialis pemasaran digital (Digital Marketer) di salah satu startup teknologi terbesar di Jakarta mungkin terdengar seperti mimpi yang mustahil bagi seorang pemuda dari desa kecil di pinggiran kota. Namun, hal itu berhasil diwujudkan oleh Budi Haryanto, salah satu alumni pertama program vokasi Vernon Indonesia Pintar (VIP).\n\nBudi, lulusan SMK jurusan Akuntansi, awalnya kesulitan mencari pekerjaan yang layak. Lewat informasi dari gurunya, ia mencoba mendaftar Beasiswa VIP dan mengambil peminatan Pemasaran Digital.\n\n'Di Vernon Edu, saya diajarkan dari nol. Mulai dari dasar-dasar SEO, cara beriklan di media sosial, hingga membaca analisis data. Mentor-mentornya sangat praktikal,' kenang Budi.\n\nHanya berselang dua bulan pasca kelulusannya, Budi berhasil direkrut berkat portofolio kampanye digital yang ia buat sebagai tugas akhir di VIP. Kisah Budi membuktikan bahwa dedikasi dipadu dengan akses pendidikan yang tepat dapat benar-benar mengubah garis takdir seseorang.",
      "kategori": "Inspirasi"
    },
    {
      "id": "A4",
      "title": "Tips Lolos Wawancara Beasiswa Vernon Indonesia Pintar",
      "date": "15 April 2026",
      "desc": "Persiapkan diri Anda! Berikut adalah 5 tips jitu untuk menghadapi wawancara beasiswa dari tim HR VernonCorp.",
      // 👇 PERBAIKAN: Menambahkan 'content'
      "content": "Tahap wawancara sering kali menjadi batu sandungan bagi banyak pelamar beasiswa. Rasa gugup dan ketidaksiapan mental membuat pelamar tidak bisa menunjukkan potensi terbaiknya.\n\nAgar Anda bisa tampil maksimal, Tim HR VernonCorp membagikan 5 tips penting saat wawancara Beasiswa VIP:\n\n1. Kenali Dirimu Sendiri: Pewawancara akan banyak menggali tentang motivasi, kelebihan, dan kekurangan Anda. Jujurlah dalam menjawab dan jangan melebih-lebihkan.\n2. Pahami Visi Program VIP: Tunjukkan bahwa Anda tahu tujuan program ini dan bagaimana program ini sejalan dengan cita-cita masa depan Anda.\n3. Berpakaian Rapi dan Sopan: Kesan pertama sangat penting. Pakaian rapi mencerminkan keseriusan dan profesionalisme Anda.\n4. Datang Tepat Waktu: Disiplin waktu adalah nilai utama di VernonCorp. Pastikan Anda sudah siap 15 menit sebelum jadwal wawancara dimulai, baik daring maupun luring.\n5. Tunjukkan Semangat Belajar: Yang kami cari bukanlah orang yang sudah sempurna pintar, melainkan orang yang tangguh dan punya kemauan keras untuk dibentuk menjadi lebih baik.\n\nTetap tenang dan percaya diri. Semoga berhasil di tahap wawancara!",
      "kategori": "Edukasi"
    },
  ];

  static final List<Map<String, String>> _galeriList = [
    {"id": "G1", "title": "Kegiatan Orientasi Beasiswa VIP 2026"},
    {"id": "G2", "title": "Sesi Praktik Pelatihan Barista"},
    {"id": "G3", "title": "Pemberian Sertifikat Kelulusan"},
    {"id": "G4", "title": "Kunjungan Industri ke VernonCorp"},
    {"id": "G5", "title": "Sesi Pelatihan Digital Marketing"},
    {"id": "G6", "title": "Malam Keakraban Alumni VIP"},
  ];

  // --- Fungsi CMS Artikel ---
  static List<Map<String, String>> getSemuaArtikel() => List.from(_artikelList);

  static void tambahArtikel(Map<String, String> artikel) {
    artikel['id'] = "A${DateTime.now().millisecondsSinceEpoch}";
    _artikelList.insert(0, artikel); // Masukkan di urutan paling atas
  }

  static void editArtikel(String id, Map<String, String> dataBaru) {
    int index = _artikelList.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      _artikelList[index] = {..._artikelList[index], ...dataBaru};
    }
  }

  static void hapusArtikel(String id) {
    _artikelList.removeWhere((a) => a['id'] == id);
  }

  // --- Fungsi CMS Galeri ---
  static List<Map<String, String>> getSemuaGaleri() => List.from(_galeriList);

  static void tambahGaleri(String title) {
    _galeriList.insert(0, {
      "id": "G${DateTime.now().millisecondsSinceEpoch}",
      "title": title,
    });
  }

  static void editGaleri(String id, String titleBaru) {
    int index = _galeriList.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      _galeriList[index]['title'] = titleBaru;
    }
  }

  static void hapusGaleri(String id) {
    _galeriList.removeWhere((g) => g['id'] == id);
  }
}