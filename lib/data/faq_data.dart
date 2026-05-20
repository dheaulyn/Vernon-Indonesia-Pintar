import 'package:flutter/material.dart';

class FaqDataStore extends ChangeNotifier {
  // Data FAQ tunggal yang disesuaikan dengan konten Instagram resmi @yayasanvip
  final List<Map<String, String>> faqList = [
    {
      "tanya": "Apa itu Yayasan Vernon Indonesia Pintar (VIP)?",
      "jawab":
          "Kami adalah yayasan pendidikan yang berdedikasi memberdayakan generasi muda Indonesia melalui akses setara ke pendidikan berkualitas, pelatihan vokasi, dan peluang karier.",
    },
    {
      "tanya": "Apa itu Program Beasiswa VIP?",
      "jawab":
          "Program Beasiswa Vernon Indonesia Pintar (VIP) memberikan beasiswa penuh bagi anak-anak yang memenuhi kriteria agar mendapatkan pelatihan dan bantuan yang tepat.",
    },
    {
      "tanya": "Berapa lama durasi program beasiswa ini berlangsung?",
      "jawab":
          "Program ini dirancang secara terstruktur dengan durasi:\n• Beasiswa Vokasi: 10 Bulan\n• Magang Industri: 4 Bulan",
    },
    {
      "tanya": "Fasilitas apa saja yang didapatkan oleh penerima beasiswa?",
      "jawab":
          "Penerima beasiswa mendapatkan dukungan penuh melalui:\n• Tanggungan Biaya Pelatihan\n• Laptop & Alat Belajar\n• Uang Saku Bulanan\n• Akomodasi (Mess)\n• Sertifikasi Industri",
    },
    {
      "tanya": "Apakah program beasiswa ini dipungut biaya?",
      "jawab":
          "Tidak. Program Beasiswa VIP memberikan beasiswa penuh (100% gratis) bagi mereka yang memenuhi kriteria, mulai dari awal pelatihan hingga magang.",
    },
    {
      "tanya": "Bagaimana cara menghubungi pihak Yayasan VIP?",
      "jawab":
          "Anda dapat menghubungi kami melalui email di vernonindonesiapintar@gmail.com atau mengunjungi website resmi di yayasan.vip.",
    },
  ];

  // Fungsi Tambah Data (Tanpa tabIndex karena kategori sudah digabung)
  void addFaq(String tanya, String jawab) {
    faqList.add({"tanya": tanya, "jawab": jawab});
    notifyListeners();
  }

  // Fungsi Edit Data
  void editFaq(int itemIndex, String tanya, String jawab) {
    if (itemIndex >= 0 && itemIndex < faqList.length) {
      faqList[itemIndex] = {"tanya": tanya, "jawab": jawab};
      notifyListeners();
    }
  }

  // Fungsi Hapus Data
  void removeFaq(int itemIndex) {
    if (itemIndex >= 0 && itemIndex < faqList.length) {
      faqList.removeAt(itemIndex);
      notifyListeners();
    }
  }
}

// Global variable untuk testing dan sinkronisasi antar halaman
final globalFaqStore = FaqDataStore();
