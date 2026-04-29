import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
import 'widgets/program_card.dart';
import 'widgets/about_section.dart';
import '../../data/dummy_data.dart';
import '../../core/app_colors.dart';
import '../../data/hero_banner_data.dart';
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
  final GlobalKey contactKey = GlobalKey(); // Key ini tetap dipertahankan
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
    if (widget.targetSection != oldWidget.targetSection && widget.targetSection != null) {
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
            _buildHero(context, isMobile),
            AboutSection(key: aboutKey),
            Padding(
              key: programKey,
              padding: EdgeInsets.only(
                top: 30, bottom: isMobile ? 40 : 80,
                left: isMobile ? 20 : 50, right: isMobile ? 20 : 50,
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 45, fontWeight: FontWeight.bold, fontFamily: 'sans-serif',
                      ),
                      children: [
                        TextSpan(text: "Program ", style: TextStyle(color: AppColors.primary)),
                        const TextSpan(text: "Unggulan", style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 30 : 50),
                  if (isMobile)
                    Column(
                      children: DummyData.listProgram.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ProgramCard(
                            program: p,
                            onHomeTap: () => scrollToSection(homeKey),
                            onProgramTap: () => scrollToSection(programKey),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: DummyData.listProgram.map((p) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ProgramCard(
                              program: p,
                              onHomeTap: () => scrollToSection(homeKey),
                              onProgramTap: () => scrollToSection(programKey),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            _buildRequirementSection(isMobile),
            _buildFAQSection(context, isMobile),
            
            // 👇 2. Panggil CustomFooter dan bungkus dengan contactKey agar bisa di-scroll
            Container(
              key: contactKey,
              child: const CustomFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isMobile) {
    return Container(
      height: isMobile ? 500 : 650,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/beranda.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.7)],
          ),
        ),
        child: ListenableBuilder(
          listenable: globalHeroBannerStore,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  globalHeroBannerStore.heroSubtitle1, 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14, letterSpacing: isMobile ? 1 : 3, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: isMobile ? 10 : 20),
                Text(
                  globalHeroBannerStore.heroTitle, 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 36 : 55, fontWeight: FontWeight.w900, height: 1.1),
                ),
                SizedBox(height: isMobile ? 10 : 15),
                Text(
                  "${globalHeroBannerStore.heroSubtitle2Base} ${globalHeroBannerStore.isRegistrationOpen ? 'Telah Dibuka' : 'Telah Ditutup'}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70, 
                    fontSize: isMobile ? 14 : 18,
                  ),
                ),
                const SizedBox(height: 40),
                
                if (isMobile)
                  Column(
                    children: [
                      if (globalHeroBannerStore.isRegistrationOpen) ...[
                        SizedBox(width: double.infinity, child: _buildPrimaryButton(context, isMobile)),
                        const SizedBox(height: 15),
                      ],
                      SizedBox(width: double.infinity, child: _buildSecondaryButton(isMobile)),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (globalHeroBannerStore.isRegistrationOpen) ...[
                        _buildPrimaryButton(context, isMobile),
                        const SizedBox(width: 20),
                      ],
                      _buildSecondaryButton(isMobile),
                    ],
                  ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, bool isMobile) {
    return ElevatedButton(
      onPressed: () => context.go('/beasiswa'), 
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 35, vertical: isMobile ? 18 : 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: const Text("DAFTAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSecondaryButton(bool isMobile) {
    return OutlinedButton(
      onPressed: () => context.go('/panduan-pendaftaran'),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 2),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 35, vertical: isMobile ? 18 : 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: const Text("PANDUAN PENDAFTARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRequirementSection(bool isMobile) {
    return Container(
      key: stepKey, width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: isMobile ? 20 : 50),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            "Langkah Pendaftaran Beasiswa", textAlign: TextAlign.center,
            style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          if (isMobile)
            Column(
              children: [
                _buildStepItem(Icons.edit_note_rounded, "Isi Formulir", "Lengkapi data diri di Portal Siswa."),
                const SizedBox(height: 30),
                _buildStepItem(Icons.cloud_upload_outlined, "Unggah Berkas", "Upload scan rapor & prestasi."),
                const SizedBox(height: 30),
                _buildStepItem(Icons.assignment_ind_outlined, "Seleksi", "Verifikasi data oleh tim Vernon."),
                const SizedBox(height: 30),
                _buildStepItem(Icons.verified_outlined, "Pengumuman", "Cek hasil di dashboard portal."),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildStepItem(Icons.edit_note_rounded, "Isi Formulir", "Lengkapi data diri di Portal Siswa.")),
                Expanded(child: _buildStepItem(Icons.cloud_upload_outlined, "Unggah Berkas", "Upload scan rapor & prestasi.")),
                Expanded(child: _buildStepItem(Icons.assignment_ind_outlined, "Seleksi", "Verifikasi data oleh tim Vernon.")),
                Expanded(child: _buildStepItem(Icons.verified_outlined, "Pengumuman", "Cek hasil di dashboard portal.")),
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
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 25),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
      ],
    );
  }

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
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              text: TextSpan(
                style: TextStyle(fontSize: isMobile ? 28 : 38, fontWeight: FontWeight.bold, fontFamily: 'sans-serif', height: 1.2),
                children: [
                  TextSpan(text: "Pertanyaan seputar\n", style: TextStyle(color: AppColors.primary)),
                  const TextSpan(text: "Beasiswa VIP", style: TextStyle(color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text("Hal umum yang sering ditanyakan oleh pendaftar.", textAlign: isMobile ? TextAlign.center : TextAlign.left, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: isMobile ? 30 : 40),
            
            FAQAccordion(faqs: previewFaqs),
            
            SizedBox(height: isMobile ? 20 : 30),
            ElevatedButton(
              onPressed: () => context.go('/pusat-bantuan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Lihat Lebih Banyak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );

        Widget illustration = Container(
          height: isMobile ? 250 : 500,
          decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('assets/faq_illustration.png'), fit: BoxFit.contain), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.live_help_outlined, size: 200, color: Colors.black12),
        );

        return Container(
          key: faqKey, width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: isMobile ? 20 : 80),
          color: const Color(0xFFFDFCF8),
          child: isMobile
              ? Column(children: [illustration, const SizedBox(height: 40), faqContent])
              : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 5, child: faqContent), const SizedBox(width: 80), Expanded(flex: 4, child: illustration)]),
        );
      }
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
    if (widget.faqs.isEmpty) {
       return const Center(
         child: Text(
           "Belum ada pertanyaan pada kategori ini.",
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
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: ThemeData().copyWith(
              dividerColor: Colors.transparent, 
            ),
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
                  if (expanded) {
                    expandedIndex = index;
                  } else {
                    expandedIndex = -1;
                  }
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
                        color: Colors.grey[700],
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