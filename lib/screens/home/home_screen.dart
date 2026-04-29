import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
import 'widgets/about_section.dart'; // Aktifkan kalau kamu masih pakai section ini
import '../../core/app_colors.dart';
import '../../data/hero_banner_data.dart';
import '../../data/faq_data.dart';

// ==========================================
// MODEL DATA DONASI SEMENTARA
// ==========================================
class ProgramDonasi {
  final String imageUrl;
  final String kategori;
  final String judul;
  final int terkumpul;
  final int target;

  ProgramDonasi({
    required this.imageUrl,
    required this.kategori,
    required this.judul,
    required this.terkumpul,
    required this.target,
  });

  double get progress => terkumpul / target;
}

class HomeScreen extends StatefulWidget {
  final String? targetSection;
  const HomeScreen({super.key, this.targetSection});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey programKey = GlobalKey();
  final GlobalKey homeKey = GlobalKey();
  final GlobalKey faqKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();
  final GlobalKey stepKey = GlobalKey();

  // Data Dummy Program Crowdfunding
  final List<ProgramDonasi> listProgramDonasi = [
    ProgramDonasi(
      imageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=600&auto=format&fit=crop',
      kategori: 'Pendidikan',
      judul: 'Beasiswa Vokasi 10 Bulan',
      terkumpul: 75,
      target: 100,
    ),
    ProgramDonasi(
      imageUrl:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=600&auto=format&fit=crop',
      kategori: 'Impact',
      judul: 'Bantuan Alat Belajar',
      terkumpul: 45,
      target: 100,
    ),
    ProgramDonasi(
      imageUrl:
          'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=600&auto=format&fit=crop',
      kategori: 'Karir',
      judul: 'Magang Industri 4 Bulan',
      terkumpul: 90,
      target: 100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.targetSection != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _autoScrollToTarget();
      });
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetSection != oldWidget.targetSection &&
        widget.targetSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoScrollToTarget();
      });
    }
  }

  void _autoScrollToTarget() {
    switch (widget.targetSection) {
      case 'tentang':
        scrollToSection(aboutKey);
        break;
      case 'program':
        scrollToSection(programKey);
        break;
      case 'kontak':
        scrollToSection(contactKey);
        break;
      case 'panduan-pendaftaran':
        scrollToSection(stepKey);
        break;
      case 'faq':
        scrollToSection(faqKey);
        break;
      default:
        scrollToSection(homeKey);
    }
  }

  void scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(key: homeKey),
            // 1. HERO BANNER
            _buildNewHero(context, isMobile),

            // 👇 2. SECTION BARU: ANGKA STATISTIK (IMPACT)
            _buildImpactSection(isMobile),

            // 3. TENTANG KAMI
            AboutSection(key: aboutKey),

            // 4. PROGRAM UNGGULAN (CROWDFUNDING)
            _buildProgramUnggulan(context, isMobile),

            // 5. LANGKAH PENDAFTARAN & FAQ
            _buildRequirementSection(isMobile),
            _buildFAQSection(context, isMobile),

            // 6. FOOTER
            Container(key: contactKey, child: const CustomFooter()),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HERO BANNER
  // ==========================================
  Widget _buildNewHero(BuildContext context, bool isMobile) {
    return Container(
      height: isMobile ? 550 : 650,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=1200&auto=format&fit=crop',
          ), // Sesuaikan dengan asset kamu
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.4),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 80,
          vertical: 50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "#EmpowerTomorrowsLeaders",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Your Support\nUnlocks\nEqual Futures",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 40 : 65,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: isMobile ? double.infinity : 600,
              child: const Text(
                "Vernon Indonesia Pintar (VIP) memberdayakan generasi muda melalui beasiswa, pelatihan vokasi, dan penempatan kerja nyata.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/donasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "DONASI SEKARANG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                ElevatedButton(
                  onPressed: () => context.go('/program'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text(
                    "LIHAT PROGRAM",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET STATISTIK / IMPACT (BARU)
  // ==========================================
  Widget _buildImpactSection(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFBFBFB), // Warna background soft agar menyatu
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 80,
      ),
      child: Column(
        children: [
          // Konteks & Judul
          const Text(
            "DAMPAK NYATA VIP",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Jejak Langkah & Transparansi Kami",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 600,
            child: Text(
              "Setiap dukungan Anda telah membantu kami menciptakan perubahan nyata. Berikut adalah capaian kami hingga hari ini.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 50),

          // Deretan Kartu Angka
          if (isMobile)
            Column(
              children: [
                _buildStatCard(
                  "Rp 0",
                  "Total Donasi Terkumpul",
                ), // Nanti "0" bisa diganti dengan angka statis atau dari API
                const SizedBox(height: 20),
                _buildStatCard("0", "Penerima Beasiswa"),
                const SizedBox(height: 20),
                _buildStatCard("0", "Batch Aktif"),
                const SizedBox(height: 20),
                _buildStatCard("0", "Alumni Bekerja"),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildStatCard("Rp 0", "Total Donasi Terkumpul"),
                ),
                const SizedBox(width: 25),
                Expanded(child: _buildStatCard("0", "Penerima Beasiswa")),
                const SizedBox(width: 25),
                Expanded(child: _buildStatCard("0", "Batch Aktif")),
                const SizedBox(width: 25),
                Expanded(child: _buildStatCard("0", "Alumni Bekerja")),
              ],
            ),
        ],
      ),
    );
  }

  // Desain Kartu Angkanya
  Widget _buildStatCard(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET PROGRAM UNGGULAN (CROWDFUNDING)
  // ==========================================
  Widget _buildProgramUnggulan(BuildContext context, bool isMobile) {
    return Container(
      key: programKey,
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 80,
      ),
      child: Column(
        children: [
          const Text(
            "PROGRAM UNGGULAN",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Wujudkan Perubahan Nyata",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return Column(
                  children: listProgramDonasi
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: _buildDonationCard(context, item),
                        ),
                      )
                      .toList(),
                );
              } else {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: listProgramDonasi
                        .map(
                          (item) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: item != listProgramDonasi.last
                                    ? 25.0
                                    : 0,
                              ),
                              child: _buildDonationCard(context, item),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context, ProgramDonasi item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.kategori,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'Terkumpul: '),
                            TextSpan(
                              text: 'Rp ${item.terkumpul}jt',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Target: Rp ${item.target}jt',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/donasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 16,
                        ),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        "IKUT BERDONASI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
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

  // ==========================================
  // WIDGET LANGKAH PENDAFTARAN
  // ==========================================
  Widget _buildRequirementSection(bool isMobile) {
    return Container(
      key: stepKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 20 : 50,
      ),
      color: const Color(0xFFFBFBFB),
      child: Column(
        children: [
          Text(
            "Langkah Pendaftaran Beasiswa",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          if (isMobile)
            Column(
              children: [
                _buildStepItem(
                  Icons.edit_note_rounded,
                  "Isi Formulir",
                  "Lengkapi data diri dan berkas di Portal Siswa.",
                ),
                const SizedBox(height: 30),
                _buildStepItem(
                  Icons.assignment_ind_outlined,
                  "Seleksi",
                  "Verifikasi kelengkapan data oleh tim Vernon.",
                ),
                const SizedBox(height: 30),
                _buildStepItem(
                  Icons.record_voice_over_outlined,
                  "Wawancara",
                  "Sesi tanya jawab untuk kandidat yang lolos tahap awal.",
                ),
                const SizedBox(height: 30),
                _buildStepItem(
                  Icons.verified_outlined,
                  "Pengumuman",
                  "Cek hasil akhir di dashboard portal.",
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStepItem(
                    Icons.edit_note_rounded,
                    "Isi Formulir",
                    "Lengkapi data diri dan berkas di Portal Siswa.",
                  ),
                ),
                Expanded(
                  child: _buildStepItem(
                    Icons.assignment_ind_outlined,
                    "Seleksi",
                    "Verifikasi kelengkapan data oleh tim Vernon.",
                  ),
                ),
                Expanded(
                  child: _buildStepItem(
                    Icons.record_voice_over_outlined,
                    "Wawancara",
                    "Sesi tanya jawab untuk kandidat yang lolos tahap awal.",
                  ),
                ),
                Expanded(
                  child: _buildStepItem(
                    Icons.verified_outlined,
                    "Pengumuman",
                    "Cek hasil akhir di dashboard portal.",
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String title, String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 25),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET FAQ
  // ==========================================
  Widget _buildFAQSection(BuildContext context, bool isMobile) {
    return ListenableBuilder(
      listenable: globalFaqStore,
      builder: (context, _) {
        final List<Map<String, String>> allFaqs = [
          ...globalFaqStore.faqBerprestasi,
          ...globalFaqStore.faqReguler,
        ];
        final List<Map<String, String>> previewFaqs = allFaqs.take(4).toList();

        Widget faqContent = Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: isMobile ? 28 : 38,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                  height: 1.2,
                ),
                children: [
                  TextSpan(
                    text: "Pertanyaan seputar\n",
                    style: TextStyle(color: AppColors.primary),
                  ),
                  const TextSpan(
                    text: "Beasiswa VIP",
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Hal umum yang sering ditanyakan oleh pendaftar.",
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: isMobile ? 30 : 40),
            FAQAccordion(faqs: previewFaqs),
            SizedBox(height: isMobile ? 20 : 30),
            ElevatedButton(
              onPressed: () => context.go('/pusat-bantuan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Lihat Lebih Banyak",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );

        Widget illustration = Container(
          height: isMobile ? 250 : 500,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/faq_illustration.png'),
              fit: BoxFit.contain,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.live_help_outlined,
            size: 200,
            color: Colors.black12,
          ),
        );

        return Container(
          key: faqKey,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 60 : 100,
            horizontal: isMobile ? 20 : 80,
          ),
          color: Colors.white,
          child: isMobile
              ? Column(
                  children: [
                    illustration,
                    const SizedBox(height: 40),
                    faqContent,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: faqContent),
                    const SizedBox(width: 80),
                    Expanded(flex: 4, child: illustration),
                  ],
                ),
        );
      },
    );
  }
}

class FAQAccordion extends StatefulWidget {
  final List<Map<String, String>> faqs;
  const FAQAccordion({super.key, required this.faqs});

  @override
  State<FAQAccordion> createState() => _FAQAccordionState();
}

class _FAQAccordionState extends State<FAQAccordion> {
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.faqs.isEmpty)
      return const Center(
        child: Text(
          "Belum ada pertanyaan pada kategori ini.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );

    return Column(
      children: List.generate(widget.faqs.length, (index) {
        final faq = widget.faqs[index];
        final bool isExpanded = expandedIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: Key(index.toString() + isExpanded.toString()),
              initiallyExpanded: isExpanded,
              iconColor: AppColors.primary,
              collapsedIconColor: Colors.grey,
              title: Text(
                faq["tanya"]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isExpanded ? AppColors.primary : Colors.black87,
                ),
              ),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  expandedIndex = expanded ? index : -1;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq["jawab"]!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
