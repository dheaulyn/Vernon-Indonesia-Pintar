import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../shared/custom_navbar.dart';
import '../home_screen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int expandedIndex = -1;
  int selectedTabIndex = 0;

  final List<Map<String, String>> faqBerprestasi = [
    {
      "tanya": "Apa syarat nilai/prestasi untuk Beasiswa Berprestasi?",
      "jawab":
          "Pendaftar wajib memiliki IPK minimal 3.20 (untuk mahasiswa) atau rata-rata rapor 85.00 (untuk siswa SMA). Prestasi tingkat nasional atau internasional akan menjadi nilai tambah yang besar.",
    },
    {
      "tanya": "Apakah Beasiswa Berprestasi mengcover biaya hidup?",
      "jawab":
          "Ya, Beasiswa Berprestasi memberikan pembebasan biaya pendidikan (UKT/SPP) 100% sekaligus uang saku bulanan sebesar Rp 1.500.000.",
    },
    {
      "tanya": "Apakah saya harus aktif berorganisasi?",
      "jawab":
          "Sangat disarankan. Kami mencari calon pemimpin masa depan, sehingga rekam jejak kepemimpinan dalam organisasi sekolah/kampus akan sangat dipertimbangkan.",
    },
    {
      "tanya": "Bagaimana format surat rekomendasi yang benar?",
      "jawab":
          "Surat rekomendasi diketik bebas, namun wajib menggunakan kop surat resmi sekolah/kampus, ditandatangani oleh Kepala Sekolah/Dekan, dan diberi stempel basah.",
    },
  ];

  final List<Map<String, String>> faqReguler = [
    {
      "tanya": "Apa itu Beasiswa Reguler?",
      "jawab":
          "Program bantuan pendidikan yang ditujukan bagi masyarakat umum guna menjamin keberlangsungan pendidikan bagi siswa/mahasiswa yang memiliki keterbatasan finansial.",
    },
    {
      "tanya": "Apakah ada syarat batas pendapatan orang tua?",
      "jawab":
          "Ya, untuk jalur Reguler, gabungan pendapatan kotor kedua orang tua/wali maksimal adalah Rp 4.000.000 per bulan, dibuktikan dengan slip gaji atau Surat Keterangan Tidak Mampu (SKTM).",
    },
    {
      "tanya": "Berapa minimal IPK/Rapor untuk jalur Reguler?",
      "jawab":
          "Syarat akademik untuk jalur Reguler lebih ringan, yaitu minimal IPK 2.75 untuk mahasiswa, dan nilai rata-rata rapor 75.00 untuk siswa.",
    },
    {
      "tanya": "Apa saja benefit dari Beasiswa Reguler?",
      "jawab":
          "Penerima akan mendapatkan bantuan biaya pendidikan penuh dan uang saku bulanan sebesar Rp 750.000.",
    },
  ];

  void _backToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFaqList = selectedTabIndex == 0 ? faqBerprestasi : faqReguler;
    final String currentTitle = selectedTabIndex == 0
        ? "FAQ Beasiswa Berprestasi 2026"
        : "FAQ Beasiswa Reguler 2026";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // PERUBAHAN: Navbar kita kembalikan menjadi appBar standar
      // Sekarang dia akan selalu muncul di atas tanpa perlu di-scroll!
      appBar: CustomNavbar(
        onHomeTap: () => _backToHome(context),
        onAboutTap: () => _backToHome(context),
        onProgramTap: () => _backToHome(context),
        onContactTap: () => _backToHome(context),
        onFAQTap: () {}, // Diam saja karena sedang di halaman FAQ
      ),

      // PERUBAHAN: Stack dan Pendeteksi Scroll sudah dihapus sepenuhnya
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER BANNER ALA VIP ---
            Container(
              width: double.infinity,
              height: 320,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/beranda.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "PUSAT BANTUAN",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Frequently Asked Questions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BREADCRUMB
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _backToHome(context),
                          child: const Text(
                            "Beranda",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "  /  FAQ",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- KONTEN FAQ ---
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TOMBOL TAB PILIHAN PREMIUM ---
                    Row(
                      children: [
                        _buildTabButton("Beasiswa Berprestasi", 0),
                        const SizedBox(width: 20),
                        _buildTabButton("Beasiswa Reguler", 1),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Text(
                      currentTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- LIST FAQ ACCORDION ---
                    ...List.generate(currentFaqList.length, (index) {
                      final faq = currentFaqList[index];
                      final bool isExpanded = expandedIndex == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isExpanded
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: ThemeData().copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            key: Key(
                              selectedTabIndex.toString() +
                                  index.toString() +
                                  isExpanded.toString(),
                            ),
                            initiallyExpanded: isExpanded,
                            iconColor: AppColors.primary,
                            collapsedIconColor: Colors.grey[400],
                            title: Text(
                              faq["tanya"]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isExpanded
                                    ? AppColors.primary
                                    : Colors.black87,
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

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET PEMBANTU UNTUK TOMBOL TAB ALA VIP
  Widget _buildTabButton(String title, int index) {
    bool isSelected = selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
            expandedIndex = -1;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
