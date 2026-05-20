import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '/data/mock_database.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  late Map<String, dynamic> _tentangKamiData;

  @override
  void initState() {
    super.initState();
    // Menarik data CMS "Tentang Kami" dari database
    _tentangKamiData = MockDatabase.getAboutSectionData();
  }

  // Fungsi pintar untuk merender gambar (URL atau Base64)
  Widget _buildImageDisplay(String imageSource, bool isMobile) {
    final double? height = isMobile ? 250 : null;

    if (imageSource.isEmpty) {
      // Fallback ke gambar lokal jika kosong
      return Image.asset(
        'assets/tentang.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );
    }
    if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );
    }
    try {
      return Image.memory(
        base64Decode(imageSource),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );
    } catch (e) {
      return Container(
        color: Colors.grey.shade300,
        width: double.infinity,
        height: height,
        child: const Icon(Icons.broken_image, color: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    Widget textContent = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          "TENTANG KAMI",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          // 👇 Menggunakan Judul Dinamis dari CMS
          _tentangKamiData['title'] ?? "Membantu Anak Bangsa Meraih Mimpi",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 26 : 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          // 👇 Menggunakan Deskripsi Dinamis dari CMS
          _tentangKamiData['description'] ??
              "Vernon Indonesia Pintar bukan sekadar yayasan beasiswa. Kami adalah inkubator karir bagi pemuda berpotensi dari keluarga tidak mampu.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
        ),

        // 👇 HAPUS BAGIAN STATISTIK PENERIMA & MITRA DI SINI
        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: () => context.go('/profil-yayasan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "BACA SELENGKAPNYA",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ],
    );

    Widget imageContent = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      // 👇 Menggunakan Gambar Dinamis dari CMS
      child: _buildImageDisplay(_tentangKamiData['image'] ?? '', isMobile),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 20 : 50,
      ),
      color: Colors.white,
      child: isMobile
          ? Column(
              children: [textContent, const SizedBox(height: 40), imageContent],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: textContent),
                const SizedBox(width: 60),
                Expanded(flex: 1, child: imageContent),
              ],
            ),
    );
  }
}
