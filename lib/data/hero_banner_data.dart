import 'package:flutter/material.dart';

class HeroBannerDataStore extends ChangeNotifier {
  String heroSubtitle1 = "PROGRAM BEASISWA VERNON INDONESIA PINTAR";
  String heroTitle = "Membuka Pintu Dunia\nLewat Pendidikan";
  
  // 👇 Simpan teks dasar saja (tanpa status buka/tutup)
  String heroSubtitle2Base = "Pendaftaran Beasiswa Periode 2026"; 
  bool isRegistrationOpen = true; 

  void updateHeroBanner(String sub1, String title, String sub2Base, bool isOpen) {
    heroSubtitle1 = sub1;
    heroTitle = title;
    heroSubtitle2Base = sub2Base;
    isRegistrationOpen = isOpen;
    notifyListeners(); 
  }
}

final globalHeroBannerStore = HeroBannerDataStore();