import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
import 'widgets/about_section.dart';
import '../../core/app_colors.dart';
import '../../data/faq_data.dart';

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

            // 1. Hero Banner
            _buildNewHero(context, isMobile),

            // 2. Dampak Nyata
            _buildImpactSection(isMobile),

            // 3. Tentang VIP
            AboutSection(key: aboutKey),

            // 4. Program Unggulan
            _buildProgramUnggulan(context, isMobile),

            // 5. Testimoni Penerima Beasiswa (SEKARANG SUDAH BERANIMASI!)
            _buildTestimonialSection(isMobile),

            // 6. Our Partner / Didukung Oleh
            _buildPartnerSection(isMobile),

            // Anchor agar menu pendaftaran di navbar tidak error
            Container(key: stepKey),

            // 7. FAQ
            _buildFAQSection(context, isMobile),

            // 8. Info Sosmed
            _buildSocialMediaSection(isMobile),

            // 9. Footer
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
          ),
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
                  onPressed: () => context.go('/login-donatur'),
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
  // WIDGET IMPACT SECTION
  // ==========================================
  Widget _buildImpactSection(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFBFBFB),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        children: [
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

          if (isMobile)
            Column(
              children: [
                _buildStatCard("Rp 0", "Total Donasi Terkumpul"),
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
  // WIDGET PROGRAM UNGGULAN
  // ==========================================
  Widget _buildProgramUnggulan(BuildContext context, bool isMobile) {
    return Container(
      key: programKey,
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Center(
        child: SizedBox(
          width: isMobile ? double.infinity : 1100,
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
              Text(
                "Wujudkan Perubahan Nyata",
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 250,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          _buildProgramCardContent(context, isMobile: true),
                        ],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: _buildProgramCardContent(
                                context,
                                isMobile: false,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramCardContent(
    BuildContext context, {
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 30 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Pendidikan & Karir",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Program Karir Kurikulum 10 Bulan VIP",
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Pelatihan intensif terpadu untuk membekali generasi muda kurang mampu dengan keterampilan praktis dan karakter profesional agar siap bersaing di dunia kerja.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.45,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  children: const [
                    TextSpan(text: "Terkumpul: "),
                    TextSpan(
                      text: "Rp 135jt",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Target: Rp 300jt",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                context.go('/login-donatur');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                "IKUT BERDONASI",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET TESTIMONIAL SECTION (Pemanggilan Widget Beranimasi)
  // ==========================================
  Widget _buildTestimonialSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          const Text(
            "CERITA PERUBAHAN",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Bukti Nyata Dampak VIP",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                // 👇 Menggunakan Widget TestimonialCard yang sudah Stateful & Beranimasi
                TestimonialCard(
                  name: "Andi Pratama",
                  role: "Alumni Batch 1 - Karyawan IT",
                  quote:
                      "Awalnya saya hampir putus asa karena tidak ada biaya kuliah. Berkat beasiswa vokasi VIP, saya dibimbing dari nol hingga sekarang bisa bekerja sebagai Junior Programmer di Jakarta.",
                  isMobile: isMobile,
                ),
                TestimonialCard(
                  name: "Siti Nurbaya",
                  role: "Alumni Batch 2 - UI/UX Designer",
                  quote:
                      "Program 10 bulan ini sangat intensif dan daging semua. Fasilitas laptop gratis sangat membantu saya yang berasal dari desa. Terima kasih para donatur VIP!",
                  isMobile: isMobile,
                ),
                TestimonialCard(
                  name: "Budi Santoso",
                  role: "Alumni Batch 3 - Data Analyst",
                  quote:
                      "Mentoring karirnya luar biasa. Saya tidak hanya diajari coding, tapi juga cara membuat CV dan wawancara kerja. Kini saya bisa mengangkat derajat keluarga.",
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET OUR PARTNER SECTION
  // ==========================================
  Widget _buildPartnerSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Text(
            "DIDUKUNG DAN DIPERCAYA OLEH",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: isMobile ? 30 : 60,
            runSpacing: 30,
            children: [
              _buildPartnerLogo(Icons.account_balance_rounded, "Bank Edukasi"),
              _buildPartnerLogo(Icons.business_rounded, "TechCorp Inc."),
              _buildPartnerLogo(Icons.language_rounded, "Global NGO"),
              _buildPartnerLogo(Icons.computer_rounded, "IT Academy"),
              _buildPartnerLogo(Icons.foundation_rounded, "Yayasan Peduli"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(IconData icon, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 36),
        const SizedBox(width: 10),
        Text(
          name,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET FAQ SECTION
  // ==========================================
  Widget _buildFAQSection(BuildContext context, bool isMobile) {
    return ListenableBuilder(
      listenable: globalFaqStore,
      builder: (context, _) {
        final List<Map<String, String>> allFaqs = globalFaqStore.faqList;
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

  // ==========================================
  // WIDGET SOCIAL MEDIA SECTION
  // ==========================================
  Widget _buildSocialMediaSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 40,
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          const Text(
            "IKUTI PERJALANAN KAMI",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.camera_alt_outlined),
              const SizedBox(width: 15),
              _buildSocialIcon(Icons.work_outline_rounded),
              const SizedBox(width: 15),
              _buildSocialIcon(Icons.ondemand_video_rounded),
              const SizedBox(width: 15),
              _buildSocialIcon(Icons.email_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }
}

// ==========================================
// FAQ ACCORDION WIDGET
// ==========================================
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
    if (widget.faqs.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada pertanyaan saat ini.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

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

// ==========================================
// 👇 WIDGET BARU: TestimonialCard (STATEFUL & BERANIMASI)
// ==========================================
class TestimonialCard extends StatefulWidget {
  final String name;
  final String role;
  final String quote;
  final bool isMobile;

  const TestimonialCard({
    super.key,
    required this.name,
    required this.role,
    required this.quote,
    required this.isMobile,
  });

  @override
  State<TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<TestimonialCard> {
  // Variabel untuk melacak apakah kursor sedang berada di atas kartu
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // MouseRegion digunakan untuk mendeteksi kursor masuk/keluar di Web/Desktop
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true), // Kursor masuk
      onExit: (_) => setState(() => _isHovered = false), // Kursor keluar
      cursor: SystemMouseCursors.click, // Ubah kursor menjadi pointer klik
      // AnimatedContainer menangani transisi animasi yang halus
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Durasi animasi 0.3 detik
        curve: Curves.easeInOut, // Kurva animasi agar terasa natural

        width: widget.isMobile ? 300 : 400,
        margin: const EdgeInsets.only(
          right: 24,
          bottom: 20,
          top: 10,
        ), // Jarak ekstra agar animasi Scale tidak terpotong
        padding: const EdgeInsets.all(30),

        // 1. ANIMASI LIFTING (Scale Up) -> Membesar 3% saat di-hover
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        alignment: Alignment.center, // Skala membesar dari tengah

        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B), // Latar gelap permanen
          borderRadius: BorderRadius.circular(20),

          // 2. ANIMASI GLOWING BORDER -> Berubah menjadi merah saat di-hover
          border: Border.all(
            color: _isHovered ? Colors.red : Colors.white12,
            width: _isHovered ? 1.5 : 1.0, // Sedikit ditebalkan
          ),

          // 3. ANIMASI SHADOW DROP -> Muncul bayangan merah tipis saat di-hover (efek terangkat)
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: Colors.red.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10), // Bayangan ke bawah
              )
            else
              const BoxShadow(
                color: Colors.transparent,
              ), // Tidak ada bayangan saat normal
          ],
        ),

        // --- Konten di dalam Kartu (Tetap Sama) ---
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Agar tinggi menyesuaikan konten
          children: [
            const Icon(Icons.format_quote_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            Text(
              '"${widget.quote}"',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade700,
                  radius: 24,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.role,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
