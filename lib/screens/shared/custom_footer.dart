import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

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
    final supabase = Supabase.instance.client;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('cms_footer').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        final footerData = (snapshot.data != null && snapshot.data!.isNotEmpty)
            ? snapshot.data!.first
            : {};

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
              footerData['deskripsi_yayasan'] ?? 'Loading...',
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

            // 👇 Alamat (Bisa diklik untuk buka Maps, link sudah diperbaiki)
            InkWell(
              onTap: () {
                final alamat = footerData['alamat'] ?? '';
                if (alamat.isNotEmpty) {
                  _launchURL(
                    "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(alamat)}",
                  );
                }
              },
              child: Text(
                footerData['alamat'] ?? '-',
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white38,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 👇 Email dengan Ikon Amplop Penanda
            Row(
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.email_outlined,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: SelectableText(
                    footerData['email'] ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 👇 Ikon sosmed sisa WhatsApp dan Instagram
            Row(
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                _buildSocialIcon(
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/733/733585.png',
                  url: footerData['whatsapp'] ?? '',
                ),
                const SizedBox(width: 15),
                _buildSocialIcon(
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/174/174855.png',
                  url: footerData['instagram'] ?? '',
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
      onTap: () {
        if (url.isNotEmpty) _launchURL(url);
      },
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
