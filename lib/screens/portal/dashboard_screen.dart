import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'portal_layout.dart'; // Import layout master yang baru dibuat
import 'form_beasiswa_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 Bungkus halaman ini dengan PortalLayout
    return PortalLayout(
      activeMenu:
          'dashboard', // Beri tahu layout bahwa menu Dashboard sedang aktif
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard Siswa',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                // (Header Sapaan "Halo, Rudolph!" bisa dihapus jika mau karena sudah ada di Top Navbar)
              ],
            ),
            const SizedBox(height: 40),

            // KARTU STATUS PENDAFTARAN (Sama persis dengan milikmu)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors
                    .white, // Ganti jadi putih agar tidak nabrak warna background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Pendaftaran Beasiswa VIP 2026',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Belum Melengkapi Berkas',
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FormBeasiswaScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_document),
                        label: const Text('Lengkapi Berkas Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Progres Anda: 0 dari 3 Tahap Selesai',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.1,
                    backgroundColor: Colors.grey.shade200,
                    color: AppColors.primary,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // KARTU INFORMASI PENTING (Sama persis dengan milikmu)
            const Text(
              'Informasi Penting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Pastikan Anda menyiapkan scan KTP, Transkrip Nilai, dan Portofolio sebelum mengisi formulir.',
                    style: TextStyle(height: 1.5),
                  ),
                  Text(
                    '• Batas akhir pengumpulan berkas adalah tanggal 30 Mei 2026.',
                    style: TextStyle(height: 1.5),
                  ),
                  Text(
                    '• Jika mengalami kendala teknis, silakan hubungi WhatsApp admin VIP.',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
