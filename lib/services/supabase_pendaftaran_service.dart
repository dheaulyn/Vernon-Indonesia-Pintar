import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'supabase_auth_service.dart';

/// Service untuk mengelola data pendaftaran siswa ke Supabase.
/// Menangani:
/// - Submit pendaftaran siswa (form beasiswa)
/// - Update data revisi oleh siswa
/// - Ambil semua pendaftar (untuk admin)
/// - Update status oleh admin
/// - Real-time listener untuk data pendaftar
class SupabasePendaftaranService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// ValueNotifier untuk data pendaftar real-time (admin dashboard)
  static final ValueNotifier<List<Map<String, dynamic>>> listPendaftar =
      ValueNotifier([]);

  // ==========================================
  // HELPER: UPLOAD FILE KE STORAGE
  // ==========================================
  static Future<String?> _uploadFileToStorage(
      PlatformFile file, String userId, String type) async {
    if (file.bytes == null) return null;

    try {
      // Buat nama file unik: userId_type_timestamp_namafile
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Hapus karakter bermasalah pada nama file asli
      final safeOriginalName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');
      final fileName = '${userId}_${type}_${timestamp}_$safeOriginalName';

      await _client.storage.from('berkas_pendaftaran').uploadBinary(
            fileName,
            file.bytes!,
            fileOptions: const FileOptions(upsert: true),
          );

      return _client.storage.from('berkas_pendaftaran').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('_uploadFileToStorage Error ($type): $e');
      return null;
    }
  }

  // ==========================================
  // FUNGSI SISWA: SUBMIT PENDAFTARAN BARU
  // ==========================================

  /// Menyimpan data pendaftaran ke tabel `profiles` di Supabase.
  /// Dipanggil saat siswa mengisi formulir beasiswa dan klik submit.
  static Future<String?> submitPendaftaran({
    required String nama,
    required String nik,
    required String telepon,
    required String domisili,
    required String pendidikan,
    required String asalSekolah,
    required String tahunLulus,
    PlatformFile? fileKtp,
    PlatformFile? fileRapor,
    PlatformFile? fileFoto,
    PlatformFile? fileMotivasi,
    PlatformFile? fileSktm,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 'User belum login.';

      String? ktpUrl, raporUrl, fotoUrl, motivasiUrl, sktmUrl;

      // Upload file jika ada
      if (fileKtp != null) ktpUrl = await _uploadFileToStorage(fileKtp, user.id, 'ktp');
      if (fileRapor != null) raporUrl = await _uploadFileToStorage(fileRapor, user.id, 'rapor');
      if (fileFoto != null) fotoUrl = await _uploadFileToStorage(fileFoto, user.id, 'foto');
      if (fileMotivasi != null) motivasiUrl = await _uploadFileToStorage(fileMotivasi, user.id, 'motivasi');
      if (fileSktm != null) sktmUrl = await _uploadFileToStorage(fileSktm, user.id, 'sktm');

      await _client.from('profiles').update({
        'name': nama.toUpperCase(),
        'nik': nik,
        'telepon': telepon,
        'domisili': domisili,
        'pendidikan': pendidikan,
        'asal_sekolah': asalSekolah,
        'tahun_lulus': tahunLulus,
        'file_ktp': ktpUrl,
        'file_rapor': raporUrl,
        'file_foto': fotoUrl,
        'file_motivasi': motivasiUrl,
        'file_sktm': sktmUrl,
        'tgl_daftar': DateTime.now().toIso8601String(),
        'is_registered': true,
        'current_step': 1,
        'is_revisi': false,
        'catatan_revisi': '',
        'admin_status': 'Menunggu Review',
      }).eq('id', user.id);

      // Sinkronkan data lokal agar UI langsung update
      await _refreshCurrentUserData();

      return null; // null = sukses
    } catch (e) {
      debugPrint('submitPendaftaran Error: $e');
      return 'Terjadi kesalahan saat mengirim pendaftaran: $e';
    }
  }

  // ==========================================
  // FUNGSI SISWA: SUBMIT REVISI
  // ==========================================

  /// Menyimpan data revisi siswa ke tabel `profiles` dan reset status ke "Menunggu Review".
  static Future<String?> submitRevisi({
    required String nama,
    required String nik,
    required String telepon,
    required String domisili,
    required String pendidikan,
    required String asalSekolah,
    required String tahunLulus,
    PlatformFile? fileKtp,
    PlatformFile? fileRapor,
    PlatformFile? fileFoto,
    PlatformFile? fileMotivasi,
    PlatformFile? fileSktm,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 'User belum login.';

      String? ktpUrl, raporUrl, fotoUrl, motivasiUrl, sktmUrl;

      // Upload file jika ada
      if (fileKtp != null) ktpUrl = await _uploadFileToStorage(fileKtp, user.id, 'ktp');
      if (fileRapor != null) raporUrl = await _uploadFileToStorage(fileRapor, user.id, 'rapor');
      if (fileFoto != null) fotoUrl = await _uploadFileToStorage(fileFoto, user.id, 'foto');
      if (fileMotivasi != null) motivasiUrl = await _uploadFileToStorage(fileMotivasi, user.id, 'motivasi');
      if (fileSktm != null) sktmUrl = await _uploadFileToStorage(fileSktm, user.id, 'sktm');

      // Ambil data lama jika ada file yang tidak diupload ulang
      final oldData = await _client.from('profiles').select().eq('id', user.id).maybeSingle();

      await _client.from('profiles').update({
        'name': nama.toUpperCase(),
        'nik': nik,
        'telepon': telepon,
        'domisili': domisili,
        'pendidikan': pendidikan,
        'asal_sekolah': asalSekolah,
        'tahun_lulus': tahunLulus,
        'file_ktp': ktpUrl ?? oldData?['file_ktp'],
        'file_rapor': raporUrl ?? oldData?['file_rapor'],
        'file_foto': fotoUrl ?? oldData?['file_foto'],
        'file_motivasi': motivasiUrl ?? oldData?['file_motivasi'],
        'file_sktm': sktmUrl ?? oldData?['file_sktm'],
        'is_revisi': false,
        'catatan_revisi': '',
        'admin_status': 'Menunggu Review',
        'current_step': 1,
      }).eq('id', user.id);

      // Sinkronkan data lokal
      await _refreshCurrentUserData();

      return null; // null = sukses
    } catch (e) {
      debugPrint('submitRevisi Error: $e');
      return 'Terjadi kesalahan saat mengirim revisi: $e';
    }
  }

  // ==========================================
  // FUNGSI SISWA: AMBIL DATA PENDAFTARAN SENDIRI
  // ==========================================

  /// Mengambil data pendaftaran user yang sedang login dari Supabase.
  /// Berguna untuk memuat ulang data setelah refresh halaman.
  static Future<Map<String, dynamic>?> getMyPendaftaran() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return data;
    } catch (e) {
      debugPrint('getMyPendaftaran Error: $e');
      return null;
    }
  }

  // ==========================================
  // FUNGSI ADMIN: AMBIL SEMUA PENDAFTAR
  // ==========================================

  /// Mengambil semua siswa yang sudah mendaftar (is_registered = true)
  /// untuk ditampilkan di halaman manajemen pendaftar admin.
  static Future<List<Map<String, dynamic>>> getAllPendaftar() async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('role', 'siswa')
          .eq('is_registered', true)
          .order('tgl_daftar', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('getAllPendaftar Error: $e');
      return [];
    }
  }

  /// Mengambil data detail satu pendaftar berdasarkan email.
  static Future<Map<String, dynamic>?> getDetailPendaftar(String email) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      return data;
    } catch (e) {
      debugPrint('getDetailPendaftar Error: $e');
      return null;
    }
  }

  // ==========================================
  // FUNGSI ADMIN: UPDATE STATUS PENDAFTAR
  // ==========================================

  /// Mengubah status pendaftar oleh admin.
  /// Menangani logika status: Revisi, Wawancara, Diterima, Pelatihan, Lulus, Ditolak.
  static Future<String?> updateStatusPendaftar({
    required String email,
    required String newStatus,
    String catatan = '',
    String? jadwalWawancara,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'admin_status': newStatus,
      };

      if (newStatus == 'Revisi') {
        updateData['is_revisi'] = true;
        updateData['catatan_revisi'] = catatan;
        updateData['current_step'] = 1;
      } else {
        updateData['is_revisi'] = false;
        updateData['catatan_revisi'] = '';

        if (newStatus == 'Menunggu Review') updateData['current_step'] = 1;
        if (newStatus == 'Wawancara') {
          updateData['current_step'] = 2;
          if (jadwalWawancara != null && jadwalWawancara.isNotEmpty) {
            updateData['jadwal_wawancara'] = jadwalWawancara;
          }
        }
        if (newStatus == 'Diterima') updateData['current_step'] = 4;
        if (newStatus == 'Pelatihan') updateData['current_step'] = 5;
        if (newStatus == 'Lulus') updateData['current_step'] = 6;
      }

      await _client
          .from('profiles')
          .update(updateData)
          .eq('email', email);

      return null; // null = sukses
    } catch (e) {
      debugPrint('updateStatusPendaftar Error: $e');
      return 'Gagal update status: $e';
    }
  }

  // ==========================================
  // REAL-TIME LISTENER (UNTUK ADMIN)
  // ==========================================

  /// Mendengarkan perubahan data pendaftar secara real-time.
  /// Otomatis di-trigger ketika ada siswa baru yang mendaftar atau status berubah.
  static void listenToPendaftaranRealtime() {
    _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('role', 'siswa')
        .listen((List<Map<String, dynamic>> data) {
          // Filter hanya yang sudah mendaftar
          final registered = data
              .where((d) => d['is_registered'] == true)
              .toList();

          // Urutkan berdasarkan tanggal daftar terbaru
          registered.sort((a, b) {
            final dateA = a['tgl_daftar'] ?? '';
            final dateB = b['tgl_daftar'] ?? '';
            return dateB.toString().compareTo(dateA.toString());
          });

          listPendaftar.value = registered;
        });
  }

  // ==========================================
  // HELPER: REFRESH DATA USER YANG SEDANG LOGIN
  // ==========================================

  /// Mengambil ulang data profiles dari Supabase dan menyimpannya
  /// ke SupabaseAuthService.currentUserData agar UI tetap sinkron.
  static Future<void> _refreshCurrentUserData() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        SupabaseAuthService.currentUserData = data;
      }
    } catch (e) {
      debugPrint('_refreshCurrentUserData Error: $e');
    }
  }

  /// Public method untuk refresh data user yang sedang login.
  /// Bisa dipanggil dari screen manapun setelah operasi penting.
  static Future<void> refreshCurrentUser() async {
    await _refreshCurrentUserData();
  }
}
