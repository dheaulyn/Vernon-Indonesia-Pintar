import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class LaporanView extends StatelessWidget {
  final bool isMobile;

  const LaporanView({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: 8,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Alokasi Penggunaan Dana",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Total dana terkumpul saat ini adalah Rp 135.000.000. Berikut adalah persentase rincian penggunaannya dalam membiayai Program Karir Kurikulum 10 Bulan VIP.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              _buildAlokasiItem(
                "Biaya Instruktur & Modul Pelatihan",
                0.40,
                Colors.blue.shade500,
                "Rp 54.000.000",
              ),
              const SizedBox(height: 20),
              _buildAlokasiItem(
                "Alat Praktik & Fasilitas Belajar",
                0.30,
                Colors.green.shade500,
                "Rp 40.500.000",
              ),
              const SizedBox(height: 20),
              _buildAlokasiItem(
                "Uang Saku & Akomodasi Siswa",
                0.20,
                Colors.orange.shade500,
                "Rp 27.000.000",
              ),
              const SizedBox(height: 20),
              _buildAlokasiItem(
                "Operasional Yayasan & Penyaluran",
                0.10,
                AppColors.primary,
                "Rp 13.500.000",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlokasiItem(
    String label,
    double percentage,
    Color color,
    String amount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            Text(
              "${(percentage * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Estimasi: $amount",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
