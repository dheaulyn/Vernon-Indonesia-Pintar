import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

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
    String? telepon,
  ]) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Upsert data ke tabel profiles untuk menghindari error jika trigger DB sudah membuat row
        await _client.from('profiles').upsert({
          'id': res.user!.id,
          'email': email,
          'name': name.toUpperCase(),
          'role': role,
          'telepon': telepon,
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

  /// Mereset password dengan verifikasi data (email + nama lengkap).
  /// Memanggil RPC function di Supabase yang memverifikasi identitas
  /// dan langsung mengupdate password tanpa perlu email.
  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  static Future<String?> verifyAndResetPassword(
    String email,
    String name,
    String newPassword,
  ) async {
    try {
      final result = await _client.rpc('reset_password_with_verification', params: {
        'p_email': email.trim(),
        'p_name': name.trim(),
        'p_new_password': newPassword,
      });

      if (result == null) {
        return 'Terjadi kesalahan. Silakan coba lagi.';
      }

      final Map<String, dynamic> response = result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result as Map);

      if (response['success'] == true) {
        return null; // null = sukses
      }

      // Terjemahkan pesan error dari RPC
      final message = response['message'] as String? ?? '';
      switch (message) {
        case 'EMAIL_NOT_FOUND':
          return 'Email tidak ditemukan. Pastikan email yang Anda masukkan benar.';
        case 'NAME_MISMATCH':
          return 'Nama lengkap tidak cocok dengan data yang terdaftar.';
        default:
          return 'Terjadi kesalahan. Silakan coba lagi.';
      }
    } catch (e) {
      debugPrint('verifyAndResetPassword Error: $e');
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
    if (user != null) {
      try {
        final data = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (data != null) {
          currentUserData = data;
        }
      } catch (e) {
        debugPrint('RestoreSession Error: $e');
      }
    }
  }

  /// Mengupdate field-field tertentu di tabel profiles untuk user yang sedang login.
  /// Setelah update, currentUserData juga disinkronkan.
  static Future<String?> updateProfileFields(Map<String, dynamic> fields) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 'User belum login.';

      await _client.from('profiles').update(fields).eq('id', user.id);

      // Sinkronkan data lokal
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        currentUserData = data;
      }

      return null; // null = sukses
    } catch (e) {
      debugPrint('updateProfileFields Error: $e');
      return 'Gagal mengupdate data: $e';
    }
  }

  /// Mengubah password user yang sedang login.
  static Future<String?> changePassword(String newPassword) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 'User belum login.';

      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      debugPrint('changePassword AuthException: ${e.message}');
      if (e.message.toLowerCase().contains('different')) {
        return 'Password baru harus berbeda dengan password saat ini.';
      }
      return e.message;
    } catch (e) {
      debugPrint('changePassword Error: $e');
      return 'Gagal mengubah password: $e';
    }
  }

  /// Mengunggah foto profil ke bucket 'avatars' dan mengupdate field avatar_url
  static Future<String?> uploadAvatar(PlatformFile file) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 'User belum login.';
      if (file.bytes == null) return 'File tidak valid.';

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeOriginalName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');
      final fileName = '${user.id}_${timestamp}_$safeOriginalName';

      // 1. Upload file ke bucket 'avatars'
      await _client.storage.from('avatars').uploadBinary(
            fileName,
            file.bytes!,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Dapatkan public URL
      final avatarUrl = _client.storage.from('avatars').getPublicUrl(fileName);

      // 3. Update field avatar_url di tabel profiles
      final updateError = await updateProfileFields({'avatar_url': avatarUrl});
      
      if (updateError != null) {
        return updateError;
      }

      return null;
    } catch (e) {
      debugPrint('uploadAvatar Error: $e');
      return 'Gagal mengunggah foto profil: $e';
    }
  }
}
