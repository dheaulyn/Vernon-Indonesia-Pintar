// lib/data/faq_data.dart
import 'package:flutter/material.dart';

// Gunakan ChangeNotifier agar UI bisa otomatis me-refresh jika data berubah
class FaqDataStore extends ChangeNotifier {
  // Ini adalah data yang akan dipakai BERSAMA
  final List<Map<String, String>> faqBerprestasi = [
    {
      "tanya": "Apa syarat nilai/prestasi untuk Beasiswa Berprestasi?",
      "jawab": "Pendaftar wajib memiliki IPK minimal 3.20 (untuk mahasiswa) atau rata-rata rapor 85.00 (untuk siswa SMA). Prestasi tingkat nasional atau internasional akan menjadi nilai tambah yang besar.",
    },
    {
      "tanya": "Apakah Beasiswa Berprestasi mengcover biaya hidup?",
      "jawab": "Ya, Beasiswa Berprestasi memberikan pembebasan biaya pendidikan (UKT/SPP) 100% sekaligus uang saku bulanan sebesar Rp 1.500.000.",
    },
  ];

  final List<Map<String, String>> faqReguler = [
    {
      "tanya": "Apa itu Beasiswa Reguler?",
      "jawab": "Program bantuan pendidikan yang ditujukan bagi masyarakat umum guna menjamin keberlangsungan pendidikan bagi siswa/mahasiswa yang memiliki keterbatasan finansial.",
    },
  ];

  // Fungsi untuk Tambah Data
  void addFaq(int tabIndex, String tanya, String jawab) {
    if (tabIndex == 0) {
      faqBerprestasi.add({"tanya": tanya, "jawab": jawab});
    } else {
      faqReguler.add({"tanya": tanya, "jawab": jawab});
    }
    notifyListeners(); // Beri tahu seluruh halaman untuk me-refresh!
  }

  // Fungsi untuk Edit Data
  void editFaq(int tabIndex, int itemIndex, String tanya, String jawab) {
    if (tabIndex == 0) {
      faqBerprestasi[itemIndex] = {"tanya": tanya, "jawab": jawab};
    } else {
      faqReguler[itemIndex] = {"tanya": tanya, "jawab": jawab};
    }
    notifyListeners();
  }

  // Fungsi untuk Hapus Data
  void removeFaq(int tabIndex, int itemIndex) {
    if (tabIndex == 0) {
      faqBerprestasi.removeAt(itemIndex);
    } else {
      faqReguler.removeAt(itemIndex);
    }
    notifyListeners();
  }
}

// Global variable (Sederhana untuk tahap testing)
// Nanti, tim backend akan mengganti ini dengan Provider/Riverpod yang lebih kokoh
final globalFaqStore = FaqDataStore();