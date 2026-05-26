import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_auth_service.dart';
import 'supabase_notification_service.dart';

class SupabaseDonationService {
  static final SupabaseClient _client = Supabase.instance.client;

  // State local pengganti ValueNotifier kemarin agar UI tetap reaktif secara Real-time
  static final ValueNotifier<List<Map<String, dynamic>>> riwayatDonasi =
      ValueNotifier([]);
  static final ValueNotifier<List<Map<String, dynamic>>> riwayatPenyaluran =
      ValueNotifier([]);
  static final ValueNotifier<int> totalDonasiTerkumpul = ValueNotifier(0);
  static final ValueNotifier<int> danaTersalurkan = ValueNotifier(0);

  // ==========================================
  // FITUR ALIRAN DANA & REAL-TIME STREAM (TUGAS DHEA)
  // ==========================================

  // Fungsi dipanggil pertama kali saat aplikasi dibuka untuk mendengarkan perubahan database
  static void listenToFinancialRealtime() {
    // A. Dengarkan tabel donasi masuk
    _client.from('donations').stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      data.sort((a, b) => b['created_at'].compareTo(a['created_at']));
      riwayatDonasi.value = data;

      int total = data.fold(
        0,
        (sum, item) => sum + (item['amount'] as int? ?? 0),
      );
      totalDonasiTerkumpul.value = total;
    });

    // B. Dengarkan tabel penyaluran dana keluar
    _client.from('disbursements').stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      data.sort((a, b) => b['created_at'].compareTo(a['created_at']));
      riwayatPenyaluran.value = data;

      int tersalurkan = data.fold(
        0,
        (sum, item) => sum + (item['nominal'] as int? ?? 0),
      );
      danaTersalurkan.value = tersalurkan;
    });
  }

  // Fungsi saat Donatur mengirim uang dari halaman Formulir Donasi
  static Future<void> kirimDonasiKeCloud(
    String nama,
    String program,
    int nominal,
  ) async {
    // 👇 2. KUNCI KOLABORASI: Ambil email user yang sedang login dari file Nabila
    final user = SupabaseAuthService.currentUserData;
    final emailDonatur = user?['email'];
    final uid = Supabase.instance.client.auth.currentUser?.id;

    await _client.from('donations').insert({
      'donatur_email': emailDonatur,
      'nama_donatur': nama.isEmpty ? 'Hamba Allah' : nama,
      'program_name': program,
      'amount': nominal,
    });

    // 🔔 Buat notifikasi untuk ADMIN
    await SupabaseNotificationService.createNotification(
      userId: null, // Global untuk admin
      title: 'Donasi Masuk',
      message: 'Donasi sebesar Rp $nominal berhasil diterima dari ${nama.isEmpty ? 'Hamba Allah' : nama} untuk program $program.',
      type: 'donasi_masuk',
    );

    // 🔔 Buat notifikasi untuk DONATUR (jika login)
    if (uid != null) {
      await SupabaseNotificationService.createNotification(
        userId: uid,
        title: 'Donasi Berhasil',
        message: 'Terima kasih! Donasi Anda sebesar Rp $nominal untuk program $program telah kami terima.',
        type: 'donasi_sukses',
      );
    }
  }

  // Fungsi saat Admin mencatatkan pengeluaran
  static Future<void> catatPengeluaranKeCloud(
    int nominal,
    String kategori,
  ) async {
    int saldoAktif = totalDonasiTerkumpul.value - danaTersalurkan.value;
    if (nominal > saldoAktif) {
      throw Exception("Saldo Aktif tidak mencukupi!");
    }

    await _client.from('disbursements').insert({
      'keterangan': kategori,
      'nominal': nominal,
    });

    // Buat notifikasi ke admin (global)
    await SupabaseNotificationService.createNotification(
      userId: null,
      title: 'Penyaluran Dana',
      message: 'Penyaluran dana berhasil ke kategori $kategori sebesar Rp $nominal.',
      type: 'donasi_keluar',
    );
  }
}
