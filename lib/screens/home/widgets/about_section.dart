import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 50),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(child: _buildTextContent()),
                const SizedBox(width: 50),
                Expanded(child: _buildImageContent()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildImageContent(),
                const SizedBox(height: 40),
                _buildTextContent(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TENTANG KAMI",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Vernon Indonesia Pintar",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "VIP hadir sebagai wadah dedikasi untuk mencerdaskan anak bangsa. Kami percaya bahwa setiap anak Indonesia berhak mendapatkan akses pendidikan yang layak.",
          style: TextStyle(fontSize: 18, height: 1.6, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?q=80&w=1000",
        fit: BoxFit.cover,
      ),
    );
  }
}
