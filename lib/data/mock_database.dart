import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_auth_service.dart';

// ==========================================
// 1. MODEL DATA (Struktur data yang dibutuhkan)
// ==========================================

class DonationHistory {
  final String id;
  final String email;
  final String programName;
  final int amount;
  final DateTime date;
  final String status;

  DonationHistory({
    required this.id,
    required this.email,
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
  final double progress;

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

  static Map<String, dynamic>? get currentUser => SupabaseAuthService.currentUserData;
  static set currentUser(Map<String, dynamic>? val) => SupabaseAuthService.currentUserData = val;

  static final List<DonationHistory> _donationHistory = [];

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

  static List<Map<String, dynamic>> getAllRegisteredSiswaFullData() {
    List<Map<String, dynamic>> result = [];
    _users.forEach((email, data) {
      if (data['role'] == 'siswa' && data['is_registered'] == true) {
        result.add(data);
      }
    });
    return result;
  }

  static void updateStatusSiswa(
    String email,
    String newStatus,
    String catatan, {
    String? jadwalWawancara,
  }) {
    if (_users.containsKey(email)) {
      _users[email]!['admin_status'] = newStatus;
      if (newStatus == 'Revisi') {
        _users[email]!['is_revisi'] = true;
        _users[email]!['catatan_revisi'] = catatan;
        _users[email]!['current_step'] = 1;
      } else {
        _users[email]!['is_revisi'] = false;
        _users[email]!['catatan_revisi'] = '';
        if (newStatus == 'Menunggu Review') _users[email]!['current_step'] = 1;
        if (newStatus == 'Wawancara') {
          _users[email]!['current_step'] = 2;
          if (jadwalWawancara != null && jadwalWawancara.isNotEmpty) {
            _users[email]!['jadwal_wawancara'] = jadwalWawancara;
          }
        }
        if (newStatus == 'Diterima') _users[email]!['current_step'] = 4;
        if (newStatus == 'Pelatihan') _users[email]!['current_step'] = 5;
        if (newStatus == 'Lulus') _users[email]!['current_step'] = 6;
      }
    }
  }

  static void submitRevisiSiswa() {
    if (currentUser != null) {
      String email = currentUser!['email'];
      _users[email]!['is_revisi'] = false;
      _users[email]!['catatan_revisi'] = '';
      _users[email]!['admin_status'] = 'Menunggu Review';
      _users[email]!['current_step'] = 1;
      currentUser = _users[email];
    }
  }



  // ==========================================
  // FITUR DATA PORTAL DONATUR
  // ==========================================
  static int getTotalDonasi() {
    return _donationHistory
        .where((d) => d.status == 'Sukses')
        .fold(0, (sum, item) => sum + item.amount);
  }

  static List<DonationHistory> getDonationHistory(String email) {
    return _donationHistory.where((d) => d.email == email).toList();
  }

  static void addDonation(String email, String programName, int amount) {
    _donationHistory.add(
      DonationHistory(
        id: 'd${_donationHistory.length + 1}',
        email: email,
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
  // LOGIKA DONASI & FUND POOL REAL-TIME
  // ==========================================

  // 1. Daftar Riwayat Donasi (Dimulai dari kosong sesuai permintaanmu)
  static final ValueNotifier<List<Map<String, dynamic>>> riwayatDonasi =
      ValueNotifier([]);

  // 👇 DATA TAMBAHAN BARU: Daftar Riwayat Penyaluran Dana Keluar
  static final ValueNotifier<List<Map<String, dynamic>>> riwayatPenyaluran =
      ValueNotifier([]);

  // 2. Angka Saldo (Kita mulai dari 0 agar murni real-time dari donatur)
  static final ValueNotifier<int> totalDonasiTerkumpul = ValueNotifier(0);
  static final ValueNotifier<int> danaTersalurkan = ValueNotifier(0);

  // 3. Fungsi saat Donatur klik "Kirim Donasi" (Otomatis langsung masuk tanpa di-acc)
  static void tambahDonasiInstan(Map<String, dynamic> donasiBaru) {
    // Tambah ke total uang
    totalDonasiTerkumpul.value += donasiBaru['nominal'] as int;

    // Masukkan ke riwayat paling atas
    riwayatDonasi.value = [donasiBaru, ...riwayatDonasi.value];
  }

  // 4. Fungsi saat Admin menyalurkan/memakai uang yayasan (SEKARANG OTOMATIS MENCATAT)
  static void salurkanDanaAdmin(int nominal, String keterangan) {
    if (nominal > (totalDonasiTerkumpul.value - danaTersalurkan.value)) {
      throw Exception("Saldo Aktif tidak mencukupi!");
    }
    danaTersalurkan.value += nominal;

    // 👇 TAMBAHAN BARU: Otomatis memasukkan data ke riwayat pengeluaran dana keluar
    riwayatPenyaluran.value = [
      {
        'id': 'out${DateTime.now().millisecondsSinceEpoch}',
        'nominal': nominal,
        'keterangan': keterangan,
        'tgl': DateTime.now().toString().split(' ')[0], // Format: YYYY-MM-DD
      },
      ...riwayatPenyaluran.value,
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
      "desc":
          "Sebanyak 50 peserta program beasiswa VIP berhasil menyelesaikan pelatihan barista intensif selama 10 bulan...",
      "content":
          "Malang — Suasana haru dan bangga menyelimuti gedung pelatihan Vernon Edu pada pagi hari ini. Sebanyak 50 peserta program beasiswa Vernon Indonesia Pintar (VIP) secara resmi dinyatakan lulus dari program Pelatihan Barista Intensif Angkatan 1.\n\nSelama 10 bulan penuh, para peserta yang mayoritas berasal dari keluarga pra-sejahtera ini tidak hanya dibekali keahlian meracik kopi (brewing, latte art, dan espresso espresso base), tetapi juga dibekali materi kewirausahaan, pelayanan pelanggan, hingga literasi keuangan dasar.\n\nBapak Budi Santoso, selaku Direktur Program VIP, menyampaikan apresiasinya. 'Mereka datang ke sini dengan semangat belajar yang luar biasa. Kini mereka siap untuk diterjunkan langsung ke industri Food & Beverage yang sedang berkembang pesat,' ujarnya.\n\nSebagai langkah konkret, pihak Yayasan juga telah menjalin kerja sama dengan lebih dari 20 kedai kopi dan restoran di wilayah Jawa Timur untuk menyalurkan lulusan terbaik langsung bekerja. Semoga langkah ini menjadi awal yang cerah bagi masa depan mereka.",
      "kategori": "Berita",
      "image":
          "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=800&auto=format&fit=crop",
    },
    {
      "id": "A2",
      "title": "VernonCorp Buka Pendaftaran Beasiswa VIP Gelombang 2",
      "date": "02 Mei 2026",
      "desc":
          "Program beasiswa Vernon Indonesia Pintar (VIP) kembali dibuka untuk siswa berprestasi yang kurang mampu di seluruh Indonesia.",
      "content":
          "Jakarta — Kabar gembira bagi para pemuda-pemudi inspiratif di seluruh Nusantara. Yayasan Vernon Indonesia Pintar dengan bangga mengumumkan pembukaan pendaftaran beasiswa penuh gelombang ke-2 untuk tahun ajaran 2026/2027.\n\nProgram ini secara khusus menargetkan siswa-siswi berprestasi tingkat SMA/SMK sederajat yang menghadapi kendala finansial untuk melanjutkan pendidikan atau mendapatkan keterampilan siap kerja.\n\nSyarat utama pendaftaran meliputi:\n1. Fotokopi KTP/Kartu Pelajar\n2. Surat Keterangan Tidak Mampu (SKTM) dari Kelurahan\n3. Ijazah atau SKL Terakhir\n4. Lulus seleksi administrasi dan wawancara.\n\n'Kami menargetkan menjangkau 200 anak muda pada gelombang kedua ini. Mari manfaatkan kesempatan ini sebaik-baiknya,' ungkap tim pendaftaran VIP. Pendaftaran sepenuhnya dilakukan secara online melalui portal resmi website Vernon.",
      "kategori": "Pengumuman",
      "image":
          "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=800&auto=format&fit=crop",
    },
    {
      "id": "A3",
      "title": "Kisah Sukses: Dari Siswa SMK Menjadi Digital Marketer",
      "date": "25 April 2026",
      "desc":
          "Mengenal Budi, alumni VIP yang kini sukses menjadi spesialis pemasaran digital di salah satu startup terkemuka di Jakarta.",
      "content":
          "Menjadi seorang spesialis pemasaran digital (Digital Marketer) di salah satu startup teknologi terbesar di Jakarta mungkin terdengar seperti mimpi yang mustahil bagi seorang pemuda dari desa kecil di pinggiran kota. Namun, hal itu berhasil diwujudkan oleh Budi Haryanto, salah satu alumni pertama program vokasi Vernon Indonesia Pintar (VIP).\n\nBudi, lulusan SMK jurusan Akuntansi, awalnya kesulitan mencari pekerjaan yang layak. Lewat informasi dari gurunya, ia mencoba mendaftar Beasiswa VIP dan mengambil peminatan Pemasaran Digital.\n\n'Di Vernon Edu, saya diajarkan dari nol. Mulai dari dasar-dasar SEO, cara beriklan di media sosial, hingga membaca analisis data. Mentor-mentornya sangat praktikal,' kenang Budi.\n\nHanya berselang dua bulan pasca kelulusannya, Budi berhasil direkrut berkat portofolio kampanye digital yang ia buat sebagai tugas akhir di VIP. Kisah Budi membuktikan bahwa dedikasi dipadu dengan akses pendidikan yang tepat dapat benar-benar mengubah garis takdir seseorang.",
      "kategori": "Inspirasi",
      "image":
          "https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=800&auto=format&fit=crop",
    },
  ];

  static final List<Map<String, String>> _galeriList = [
    {
      "id": "G1",
      "title": "Kegiatan Orientasi Beasiswa VIP 2026",
      "image":
          "https://images.unsplash.com/photo-1515187029135-18ee286d815b?q=80&w=800&auto=format&fit=crop",
    },
    {
      "id": "G2",
      "title": "Sesi Praktik Pelatihan Barista",
      "image":
          "https://images.unsplash.com/photo-1511920170033-f8396924c648?q=80&w=800&auto=format&fit=crop",
    },
    {
      "id": "G3",
      "title": "Pemberian Sertifikat Kelulusan",
      "image":
          "https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=800&auto=format&fit=crop",
    },
    {
      "id": "G4",
      "title": "Kunjungan Industri ke VernonCorp",
      "image":
          "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=800&auto=format&fit=crop",
    },
  ];

  static List<Map<String, String>> getSemuaArtikel() => List.from(_artikelList);

  static void tambahArtikel(Map<String, String> artikel) {
    artikel['id'] = "A${DateTime.now().millisecondsSinceEpoch}";
    _artikelList.insert(0, artikel);
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

  static List<Map<String, String>> getSemuaGaleri() => List.from(_galeriList);

  static void tambahGaleri(Map<String, String> data) {
    data['id'] = "G${DateTime.now().millisecondsSinceEpoch}";
    _galeriList.insert(0, data);
  }

  static void editGaleri(String id, Map<String, String> dataBaru) {
    int index = _galeriList.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      _galeriList[index] = {..._galeriList[index], ...dataBaru};
    }
  }

  static void hapusGaleri(String id) {
    _galeriList.removeWhere((g) => g['id'] == id);
  }

  // ==========================================
  // DATA CMS BERANDA (HOME SCREEN)
  // ==========================================
  static Map<String, String> _homeHeroData = {
    "tagline": "#EmpowerTomorrowsLeaders",
    "title": "Your Support\nUnlocks\nEqual Futures",
    "subtitle":
        "Vernon Indonesia Pintar (VIP) memberdayakan generasi muda melalui beasiswa, pelatihan vokasi, dan penempatan kerja nyata.",
    "image":
        "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=1200&auto=format&fit=crop",
  };

  static Map<String, String> getHomeHeroData() => Map.from(_homeHeroData);
  static void updateHomeHeroData(Map<String, String> newData) {
    _homeHeroData = {..._homeHeroData, ...newData};
  }

  // ==========================================
  // DATA CMS ABOUT SECTION (KHUSUS BERANDA)
  // ==========================================
  static Map<String, String> _aboutSectionData = {
    "title": "Membantu Anak Bangsa Meraih Mimpi",
    "description":
        "Vernon Indonesia Pintar bukan sekadar yayasan beasiswa. Kami adalah inkubator karir bagi pemuda berpotensi dari keluarga tidak mampu.",
    "image":
        "https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop",
  };

  static Map<String, String> getAboutSectionData() =>
      Map.from(_aboutSectionData);
  static void updateAboutSectionData(Map<String, String> newData) {
    _aboutSectionData = {..._aboutSectionData, ...newData};
  }

  // ==========================================
  // DATA CMS PROFIL YAYASAN (HALAMAN PENUH NANTI)
  // ==========================================
  static Map<String, dynamic> _profilYayasanData = {
    "title": "Apa itu YAYASAN VERNON INDONESIA PINTAR (VIP)?",
    "description":
        "Kami adalah yayasan pendidikan yang berdedikasi penuh untuk memberdayakan generasi muda Indonesia. VIP hadir sebagai jembatan bagi mereka yang memiliki potensi besar namun terkendala secara finansial, untuk meraih masa depan yang lebih cerah.",
    "vision_text":
        "Mewujudkan generasi muda unggul dengan akses penuh pendidikan, pelatihan, dan kesempatan kerja setara demi Indonesia maju global.",
    "mission_points": [
      "Ekosistem pendampingan & pembiayaan anak berprestasi",
      "Hubungkan siswa-praktisi-industri",
      "Beasiswa + vokasi + soft skills",
      "Kawal dari belajar hingga kerja",
    ],
    "image": "",
  };

  static Map<String, dynamic> getProfilYayasanData() =>
      Map.from(_profilYayasanData);
  static void updateProfilYayasanData(Map<String, dynamic> newData) {
    _profilYayasanData = {..._profilYayasanData, ...newData};
  }

  // ==========================================
  // DATA CMS TESTIMONI (CERITA PERUBAHAN)
  // ==========================================
  static final List<Map<String, String>> _testimoniList = [
    {
      "id": "T1",
      "name": "Andi Pratama",
      "role": "Alumni Batch 1 - Karyawan IT",
      "quote":
          "Awalnya saya hampir putus asa karena tidak ada biaya kuliah. Berkat beasiswa vokasi VIP, saya dibimbing dari nol hingga sekarang bisa bekerja sebagai Junior Programmer di Jakarta.",
    },
    {
      "id": "T2",
      "name": "Siti Nurbaya",
      "role": "Alumni Batch 2 - UI/UX Designer",
      "quote":
          "Program 10 bulan ini sangat intensif dan daging semua. Fasilitas laptop gratis sangat membantu saya yang berasal dari desa. Terima kasih para donatur VIP!",
    },
    {
      "id": "T3",
      "name": "Budi Santoso",
      "role": "Alumni Batch 3 - Data Analyst",
      "quote":
          "Mentoring karirnya luar biasa. Saya tidak hanya diajari coding, tapi juga cara membuat CV dan wawancara kerja. Kini saya bisa mengangkat derajat keluarga.",
    },
  ];

  static List<Map<String, String>> getSemuaTestimoni() =>
      List.from(_testimoniList);

  static void tambahTestimoni(Map<String, String> data) {
    data['id'] = "T${DateTime.now().millisecondsSinceEpoch}";
    _testimoniList.add(data);
  }

  static void editTestimoni(String id, Map<String, String> dataBaru) {
    int index = _testimoniList.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      _testimoniList[index] = {..._testimoniList[index], ...dataBaru};
    }
  }

  static void hapusTestimoni(String id) {
    _testimoniList.removeWhere((t) => t['id'] == id);
  }

  // ==========================================
  // DATA CMS DETAIL PROGRAM (SYARAT & ALUR)
  // ==========================================
  static final Map<String, dynamic> _programDetailData = {
    "requirements": [
      {
        "title": "Syarat Umum",
        "points": [
          "Warga Negara Indonesia berusia minimal 18 tahun.",
          "Usia maksimal 25 tahun saat mendaftar.",
          "Berasal dari keluarga kurang mampu (PKH / KKS / SKTM).",
          "Belum bekerja atau belum memiliki penghasilan tetap.",
          "Bersedia mengikuti seluruh rangkaian program selama ±14 bulan.",
        ],
      },
      {
        "title": "Pendidikan",
        "points": [
          "Terbuka untuk semua jenjang pendidikan (SD / SMP / SMA / SMK sederajat).",
          "Memiliki ijazah atau Surat Keterangan Lulus (SKL).",
          "Tidak sedang menempuh pendidikan formal.",
        ],
      },
      {
        "title": "Karakter & Motivasi",
        "points": [
          "Memiliki semangat belajar yang tinggi dan tekad kuat.",
          "Bersikap jujur, disiplin, dan bertanggung jawab.",
          "Bersedia menerima arahan dan mentoring dari instruktur.",
          "Tidak sedang menerima beasiswa lain yang serupa.",
        ],
      },
      {
        "title": "Dokumen yang Diperlukan",
        "points": [
          "Fotokopi KTP.",
          "Fotokopi ijazah / SKL terakhir.",
          "Surat Keterangan Tidak Mampu (SKTM).",
          "Pas foto 3×4 terbaru (2 lembar).",
          "Surat motivasi tulis tangan (1 halaman).",
          "Nomor HP aktif & akun WhatsApp.",
        ],
      },
    ],
    "timeline": [
      {
        "title": "Pengisian formulir pendaftaran online",
        "description":
            "Isi data diri lengkap melalui website VIP. Lampirkan foto dokumen persyaratan.",
      },
      {
        "title": "Verifikasi dokumen & kelayakan administrasi",
        "description":
            "Tim VIP memverifikasi kelengkapan dokumen dan kesesuaian kriteria usia serta ekonomi.",
      },
      {
        "title": "Wawancara langsung dengan tim yayasan",
        "description":
            "Tahap penentu kelulusan seleksi. Tim yayasan menilai secara langsung kemampuan, karakter, and kesungguhan calon penerima.",
      },
      {
        "title": "Pengumuman hasil seleksi",
        "description":
            "Hasil seleksi diumumkan melalui website VIP. Calon penerima yang lolos menerima Surat Penetapan Beasiswa resmi.",
      },
      {
        "title": "Orientasi & penandatanganan perjanjian",
        "description":
            "Penerima beasiswa menghadiri sesi orientasi dan menandatangani surat komitmen mengikuti pelatihan hingga penempatan kerja.",
      },
      {
        "title": "Mulai pelatihan vokasi di Vernon Edu",
        "description":
            "Program resmi dimulai. Pelatihan intensif 10 bulan mencakup keterampilan barista, digital marketing, administrasi, atau bidang lain sesuai minat & kebutuhan industri.",
      },
    ],
  };

  static Map<String, dynamic> getProgramDetailData() =>
      Map.from(_programDetailData);

  static void updateProgramDetailData(Map<String, dynamic> newData) {
    _programDetailData.addAll(newData);
  }

  // ==========================================
  // DATA CMS OUR PARTNERS
  // ==========================================
  static final List<Map<String, dynamic>> _partnerList = [
    {
      "id": "P1",
      "name": "Bank Edukasi",
      "image": "https://cdn-icons-png.flaticon.com/512/2830/2830284.png",
    },
    {
      "id": "P2",
      "name": "TechCorp Inc.",
      "image": "https://cdn-icons-png.flaticon.com/512/3536/3536505.png",
    },
    {
      "id": "P3",
      "name": "Global NGO",
      "image": "https://cdn-icons-png.flaticon.com/512/2038/2038472.png",
    },
    {
      "id": "P4",
      "name": "IT Academy",
      "image": "https://cdn-icons-png.flaticon.com/512/2721/2721620.png",
    },
    {
      "id": "P5",
      "name": "Yayasan Peduli",
      "image": "https://cdn-icons-png.flaticon.com/512/3362/3362145.png",
    },
  ];

  static List<Map<String, dynamic>> getSemuaPartner() =>
      List.from(_partnerList);

  static void tambahPartner(Map<String, dynamic> data) {
    data['id'] = "P${DateTime.now().millisecondsSinceEpoch}";
    _partnerList.add(data);
  }

  static void editPartner(String id, Map<String, dynamic> data) {
    int idx = _partnerList.indexWhere((p) => p['id'] == id);
    if (idx != -1) _partnerList[idx] = {..._partnerList[idx], ...data};
  }

  static void hapusPartner(String id) =>
      _partnerList.removeWhere((p) => p['id'] == id);

  // ==========================================
  // DATA CMS FAQ
  // ==========================================
  static final List<Map<String, String>> _faqList = [
    {
      "id": "F1",
      "tanya": "Apa itu Yayasan Vernon Indonesia Pintar (VIP)?",
      "jawab":
          "Kami adalah yayasan pendidikan yang berdedikasi memberdayakan generasi muda Indonesia melalui akses setara ke pendidikan berkualitas, pelatihan vokasi, dan peluang karier.",
    },
    {
      "id": "F2",
      "tanya": "Apa itu Program Beasiswa VIP?",
      "jawab":
          "Program Beasiswa Vernon Indonesia Pintar (VIP) memberikan beasiswa penuh bagi anak-anak yang memenuhi kriteria agar mendapatkan pelatihan dan bantuan yang tepat.",
    },
    {
      "id": "F3",
      "tanya": "Berapa lama durasi program beasiswa ini berlangsung?",
      "jawab":
          "Program ini dirancang secara terstruktur dengan durasi:\n• Beasiswa Vokasi: 10 Bulan\n• Magang Industri: 4 Bulan",
    },
    {
      "id": "F4",
      "tanya": "Fasilitas apa saja yang didapatkan oleh penerima beasiswa?",
      "jawab":
          "Penerima beasiswa mendapatkan dukungan penuh melalui:\n• Tanggungan Biaya Pelatihan\n• Laptop & Alat Belajar\n• Uang Saku Bulanan\n• Akomodasi (Mess)\n• Sertifikasi Industri",
    },
    {
      "id": "F5",
      "tanya": "Apakah program beasiswa ini dipungut biaya?",
      "jawab":
          "Tidak. Program Beasiswa VIP memberikan beasiswa penuh (100% gratis) bagi mereka yang memenuhi kriteria, mulai dari awal pelatihan hingga magang.",
    },
    {
      "id": "F6",
      "tanya": "Bagaimana cara menghubungi pihak Yayasan VIP?",
      "jawab":
          "Anda dapat menghubungi kami melalui email di vernonindonesiapintar@gmail.com atau mengunjungi website resmi di yayasan.vip.",
    },
  ];

  static List<Map<String, String>> getSemuaFaq() => List.from(_faqList);

  static void tambahFaq(Map<String, String> data) {
    data['id'] = "F${DateTime.now().millisecondsSinceEpoch}";
    _faqList.add(data);
  }

  static void editFaq(String id, Map<String, String> dataBaru) {
    int index = _faqList.indexWhere((f) => f['id'] == id);
    if (index != -1) {
      _faqList[index] = {..._faqList[index], ...dataBaru};
    }
  }

  static void hapusFaq(String id) {
    _faqList.removeWhere((f) => f['id'] == id);
  }

  // ==========================================
  // DATA CMS FOOTER & KONTAK (REAL-TIME)
  // ==========================================
  static final ValueNotifier<Map<String, String>> footerData = ValueNotifier({
    'deskripsi':
        'Membangun generasi emas Indonesia melalui akses pendidikan yang merata dan berkualitas.',
    'alamat':
        'Jl. Letjen Sutoyo No.102A, Bunulrejo, Kec. Blimbing, Kota Malang, Jawa Timur, Indonesia',
    'whatsapp': 'https://wa.me/628885864995',
    'email': 'vernonindonesiapintar@gmail.com',
    'instagram': 'https://www.instagram.com/yayasanvip',
  });
}
