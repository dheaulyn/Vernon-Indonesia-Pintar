import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../shared/custom_navbar.dart';
import '../../shared/custom_footer.dart'; 
import '../../../data/mock_database.dart'; 

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int expandedIndex = -1;
  List<Map<String, String>> _faqList = [];

  @override
  void initState() {
    super.initState();
    _loadFaqData();
  }

  // 👇 PERBAIKAN: Fungsi untuk menarik data saat halaman dibuka
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFaqData();
  }

  void _loadFaqData() {
    setState(() {
      _faqList = MockDatabase.getSemuaFaq();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu terang
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER BANNER
            Container(
              width: double.infinity,
              height: isMobile ? 250 : 320, 
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
                    Text(
                      "PUSAT BANTUAN",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isMobile ? 14 : 16, 
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Frequently Asked Questions",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 28 : 40, 
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // KONTEN DAFTAR PERTANYAAN
            Padding(
              padding: EdgeInsets.only(
                top: 50, 
                left: isMobile ? 20 : 100, 
                right: isMobile ? 20 : 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pertanyaan Seputar Beasiswa VIP",
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Temukan jawaban dari pertanyaan yang paling sering diajukan di bawah ini.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 👇 PERBAIKAN: Menggunakan _faqList dari MockDatabase
                  if (_faqList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "Belum ada pertanyaan saat ini.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_faqList.length, (index) {
                      final faq = _faqList[index];
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

                  const SizedBox(height: 60), 
                ],
              ),
            ),

            // PANGGIL CUSTOM FOOTER
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}