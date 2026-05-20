import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Menyimpan data profil user yang sedang login
  static Map<String, dynamic>? currentUserData;

  /// Melakukan login dan mengembalikan role dari tabel profiles
  static Future<String?> loginRole(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Ambil data profil berdasarkan email atau id
        final data = await _client
            .from('profiles')
            .select()
            .eq('email', email)
            .maybeSingle(); // maybeSingle mencegah error jika tidak ditemukan

        if (data != null) {
          currentUserData = data;
          return data['role'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return null;
    }
    return null;
  }

  /// Melakukan registrasi user baru ke auth dan tabel profiles.
  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  static Future<String?> register(
    String name,
    String email,
    String password, [
    String role = 'siswa',
  ]) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Insert data ke tabel profiles
        await _client.from('profiles').insert({
          'id': res.user!.id,
          'email': email,
          'name': name.toUpperCase(),
          'role': role,
          'is_registered': false,
          'current_step': 0,
          'is_revisi': false,
          'catatan_revisi': '',
          'admin_status': 'Menunggu Review',
        });
        return null; // null = sukses
      }
      return 'Registrasi gagal. Coba lagi.';
    } on AuthException catch (e) {
      debugPrint('Register AuthException: ${e.message}');
      // Terjemahkan pesan Supabase yang umum
      if (e.message.contains('already registered') || e.message.contains('User already registered')) {
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau login.';
      } else if (e.message.contains('Password should be at least')) {
        return 'Password terlalu pendek. Minimal 6 karakter.';
      } else if (e.message.contains('invalid')) {
        return 'Format email tidak valid.';
      } else if (e.message.contains('rate limit') || e.message.contains('email rate limit') || e.message.contains('over_email_send_rate_limit')) {
        return 'Terlalu banyak percobaan. Silakan tunggu beberapa menit sebelum mencoba lagi.';
      }
      return e.message;
    } catch (e) {
      debugPrint('Register Error: $e');
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Logout user
  static Future<void> logout() async {
    await _client.auth.signOut();
    currentUserData = null;
  }

  /// Mengecek apakah user saat ini sedang login di Supabase
  static bool get isLoggedIn => _client.auth.currentUser != null;

  /// Memulihkan sesi dari Supabase jika ada (dipanggil saat app start)
  /// Berguna ketika user me-refresh halaman sehingga currentUserData di-load ulang.
  static Future<void> restoreSession() async {
    final user = _client.auth.currentUser;
    if (user != null && currentUserData == null) {
      try {
        final data = await _client
            .from('profiles')
            .select()
            .eq('email', user.email!)
            .maybeSingle();
        if (data != null) {
          currentUserData = data;
        }
      } catch (e) {
        debugPrint('RestoreSession Error: $e');
      }
    }
  }
}
