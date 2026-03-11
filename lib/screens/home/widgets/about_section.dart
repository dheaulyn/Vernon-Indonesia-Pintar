import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
    color: Colors.white,
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TENTANG KAMI",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 20),
              const Text(
                "Lebih dari Sekadar Bantuan Biaya Pendidikan",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 25),
              Text(
                "Vernon Indonesia Pintar adalah yayasan nirlaba yang berfokus pada pemberdayaan generasi muda. Melalui Beasiswa Reguler dan Berprestasi, kami berkomitmen untuk menciptakan ekosistem pendidikan yang adil bagi seluruh talenta hebat di Indonesia.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  _buildStatItem("500+", "Penerima"),
                  const SizedBox(width: 40),
                  _buildStatItem("20+", "Mitra Universitas"),
                ],
              )
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/tentang.png', 
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatItem(String value, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
      Text(label, style: TextStyle(color: Colors.grey[600])),
    ],
  );
}
}