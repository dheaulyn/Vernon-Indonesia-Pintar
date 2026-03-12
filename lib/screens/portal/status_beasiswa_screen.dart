import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'portal_layout.dart'; // Pastikan import PortalLayout ini ada

class StatusBeasiswaScreen extends StatelessWidget {
  const StatusBeasiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 Membungkus halaman dengan PortalLayout
    return PortalLayout(
      activeMenu:
          'status', // Beritahu layout bahwa menu 'Status Beasiswa' sedang aktif
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Pendaftaran',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lacak progres seleksi beasiswa VIP 2026 Anda di sini.',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Kartu ID Pendaftaran
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID Pendaftaran: VIP-2026-08912',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Rudolph Benjamin Gaspersz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Program S1 - Sistem Informasi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tahap Seleksi Berkas',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Timeline Status
            const Text(
              'Jejak Langkah (Timeline)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildTimelineItem(
                    title: 'Pengisian Formulir Selesai',
                    date: '11 Maret 2026, 10:30 WIB',
                    description:
                        'Formulir pendaftaran dan berkas Anda telah berhasil masuk ke sistem kami.',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Seleksi Berkas (Sedang Diproses)',
                    date: 'Estimasi: 14 - 20 Maret 2026',
                    description:
                        'Tim kami sedang memverifikasi keaslian dokumen dan kesesuaian nilai rapor/IPK Anda.',
                    icon: Icons.sync,
                    color: Colors.orange,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Wawancara Daring',
                    date: 'Menunggu Jadwal',
                    description:
                        'Tautan Zoom akan dikirimkan jika Anda lolos tahap seleksi berkas.',
                    icon: Icons.video_camera_front,
                    color: Colors.grey,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Pengumuman Akhir',
                    date: 'April 2026',
                    description: 'Pengumuman penerima beasiswa penuh VIP 2026.',
                    icon: Icons.emoji_events,
                    color: Colors.grey,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN UNTUK ITEM TIMELINE (Tetap dipertahankan karena khusus untuk halaman ini)
  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            if (!isLast)
              Container(width: 2, height: 60, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color == Colors.grey
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
