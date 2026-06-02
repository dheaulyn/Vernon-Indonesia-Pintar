import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_colors.dart';
import 'shared/custom_navbar.dart';
import 'shared/custom_footer.dart';

class ProgramDetailScreen extends StatefulWidget {
  const ProgramDetailScreen({super.key});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  // 👇 Data sekarang bertipe dynamic
  Map<String, dynamic>? _detailData;
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchProgramData();
  }

  // 👇 FUNGSI MENARIK DATA DARI SUPABASE
  Future<void> _fetchProgramData() async {
    try {
      final response = await _supabase
          .from('programs')
          .select()
          .eq('id', 1) // Ambil program dengan ID 1
          .maybeSingle();

      if (mounted) {
        setState(() {
          _detailData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat program: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIconForIndex(int index) {
    const icons = [
      Icons.person_outline,
      Icons.school_outlined,
      Icons.favorite_border_rounded,
      Icons.folder_open_rounded,
      Icons.assignment_turned_in_outlined,
      Icons.verified_user_outlined,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomNavbar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detailData == null
          ? const Center(child: Text("Data program tidak ditemukan."))
          : SingleChildScrollView(
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

                        // 👇 DATA SYARAT DINAMIS DARI SUPABASE
                        ...List.generate(
                          (_detailData!['syarat_ketentuan'] as List).length,
                          (index) {
                            final req =
                                (_detailData!['syarat_ketentuan']
                                    as List)[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildRequirementCard(
                                req['title'] ?? '',
                                _getIconForIndex(index),
                                List<String>.from(req['points'] ?? []),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 80),

                        _buildSectionTitle(
                          "Alur Pendaftaran & Seleksi",
                          "Langkah-langkah yang akan Anda lalui dari pendaftaran hingga penempatan.",
                        ),
                        const SizedBox(height: 40),

                        // 👇 DATA ALUR DINAMIS DARI SUPABASE
                        ...List.generate(
                          (_detailData!['alur_pendaftaran'] as List).length,
                          (index) {
                            final step =
                                (_detailData!['alur_pendaftaran']
                                    as List)[index];
                            return _buildTimelineStep(
                              index + 1,
                              step['title'] ?? '',
                              step['description'] ?? '',
                              isLast:
                                  index ==
                                  (_detailData!['alur_pendaftaran'] as List)
                                          .length -
                                      1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const CustomFooter(),
                ],
              ),
            ),
    );
  }

  // =====================================
  // WIDGET-WIDGET HERO & SECTION (SAMA SEPERTI KODE LAMA)
  // =====================================
  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 0,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2329),
        image: DecorationImage(
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
                "Program Karir Kurikulum 10 Bulan VIP",
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
                "Pelatihan intensif terpadu untuk membekali generasi muda dengan keterampilan vokasional siap kerja, pembentukan karakter unggul, serta pendampingan karir hingga penempatan kerja.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
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
    String title,
    IconData icon,
    List<String> points,
  ) {
    return Container(
      width: double.infinity,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
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
