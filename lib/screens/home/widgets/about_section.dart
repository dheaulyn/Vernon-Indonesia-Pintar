import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 👇 1. Tambahkan import go_router
import '../../../core/app_colors.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    Widget textContent = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          "TENTANG KAMI",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        Text(
          "Membantu Anak Bangsa Meraih Mimpi",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 26 : 32, 
            fontWeight: FontWeight.bold, 
            height: 1.2,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "Vernon Indonesia Pintar bukan sekadar yayasan beasiswa. Kami adalah inkubator karir bagi pemuda berpotensi dari keluarga tidak mampu.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
        ),
        const SizedBox(height: 30),
        
        Wrap(
          spacing: 40,
          runSpacing: 20,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildStatItem("500+", "Penerima", isMobile),
            _buildStatItem("20+", "Mitra Universitas", isMobile),
          ],
        ),
        
        // 👇 2. TAMBAHKAN TOMBOL SELENGKAPNYA DI SINI
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => context.go('/profil-yayasan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0, // Dibuat flat agar elegan
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "BACA SELENGKAPNYA",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      child: Image.asset(
        'assets/tentang.png', 
        fit: BoxFit.cover,
        width: double.infinity,
        height: isMobile ? 250 : null, 
      ),
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
                Expanded(
                  flex: 1,
                  child: textContent,
                ),
                const SizedBox(width: 60),
                Expanded(
                  flex: 1,
                  child: imageContent,
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          value, 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        Text(
          label, 
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}