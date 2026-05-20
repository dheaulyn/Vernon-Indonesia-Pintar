import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // State local pengganti ValueNotifier kemarin agar UI tetap reaktif secara Real-time
  static final ValueNotifier<List<Map<String, dynamic>>> riwayatDonasi =
      ValueNotifier([]);
  static final ValueNotifier<List<Map<String, dynamic>>> riwayatPenyaluran =
      ValueNotifier([]);
  static final ValueNotifier<int> totalDonasiTerkumpul = ValueNotifier(0);
  static final ValueNotifier<int> danaTersalurkan = ValueNotifier(0);

  static Map<String, dynamic>? currentDonatur;

  // ==========================================
  // 1. FITUR AUTENTIKASI DONATUR
  // ==========================================
  static Future<bool> loginDonatur(String email, String password) async {
    try {
      final response = await _client
          .from('donatur_accounts')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response != null && response['password'] == password) {
        currentDonatur = response;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerDonatur(
    String name,
    String email,
    String password,
  ) async {
    try {
      await _client.from('donatur_accounts').insert({
        'name': name.toUpperCase(),
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static void logoutDonatur() {
    currentDonatur = null;
  }

  // ==========================================
  // 2. FITUR ALIRAN DANA & REAL-TIME STREAM
  // ==========================================

  // Fungsi dipanggil pertama kali saat aplikasi dibuka untuk mendengarkan perubahan database di awan
  static void listenToFinancialRealtime() {
    // A. Dengarkan tabel donasi masuk
    _client.from('donations').stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      // Urutkan data donasi terbaru ke paling atas
      data.sort((a, b) => b['created_at'].compareTo(a['created_at']));
      riwayatDonasi.value = data;

      // Hitung akumulasi kotor Donasi Masuk secara otomatis
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

      // Hitung akumulasi Dana Tersalurkan secara otomatis
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
    await _client.from('donations').insert({
      'nama_donatur': nama.isEmpty ? 'Hamba Allah' : nama,
      'email': currentDonatur?['email'],
      'program_name': program,
      'amount': nominal,
    });
  }

  // Fungsi saat Admin mencatatkan pengeluaran di halaman Penyaluran Dana
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
  }
}
