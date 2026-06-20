import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCmsService {
  static final _supabase = Supabase.instance.client;

  // Tabungan data dinamis yang bisa didengarkan oleh halaman depan (Real-time).
  static final ValueNotifier<Map<String, dynamic>> heroBanner = ValueNotifier(
    {},
  );
  static final ValueNotifier<Map<String, dynamic>> aboutUs = ValueNotifier({});
  static final ValueNotifier<Map<String, dynamic>> foundationProfile =
      ValueNotifier({});
  static final ValueNotifier<Map<String, dynamic>> impactSection =
      ValueNotifier({});
  static final ValueNotifier<Map<String, dynamic>> sectionHeaders =
      ValueNotifier({});

  static bool _isInitialized = false;

  /// Fungsi untuk menyalukan "radar" realtime ke Supabase CMS.
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Dengarkan perubahan tabel Hero Banner secara live.
    _supabase.from('cms_hero_banners').stream(primaryKey: ['id']).listen((
      data,
    ) {
      if (data.isNotEmpty) {
        heroBanner.value = data.first;
      }
    });

    // 2. Dengarkan perubahan tabel Tentang Kami secara live.
    _supabase.from('cms_about_us').stream(primaryKey: ['id']).listen((data) {
      if (data.isNotEmpty) {
        aboutUs.value = data.first;
      }
    });

    // 3. Dengarkan perubahan tabel Profil Yayasan (Visi Misi) secara live.
    _supabase.from('cms_foundation_profiles').stream(primaryKey: ['id']).listen(
      (data) {
        if (data.isNotEmpty) {
          foundationProfile.value = data.first;
        }
      },
    );

    // 4. Dengarkan perubahan tabel Impact Section secara live.
    _supabase.from('cms_impact_section').stream(primaryKey: ['id']).listen(
      (data) {
        if (data.isNotEmpty) {
          impactSection.value = data.first;
        }
      },
    );

    // 5. Dengarkan perubahan tabel Section Headers secara live.
    _supabase.from('cms_section_headers').stream(primaryKey: ['id']).listen(
      (data) {
        if (data.isNotEmpty) {
          sectionHeaders.value = data.first;
        }
      },
    );
  }
}

