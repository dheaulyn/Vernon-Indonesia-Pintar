import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
import 'widgets/about_section.dart';
import '../../core/app_colors.dart';
import '../../data/faq_data.dart';
import '../../data/mock_database.dart';

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

  late Map<String, String> _heroData;
  List<Map<String, String>> _testimonialData = [];
  List<Map<String, dynamic>> _partnerData = [];

  @override
  void initState() {
    super.initState();
    _refreshAllData();

    if (widget.targetSection != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _autoScrollToTarget();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshAllData();
  }

  void _refreshAllData() {
    setState(() {
      _heroData = MockDatabase.getHomeHeroData();
      _testimonialData = MockDatabase.getSemuaTestimoni();
      _partnerData = MockDatabase.getSemuaPartner();
    });
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

  ImageProvider _getImageProvider(String imageSource) {
    if (imageSource.isEmpty) {
      return const NetworkImage(
        'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=1200&auto=format&fit=crop',
      );
    }
    if (imageSource.startsWith('http')) {
      return NetworkImage(imageSource);
    }
    return MemoryImage(base64Decode(imageSource));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(key: homeKey),
            _buildNewHero(context, isMobile),
            _buildImpactSection(isMobile),
            AboutSection(key: aboutKey),
            _buildProgramUnggulan(context, isMobile),

            _buildTestimonialSection(isMobile),
            _buildPartnerSection(isMobile),

            Container(key: stepKey),
            _buildFAQSection(context, isMobile),

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
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _getImageProvider(_heroData['image'] ?? ''),
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
              child: Text(
                _heroData['tagline'] ?? "#EmpowerTomorrowsLeaders",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              _heroData['title']?.replaceAll('\\n', '\n') ??
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
              child: Text(
                _heroData['subtitle'] ??
                    "Vernon Indonesia Pintar (VIP) memberdayakan generasi muda melalui beasiswa, pelatihan vokasi, dan penempatan kerja nyata.",
                style: const TextStyle(
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
  // WIDGET IMPACT SECTION (SUDAH FIX FORMAT RUPIAH & ANTI-PECAH)
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
                ValueListenableBuilder<int>(
                  valueListenable: MockDatabase.totalDonasiTerkumpul,
                  builder: (context, total, _) {
                    final formatRp = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    );
                    return _buildStatCard(
                      formatRp.format(total),
                      "Total Donasi Terkumpul",
                    );
                  },
                ),
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
                  child: ValueListenableBuilder<int>(
                    valueListenable: MockDatabase.totalDonasiTerkumpul,
                    builder: (context, total, _) {
                      final formatRp = NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      );
                      return _buildStatCard(
                        formatRp.format(total),
                        "Total Donasi Terkumpul",
                      );
                    },
                  ),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.red,
              ),
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

          ValueListenableBuilder<int>(
            valueListenable: MockDatabase.totalDonasiTerkumpul,
            builder: (context, int total, _) {
              double progressValue = total / 300000000;
              final formatRp = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              );
              String displayTotal = formatRp.format(total);
              String displayTarget = formatRp.format(300000000);

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: "Terkumpul: "),
                            TextSpan(
                              text: displayTotal,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Target: $displayTarget",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
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
  // WIDGET TESTIMONIAL SECTION
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
              children: _testimonialData.isEmpty
                  ? [
                      const Center(
                        child: Text(
                          "Belum ada testimoni.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ]
                  : _testimonialData.map((testimoni) {
                      return TestimonialCard(
                        name: testimoni['name'] ?? '',
                        role: testimoni['role'] ?? '',
                        quote: testimoni['quote'] ?? '',
                        isMobile: isMobile,
                      );
                    }).toList(),
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
            "Our Partners",
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
            children: _partnerData.isEmpty
                ? [
                    Text(
                      "Belum ada partner.",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ]
                : _partnerData.map((p) {
                    return _buildPartnerLogo(p['image'] ?? '', p['name'] ?? '');
                  }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(String imageSource, String name) {
    Widget imageWidget;
    final double logoHeight = 60.0;

    if (imageSource.isEmpty) {
      imageWidget = Icon(
        Icons.business,
        color: Colors.grey.shade400,
        size: logoHeight,
      );
    } else if (imageSource.startsWith('http')) {
      imageWidget = Image.network(
        imageSource,
        height: logoHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image,
            color: Colors.grey.shade400,
            size: logoHeight,
          );
        },
      );
    } else {
      try {
        imageWidget = Image.memory(
          base64Decode(imageSource),
          height: logoHeight,
          fit: BoxFit.contain,
        );
      } catch (e) {
        imageWidget = Icon(
          Icons.broken_image,
          color: Colors.grey.shade400,
          size: logoHeight,
        );
      }
    }

    return Tooltip(message: name, child: imageWidget);
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

        Widget illustration = ConstrainedBox(
          constraints: BoxConstraints(maxHeight: isMobile ? 400 : 550),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.transparent],
                stops: [0.0, 0.6, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/faq_illustration.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
        );

        return Container(
          key: faqKey,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 60 : 100,
            horizontal: isMobile ? 24 : 80,
          ),
          color: Colors.white,
          child: isMobile
              ? Column(
                  children: [
                    illustration,
                    const SizedBox(height: 30),
                    faqContent,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
// TestimonialCard WIDGET
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,

        width: widget.isMobile ? 300 : 400,
        margin: const EdgeInsets.only(right: 24, bottom: 20, top: 10),
        padding: const EdgeInsets.all(30),

        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: _isHovered ? Colors.red : Colors.white12,
            width: _isHovered ? 1.5 : 1.0,
          ),

          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: Colors.red.withOpacity(0.15),
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
          mainAxisSize: MainAxisSize.min,
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
