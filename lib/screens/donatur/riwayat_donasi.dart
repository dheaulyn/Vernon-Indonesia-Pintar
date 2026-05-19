import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/mock_database.dart';

class RiwayatDonasiView extends StatelessWidget {
  final bool isMobile;
  // parameter allHistories dihapus karena kita panggil langsung dari MockDatabase

  const RiwayatDonasiView({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Ambil nama user yang sedang login
    final String currentUserName = MockDatabase.currentUser?['name'] ?? '';

    return ValueListenableBuilder(
      valueListenable: MockDatabase.riwayatDonasi,
      builder: (context, List<Map<String, dynamic>> riwayatGlobal, _) {
        // 👇 FILTER: Hanya ambil donasi yang namanya sama dengan user login
        // atau yang berdonasi anonim (Hamba Allah) tapi dari akun ini (bisa difilter via email jika ada)
        // Untuk simulasi ini, kita tampilkan yang namanya cocok.
        final riwayatPribadi = riwayatGlobal
            .where(
              (donasi) =>
                  donasi['nama'] == currentUserName ||
                  donasi['nama'] == 'Hamba Allah',
            )
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
              ...riwayatPribadi.map(
                (history) => Container(
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
                              history['program'] ?? "Program VIP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              history['tgl'] ?? '-',
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
                            currencyFormatter.format(history['nominal'] ?? 0),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sukses", // Di sistem real-time kita, uang langsung masuk, jadi statusnya selalu sukses
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
                ),
              ),
          ],
        );
      },
    );
  }
}
