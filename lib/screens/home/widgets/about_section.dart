import 'package:flutter/material.dart';
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
          "Lebih dari Sekadar Bantuan Biaya Pendidikan",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 26 : 32, 
            fontWeight: FontWeight.bold, 
            height: 1.2,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "Vernon Indonesia Pintar adalah yayasan nirlaba yang berfokus pada pemberdayaan generasi muda. Melalui Beasiswa Reguler dan Berprestasi, kami berkomitmen untuk menciptakan ekosistem pendidikan yang adil bagi seluruh talenta hebat di Indonesia.",
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
        )
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