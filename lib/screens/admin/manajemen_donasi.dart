import 'package:flutter/material.dart';
import '../../services/supabase_donasi_service.dart';
import 'package:intl/intl.dart';
import '../../../core/snackbar_helper.dart';

// ========================================================
// 1. VIEW: RIWAYAT DANA MASUK
// ========================================================
class RiwayatDanaMasukView extends StatelessWidget {
  const RiwayatDanaMasukView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Riwayat Dana Masuk",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Daftar seluruh donasi publik yang masuk secara real-time.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: SupabaseDonationService.riwayatDonasi,
              builder: (context, List<Map<String, dynamic>> donasiList, _) {
                if (donasiList.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada donasi masuk.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: donasiList.length,
                  itemBuilder: (context, index) {
                    final item = donasiList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: const Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          item['nama_donatur']?.toString() ?? 'Donatur VIP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${item['program_name'] ?? 'Program VIP'}\n${item['created_at']?.toString().substring(0, 10) ?? '-'}",
                        ),
                        trailing: Text(
                          "+ ${currencyFormat.format(item['amount'] ?? 0)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// 2. VIEW: RIWAYAT DANA KELUAR (SUDAH FIX BEBAS ERROR RED SCREEN)
// ========================================================
class RiwayatDanaKeluarView extends StatelessWidget {
  const RiwayatDanaKeluarView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Riwayat Dana Keluar",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Catatan penyaluran alokasi dana yang telah digunakan oleh yayasan.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: SupabaseDonationService.riwayatPenyaluran,
              builder: (context, List<Map<String, dynamic>> pengeluaranList, _) {
                if (pengeluaranList.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada catatan pengeluaran dana.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: pengeluaranList.length,
                  itemBuilder: (context, index) {
                    final item = pengeluaranList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.red,
                          ),
                        ),
                        title: Text(
                          item['keterangan']?.toString() ?? 'Penyaluran Dana',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Alokasi Program VIP\nTanggal pengeluaran: ${item['created_at']?.toString().substring(0, 10) ?? '-'}",
                        ),
                        trailing: Text(
                          "- ${currencyFormat.format(item['nominal'] ?? 0)}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// 3. VIEW: FORM PENYALURAN DANA (FIX TYPO CLASS STATE)
// ========================================================
class PenyaluranDanaView extends StatefulWidget {
  const PenyaluranDanaView({super.key});

  @override
  State<PenyaluranDanaView> createState() => _PenyaluranDanaViewState();
}

class _PenyaluranDanaViewState extends State<PenyaluranDanaView> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final nominalController = TextEditingController();
  String? selectedKategori;

  final List<String> kategoriList = [
    "Pendidikan & Vokasi",
    "Uang Saku Siswa",
    "Operasional Yayasan",
  ];

  @override
  void dispose() {
    nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Penyaluran Dana",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Salurkan saldo aktif yayasan ke kategori alokasi resmi program VIP.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 10),
                      ValueListenableBuilder(
                        valueListenable: SupabaseDonationService.totalDonasiTerkumpul,
                        builder: (context, total, _) {
                          return ValueListenableBuilder(
                            valueListenable: SupabaseDonationService.danaTersalurkan,
                            builder: (context, tersalurkan, _) {
                              int saldoAktif = total - tersalurkan;
                              return Text(
                                "Saldo Available: ${currencyFormat.format(saldoAktif)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: nominalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Nominal Pengeluaran (Rp)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedKategori,
                  decoration: const InputDecoration(
                    labelText: "Pilih Kategori Penyaluran",
                    border: OutlineInputBorder(),
                  ),
                  items: kategoriList
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedKategori = val),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (nominalController.text.isNotEmpty &&
                          selectedKategori != null) {
                        try {
                          int nominal = int.parse(nominalController.text);
                          await SupabaseDonationService.catatPengeluaranKeCloud(
                            nominal,
                            selectedKategori!,
                          );
                          if (context.mounted) {
                            showSuccessSnackBar(context, 'Penyaluran berhasil dicatat! Dana publik terupdate.');
                            nominalController.clear();
                            setState(() => selectedKategori = null);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showErrorSnackBar(context, e.toString());
                          }
                        }
                      } else {
                        showInfoSnackBar(context, 'Mohon lengkapi nominal & kategori!');
                      }
                    },
                    child: const Text(
                      "Simpan Catatan Pengeluaran",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
