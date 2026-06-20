import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../program_detail_screen.dart'; 
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
import '../../core/app_colors.dart';

class ProgramCatalogScreen extends StatefulWidget {
  const ProgramCatalogScreen({super.key});

  @override
  State<ProgramCatalogScreen> createState() => _ProgramCatalogScreenState();
}

class _ProgramCatalogScreenState extends State<ProgramCatalogScreen> {
  final _supabase = Supabase.instance.client;
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('programs')
          .stream(primaryKey: ['id'])
          .order('sort_order', ascending: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomNavbar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final programs = snapshot.data ?? [];

        if (programs.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const CustomNavbar(),
            body: const Center(
              child: Text(
                "Belum ada program publik.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        // ==========================================================
        // SULAP 1: JIKA CUMA 1 PROGRAM -> WUJUDNYA JADI HALAMAN DETAIL
        // ==========================================================
        if (programs.length == 1) {
          // Langsung render halaman detail, URL tetap /program
          final slug = (programs[0]['slug'] ?? programs[0]['id']).toString();
          return ProgramDetailScreen(programSlug: slug);
        }

        // ==========================================================
        // SULAP 2: JIKA > 1 PROGRAM -> WUJUDNYA JADI GRID KATALOG
        // ==========================================================

        // Ambil daftar kategori unik dari data program
        final categories = <String>{'Semua'};
        for (final prog in programs) {
          final kat = (prog['kategori'] ?? '').toString().trim();
          if (kat.isNotEmpty) categories.add(kat);
        }

        // Filter program berdasarkan kategori terpilih
        final filteredPrograms = _selectedCategory == 'Semua'
            ? programs
            : programs
                .where((p) =>
                    (p['kategori'] ?? '').toString().trim() ==
                    _selectedCategory)
                .toList();

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 600;
        double cardWidth;
        if (isMobile) {
          cardWidth = double.infinity;
        } else if (screenWidth < 900) {
          cardWidth = (screenWidth - 48 - 30) / 2;
        } else {
          cardWidth = 360;
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: const CustomNavbar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.accentBlack,
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "PROGRAM BEASISWA",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Pilih Program yang Tepat Untukmu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==============================
                // FILTER KATEGORI (CHIP BUTTONS)
                // ==============================
                if (categories.length > 2)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24.0 : 80.0,
                      vertical: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _selectedCategory = cat);
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 900 ? 24.0 : 80.0,
                    vertical: 60.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: filteredPrograms.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada program untuk kategori "$_selectedCategory".',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Wrap(
                            alignment: WrapAlignment.center, // BIKIN RATA TENGAH
                            spacing: 30,
                            runSpacing: 30,
                            children: filteredPrograms.map((prog) {
                              return SizedBox(
                                width: cardWidth,
                                height: 480,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(
                                                    20,
                                                  ),
                                                ),
                                                child: Text(
                                                  prog['kategori'] ?? 'Pendidikan',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Text(
                                                prog['nama_program'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Expanded(
                                                child: Text(
                                                  prog['deskripsi'] ?? '',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    final slug = prog['slug']?.toString() ?? prog['id'].toString();
                                                    context.go('/program-detail/$slug');
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.accentBlack,
                                                    foregroundColor: Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 18,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "LIHAT DETAIL",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
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
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
                const CustomFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
