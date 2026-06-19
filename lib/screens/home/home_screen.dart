import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
import 'widgets/about_section.dart';
import '../../core/app_colors.dart';

import '../../services/supabase_donasi_service.dart';
import '../../services/supabase_cms_service.dart';
import '../../services/supabase_pendaftaran_service.dart';

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

  final _supabase = Supabase.instance.client;
  bool _faqLoaded = false;
  final ScrollController _testimonialScrollController = ScrollController();
  final ValueNotifier<bool> _leftArrowNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _rightArrowNotifier = ValueNotifier<bool>(true);

  // Controller dan Notifier untuk PageView Program
  final PageController _programPageController = PageController();
  final ValueNotifier<int> _currentProgramPage = ValueNotifier<int>(0);
  int _totalProgramPages = 0;

  @override
  void dispose() {
    _leftArrowNotifier.dispose();
    _rightArrowNotifier.dispose();
    _testimonialScrollController.dispose();
    
    _programPageController.dispose();
    _currentProgramPage.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SupabaseCmsService.initialize();
    SupabasePendaftaranService.listenPenerimaBeasiswaCount();

    _testimonialScrollController.addListener(() {
      if (_testimonialScrollController.hasClients) {
        final position = _testimonialScrollController.position;
        _leftArrowNotifier.value = position.pixels > 0;
        _rightArrowNotifier.value = position.pixels < position.maxScrollExtent;
      }
    });

    _programPageController.addListener(() {
      if (_programPageController.hasClients && _programPageController.page != null) {
        _currentProgramPage.value = _programPageController.page!.round();
      }
    });

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

  ImageProvider _getImageProvider(String imageSource) {
    if (imageSource.isEmpty) {
      return const NetworkImage(
        'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=1200&auto=format&fit=crop',
      );
    }
    if (imageSource.startsWith('http')) return NetworkImage(imageSource);
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
            _buildProgramUnggulan(context, isMobile: isMobile),
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
  // HERO BANNER (Real-time via ValueListenableBuilder)
  // ==========================================
  Widget _buildNewHero(BuildContext context, bool isMobile) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: SupabaseCmsService.heroBanner,
      builder: (context, heroData, _) {
        String image = heroData['image_url'] ?? '';
        String tagline = heroData['tagline'] ?? '#EmpowerTomorrowsLeaders';
        String title =
            heroData['title'] ?? 'Your Support\nUnlocks\nEqual Futures';
        String subtitle =
            heroData['subtitle'] ??
            'Vernon Indonesia Pintar (VIP) memberdayakan generasi muda melalui beasiswa, pelatihan vokasi, dan penempatan kerja nyata.';

        return Container(
          height: isMobile ? 550 : 650,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _getImageProvider(image),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tagline,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  title.replaceAll('\\n', '\n'),
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
                    subtitle,
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
                      onPressed: () {
                        // Diarahkan auto scroll ke bagian Program
                        Scrollable.ensureVisible(
                          programKey.currentContext!,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                        );
                      },
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
      },
    );
  }

  // ==========================================
  // IMPACT SECTION (Real-time Total Donasi)
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
                  valueListenable: SupabaseDonationService.totalDonasiTerkumpul,
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
                ValueListenableBuilder<int>(
                  valueListenable: SupabasePendaftaranService.totalPenerimaBeasiswa,
                  builder: (context, count, _) {
                    return _buildStatCard(
                      count.toString(),
                      "Penerima Beasiswa",
                    );
                  },
                ),
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
                    valueListenable:
                        SupabaseDonationService.totalDonasiTerkumpul,
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
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: SupabasePendaftaranService.totalPenerimaBeasiswa,
                    builder: (context, count, _) {
                      return _buildStatCard(
                        count.toString(),
                        "Penerima Beasiswa",
                      );
                    },
                  ),
                ),
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
  // PROGRAM UNGGULAN (Dinamis: 1 Program vs Banyak Program)
  // ==========================================
  Widget _buildProgramUnggulan(BuildContext context, {required bool isMobile}) {
    return Container(
      key: programKey,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 80,
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('programs')
            .stream(primaryKey: ['id'])
            .order('sort_order', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final programs = snapshot.data ?? [];

          if (programs.isEmpty) {
            return const SizedBox(
              height: 400,
              child: Center(child: Text("Belum ada program.")),
            );
          }

          _totalProgramPages = programs.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER SECTION
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
                child: Column(
                  children: [
                    const Text(
                      "PROGRAM UNGGULAN",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Program Beasiswa & Pelatihan VIP",
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
                        "Akses program bantuan pendidikan kami yang dirancang khusus untuk meningkatkan keterampilan dan menunjang masa depan Anda.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // KARTU PROGRAM BESAR (SATU PER HALAMAN, SWIPE/GESER)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
                child: Center(
                  child: SizedBox(
                    width: isMobile ? double.infinity : 1160,
                    height: isMobile ? 650 : 450,
                    child: Stack(
                      children: [
                        // PageView dengan padding horizontal agar tidak tertutup tombol panah
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 30),
                          child: ScrollConfiguration(
                            behavior: AppScrollBehavior(),
                            child: PageView.builder(
                              controller: _programPageController,
                              itemCount: programs.length,
                              itemBuilder: (context, index) {
                                final prog = programs[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
                                              height: 200,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    (prog['thumbnail_url'] != null &&
                                                            prog['thumbnail_url']
                                                                .toString()
                                                                .isNotEmpty)
                                                        ? prog['thumbnail_url']
                                                        : 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: _buildProgramCardContent(
                                                context,
                                                isMobile: true,
                                                prog: prog,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      (prog['thumbnail_url'] != null &&
                                                              prog['thumbnail_url']
                                                                  .toString()
                                                                  .isNotEmpty)
                                                          ? prog['thumbnail_url']
                                                          : 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop',
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
                                                prog: prog,
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Tombol panah kiri (desktop)
                        if (!isMobile)
                          Positioned(
                            left: 9,
                            top: 0,
                            bottom: 0,
                            child: ValueListenableBuilder<int>(
                              valueListenable: _currentProgramPage,
                              builder: (context, currentPage, _) {
                                if (currentPage <= 0) return const SizedBox.shrink();
                                return Center(
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 4,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        _programPageController.previousPage(
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Tombol panah kanan (desktop)
                        if (!isMobile)
                          Positioned(
                            right: 9,
                            top: 0,
                            bottom: 0,
                            child: ValueListenableBuilder<int>(
                              valueListenable: _currentProgramPage,
                              builder: (context, currentPage, _) {
                                if (currentPage >= programs.length - 1) return const SizedBox.shrink();
                                return Center(
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 4,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        _programPageController.nextPage(
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // DOT INDICATOR & COUNTER
              if (programs.length > 1) ...[
                const SizedBox(height: 30),
                ValueListenableBuilder<int>(
                  valueListenable: _currentProgramPage,
                  builder: (context, currentPage, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(programs.length, (index) {
                        final isActive = index == currentPage;
                        return GestureDetector(
                          onTap: () {
                            _programPageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: isActive ? 32 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.red : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // WIDGET KONTEN CARD PROGRAM (PENTING! JANGAN DIHAPUS)
  // ==========================================
  Widget _buildProgramCardContent(
    BuildContext context, {
    required bool isMobile,
    required Map<String, dynamic> prog,
  }) {
    final kategori = prog['kategori']?.toString() ?? 'Pendidikan & Karir';
    final namaProgram =
        prog['nama_program']?.toString() ?? 'Program Tanpa Nama';
    final deskripsi =
        prog['deskripsi']?.toString() ?? 'Deskripsi belum tersedia.';

    return Padding(
      padding: EdgeInsets.all(isMobile ? 25 : 50),
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
            child: Text(
              kategori,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            namaProgram,
            style: TextStyle(
              fontSize: isMobile ? 22 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 15),
          Text(
            deskripsi,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(), // Mendorong tombol agar selalu menempel di bawah
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                final slug = prog['slug']?.toString() ?? prog['id'].toString();
                context.go('/program-detail/$slug');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                "LIHAT DETAIL PROGRAM",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TESTIMONIAL SECTION (Real-time)
  // ==========================================
  Widget _buildTestimonialSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
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
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: _leftArrowNotifier,
            builder: (context, showLeft, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _rightArrowNotifier,
                builder: (context, showRight, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        child: showLeft
                            ? IconButton(
                                onPressed: () {
                                  if (_testimonialScrollController.hasClients) {
                                    final target = (_testimonialScrollController.offset - 400).clamp(
                                      0.0,
                                      _testimonialScrollController.position.maxScrollExtent,
                                    );
                                    _testimonialScrollController.animateTo(
                                      target,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              )
                            : null,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Geser untuk melihat",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: showRight
                            ? IconButton(
                                onPressed: () {
                                  if (_testimonialScrollController.hasClients) {
                                    final target = (_testimonialScrollController.offset + 400).clamp(
                                      0.0,
                                      _testimonialScrollController.position.maxScrollExtent,
                                    );
                                    _testimonialScrollController.animateTo(
                                      target,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              )
                            : null,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 40),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase
                .from('testimonials')
                .stream(primaryKey: ['id'])
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              final testimonials = snapshot.data ?? [];

              if (testimonials.isEmpty) {
                return const Center(
                  child: Text(
                    "Belum ada testimoni.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Update arrows post layout to ensure correctness without setState loop
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_testimonialScrollController.hasClients) {
                  final pos = _testimonialScrollController.position;
                  _leftArrowNotifier.value = pos.pixels > 0;
                  _rightArrowNotifier.value = pos.pixels < pos.maxScrollExtent;
                }
              });

              return SingleChildScrollView(
                controller: _testimonialScrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
                child: Row(
                  children: testimonials.map((testimoni) {
                    return TestimonialCard(
                      name: testimoni['name'] ?? '',
                      role: testimoni['role'] ?? '',
                      quote: testimoni['quote'] ?? '',
                      isMobile: isMobile,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PARTNER SECTION (Real-time)
  // ==========================================
  Widget _buildPartnerSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 80 : 100,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const Text(
            "MITRA & PARTNER",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Didukung oleh Institusi & Perusahaan Terpercaya",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 50),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase
                .from('partners')
                .stream(primaryKey: ['id'])
                .order('sort_order', ascending: true),
            builder: (context, snapshot) {
              final partners = snapshot.data ?? [];

              if (partners.isEmpty) {
                return Text(
                  "Belum ada partner.",
                  style: TextStyle(color: Colors.grey.shade400),
                );
              }

              return Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: isMobile ? 20 : 30,
                runSpacing: isMobile ? 20 : 30,
                children: partners
                    .map(
                      (p) => PartnerCard(
                        imageSource: p['image_url'] ?? '',
                        name: p['name'] ?? '',
                        isMobile: isMobile,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FAQ SECTION (Real-time)
  // ==========================================
  Widget _buildFAQSection(BuildContext context, bool isMobile) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('faqs')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting &&
            !_faqLoaded) {
          _faqLoaded = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.targetSection == 'faq' && mounted) {
              _autoScrollToTarget();
            }
          });
        }
        final faqs = snapshot.data ?? [];
        final previewFaqs = faqs.take(4).toList();

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
                colors: [
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: [0.0, 0.6, 0.95, 1.0],
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
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 60 : 100,
            horizontal: isMobile ? 24 : 80,
          ),
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
  final List<Map<String, dynamic>> faqs;
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
                faq["question"] ?? faq["tanya"] ?? '',
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
                      faq["answer"] ?? faq["jawab"] ?? '',
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
// TESTIMONIAL CARD WIDGET
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
      onHover: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: widget.isMobile ? 300 : 400,
        height: 280,
        margin: const EdgeInsets.only(right: 24, bottom: 20, top: 10),
        padding: const EdgeInsets.all(30),
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
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
          children: [
            const Icon(Icons.format_quote_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                '"${widget.quote}"',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
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

// ==========================================
// PartnerCard WIDGET
// ==========================================
class PartnerCard extends StatefulWidget {
  final String imageSource;
  final String name;
  final bool isMobile;

  const PartnerCard({
    super.key,
    required this.imageSource,
    required this.name,
    required this.isMobile,
  });

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = widget.isMobile ? 150.0 : 210.0;
    final double cardHeight = widget.isMobile ? 110.0 : 150.0;
    final double logoHeight = widget.isMobile ? 50.0 : 70.0;

    Widget imageWidget;
    if (widget.imageSource.isEmpty) {
      imageWidget = Icon(
        Icons.business,
        color: Colors.grey.shade400,
        size: logoHeight,
      );
    } else if (widget.imageSource.startsWith('http')) {
      imageWidget = Image.network(
        widget.imageSource,
        height: logoHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image,
          color: Colors.grey.shade400,
          size: logoHeight,
        ),
      );
    } else {
      try {
        imageWidget = Image.memory(
          base64Decode(widget.imageSource),
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

    return MouseRegion(
      onHover: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.05 : 1.0,
          _isHovered ? 1.05 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? Colors.red : Colors.grey.shade200,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: imageWidget)),
            const SizedBox(height: 8),
            Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isHovered ? Colors.red.shade700 : Colors.black87,
                fontSize: widget.isMobile ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// AppScrollBehavior (Mendukung drag menggunakan mouse di Web/Desktop)
// ==========================================
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
