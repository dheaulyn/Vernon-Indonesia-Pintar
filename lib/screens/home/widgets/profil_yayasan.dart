import 'dart:convert';
import 'package:flutter/material.dart';
import '../../shared/custom_navbar.dart';
import '../../shared/custom_footer.dart';
import '/core/app_colors.dart'; 
import '/data/mock_database.dart'; 

class ProfilYayasanScreen extends StatefulWidget {
  const ProfilYayasanScreen({super.key});

  @override
  State<ProfilYayasanScreen> createState() => _ProfilYayasanScreenState();
}

class _ProfilYayasanScreenState extends State<ProfilYayasanScreen> {
  late Map<String, dynamic> _dataProfil;

  @override
  void initState() {
    super.initState();
    // Mengambil data dari MockDatabase saat halaman dimuat
    _dataProfil = MockDatabase.getProfilYayasanData();
  }

  Widget _buildImageDisplay(String imageSource, bool isMobile) {
    final double height = isMobile ? 300 : 400;

    if (imageSource.isEmpty) {
      return Image.asset('assets/tentang.png', fit: BoxFit.cover, width: double.infinity, height: height);
    }
    if (imageSource.startsWith('http')) {
      return Image.network(imageSource, fit: BoxFit.cover, width: double.infinity, height: height);
    }
    try {
      return Image.memory(base64Decode(imageSource), fit: BoxFit.cover, width: double.infinity, height: height);
    } catch (e) {
      return Container(color: Colors.grey.shade300, width: double.infinity, height: height, child: const Icon(Icons.broken_image, color: Colors.red));
    }
  }

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
              child: Column(
                children: [
                  // ==========================================
                  // SECTION 1: TENTANG KAMI & GAMBAR
                  // ==========================================
                  isMobile
                      ? Column(
                          children: [
                            _buildImageSection(isMobile),
                            const SizedBox(height: 40),
                            _buildAboutText(isMobile),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [
                            Expanded(flex: 5, child: _buildAboutText(isMobile)),
                            const SizedBox(width: 60),
                            Expanded(flex: 4, child: _buildImageSection(isMobile)), 
                          ],
                        ),

                  const SizedBox(height: 80),

                  // ==========================================
                  // SECTION 2: VISION & MISSION
                  // ==========================================
                  isMobile
                      ? Column(
                          children: [
                            _buildVisionCard(),
                            const SizedBox(height: 30),
                            _buildMissionCard(),
                          ],
                        )
                      : IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _buildVisionCard()),
                              const SizedBox(width: 40),
                              Expanded(child: _buildMissionCard()),
                            ],
                          ),
                        ),
                ],
              ),
            ),

            const CustomFooter(),
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
          const Text(
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

  // 👇 Data Teks Dinamis
  Widget _buildAboutText(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _dataProfil['title'] ?? "Apa itu YAYASAN VERNON INDONESIA PINTAR (VIP)?",
          style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, height: 1.3),
        ),
        const SizedBox(height: 20),
        Text(
          _dataProfil['description'] ?? "Deskripsi tentang Yayasan...",
          style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6),
        ),
      ],
    );
  }

  // 👇 Data Gambar Dinamis
  Widget _buildImageSection(bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: _buildImageDisplay(_dataProfil['image'] ?? '', isMobile),
    );
  }

  // 👇 Data Visi Dinamis
  Widget _buildVisionCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: Colors.amber, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text("✨", style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Text("VISION", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.amber, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _dataProfil['vision_text'] ?? "Teks Visi...",
            style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 👇 Data Misi Dinamis dari Array
  Widget _buildMissionCard() {
    List<dynamic> missions = _dataProfil['mission_points'] ?? [];

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text("🚀", style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Text("MISSION", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.primary, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Loop data poin misi dari database
          ...missions.map((missionText) => _buildMissionItem(missionText.toString())),
        ],
      ),
    );
  }

  Widget _buildMissionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1), 
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 10),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}