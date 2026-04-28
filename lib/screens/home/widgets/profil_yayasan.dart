import 'package:flutter/material.dart';
import '../../shared/custom_navbar.dart';
import '/core/app_colors.dart'; // 👇 Import path sudah diperbaiki

class ProfilYayasanScreen extends StatelessWidget {
  const ProfilYayasanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isMobile),
            
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 50 : 80,
                horizontal: isMobile ? 20 : 80,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        _buildImageSection(isMobile),
                        const SizedBox(height: 40),
                        _buildTextContent(isMobile),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: _buildTextContent(isMobile)),
                        const SizedBox(width: 60),
                        Expanded(flex: 5, child: _buildImageSection(isMobile)),
                      ],
                    ),
            ),

            // FOOTER LENGKAP
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 50 : 80, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Text(
            "TENTANG KAMI",
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 15),
          Text(
            "Profil Yayasan",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isMobile ? 32 : 45, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Apa itu YAYASAN VERNON INDONESIA PINTAR (VIP)?",
          style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, height: 1.3),
        ),
        const SizedBox(height: 20),
        Text(
          "Kami yayasan pendidikan yang berdedikasi memberdayakan generasi muda Indonesia melalui:",
          style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6),
        ),
        const SizedBox(height: 25),
        
        _buildCheckItem("Akses setara ke pendidikan berkualitas"),
        _buildCheckItem("Pelatihan vokasi profesional"),
        _buildCheckItem("Peluang karier relevan dengan industri"),
        
        const SizedBox(height: 40),

        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: AppColors.primary, width: 5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text("Misi Kami", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "Setiap potensi anak muda harus diberdayakan tanpa hambatan ekonomi atau sosial.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700], fontStyle: FontStyle.italic, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/tentang.png', 
        fit: BoxFit.cover,
        width: double.infinity,
        height: isMobile ? 250 : 500,
      ),
    );
  }

  // ==========================================
  // WIDGET: FOOTER LENGKAP (SERAGAM)
  // ==========================================
  Widget _buildFooter(bool isMobile) {
    Widget aboutFooter = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text("VERNON INDONESIA PINTAR", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Text("Membangun generasi emas Indonesia melalui akses pendidikan yang merata dan berkualitas.", textAlign: isMobile ? TextAlign.center : TextAlign.left, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
      ],
    );

    Widget contactFooter = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text("HUBUNGI KAMI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _footerLink("WhatsApp: +62 812-3456-7890", isMobile),
        _footerLink("Email: info@vip.or.id", isMobile),
        _footerLink("Alamat: Jl. Letjen Sutoyo No.102A, Bunulrejo, Kec. Blimbing, Kota Malang, Jawa Timur, Indonesia", isMobile),
      ],
    );

    return Container(
      width: double.infinity, color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: isMobile ? 30 : 50),
      child: Column(
        children: [
          if (isMobile) Column(children: [aboutFooter, const SizedBox(height: 40), contactFooter])
          else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: aboutFooter), const SizedBox(width: 50), Expanded(child: contactFooter)]),
          SizedBox(height: isMobile ? 30 : 50),
          Text("© 2026 Vernon Indonesia Pintar. All Rights Reserved.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _footerLink(String title, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(onTap: () {}, child: Text(title, textAlign: isMobile ? TextAlign.center : TextAlign.left, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15))),
    );
  }
}