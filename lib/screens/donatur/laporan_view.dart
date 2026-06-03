import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../../services/supabase_donasi_service.dart';

class LaporanView extends StatefulWidget {
  final bool isMobile;
  const LaporanView({super.key, required this.isMobile});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _artikelTerbaru = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtikelTerbaru();
  }

  // Mengambil 4 artikel terbaru dari tabel articles.
  Future<void> _fetchArtikelTerbaru() async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .neq('category', 'Galeri')
          .order('created_at', ascending: false)
          .limit(4);

      if (mounted) {
        setState(() {
          _artikelTerbaru = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil artikel donatur: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk merender gambar (URL atau Base64).
  Widget _buildImageDisplay(String imageSource) {
    if (imageSource.isEmpty) {
      return const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }
    if (imageSource.startsWith('http')) {
      return Image.network(imageSource, fit: BoxFit.cover);
    }
    try {
      return Image.memory(base64Decode(imageSource), fit: BoxFit.cover);
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 20 : 32,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================================================================
          // 1. KARTU ALOKASI DANA REVISI
          // =========================================================================
          // Catatan: Jika total donasi sudah pindah ke SupabaseDonationService,.
          // Ganti MockDatabase.totalDonasiTerkumpul di bawah ini.
          ValueListenableBuilder(
            valueListenable: SupabaseDonationService.riwayatPenyaluran,
            builder: (context, List<Map<String, dynamic>> pengeluaran, _) {
              return ValueListenableBuilder(
                valueListenable: SupabaseDonationService.totalDonasiTerkumpul,
                builder: (context, int totalDonasi, _) {
                  int totalPendidikan = 0;
                  int totalUangSaku = 0;
                  int totalOperasional = 0;

                  for (var item in pengeluaran) {
                    int nom = item['nominal'] as int? ?? 0;
                    String ket = item['keterangan']?.toString() ?? '';
                    if (ket == "Pendidikan & Vokasi") totalPendidikan += nom;
                    if (ket == "Uang Saku Siswa") totalUangSaku += nom;
                    if (ket == "Operasional Yayasan") totalOperasional += nom;
                  }

                  double progressPendidikan = totalDonasi > 0
                      ? (totalPendidikan / totalDonasi)
                      : 0.0;
                  double progressUangSaku = totalDonasi > 0
                      ? (totalUangSaku / totalDonasi)
                      : 0.0;
                  double progressOperasional = totalDonasi > 0
                      ? (totalOperasional / totalDonasi)
                      : 0.0;

                  String formatPersenDinamis(double progress) {
                    double hasil = progress * 100;
                    if (hasil == 0) return "0%";
                    if (hasil < 1) return "${hasil.toStringAsFixed(2)}%";
                    return "${hasil.toStringAsFixed(1)}%";
                  }

                  return Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Alokasi Penggunaan Dana",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Pantau persentase penyerapan dana program nyata secara real-time dari panel pusat yayasan VIP.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 35),

                        _buildDetailedAllocationBar(
                          "Pendidikan & Vokasi",
                          progressPendidikan.clamp(0.0, 1.0),
                          Colors.red,
                          formatPersenDinamis(progressPendidikan),
                          "Terpakai: ${currencyFormat.format(totalPendidikan)}",
                        ),
                        const SizedBox(height: 25),
                        _buildDetailedAllocationBar(
                          "Uang Saku Siswa",
                          progressUangSaku.clamp(0.0, 1.0),
                          Colors.orange,
                          formatPersenDinamis(progressUangSaku),
                          "Terpakai: ${currencyFormat.format(totalUangSaku)}",
                        ),
                        const SizedBox(height: 25),
                        _buildDetailedAllocationBar(
                          "Operasional Yayasan",
                          progressOperasional.clamp(0.0, 1.0),
                          Colors.grey,
                          formatPersenDinamis(progressOperasional),
                          "Terpakai: ${currencyFormat.format(totalOperasional)}",
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 40),

          // =========================================================================
          // 2. TIMELINE DAMPAK / BERITA (DARI SUPABASE)
          // =========================================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Jejak Kebaikan Terbaru",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_artikelTerbaru.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Belum ada update terbaru.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            widget.isMobile
                ? Column(
                    children: _artikelTerbaru
                        .map(
                          (artikel) =>
                              _buildImpactCard(artikel, widget.isMobile),
                        )
                        .toList(),
                  )
                : Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: _artikelTerbaru
                        .map(
                          (artikel) => SizedBox(
                            width: 400,
                            child: _buildImpactCard(artikel, widget.isMobile),
                          ),
                        )
                        .toList(),
                  ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailedAllocationBar(
    String title,
    double percentage,
    Color color,
    String percentText,
    String estimateText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            Text(
              percentText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          estimateText,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  // Menerima data Map (JSON dari Supabase).
  Widget _buildImpactCard(Map<String, dynamic> artikel, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 20 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: _buildImageDisplay(
              artikel['image_url'] ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      artikel['date'] ?? '-',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  artikel['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  artikel['description'] ??
                      '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    artikel['category'] ??
                        'Berita',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
