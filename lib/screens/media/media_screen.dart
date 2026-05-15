import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../shared/custom_navbar.dart'; 
import '../shared/custom_footer.dart'; 
import '../../data/mock_database.dart'; 

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data diambil dari MockDatabase
  List<Map<String, String>> _artikelList = [];
  List<Map<String, String>> _galeriList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Menarik data saat halaman pertama kali dibuka
    _artikelList = MockDatabase.getSemuaArtikel();
    _galeriList = MockDatabase.getSemuaGaleri();

    // Listener ini berguna agar layar ter-update saat tab diklik
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 👇 FUNGSI PINTAR: Untuk merender gambar URL maupun Base64
  Widget _buildImageDisplay(String imageSource, {BoxFit fit = BoxFit.cover}) {
    if (imageSource.isEmpty) {
      return const Center(child: Icon(Icons.image_rounded, size: 50, color: Colors.black12));
    }
    if (imageSource.startsWith('http')) {
      return Image.network(imageSource, fit: fit);
    } 
    try {
      return Image.memory(base64Decode(imageSource), fit: fit);
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      // MENGGUNAKAN SINGLE CHILD SCROLL VIEW AGAR NAVBAR & FOOTER IKUT TER-SCROLL
      body: SingleChildScrollView(
        child: Column(
          children: [
            // NAVBAR DI BAGIAN ATAS
            const CustomNavbar(),
            
            // HEADER MEDIA PUBLIKASI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: Colors.white,
              child: Column(
                children: [
                  const Text(
                    "Media & Publikasi",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ikuti terus perkembangan, berita terbaru, dan galeri kegiatan Vernon Indonesia Pintar.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // WIDGET TAB BAR (DI TENGAH)
                  Container(
                    width: isMobile ? double.infinity : 500,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: "Artikel Terbaru"),
                        Tab(text: "Galeri Kegiatan"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // KONTEN TAB (ARTIKEL ATAU GALERI)
            Container(
              constraints: const BoxConstraints(minHeight: 500), 
              width: 1200, 
              padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40, horizontal: isMobile ? 0 : 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _tabController.index == 0 
                  ? _buildArtikelTab(isMobile) 
                  : _buildGaleriTab(isMobile),
              ),
            ),

            // FOOTER DI BAGIAN BAWAH
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET ARTIKEL
  // ==========================================
  Widget _buildArtikelTab(bool isMobile) {
    int crossAxisCount = isMobile ? 1 : 3;

    if (_artikelList.isEmpty) {
      return const Center(child: Text("Belum ada artikel yang diterbitkan."));
    }

    return Padding(
      key: const ValueKey('artikel'),
      padding: EdgeInsets.all(isMobile ? 15.0 : 0),
      child: GridView.builder(
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(), 
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 25,
          mainAxisSpacing: 25,
          childAspectRatio: isMobile ? 1.0 : 0.85, 
        ),
        itemCount: _artikelList.length,
        itemBuilder: (context, index) {
          final artikel = _artikelList[index];
          return Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                context.go('/media/artikel', extra: artikel);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      // 👇 MENAMPILKAN GAMBAR ARTIKEL
                      child: _buildImageDisplay(artikel['image'] ?? ''),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  artikel['kategori'] ?? 'Berita',
                                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                artikel['date'] ?? '-',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            artikel['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              artikel['desc'] ?? '',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const [
                              Text("Baca Selengkapnya", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // WIDGET GALERI DENGAN FITUR POP-UP (LIGHTBOX)
  // ==========================================
  Widget _buildGaleriTab(bool isMobile) {
    int crossAxisCount = isMobile ? 2 : 4;

    if (_galeriList.isEmpty) {
      return const Center(child: Text("Belum ada foto galeri."));
    }

    return Padding(
      key: const ValueKey('galeri'),
      padding: EdgeInsets.all(isMobile ? 15.0 : 0),
      child: GridView.builder(
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(), 
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.0, 
        ),
        itemCount: _galeriList.length,
        itemBuilder: (context, index) {
          final g = _galeriList[index];
          final judulFoto = g['title'] ?? '';
          final imageSource = g['image'] ?? '';
          
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                // MEMUNCULKAN POP-UP (DIALOG) SAAT FOTO DIKLIK
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent, // Latar belakang transparan agar elegan
                      insetPadding: EdgeInsets.all(isMobile ? 20 : 60),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // AREA GAMBAR BESAR
                                Flexible(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    clipBehavior: Clip.antiAlias, // Wajib agar ujung gambar ikut melengkung
                                    // 👇 MENAMPILKAN GAMBAR ASLI DI POPUP
                                    child: _buildImageDisplay(imageSource),
                                  ),
                                ),
                                // AREA TEKS DESKRIPSI DI BAWAH GAMBAR
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                                  ),
                                  child: Text(
                                    judulFoto,
                                    style: const TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // TOMBOL CLOSE (X) MELAYANG DI POJOK KANAN ATAS
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Material(
                                color: Colors.black54,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  tooltip: "Tutup",
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey.shade200,
                    // 👇 MENAMPILKAN THUMBNAIL FOTO GALERI
                    child: _buildImageDisplay(imageSource),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                      child: Text(
                        judulFoto,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}