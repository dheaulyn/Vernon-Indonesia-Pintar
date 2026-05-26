import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/snackbar_helper.dart';
import 'package:go_router/go_router.dart';

// 👇 1. IMPORT SERVICE SUPABASE DONASI (Gantikan MockDatabase)
import '../../../services/supabase_donasi_service.dart';

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
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

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
              // 👇 Gunakan data asli dari Supabase
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

                    // Format tanggal dari database
                    String tgl = '-';
                    if (item['created_at'] != null) {
                      try {
                        tgl = dateFormat.format(
                          DateTime.parse(item['created_at']).toLocal(),
                        );
                      } catch (e) {
                        tgl = item['created_at'].toString();
                      }
                    }

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
                          item['nama_donatur']?.toString() ??
                              'Donatur VIP', // Sesuai kolom DB
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${item['program_name'] ?? 'Program VIP'}\n$tgl", // Sesuai kolom DB
                        ),
                        trailing: Text(
                          "+ ${currencyFormat.format(item['amount'] ?? 0)}", // Sesuai kolom DB
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
// 2. VIEW: RIWAYAT DANA KELUAR
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
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

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
              // 👇 Gunakan data asli dari Supabase
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

                    // Format tanggal dari database
                    String tgl = '-';
                    if (item['created_at'] != null) {
                      try {
                        tgl = dateFormat.format(
                          DateTime.parse(item['created_at']).toLocal(),
                        );
                      } catch (e) {
                        tgl = item['created_at'].toString();
                      }
                    }

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
                          item['keterangan']?.toString() ??
                              'Penyaluran Dana', // Sesuai DB
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Alokasi Program VIP\nTanggal pengeluaran: $tgl",
                        ),
                        trailing: Text(
                          "- ${currencyFormat.format(item['nominal'] ?? 0)}", // Sesuai DB
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
// 3. VIEW: FORM PENYALURAN DANA
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
  bool _isProcessing = false;
  final ValueNotifier<int> _inputNominal = ValueNotifier<int>(0);

  final List<String> kategoriList = [
    "Pendidikan & Vokasi",
    "Uang Saku Siswa",
    "Operasional Yayasan",
  ];

  @override
  void initState() {
    super.initState();
    nominalController.addListener(() {
      final raw = nominalController.text.replaceAll('.', '');
      _inputNominal.value = int.tryParse(raw) ?? 0;
    });
  }

  @override
  void dispose() {
    nominalController.dispose();
    _inputNominal.dispose();
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
                      // 👇 Gunakan data asli dari Supabase
                      ValueListenableBuilder(
                        valueListenable:
                            SupabaseDonationService.totalDonasiTerkumpul,
                        builder: (context, total, _) {
                          return ValueListenableBuilder(
                            valueListenable:
                                SupabaseDonationService.danaTersalurkan,
                            builder: (context, tersalurkan, _) {
                              return ValueListenableBuilder<int>(
                                valueListenable: _inputNominal,
                                builder: (context, inputVal, _) {
                                  int saldoAktif = total - tersalurkan;
                                  int sisaSaldo = saldoAktif - inputVal;
                                  bool isOver = sisaSaldo < 0;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Saldo Tersedia: ${currencyFormat.format(saldoAktif)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      if (inputVal > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            "Sisa Saldo: ${currencyFormat.format(sisaSaldo)}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isOver
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyFormat(),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Nominal Pengeluaran",
                    border: OutlineInputBorder(),
                    prefixText: "Rp ",
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
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            // 👇 Ubah jadi async
                            if (nominalController.text.isNotEmpty &&
                                selectedKategori != null) {
                              setState(() => _isProcessing = true);
                              try {
                                int nominal = int.parse(
                                  nominalController.text.replaceAll('.', ''),
                                );

                                // 👇 EKSEKUSI KE CLOUD
                                await SupabaseDonationService.catatPengeluaranKeCloud(
                                  nominal,
                                  selectedKategori!,
                                );

                                if (context.mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    'Penyaluran berhasil dicatat! Dana publik terupdate.',
                                  );
                                  nominalController.clear();
                                  setState(() => selectedKategori = null);
                                  context.go('/admin-donasi-keluar');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  showErrorSnackBar(
                                    context,
                                    'Gagal mencatat penyaluran: ${e.toString().replaceAll("Exception:", "")}',
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setState(() => _isProcessing = false);
                                }
                              }
                            } else {
                              showInfoSnackBar(
                                context,
                                'Mohon lengkapi nominal & kategori!',
                              );
                            }
                          },
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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

class CurrencyFormat extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');
    String formatted = '';
    int count = 0;
    for (int i = numericOnly.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = numericOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
