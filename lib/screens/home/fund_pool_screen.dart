import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';

// 👇 1. IMPORT SERVICE SUPABASE-MU
import '../../services/supabase_donasi_service.dart';

class FundPoolScreen extends StatelessWidget {
  const FundPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // 1. HEADER SEKSI
            _buildHeader(),

            const SizedBox(height: 50),

            // 2. KARTU RINGKASAN REAL-TIME
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
              child: isMobile
                  ? Column(
                      children: [
                        _buildRealtimeMasukCard(),
                        const SizedBox(height: 20),
                        _buildRealtimeTersalurkanCard(),
                        const SizedBox(height: 20),
                        _buildRealtimeSaldoCard(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildRealtimeMasukCard()),
                        const SizedBox(width: 25),
                        Expanded(child: _buildRealtimeTersalurkanCard()),
                        const SizedBox(width: 25),
                        Expanded(child: _buildRealtimeSaldoCard()),
                      ],
                    ),
            ),

            const SizedBox(height: 60),

            // 3. KONTEN UTAMA (Tabel Riwayat & Grafik Alokasi Real-time)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
              child: isMobile
                  ? Column(
                      children: [
                        _buildRiwayatDonatur(isMobile),
                        const SizedBox(height: 40),
                        _buildAlokasiDana(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildRiwayatDonatur(isMobile),
                        ),
                        const SizedBox(width: 40),
                        Expanded(flex: 1, child: _buildAlokasiDana()),
                      ],
                    ),
            ),

            const SizedBox(height: 100),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: HEADER TEXT
  // ==========================================
  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "TRANSPARANSI DANA",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Fund Pool VIP",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Setiap Rupiah aman, tercatat, dan tersalurkan dengan tepat.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET PEMBANTU: KARTU HITUNGAN REAL-TIME
  // ==========================================
  Widget _buildRealtimeMasukCard() {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // 👇 Ganti MockDatabase dengan SupabaseDonationService
    return ValueListenableBuilder(
      valueListenable: SupabaseDonationService.totalDonasiTerkumpul,
      builder: (context, total, _) {
        return _buildSummaryCard(
          "DONASI MASUK",
          formatRp.format(total),
          Icons.account_balance_wallet_outlined,
          false,
        );
      },
    );
  }

  Widget _buildRealtimeTersalurkanCard() {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // 👇 Ganti MockDatabase dengan SupabaseDonationService
    return ValueListenableBuilder(
      valueListenable: SupabaseDonationService.danaTersalurkan,
      builder: (context, tersalurkan, _) {
        return _buildSummaryCard(
          "TERSALURKAN",
          formatRp.format(tersalurkan),
          Icons.send_outlined,
          false,
        );
      },
    );
  }

  Widget _buildRealtimeSaldoCard() {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // 👇 Ganti MockDatabase dengan SupabaseDonationService
    return ValueListenableBuilder(
      valueListenable: SupabaseDonationService.totalDonasiTerkumpul,
      builder: (context, total, _) {
        return ValueListenableBuilder(
          valueListenable: SupabaseDonationService.danaTersalurkan,
          builder: (context, tersalurkan, _) {
            int saldo = total - tersalurkan;
            return _buildSummaryCard(
              "SALDO AKTIF",
              formatRp.format(saldo),
              Icons.account_balance_outlined,
              true,
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    bool isHighlighted,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFE31E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isHighlighted ? Colors.white70 : Colors.orange,
            size: 30,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white70 : Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isHighlighted ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: TABEL RIWAYAT DONATUR REAL-TIME
  // ==========================================
  Widget _buildRiwayatDonatur(bool isMobile) {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Riwayat Donatur",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text(
                    "Real-time",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          // 👇 Ganti MockDatabase dengan SupabaseDonationService
          child: ValueListenableBuilder(
            valueListenable: SupabaseDonationService.riwayatDonasi,
            builder: (context, List<Map<String, dynamic>> riwayat, _) {
              if (riwayat.isEmpty) {
                return DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'TANGGAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'DONATUR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'NOMINAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: const [
                    DataRow(
                      cells: [
                        DataCell(Text("-")),
                        DataCell(
                          Text(
                            "Belum ada data donasi",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataCell(Text("-")),
                      ],
                    ),
                  ],
                );
              }

              return DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'TANGGAL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'DONATUR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'NOMINAL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
                rows: riwayat.map((donasi) {
                  // Format tanggal dari Supabase
                  String formattedDate = '-';
                  if (donasi['created_at'] != null) {
                    try {
                      DateTime date = DateTime.parse(
                        donasi['created_at'],
                      ).toLocal();
                      formattedDate = dateFormat.format(date);
                    } catch (e) {
                      formattedDate = donasi['created_at'].toString();
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(formattedDate)),
                      DataCell(
                        Text(
                          donasi['nama_donatur'] ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: donasi['nama_donatur'] == 'Hamba Allah'
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          formatRp.format(donasi['amount'] ?? 0),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ========================================================
  // WIDGET: GRAFIK ALOKASI DANA DESIMAL
  // ========================================================
  Widget _buildAlokasiDana() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Alokasi Dana",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Distribusi dana berdasarkan anggaran program tahun berjalan.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 40),

          // 👇 Ganti MockDatabase dengan SupabaseDonationService
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
                    if (hasil < 1) {
                      return "${hasil.toStringAsFixed(2)}%";
                    }
                    return "${hasil.toStringAsFixed(1)}%";
                  }

                  return Column(
                    children: [
                      _buildProgressItem(
                        "Pendidikan & Vokasi",
                        progressPendidikan.clamp(0.0, 1.0),
                        formatPersenDinamis(progressPendidikan),
                      ),
                      _buildProgressItem(
                        "Uang Saku Siswa",
                        progressUangSaku.clamp(0.0, 1.0),
                        formatPersenDinamis(progressUangSaku),
                      ),
                      _buildProgressItem(
                        "Operasional Yayasan",
                        progressOperasional.clamp(0.0, 1.0),
                        formatPersenDinamis(progressOperasional),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 30),
          const Center(
            child: Text(
              "VIP",
              style: TextStyle(
                color: Colors.white30,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value, String percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                percent,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE31E24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
