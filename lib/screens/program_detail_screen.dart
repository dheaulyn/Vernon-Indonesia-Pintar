import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import '../../core/app_colors.dart';
import 'shared/custom_navbar.dart';
import 'shared/custom_footer.dart';

class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            _buildHeroSection(context, isMobile),
            Container(
              width: isMobile ? double.infinity : 1000,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 0,
                vertical: 50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    "Syarat & Ketentuan",
                    "Pastikan Anda memenuhi kriteria berikut sebelum mendaftar.",
                  ),
                  const SizedBox(height: 30),

                  // GRID KARTU PERSYARATAN
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildRequirementCard(
                        isMobile,
                        "Syarat Umum",
                        Icons.person_outline,
                        [
                          "Warga Negara Indonesia berusia minimal 18 tahun.",
                          "Usia maksimal 25 tahun saat mendaftar.",
                          "Berasal dari keluarga kurang mampu (PKH / KKS / SKTM).",
                          "Belum bekerja atau belum memiliki penghasilan tetap.",
                          "Bersedia mengikuti seluruh rangkaian program selama ±14 bulan.",
                        ],
                      ),
                      _buildRequirementCard(
                        isMobile,
                        "Pendidikan",
                        Icons.school_outlined,
                        [
                          "Terbuka untuk semua jenjang pendidikan (SD / SMP / SMA / SMK sederajat).",
                          "Memiliki ijazah atau Surat Keterangan Lulus (SKL).",
                          "Tidak sedang menempuh pendidikan formal.",
                        ],
                      ),
                      _buildRequirementCard(
                        isMobile,
                        "Karakter & Motivasi",
                        Icons.favorite_border_rounded,
                        [
                          "Memiliki semangat belajar yang tinggi dan tekad kuat.",
                          "Bersikap jujur, disiplin, dan bertanggung jawab.",
                          "Bersedia menerima arahan dan mentoring dari instruktur.",
                          "Tidak sedang menerima beasiswa lain yang serupa.",
                        ],
                      ),
                      _buildRequirementCard(
                        isMobile,
                        "Dokumen yang Diperlukan",
                        Icons.folder_open_rounded,
                        [
                          "Fotokopi KTP.",
                          "Fotokopi ijazah / SKL terakhir.",
                          "Surat Keterangan Tidak Mampu (SKTM).",
                          "Pas foto 3×4 terbaru (2 lembar).",
                          "Surat motivasi tulis tangan (1 halaman).",
                          "Nomor HP aktif & akun WhatsApp.",
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  _buildSectionTitle(
                    "Alur Pendaftaran & Seleksi",
                    "Langkah-langkah yang akan Anda lalui dari pendaftaran hingga penempatan.",
                  ),
                  const SizedBox(height: 40),

                  // TIMELINE ALUR PENDAFTARAN
                  _buildTimelineStep(
                    1,
                    "Pengisian formulir pendaftaran online",
                    "Isi data diri lengkap melalui website VIP. Lampirkan foto dokumen persyaratan.",
                  ),
                  _buildTimelineStep(
                    2,
                    "Verifikasi dokumen & kelayakan administrasi",
                    "Tim VIP memverifikasi kelengkapan dokumen dan kesesuaian kriteria usia serta ekonomi.",
                  ),
                  _buildTimelineStep(
                    3,
                    "Wawancara langsung dengan tim yayasan",
                    "Tahap penentu kelulusan seleksi. Tim yayasan menilai secara langsung kemampuan, karakter, dan kesungguhan calon penerima.",
                  ),
                  _buildTimelineStep(
                    4,
                    "Pengumuman hasil seleksi",
                    "Hasil seleksi diumumkan melalui website VIP. Calon penerima yang lolos menerima Surat Penetapan Beasiswa resmi.",
                  ),
                  _buildTimelineStep(
                    5,
                    "Orientasi & penandatanganan perjanjian",
                    "Penerima beasiswa menghadiri sesi orientasi dan menandatangani surat komitmen mengikuti pelatihan hingga penempatan kerja.",
                  ),
                  _buildTimelineStep(
                    6,
                    "Mulai pelatihan vokasi di Vernon Edu",
                    "Program resmi dimulai. Pelatihan intensif 10 bulan mencakup keterampilan barista, digital marketing, administrasi, atau bidang lain sesuai minat & kebutuhan industri.",
                    isLast: true,
                  ),
                ],
              ),
            ),

            // 3. FOOTER
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // =====================================
  // KUMPULAN WIDGET BANTUAN
  // =====================================

  // 👇 PERBAIKAN: Menambahkan BuildContext context sebagai parameter
  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 0,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2329), // Warna gelap khas VIP
        image: DecorationImage(
          // Opsional: Kalau punya gambar pattern atau foto kelas yang digelapkan, pasang di sini
          image: NetworkImage(
            'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=2000&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: isMobile ? double.infinity : 900,
          child: Column(
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  "PROGRAM UNGGULAN",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Program Karir Kurikulum\n10 Bulan VIP",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Pelatihan intensif terpadu untuk membekali Anda dengan keterampilan praktis dan karakter profesional agar siap bersaing di dunia kerja.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                // 👇 PERBAIKAN: Mengarahkan langsung ke halaman register
                onPressed: () => context.go('/register'), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "DAFTAR SEKARANG",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRequirementCard(
    bool isMobile,
    String title,
    IconData icon,
    List<String> points,
  ) {
    return Container(
      width: isMobile ? double.infinity : 480, // Dibagi 2 kolom jika di desktop
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    int stepNumber,
    String title,
    String description, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Garis dan Angka
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),

          // Konten Teks
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40), // Jarak antar step
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}