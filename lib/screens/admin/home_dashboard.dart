import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../data/mock_database.dart';
import '../shared/stat_card.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // LOGIKA PENARIKAN DATA DINAMIS
    // ==========================================
    final allSiswa = MockDatabase.getAllRegisteredSiswaFullData();

    // Hitung statistik berdasarkan data asli
    final int totalPendaftar = allSiswa.length;
    final int menungguReview = allSiswa
        .where((s) => s['admin_status'] == 'Menunggu Review')
        .length;
    final int beasiswaAktif = allSiswa
        .where((s) => s['admin_status'] == 'Diterima')
        .length;

    final int totalDonasi = MockDatabase.getTotalDonasi();
    final String totalDonasiFormatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(totalDonasi);

    // ==========================================
    // LOGIKA GRAFIK 6 BULAN TERAKHIR
    // ==========================================
    final DateTime now = DateTime.now();
    final List<FlSpot> chartSpots = [];
    final List<String> monthLabels = [];
    final List<String> namaBulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    int maxPendaftar = 5;

    for (int i = 5; i >= 0; i--) {
      int targetMonth = now.month - i;
      int targetYear = now.year;
      if (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      monthLabels.add(namaBulan[targetMonth - 1]);

      int jumlah = allSiswa.where((siswa) {
        if (siswa['tgl_daftar'] == null || siswa['tgl_daftar'].isEmpty)
          return false;
        try {
          DateTime tgl = DateTime.parse(siswa['tgl_daftar']);
          return tgl.month == targetMonth && tgl.year == targetYear;
        } catch (e) {
          return false;
        }
      }).length;

      if (jumlah > maxPendaftar) {
        maxPendaftar = jumlah;
      }

      chartSpots.add(FlSpot((5 - i).toDouble(), jumlah.toDouble()));
    }

    maxPendaftar = (maxPendaftar * 1.5).ceil();
    if (maxPendaftar < 5) maxPendaftar = 5;
    if (maxPendaftar % 5 != 0) {
      maxPendaftar += (5 - (maxPendaftar % 5));
    }

    // Interval label kiri agar tidak terlalu rapat
    double leftInterval = (maxPendaftar / 5).ceil().toDouble();
    if (leftInterval < 1) leftInterval = 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Performa",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 25),

          // 👇 LayoutBuilder untuk membuat kartu responsif
          LayoutBuilder(
            builder: (context, constraints) {
              // Jika dibuka di HP (layar sempit), tumpuk kartunya ke bawah
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    StatCard(
                      title: "Total Pendaftar",
                      value: totalPendaftar.toString(),
                      color: Colors.blue,
                      icon: Icons.people_alt_rounded,
                    ),
                    const SizedBox(height: 15),
                    StatCard(
                      title: "Menunggu Review",
                      value: menungguReview.toString(),
                      color: Colors.orange,
                      icon: Icons.hourglass_empty_rounded,
                    ),
                    const SizedBox(height: 15),
                    StatCard(
                      title: "Beasiswa Aktif",
                      value: beasiswaAktif.toString(),
                      color: Colors.green,
                      icon: Icons.school_rounded,
                    ),
                    const SizedBox(height: 15),
                    StatCard(
                      title: "Total Donasi",
                      value: totalDonasiFormatted,
                      color: Colors.purple,
                      icon: Icons.volunteer_activism_rounded,
                    ),
                  ],
                );
              }

              // Jika dibuka di Laptop (layar lebar), jejerkan kartunya menyamping tapi donasi di bawah
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "Total Pendaftar",
                          value: totalPendaftar.toString(),
                          color: Colors.blue,
                          icon: Icons.people_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: StatCard(
                          title: "Menunggu Review",
                          value: menungguReview.toString(),
                          color: Colors.orange,
                          icon: Icons.hourglass_empty_rounded,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: StatCard(
                          title: "Beasiswa Aktif",
                          value: beasiswaAktif.toString(),
                          color: Colors.green,
                          icon: Icons.school_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "Total Donasi Terkumpul",
                          value: totalDonasiFormatted,
                          color: Colors.purple,
                          icon: Icons.volunteer_activism_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Statistik Pendaftar Beasiswa",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Tren jumlah pendaftar 6 bulan terakhir",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                              int index = value.toInt();
                              if (index >= 0 && index < monthLabels.length) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(monthLabels[index], style: style),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: leftInterval,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                            reservedSize: 35,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: maxPendaftar.toDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartSpots,
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: AppColors.primary,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
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
