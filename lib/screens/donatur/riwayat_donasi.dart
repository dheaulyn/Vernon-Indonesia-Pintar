import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../services/supabase_auth_service.dart';
import '../../../../services/supabase_donasi_service.dart';

class RiwayatDonasiView extends StatelessWidget {
  final bool isMobile;

  const RiwayatDonasiView({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Format tanggal untuk Supabase (ISO8601 ke text biasa).
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    // Ambil email user yang login.
    final String? currentUserEmail =
        SupabaseAuthService.currentUserData?['email'];

    return ValueListenableBuilder(
      valueListenable: SupabaseDonationService.riwayatDonasi,
      builder: (context, List<Map<String, dynamic>> riwayatGlobal, _) {
        // Filter berdasarkan email, bukan nama.
        final riwayatPribadi = riwayatGlobal
            .where((donasi) => donasi['donatur_email'] == currentUserEmail)
            .toList();

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 32,
            vertical: 8,
          ),
          children: [
            if (riwayatPribadi.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "Belum ada riwayat donasi. Yuk mulai berbagi! 🌱",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ...riwayatPribadi.map((history) {

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

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history['program_name'] ??
                                  "Program VIP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(
                              history['amount'] ?? 0,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            history['status'] ?? "Sukses",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
