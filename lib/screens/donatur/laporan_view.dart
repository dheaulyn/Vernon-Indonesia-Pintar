import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../data/mock_database.dart';

class LaporanView extends StatelessWidget {
  final bool isMobile;
  const LaporanView({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final impactUpdates = MockDatabase.getImpactUpdates();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 1. KARTU ALOKASI DANA
          // ==========================================
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Alokasi Penggunaan Dana",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Total dana terkumpul saat ini adalah Rp 135.000.000. Berikut adalah persentase rincian penggunaannya dalam membiayai Program Karir Kurikulum 10 Bulan VIP.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 35),

                _buildDetailedAllocationBar(
                  "Biaya Instruktur & Modul Pelatihan",
                  0.40,
                  Colors.blue,
                  "40%",
                  "Estimasi: Rp 54.000.000",
                ),
                const SizedBox(height: 25),
                _buildDetailedAllocationBar(
                  "Alat Praktik & Fasilitas Belajar",
                  0.30,
                  Colors.green,
                  "30%",
                  "Estimasi: Rp 40.500.000",
                ),
                const SizedBox(height: 25),
                _buildDetailedAllocationBar(
                  "Uang Saku & Akomodasi Siswa",
                  0.20,
                  Colors.orange,
                  "20%",
                  "Estimasi: Rp 27.000.000",
                ),
                const SizedBox(height: 25),
                _buildDetailedAllocationBar(
                  "Operasional Yayasan & Penyaluran",
                  0.10,
                  Colors.red,
                  "10%",
                  "Estimasi: Rp 13.500.000",
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ==========================================
          // 2. TIMELINE DAMPAK / BERITA
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Jejak Kebaikan Terbaru",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          isMobile
              ? Column(
                  children: impactUpdates
                      .map((update) => _buildImpactCard(update, isMobile))
                      .toList(),
                )
              : Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: impactUpdates
                      .map(
                        (update) => SizedBox(
                          width: 400,
                          child: _buildImpactCard(update, isMobile),
                        ),
                      )
                      .toList(),
                ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Widget Bantuan untuk Grafik Alokasi
  Widget _buildDetailedAllocationBar(
    String title,
    double percentage,
    Color color,
    String percentText,
    String estimateText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            Text(
              percentText,
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
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          estimateText,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  // Widget Bantuan untuk Kartu Update Dampak
  Widget _buildImpactCard(ImpactUpdate update, bool isMobile) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 20 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(update.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateFormat.format(update.date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  update.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  update.content,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    update.programName,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
