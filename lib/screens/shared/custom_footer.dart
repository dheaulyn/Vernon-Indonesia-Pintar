import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mock_database.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  // FUNGSI UNTUK MEMBUKA LINK (MAPS & SOSMED)
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Tidak bisa membuka $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    // 👇 MENGGUNAKAN DATA DARI MOCK DATABASE
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: MockDatabase.footerData,
      builder: (context, footerData, child) {
        Widget aboutFooter = Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            const Text(
              "VERNON INDONESIA PINTAR",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              footerData['deskripsi'] ?? '',
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        );

        Widget contactFooter = Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            const Text(
              "HUBUNGI KAMI",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // ALAMAT YANG BISA DIKLIK MENGARAH KE MAPS
            InkWell(
              onTap: () => _launchURL(
                "https://www.google.com/maps/search/?api=1&query=Jl.+Letjen+Sutoyo+No.102A,+Bunulrejo,+Malang",
              ),
              child: Text(
                footerData['alamat'] ?? '',
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white38,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // BARISAN ICON SOSMED
            Row(
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                // Icon WhatsApp
                _buildSocialIcon(
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/733/733585.png',
                  url: footerData['whatsapp'] ?? 'https://wa.me/628885864995',
                ),
                const SizedBox(width: 15),
                // 👇 Icon Instagram
                _buildSocialIcon(
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/174/174855.png',
                  url:
                      footerData['instagram'] ??
                      'https://www.instagram.com/yayasanvip',
                ),
                const SizedBox(width: 15),
                // 👇 Icon Email (Otomatis Tambah Mailto:)
                _buildSocialIcon(
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/732/732200.png',
                  url:
                      'mailto:${footerData['email'] ?? 'vernonindonesiapintar@gmail.com'}',
                ),
              ],
            ),
          ],
        );

        return Container(
          width: double.infinity,
          color: const Color(0xFF1A1A1A),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 40 : 60,
            horizontal: isMobile ? 30 : 50,
          ),
          child: Column(
            children: [
              if (isMobile)
                Column(
                  children: [
                    aboutFooter,
                    const SizedBox(height: 40),
                    contactFooter,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: aboutFooter),
                    const SizedBox(width: 50),
                    Expanded(child: contactFooter),
                  ],
                ),
              SizedBox(height: isMobile ? 30 : 50),
              Text(
                "© 2026 Vernon Indonesia Pintar. All Rights Reserved.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialIcon({required String imageUrl, required String url}) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
