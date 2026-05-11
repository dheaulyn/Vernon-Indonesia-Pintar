import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../data/mock_database.dart';

// ==========================================
// 1. MODEL DATA
// ==========================================
class PendaftarModel {
  final String id;
  final String nama;
  final String asalSekolah;
  final String tglDaftar;
  String status;

  PendaftarModel({
    required this.id,
    required this.nama,
    required this.asalSekolah,
    required this.tglDaftar,
    required this.status,
  });
}

class ManajemenPendaftarAdmin extends StatefulWidget {
  const ManajemenPendaftarAdmin({super.key});

  @override
  State<ManajemenPendaftarAdmin> createState() => _ManajemenPendaftarAdminState();
}

class _ManajemenPendaftarAdminState extends State<ManajemenPendaftarAdmin> {
  List<PendaftarModel> listPendaftar = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final allFullData = MockDatabase.getAllRegisteredSiswaFullData();
    
    setState(() {
      listPendaftar = allFullData.map((s) {
        return PendaftarModel(
          id: s['email'],
          nama: s['name'],
          asalSekolah: s['asal_sekolah'] ?? '-',
          tglDaftar: _formatDate(s['tgl_daftar']), 
          status: s['admin_status'] ?? 'Menunggu Review',
        );
      }).toList();
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      final now = DateTime.now();
      final jam = now.hour.toString().padLeft(2, '0');
      final menit = now.minute.toString().padLeft(2, '0');
      return "${now.day} ${_getMonthName(now.month)} ${now.year}, $jam:$menit";
    }
    
    try {
      final date = DateTime.parse(dateString).toLocal(); 
      final jam = date.hour.toString().padLeft(2, '0');
      final menit = date.minute.toString().padLeft(2, '0');
      return "${date.day} ${_getMonthName(date.month)} ${date.year}, $jam:$menit WIB";
    } catch (e) {
      return "-";
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  // 👇 FUNGSI TAMBAHAN UNTUK PARSING BULAN KEMBALI KE ANGKA
  int _getMonthNumber(String monthName) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    int index = months.indexOf(monthName);
    return index != -1 ? index + 1 : 1; 
  }

  // ==========================================
  // WIDGET BANTUAN UI 
  // ==========================================
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Menunggu Review':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Revisi':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'Wawancara':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'Diterima':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Pelatihan':
        bgColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        break;
      case 'Lulus':
        bgColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        break;
      case 'Ditolak':
        bgColor = Colors.grey.shade300;
        textColor = Colors.black87;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ),
          const Text(": ", style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTile(String title, String? fileName) {
    bool hasFile = fileName != null && fileName.isNotEmpty;

    return ListTile(
      leading: Icon(
        hasFile ? Icons.description_rounded : Icons.not_interested_rounded,
        color: hasFile ? Colors.red.shade400 : Colors.grey.shade400,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: hasFile ? Colors.black87 : Colors.grey.shade500,
        ),
      ),
      subtitle: Text(
        hasFile ? fileName! : "Belum diunggah oleh siswa",
        style: TextStyle(fontSize: 12, color: hasFile ? Colors.blue : Colors.grey),
      ),
      trailing: hasFile
          ? const Icon(Icons.open_in_new, color: Colors.blue, size: 20)
          : null,
      onTap: hasFile ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Membuka dokumen: $fileName... (Mode Simulasi)"),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      } : null,
    );
  }

  // ==========================================
  // FUNGSI REVIEW & UBAH STATUS PENDAFTAR
  // ==========================================
  void _showReviewDialog(PendaftarModel pendaftar, int index) {
    final allFullData = MockDatabase.getAllRegisteredSiswaFullData();
    final detailSiswa = allFullData.firstWhere(
      (u) => u['email'] == pendaftar.id,
      orElse: () => {},
    );

    String selectedStatus = pendaftar.status;
    final TextEditingController catatanController = TextEditingController(text: detailSiswa['catatan_revisi'] ?? '');
    final TextEditingController jadwalDisplayController = TextEditingController(text: detailSiswa['jadwal_wawancara'] ?? ''); 
    final TextEditingController lokasiLinkController = TextEditingController();
    
    String selectedMetodeWawancara = 'Daring'; 
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // 👇 LOGIKA UNTUK MEMECAH KEMBALI TEKS JADWAL DARI DATABASE KE DALAM FIELD
    String savedJadwal = detailSiswa['jadwal_wawancara'] ?? '';
    if (savedJadwal.isNotEmpty) {
      try {
        // 1. Ekstrak Metode (Daring/Luring)
        if (savedJadwal.contains('(Daring)')) selectedMetodeWawancara = 'Daring';
        if (savedJadwal.contains('(Luring)')) selectedMetodeWawancara = 'Luring';

        // 2. Ekstrak Tautan atau Lokasi
        if (savedJadwal.contains('\nLink: ')) {
          lokasiLinkController.text = savedJadwal.split('\nLink: ').last;
        } else if (savedJadwal.contains('\nLokasi: ')) {
          lokasiLinkController.text = savedJadwal.split('\nLokasi: ').last;
        }

        // 3. Ekstrak Tanggal menggunakan Regex
        RegExp dateRegExp = RegExp(r'(\d{1,2})\s([a-zA-Z]+)\s(\d{4})');
        Match? dateMatch = dateRegExp.firstMatch(savedJadwal);
        if (dateMatch != null) {
          int day = int.parse(dateMatch.group(1)!);
          int month = _getMonthNumber(dateMatch.group(2)!);
          int year = int.parse(dateMatch.group(3)!);
          selectedDate = DateTime(year, month, day);
        }

        // 4. Ekstrak Jam menggunakan Regex
        RegExp timeRegExp = RegExp(r'Pukul\s(\d{2}):(\d{2})');
        Match? timeMatch = timeRegExp.firstMatch(savedJadwal);
        if (timeMatch != null) {
          int hour = int.parse(timeMatch.group(1)!);
          int minute = int.parse(timeMatch.group(2)!);
          selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        debugPrint("Gagal memproses jadwal lama: $e");
      }
    }
    
    final List<String> statusOptions = [
      'Menunggu Review', 'Revisi', 'Wawancara', 'Diterima', 'Pelatihan', 'Lulus', 'Ditolak'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {

            // 👇 Fungsi ini wajib berada di dalam StatefulBuilder bagian atas
            void updateJadwalString() {
              if (selectedDate != null && selectedTime != null) {
                String formattedDate = "${selectedDate!.day} ${_getMonthName(selectedDate!.month)} ${selectedDate!.year}";
                String formattedTime = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                
                String labelMetode = selectedMetodeWawancara == 'Daring' ? "Link" : "Lokasi";
                String detailTeks = lokasiLinkController.text.trim().isNotEmpty ? "\n$labelMetode: ${lokasiLinkController.text.trim()}" : "";
                
                jadwalDisplayController.text = "$formattedDate, Pukul $formattedTime WIB ($selectedMetodeWawancara)$detailTeks";
              }
            }

            Future<void> pickDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2027),
              );
              if (picked != null) {
                setStateDialog(() => selectedDate = picked);
                updateJadwalString();
              }
            }

            Future<void> pickTime() async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setStateDialog(() => selectedTime = picked);
                updateJadwalString();
              }
            }

            String timeButtonText = selectedTime == null 
                ? "Pilih Jam" 
                : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_ind_rounded, color: Colors.red, size: 28),
                      SizedBox(width: 10),
                      Text("Review Pendaftar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                  Divider(height: 20, thickness: 1),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(Icons.person, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pendaftar.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(pendaftar.id, style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      const Text("Informasi Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueGrey.shade100),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow("Waktu Daftar", pendaftar.tglDaftar),
                            _buildDetailRow("NIK", detailSiswa['nik'] ?? '-'),
                            _buildDetailRow("No. Telepon", detailSiswa['telepon'] ?? '-'),
                            _buildDetailRow("Domisili", detailSiswa['domisili'] ?? '-'),
                            _buildDetailRow("Pendidikan", detailSiswa['pendidikan'] ?? '-'),
                            _buildDetailRow("Asal Sekolah", detailSiswa['asal_sekolah'] ?? '-'),
                            _buildDetailRow("Tahun Lulus", detailSiswa['tahun_lulus'] ?? '-'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text("Berkas Persyaratan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildFileTile("Foto KTP / Kartu Pelajar", detailSiswa['file_ktp']),
                            const Divider(height: 1),
                            _buildFileTile("Scan Rapor / Ijazah Terakhir", detailSiswa['file_rapor']),
                            const Divider(height: 1),
                            _buildFileTile("Pas Foto 3x4", detailSiswa['file_foto']),
                            const Divider(height: 1),
                            _buildFileTile("Surat Motivasi", detailSiswa['file_motivasi']),
                            const Divider(height: 1),
                            _buildFileTile("Surat Keterangan Tidak Mampu", detailSiswa['file_sktm']),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text("Update Status Pendaftaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: statusOptions.map((String status) {
                          return DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontWeight: FontWeight.w600)));
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setStateDialog(() => selectedStatus = newValue);
                          }
                        },
                      ),

                      if (selectedStatus == 'Revisi') ...[
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: catatanController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Tuliskan alasan revisi...",
                            filled: true,
                            fillColor: Colors.red.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade200)),
                          ),
                        ),
                      ],
                      
                      if (selectedStatus == 'Wawancara') ...[
                        const SizedBox(height: 15),
                        const Divider(color: Colors.black12),
                        const SizedBox(height: 15),
                        const Text("Pengaturan Jadwal Wawancara", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                        const SizedBox(height: 15),

                        const Text("Metode Wawancara", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedMetodeWawancara,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: ['Daring', 'Luring'].map((String val) {
                            return DropdownMenuItem(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setStateDialog(() {
                                selectedMetodeWawancara = newValue;
                                updateJadwalString(); 
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Pilih Tanggal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: pickDate,
                                    icon: const Icon(Icons.calendar_today, size: 18),
                                    label: Text(selectedDate == null ? "Pilih Tanggal" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 50),
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade800,
                                      elevation: 0,
                                      side: BorderSide(color: Colors.blue.shade200),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Pilih Jam (24 Jam)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: pickTime,
                                    icon: const Icon(Icons.access_time, size: 18),
                                    label: Text(timeButtonText),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 50),
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade800,
                                      elevation: 0,
                                      side: BorderSide(color: Colors.blue.shade200),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        Text(selectedMetodeWawancara == 'Daring' ? "Tautan Wawancara Daring" : "Alamat / Lokasi Wawancara", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: lokasiLinkController,
                          onChanged: (value) => updateJadwalString(), 
                          decoration: InputDecoration(
                            hintText: selectedMetodeWawancara == 'Daring' 
                                ? "Contoh: https://zoom.us/j/123456789" 
                                : "Contoh: Kantor VernonCorp, Ruang Meeting 1",
                            prefixIcon: Icon(
                              selectedMetodeWawancara == 'Daring' ? Icons.link_rounded : Icons.location_on_rounded, 
                              color: Colors.blue.shade700
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade700, width: 2)),
                          ),
                        ),

                        if (selectedDate != null && selectedTime != null) ...[
                          const SizedBox(height: 25),
                          TextFormField(
                            controller: jadwalDisplayController,
                            maxLines: null, 
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Pratinjau Pesan untuk Siswa",
                              filled: true,
                              fillColor: Colors.green.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                            ),
                          ),
                        ]
                      ],
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.all(20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStatus == 'Wawancara' && jadwalDisplayController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Mohon atur jadwal (Tanggal, Jam, dan Lokasi/Link) terlebih dahulu!")),
                      );
                      return;
                    }

                    MockDatabase.updateStatusSiswa(
                      pendaftar.id, 
                      selectedStatus, 
                      catatanController.text,
                      jadwalWawancara: selectedStatus == 'Wawancara' ? jadwalDisplayController.text : null, 
                    );
                    
                    setState(() {
                      listPendaftar[index].status = selectedStatus;
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Berhasil update status ke $selectedStatus"), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  ),
                  child: const Text("Simpan Keputusan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 15.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              runSpacing: 15,
              children: [
                const Text("Manajemen Pendaftar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _loadData(),
                  icon: const Icon(Icons.refresh, color: Colors.black87),
                  label: const Text("Muat Ulang Data", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: listPendaftar.isEmpty
                  ? const Center(child: Text("Belum ada pendaftar yang men-submit formulir.", style: TextStyle(color: Colors.grey)))
                  : isMobile
                      ? _buildMobileView()
                      : _buildDesktopView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columns: const [
                DataColumn(label: Text("Waktu Daftar", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Nama Siswa", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Aksi", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(listPendaftar.length, (index) {
                final p = listPendaftar[index];
                return DataRow(
                  cells: [
                    DataCell(Text(p.tglDaftar, style: TextStyle(color: Colors.grey.shade700))),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(p.asalSekolah, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    DataCell(_buildStatusBadge(p.status)),
                    DataCell(
                      ElevatedButton.icon(
                        onPressed: () => _showReviewDialog(p, index),
                        icon: const Icon(Icons.search, size: 16, color: Colors.white),
                        label: const Text("Review", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileView() {
    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: listPendaftar.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final p = listPendaftar[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.asalSekolah),
              const SizedBox(height: 5),
              _buildStatusBadge(p.status),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 20),
            onPressed: () => _showReviewDialog(p, index),
          ),
        );
      },
    );
  }
}