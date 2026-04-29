import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../shared/custom_navbar.dart';
import '../../shared/custom_footer.dart'; // 👇 1. IMPORT CUSTOM FOOTER
import '../../../data/faq_data.dart'; 

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int expandedIndex = -1;
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah layar sedang diakses via HP atau PC
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return ListenableBuilder(
      listenable: globalFaqStore, // Pantau perubahan di Gudang Data
      builder: (context, child) {
        
        final currentFaqList = selectedTabIndex == 0 ? globalFaqStore.faqBerprestasi : globalFaqStore.faqReguler;
        
        final String currentTitle = selectedTabIndex == 0
            ? "FAQ Beasiswa Berprestasi 2026"
            : "FAQ Beasiswa Reguler 2026";

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: const CustomNavbar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
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

                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTabButton("Beasiswa Berprestasi", 0, isMobile),
                            const SizedBox(width: 15),
                            _buildTabButton("Beasiswa Reguler", 1, isMobile),
                          ],
                        ),

                        const SizedBox(height: 40),

                        Text(
                          currentTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (currentFaqList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                "Belum ada pertanyaan pada kategori ini.",
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          )
                        else
                          ...List.generate(currentFaqList.length, (index) {
                            final faq = currentFaqList[index];
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
                                  key: Key(
                                    selectedTabIndex.toString() +
                                        index.toString() +
                                        isExpanded.toString(),
                                  ),
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

                        const SizedBox(height: 60), // Kurangi sedikit padding bawah agar footer lebih proporsional
                      ],
                    ),
                  ),
                ),

                // 👇 2. PANGGIL CUSTOM FOOTER DI BAGIAN PALING BAWAH
                const CustomFooter(),
              ],
            ),
          ),
        );
      }
    );
  }

  // WIDGET PEMBANTU UNTUK TOMBOL TAB ALA VIP
  Widget _buildTabButton(String title, int index, bool isMobile) {
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
          height: isMobile ? 65 : 75,
          padding: const EdgeInsets.symmetric(horizontal: 5),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 12 : 16, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                height: 1.2,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}