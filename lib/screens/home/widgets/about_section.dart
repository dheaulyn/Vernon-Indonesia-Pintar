import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';

import '../../../services/supabase_cms_service.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  // Fungsi untuk merender gambar (URL, Base64, atau Fallback lokal).
  Widget _buildImageDisplay(String imageSource, bool isMobile) {
    final double? height = isMobile ? 250 : null;

    if (imageSource.isEmpty) {
      // Fallback ke gambar dari URL unsplash (atau lokal assets/tentang.PNG) jika kosong.
      return Image.network(
        'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop',
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
        // Tambahkan loading builder agar lebih halus saat gambar di-load.
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            width: double.infinity,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
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

    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: SupabaseCmsService.aboutUs,
      builder: (context, data, _) {
        // Siapkan variabel aman (fallback) jika data internet belum masuk.
        String title = data['title'] ?? "Membantu Anak Bangsa Meraih Mimpi";
        String description =
            data['description'] ??
            "Vernon Indonesia Pintar bukan sekadar yayasan beasiswa. Kami adalah inkubator karir bagi pemuda berpotensi dari keluarga tidak mampu.";
        String imageSource = data['image_url'] ?? '';

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
              title,
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              description,
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go('/profil-yayasan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 18,
                ),
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
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        );

        Widget imageContent = ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildImageDisplay(imageSource, isMobile),
        );

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 60 : 100,
            horizontal: isMobile ? 20 : 50,
          ),
          color: Colors.white,
          child: isMobile
              ? Column(
                  children: [
                    textContent,
                    const SizedBox(height: 40),
                    imageContent,
                  ],
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
      },
    );
  }
}
