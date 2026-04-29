import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart'; // Sesuaikan path jika berbeda
import 'shared/custom_navbar.dart';
import 'shared/custom_footer.dart';
import '../../data/models/program_model.dart';

class ProgramDetailScreen extends StatelessWidget {
  final ProgramModel? program;

  const ProgramDetailScreen({super.key, this.program});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Warna background sangat soft
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER SECTION (Desain ala Halaman Tentang)
            // ==========================================
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF8F6),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 80,
                vertical: isMobile ? 60 : 100,
              ),
              child: Column(
                children: [
                  const Text(
                    "PROGRAM KARIR",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Kurikulum VIP (10 Bulan)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Menjembatani kesenjangan antara pendidikan dan dunia kerja nyata.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // ==========================================
            // 2. FASE KURIKULUM (KARTU 3 TAHAP)
            // ==========================================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80),
              child: isMobile
                  ? Column(
                      children: [
                        _buildPhaseCard(
                          "FASE 1",
                          "Pelatihan Intensif",
                          "Membangun fondasi karakter dan keahlian teknis dasar selama 3 bulan pertama.",
                          [
                            "Soft Skill & Komunikasi",
                            "Literasi Digital & AI",
                            "Peminatan Technical Track",
                          ],
                          true,
                        ),
                        const SizedBox(height: 20),
                        _buildPhaseCard(
                          "FASE 2",
                          "Pemagangan Industri",
                          "4 bulan terjun langsung ke dunia kerja melalui jaringan mitra perusahaan VIP.",
                          [
                            "On-the-Job Training",
                            "Mentorship Profesional",
                            "Project Berbasis Industri",
                          ],
                          false,
                        ),
                        const SizedBox(height: 20),
                        _buildPhaseCard(
                          "FASE 3",
                          "Penyaluran Kerja",
                          "3 bulan terakhir fokus pada penempatan kerja dan kemandirian finansial.",
                          [
                            "Job Readiness Workshop",
                            "Interview Coaching",
                            "Penempatan Kerja Permanen",
                          ],
                          false,
                        ),
                      ],
                    )
                  // 👇 INI DIA OBAT ANTI LAYAR PUTIHNYA: IntrinsicHeight
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildPhaseCard(
                              "FASE 1",
                              "Pelatihan Intensif",
                              "Membangun fondasi karakter dan keahlian teknis dasar selama 3 bulan pertama.",
                              [
                                "Soft Skill & Komunikasi",
                                "Literasi Digital & AI",
                                "Peminatan Technical Track",
                              ],
                              true,
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: _buildPhaseCard(
                              "FASE 2",
                              "Pemagangan Industri",
                              "4 bulan terjun langsung ke dunia kerja melalui jaringan mitra perusahaan VIP.",
                              [
                                "On-the-Job Training",
                                "Mentorship Profesional",
                                "Project Berbasis Industri",
                              ],
                              false,
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: _buildPhaseCard(
                              "FASE 3",
                              "Penyaluran Kerja",
                              "3 bulan terakhir fokus pada penempatan kerja dan kemandirian finansial.",
                              [
                                "Job Readiness Workshop",
                                "Interview Coaching",
                                "Penempatan Kerja Permanen",
                              ],
                              false,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 80),

            // ==========================================
            // 3. FASILITAS BEASISWA PENUH (DARK BANNER)
            // ==========================================
            Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80),
              padding: EdgeInsets.symmetric(
                vertical: 50,
                horizontal: isMobile ? 20 : 50,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Fasilitas Beasiswa Penuh",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFacilityChip("Laptop & Alat Belajar"),
                      _buildFacilityChip("Uang Saku Bulanan"),
                      _buildFacilityChip("Akomodasi (Mess)"),
                      _buildFacilityChip("Sertifikasi Industri"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // ==========================================
            // 4. CALL TO ACTION (CTA) DAFTAR SEKARANG
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "Siap Mengubah Nasib?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => context.go('/beasiswa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: const StadiumBorder(),
                      elevation: 5,
                      shadowColor: Colors.red.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "DAFTAR SEKARANG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_outward_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),

            // ==========================================
            // 5. FOOTER
            // ==========================================
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU FASE
  Widget _buildPhaseCard(
    String phase,
    String title,
    String desc,
    List<String> items,
    bool isHighlight,
  ) {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isHighlight
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: isHighlight
                ? Colors.red.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isHighlight ? Colors.red : const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              phase,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            desc,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 15),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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

  Widget _buildFacilityChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
