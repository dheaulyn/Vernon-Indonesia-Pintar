import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    Widget aboutFooter = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text(
          "VERNON INDONESIA PINTAR",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Text(
          "Membangun generasi emas Indonesia melalui akses pendidikan yang merata dan berkualitas.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
        ),
      ],
    );

    Widget contactFooter = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text(
          "HUBUNGI KAMI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _footerLink("WhatsApp: +62 812-3456-7890", isMobile),
        _footerLink("Email: info@vip.or.id", isMobile),
        _footerLink(
          "Alamat: Jl. Letjen Sutoyo No.102A, Bunulrejo, Kec. Blimbing, Kota Malang, Jawa Timur, Indonesia",
          isMobile,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A), // Warna hitam pekat seperti halaman lain
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String title, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Text(
          title,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
        ),
      ),
    );
  }
}