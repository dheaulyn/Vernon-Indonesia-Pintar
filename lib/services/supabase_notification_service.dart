import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNotificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  // State local agar UI reaktif terhadap perubahan (seperti ValueNotifier pada Pendaftaran)
  static final ValueNotifier<List<Map<String, dynamic>>> notifications = ValueNotifier([]);

  static bool _isListening = false;

  // Mulai mendengarkan perubahan tabel notifikasi secara real-time
  static void listenToNotifications() {
    if (_isListening) return;
    _isListening = true;
    _client.from('notifikasi_donasi').stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      // Supabase secara otomatis akan mengaplikasikan kebijakan RLS 
      // sehingga pengguna hanya menerima notifikasi yang diizinkan untuknya.
      data.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
      notifications.value = data;
    });
  }

  // Menandai notifikasi sebagai sudah dibaca
  static Future<void> markAsRead(String id) async {
    try {
      // Update lokal terlebih dahulu agar UI langsung responsif
      notifications.value = notifications.value.map((n) {
        if (n['id'] == id) {
          return {...n, 'is_read': true};
        }
        return n;
      }).toList();

      // Lalu update ke database
      await _client.from('notifikasi_donasi').update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  // Menandai SEMUA notifikasi sebagai sudah dibaca untuk user ini
  static Future<void> markAllAsRead(String? userId) async {
    try {
      // Update lokal
      notifications.value = notifications.value.map((n) {
        if (userId == null ? n['user_id'] == null : n['user_id'] == userId) {
          return {...n, 'is_read': true};
        }
        return n;
      }).toList();

      // Update database
      if (userId == null) {
        await _client.from('notifikasi_donasi').update({'is_read': true}).isFilter('user_id', null);
      } else {
        await _client.from('notifikasi_donasi').update({'is_read': true}).eq('user_id', userId);
      }
    } catch (e) {
      debugPrint("Error marking all as read: $e");
    }
  }

  // Memasukkan notifikasi baru ke database
  static Future<void> createNotification({
    String? userId, // Jika null, artinya ini ditujukan untuk Admin
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final payload = <String, dynamic>{
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
      };
      if (userId != null) {
        payload['user_id'] = userId;
      }
      
      // Insert ke database dan ambil data yang baru dibuat
      final inserted = await _client
          .from('notifikasi_donasi')
          .insert(payload)
          .select()
          .single();

      // Langsung tambahkan ke data lokal agar UI langsung update
      notifications.value = [inserted, ...notifications.value];
    } catch (e) {
      debugPrint("Error inserting notification: $e");
    }
  }
}
