import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared/custom_navbar.dart';
import 'shared/custom_footer.dart';
import '../../core/app_colors.dart';

class ProgramDetailScreen extends StatefulWidget {
  const ProgramDetailScreen({super.key});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  final _supabase = Supabase.instance.client;

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
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomNavbar(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase.from('programs').stream(primaryKey: ['id']).eq('id', 1),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final programData = snapshot.data!.first;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. HEADER TEKS, FASE, FASILITAS
                _buildPhasesSection(context, isMobile, programData),

                // 2. SYARAT, KETENTUAN & ALUR PENDAFTARAN (Real-time dari Supabase)
                _buildDynamicRequirements(isMobile, programData),

                // 3. CTA SECTION (Siap Mengubah Nasib?)
                _buildCTASection(context, isMobile),

                // 4. FOOTER
                const CustomFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhasesSection(
    BuildContext context,
    bool isMobile,
    Map<String, dynamic> programData,
  ) {
    final String title = programData['nama_program'] ?? 'Kurikulum VIP (10 Bulan)';
    final String description = programData['deskripsi'] ?? 'Menjembatani kesenjangan antara pendidikan dan dunia kerja nyata.';
    final phaseData = (programData['fase_program'] as List?) ?? [];
    final fasilitasData = (programData['fasilitas'] as List?) ?? [];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        left: isMobile ? 24 : 80,
        right: isMobile ? 24 : 80,
        top: 100,
        bottom: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // HEADER TEKS
              const Text(
                "PROGRAM KARIR",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 60),

              // FASE DENGAN ANIMASI DYNAMIC HOVER
              if (isMobile)
                Column(
                  children: phaseData.map<Widget>((phase) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: PhaseCard(
                        phase: phase['phase']?.toString() ?? '',
                        title: phase['title']?.toString() ?? '',
                        desc: phase['desc']?.toString() ?? '',
                        items: List<String>.from(phase['items'] ?? []),
                      ),
                    );
                  }).toList(),
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: phaseData.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final phase = entry.value;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < phaseData.length - 1 ? 20.0 : 0.0,
                          ),
                          child: PhaseCard(
                            phase: phase['phase']?.toString() ?? '',
                            title: phase['title']?.toString() ?? '',
                            desc: phase['desc']?.toString() ?? '',
                            items: List<String>.from(phase['items'] ?? []),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 60),

              // FASILITAS BANNER SEKALIGUS KOTAK CALL-TO-ACTION (CTA)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 40 : 60,
                  horizontal: isMobile ? 30 : 50,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBlack,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Fasilitas Beasiswa Penuh",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: fasilitasData
                          .map<Widget>((fas) => FasilitasPill(text: fas.toString()))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicRequirements(
    bool isMobile,
    Map<String, dynamic> programData,
  ) {
    final syaratList = (programData['syarat_ketentuan'] as List?) ?? [];
    final alurList = (programData['alur_pendaftaran'] as List?) ?? [];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        left: isMobile ? 24 : 80,
        right: isMobile ? 24 : 80,
        bottom: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SYARAT & KETENTUAN
              _buildSectionTitle(
                "Syarat & Ketentuan",
                "Pastikan Anda memenuhi kriteria berikut sebelum mendaftar.",
              ),
              const SizedBox(height: 30),
              ...List.generate(syaratList.length, (index) {
                final req = syaratList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildRequirementCard(
                    req['title'] ?? '',
                    _getIconForIndex(index),
                    List<String>.from(req['points'] ?? []),
                  ),
                );
              }),

              const SizedBox(height: 80),

              // ALUR PENDAFTARAN
              _buildSectionTitle(
                "Alur Pendaftaran & Seleksi",
                "Langkah-langkah yang akan Anda lalui dari pendaftaran hingga penempatan.",
              ),
              const SizedBox(height: 40),
              ...List.generate(alurList.length, (index) {
                final step = alurList[index];
                return _buildTimelineStep(
                  index + 1,
                  step['title'] ?? '',
                  step['description'] ?? '',
                  isLast: index == alurList.length - 1,
                );
              }),
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

  Widget _buildCTASection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 80,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "DAFTAR SEKARANG",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET CARD FASE (DENGAN ANIMASI HOVER)
// ==========================================
class PhaseCard extends StatefulWidget {
  final String phase;
  final String title;
  final String desc;
  final List<String> items;

  const PhaseCard({
    super.key,
    required this.phase,
    required this.title,
    required this.desc,
    required this.items,
  });

  @override
  State<PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<PhaseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(30),
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              )
            else
              const BoxShadow(color: Colors.transparent),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _isHovered ? AppColors.primary : AppColors.accentBlack,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.phase,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.desc,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.6,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 25),
            ...widget.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET PILL FASILITAS
// ==========================================
class FasilitasPill extends StatefulWidget {
  final String text;
  const FasilitasPill({super.key, required this.text});

  @override
  State<FasilitasPill> createState() => _FasilitasPillState();
}

class _FasilitasPillState extends State<FasilitasPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isHovered ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
