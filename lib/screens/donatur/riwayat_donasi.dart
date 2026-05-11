import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/mock_database.dart';

class RiwayatDonasiView extends StatelessWidget {
  final bool isMobile;
  final List<DonationHistory> allHistories;

  const RiwayatDonasiView({
    super.key,
    required this.isMobile,
    required this.allHistories,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    const String programName = "Program Karir Kurikulum 10 Bulan VIP";

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: 8,
      ),
      children: [
        if (allHistories.isEmpty)
          const Text("Belum ada riwayat.")
        else
          ...allHistories.map(
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
                        const Text(
                          programName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(history.date),
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
                        currencyFormatter.format(history.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        history.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: history.status == 'Sukses'
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
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
  }
}
