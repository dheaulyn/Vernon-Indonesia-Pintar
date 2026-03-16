import 'package:flutter/material.dart';
import '../shared/custom_navbar.dart';
import 'widgets/program_card.dart';
import 'widgets/about_section.dart';
import 'widgets/faq_screen.dart';
import '../../data/dummy_data.dart';
import '../../core/app_colors.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey programKey = GlobalKey();
  final GlobalKey homeKey = GlobalKey();
  final GlobalKey faqKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();
  final GlobalKey stepKey = GlobalKey();

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavbar(
        onHomeTap: () => scrollToSection(homeKey),
        onAboutTap: () => scrollToSection(aboutKey),
        onProgramTap: () => scrollToSection(programKey),
        onContactTap: () => scrollToSection(contactKey),
        onFAQTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FAQScreen()),
          );
        }, // Nanti tambahkan onFAQTap di custom_navbar.dart jika ingin FAQ di navbar bisa diklik
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(key: homeKey),
            _buildHero(context),
            AboutSection(key: aboutKey),

            // --- SECTION: JENIS BEASISWA ---
            Padding(
              key: programKey,
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 80,
                left: 50,
                right: 50,
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'sans-serif',
                      ),
                      children: [
                        TextSpan(
                          text: "Jenis ",
                          style: TextStyle(color: AppColors.primary),
                        ),
                        const TextSpan(
                          text: "Beasiswa",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
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

            // --- SECTION: LANGKAH PENDAFTARAN ---
            _buildRequirementSection(),

            // --- SECTION: FAQ (2 KOLOM + AUTO CLOSE) ---
            _buildFAQSection(context),

            // --- SECTION: FOOTER / KONTAK ---
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // FUNGSI-FUNGSI PEMBANTU (WIDGETS)
  // =========================================================================

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 650,
      width: double.infinity,
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
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "PROGRAM BEASISWA VERNON INDONESIA PINTAR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 3,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Membuka Pintu Dunia\nLewat Pendidikan",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 55,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Pendaftaran Beasiswa Periode 2026 Telah Dibuka",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    "DAFTAR SEKARANG",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: () => scrollToSection(stepKey),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    "PANDUAN PENDAFTARAN",
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

  Widget _buildRequirementSection() {
    return Container(
      key: stepKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            "Langkah Pendaftaran Beasiswa",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStepItem(
                Icons.edit_note_rounded,
                "Isi Formulir",
                "Lengkapi data diri di Portal Siswa.",
              ),
              _buildStepItem(
                Icons.cloud_upload_outlined,
                "Unggah Berkas",
                "Upload scan rapor & prestasi.",
              ),
              _buildStepItem(
                Icons.assignment_ind_outlined,
                "Seleksi",
                "Verifikasi data oleh tim Vernon.",
              ),
              _buildStepItem(
                Icons.verified_outlined,
                "Pengumuman",
                "Cek hasil di dashboard portal.",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String title, String desc) {
    return Expanded(
      child: Column(
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
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ],
      ),
    );
  }

  // --- WIDGET FAQ SECTION (LAYOUT 2 KOLOM) ---
  Widget _buildFAQSection(BuildContext context) {
    final List<Map<String, String>> previewFaqs = [
      {
        "tanya": "Apa itu Beasiswa Vernon Indonesia Pintar?",
        "jawab":
            "Beasiswa VIP adalah program apresiasi pendidikan untuk siswa dan mahasiswa berprestasi dari seluruh Indonesia.",
      },
      {
        "tanya": "Apa saja jenis Beasiswa yang tersedia?",
        "jawab":
            "Terdapat dua jalur: Beasiswa Berprestasi (Akademik/Non-Akademik) dan Beasiswa Reguler (Bantuan Finansial).",
      },
      {
        "tanya": "Siapa saja yang bisa mendaftar?",
        "jawab":
            "Siswa SMA/SMK/MA sederajat kelas 12 dan Mahasiswa aktif maksimal semester 4.",
      },
      {
        "tanya": "Apakah pendaftaran dipungut biaya?",
        "jawab":
            "Tidak. Seluruh proses seleksi Beasiswa VIP 100% GRATIS dan tidak dipungut biaya apapun.",
      },
    ];

    return Container(
      key: faqKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      color: const Color(0xFFFDFCF8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // KOLOM KIRI: TEKS & ACCORDION PINTAR
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 38,
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
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // Memanggil Widget FAQ yang otomatis menutup
                FAQAccordion(faqs: previewFaqs),

                const SizedBox(height: 30),

                // TOMBOL LIHAT LEBIH BANYAK YANG SUDAH BERFUNGSI
                ElevatedButton(
                  onPressed: () {
                    // ARAHKAN KE HALAMAN FAQ SCREEN
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FAQScreen(),
                      ),
                    );
                  },
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
            ),
          ),

          const SizedBox(width: 80),

          // KOLOM KANAN: GAMBAR ILUSTRASI
          Expanded(
            flex: 4,
            child: Container(
              height: 500,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      key: contactKey,
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 50),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "VERNON INDONESIA PINTAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Membangun generasi emas Indonesia melalui akses pendidikan yang merata dan berkualitas.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 50),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "HUBUNGI KAMI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _footerLink("WhatsApp: +62 812-3456-7890"),
                    _footerLink("Email: info@vip.or.id"),
                    _footerLink(
                      "Alamat: Jl. Letjen Sutoyo No.102A, Bunulrejo, Kec. Blimbing, Kota Malang, Jawa Timur, Indonesia",
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Text(
            "© 2026 Vernon Indonesia Pintar. All Rights Reserved.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 28),
    );
  }

  Widget _footerLink(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET KHUSUS UNTUK FAQ YANG BISA TUTUP OTOMATIS (STATEFUL)
// =========================================================================
class FAQAccordion extends StatefulWidget {
  final List<Map<String, String>> faqs;
  const FAQAccordion({super.key, required this.faqs});

  @override
  State<FAQAccordion> createState() => _FAQAccordionState();
}

class _FAQAccordionState extends State<FAQAccordion> {
  // Ingatan untuk mencatat nomor FAQ yang sedang terbuka (-1 berarti tutup semua)
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.faqs.length, (index) {
        final faq = widget.faqs[index];
        final bool isExpanded = expandedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
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
              // Kunci utamanya di sini: memaksa Flutter menggambar ulang saat state berubah
              key: Key(index.toString() + isExpanded.toString()),
              initiallyExpanded: isExpanded,
              iconColor: AppColors.primary,
              collapsedIconColor: Colors.grey,
              title: Text(
                faq["tanya"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              onExpansionChanged: (bool expanded) {
                // Mengubah ingatan saat di-klik
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
                      style: TextStyle(color: Colors.grey[700], height: 1.6),
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
