import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../program_detail_screen.dart'; // Import halaman detail
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
import '../../core/app_colors.dart';

class ProgramCatalogScreen extends StatelessWidget {
  const ProgramCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _supabase = Supabase.instance.client;

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
          return ProgramDetailScreen(programId: programs[0]['id']);
        }

        // ==========================================================
        // SULAP 2: JIKA > 1 PROGRAM -> WUJUDNYA JADI GRID KATALOG
        // ==========================================================
        final double screenWidth = MediaQuery.of(context).size.width;
        double cardWidth;
        if (screenWidth < 600) {
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

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 900 ? 24.0 : 80.0,
                    vertical: 60.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Wrap(
                      alignment: WrapAlignment.center, // BIKIN RATA TENGAH
                      spacing: 30,
                      runSpacing: 30,
                      children: programs.map((prog) {
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
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop',
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
                                              context.go(
                                                '/program-detail/${prog['id']}',
                                              );
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
