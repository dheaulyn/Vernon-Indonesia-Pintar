import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../shared/stat_card.dart';

// 👇 1. IMPORT SERVICE SUPABASE DONASI & AUTH
import '../../services/supabase_donasi_service.dart';
import '../../services/supabase_auth_service.dart';

class DashboardView extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onNavigateToDonasi;

  const DashboardView({
    super.key,
    required this.isMobile,
    required this.onNavigateToDonasi,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Format tanggal dari database
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    // 👇 2. AMBIL EMAIL USER YANG SEDANG LOGIN (Bukan nama)
    final String? currentUserEmail =
        SupabaseAuthService.currentUserData?['email'];

    return ValueListenableBuilder(
      valueListenable:
          SupabaseDonationService.riwayatDonasi, // Ambil dari Cloud
      builder: (context, List<Map<String, dynamic>> riwayatGlobal, _) {
        // 👇 3. FILTER KHUSUS USER INI BERDASARKAN EMAIL
        final riwayatPribadi = riwayatGlobal
            .where((donasi) => donasi['donatur_email'] == currentUserEmail)
            .toList();

        // Kalkulasi matematika real-time (Sesuai nama kolom Supabase: 'amount')
        final int totalUangPribadi = riwayatPribadi.fold(
          0,
          (sum, item) => sum + (item['amount'] as int? ?? 0),
        );
        final int frekuensiDonasi = riwayatPribadi.length;

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 32,
            vertical: 8,
          ),
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mari Lanjutkan Kebaikan Anda",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Setiap rupiah yang Anda berikan adalah kepingan harapan bagi seorang siswa di Program VIP.",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) const SizedBox(width: 24),
                  if (!isMobile)
                    ElevatedButton.icon(
                      onPressed: onNavigateToDonasi,
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      label: const Text(
                        "Donasi Sekarang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isMobile) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNavigateToDonasi,
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    "Donasi Sekarang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.monitor_heart_rounded,
                    color: Colors.blue.shade600,
                    value: currencyFormatter.format(
                      totalUangPribadi,
                    ), // 👈 Real-time Nominal
                    title: "Total Donasi",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    icon: Icons.repeat_rounded,
                    color: Colors.green.shade600,
                    value: "$frekuensiDonasi Kali", // 👈 Real-time Frekuensi
                    title: "Frekuensi Donasi",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              "Aktivitas Donasi Terakhir",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "TANGGAL",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        if (!isMobile)
                          Expanded(
                            flex: 4,
                            child: Text(
                              "PROGRAM",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "JUMLAH",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "STATUS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),

                  if (riwayatPribadi.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text("Belum ada aktivitas.")),
                    )
                  else
                    ...riwayatPribadi
                        .take(
                          3,
                        ) // Tampilkan maksimal 3 donasi terakhir di beranda
                        .map((history) {
                          // Konversi tanggal dari database Supabase
                          String formattedDate = '-';
                          if (history['created_at'] != null) {
                            try {
                              DateTime date = DateTime.parse(
                                history['created_at'],
                              ).toLocal();
                              formattedDate = dateFormat.format(date);
                            } catch (e) {
                              formattedDate = history['created_at'].toString();
                            }
                          }

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    if (!isMobile)
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          history['program_name'] ??
                                              '-', // Sesuaikan kolom DB
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        currencyFormatter.format(
                                          history['amount'] ??
                                              0, // Sesuaikan kolom DB
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        history['status'] ?? "Sukses",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: Colors.grey.shade100),
                            ],
                          );
                        }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
