// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/snackbar_helper.dart';
import '../../services/supabase_pendaftaran_service.dart';
import 'package:url_launcher/url_launcher.dart';

// =========================================================================
// 1. MODEL DATA
// =========================================================================
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
  State<ManajemenPendaftarAdmin> createState() =>
      _ManajemenPendaftarAdminState();
}

class _ManajemenPendaftarAdminState extends State<ManajemenPendaftarAdmin>
    with SingleTickerProviderStateMixin {
  List<PendaftarModel> listPendaftar = [];
  List<Map<String, dynamic>> listAkunBelumLengkap = [];
  bool _isLoadingData = true;
  bool _isLoadingBelumLengkap = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _loadAkunBelumLengkap();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    final allFullData = await SupabasePendaftaranService.getAllPendaftar();

    setState(() {
      listPendaftar = allFullData.map((s) {
        return PendaftarModel(
          id: s['email'] ?? '',
          nama: s['name'] ?? '-',
          asalSekolah: s['asal_sekolah'] ?? '-',
          tglDaftar: _formatDate(s['tgl_daftar']),
          status: s['admin_status'] ?? 'Menunggu Review',
        );
      }).toList();
      _isLoadingData = false;
    });
  }

  Future<void> _loadAkunBelumLengkap() async {
    setState(() => _isLoadingBelumLengkap = true);
    final data = await SupabasePendaftaranService.getAllAkunBelumLengkap();
    setState(() {
      listAkunBelumLengkap = data;
      _isLoadingBelumLengkap = false;
    });
  }

  void _showDeleteDialog(Map<String, dynamic> akun) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Hapus Akun Siswa"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Apakah Anda yakin ingin menghapus akun siswa ini?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Nama: ${akun['name'] ?? '-'}"),
                  Text("Email: ${akun['email'] ?? '-'}"),
                  const SizedBox(height: 15),
                  const Text(
                    "Tindakan ini tidak dapat dibatalkan. Seluruh data akun dan akses login akan dihapus secara permanen dari sistem.",
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setStateDialog(() => isDeleting = true);
                          final error = await SupabasePendaftaranService.deleteAkunSiswa(akun['id']);
                          if (mounted) {
                            setStateDialog(() => isDeleting = false);
                            if (error != null) {
                              showErrorSnackBar(context, error);
                            } else {
                              showSuccessSnackBar(context, "Akun berhasil dihapus.");
                              Navigator.pop(context);
                              _loadAkunBelumLengkap();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Hapus"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRegistrationAgeBadge(String? createdAtStr) {
    if (createdAtStr == null) return const SizedBox.shrink();
    try {
      final createdAt = DateTime.parse(createdAtStr).toLocal();
      final difference = DateTime.now().difference(createdAt).inDays;

      Color bgColor;
      Color textColor;
      String text;

      if (difference < 7) {
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = "$difference Hari (Baru)";
      } else if (difference <= 30) {
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        text = "$difference Hari";
      } else {
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        text = "$difference Hari (Tidak Aktif)";
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
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
    const months = [
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
    return months[month - 1];
  }

  int _getMonthNumber(String monthName) {
    const months = [
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
    int index = months.indexOf(monthName);
    return index != -1 ? index + 1 : 1;
  }

  // =========================================================================
  // WIDGET BANTUAN UI
  // =========================================================================
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
      case 'Menunggu Pengumuman':
        bgColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade800;
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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const Text(": ", style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getFileNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        String fileName = Uri.decodeComponent(uri.pathSegments.last);
        final parts = fileName.split('_');
        if (parts.length > 3) {
          return parts.sublist(3).join('_');
        }
        return fileName;
      }
    } catch (_) {}
    return url;
  }

  Widget _buildFileTile(String title, String? fileUrl) {
    bool hasFile = fileUrl != null && fileUrl.isNotEmpty;
    String? fileName = _getFileNameFromUrl(fileUrl);

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
        hasFile ? (fileName ?? fileUrl) : "Belum diunggah oleh siswa",
        style: TextStyle(
          fontSize: 12,
          color: hasFile ? Colors.blue : Colors.grey,
        ),
      ),
      trailing: hasFile
          ? const Icon(Icons.open_in_new, color: Colors.blue, size: 20)
          : null,
      onTap: hasFile
          ? () async {
              final uri = Uri.tryParse(fileUrl);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (mounted) {
                  showErrorSnackBar(context, 'Tidak dapat membuka file atau URL tidak valid.');
                }
              }
            }
          : null,
    );
  }

  // =========================================================================
  // FUNGSI REVIEW & UBAH STATUS PENDAFTAR
  // =========================================================================
  void _showReviewDialog(PendaftarModel pendaftar, int index) async {
    final detailSiswa = await SupabasePendaftaranService.getDetailPendaftar(pendaftar.id);
    if (detailSiswa == null) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat data detail siswa.');
      return;
    }

    String selectedStatus = pendaftar.status;
    final TextEditingController catatanController = TextEditingController(
      text: detailSiswa['catatan_revisi'] ?? '',
    );
    
    // ScrollController untuk auto-scroll modal.
    final ScrollController modalScrollController = ScrollController();
    
    final TextEditingController jadwalDisplayController = TextEditingController(
      text: detailSiswa['jadwal_wawancara'] ?? '',
    );
    final TextEditingController lokasiLinkController = TextEditingController();

    String selectedMetodeWawancara = 'Daring';
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    String errorPesanWawancara = '';

    String savedJadwal = detailSiswa['jadwal_wawancara'] ?? '';
    if (savedJadwal.isNotEmpty) {
      try {
        if (savedJadwal.contains('(Daring)')) {
          selectedMetodeWawancara = 'Daring';
        }
        if (savedJadwal.contains('(Luring)')) {
          selectedMetodeWawancara = 'Luring';
        }

        if (savedJadwal.contains('\nLink: ')) {
          lokasiLinkController.text = savedJadwal.split('\nLink: ').last;
        } else if (savedJadwal.contains('\nLokasi: ')) {
          lokasiLinkController.text = savedJadwal.split('\nLokasi: ').last;
        }

        RegExp dateRegExp = RegExp(r'(\d{1,2})\s([a-zA-Z]+)\s(\d{4})');
        Match? dateMatch = dateRegExp.firstMatch(savedJadwal);
        if (dateMatch != null) {
          int day = int.parse(dateMatch.group(1)!);
          int month = _getMonthNumber(dateMatch.group(2)!);
          int year = int.parse(dateMatch.group(3)!);
          selectedDate = DateTime(year, month, day);
        }

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
      'Menunggu Review',
      'Revisi',
      'Wawancara',
      'Menunggu Pengumuman',
      'Diterima',
      'Pelatihan',
      'Lulus',
      'Ditolak',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void updateJadwalString() {
              if (selectedDate != null && selectedTime != null) {
                String formattedDate =
                    "${selectedDate!.day} ${_getMonthName(selectedDate!.month)} ${selectedDate!.year}";
                String formattedTime =
                    "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

                String labelMetode = selectedMetodeWawancara == 'Daring'
                    ? "Link"
                    : "Lokasi";
                String detailTeks = lokasiLinkController.text.trim().isNotEmpty
                    ? "\n$labelMetode: ${lokasiLinkController.text.trim()}"
                    : "";

                jadwalDisplayController.text =
                    "$formattedDate, Pukul $formattedTime WIB ($selectedMetodeWawancara)$detailTeks";
              }
            }

            Future<void> pickDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate:
                    selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2027),
              );
              if (picked != null) {
                setStateDialog(() {
                  selectedDate = picked;
                  errorPesanWawancara = '';
                });
                updateJadwalString();
              }
            }

            Future<void> pickTime() async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime:
                    selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setStateDialog(() {
                  selectedTime = picked;
                  errorPesanWawancara = '';
                });
                updateJadwalString();
              }
            }

            String timeButtonText = selectedTime == null
                ? "Pilih Jam"
                : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_ind_rounded,
                        color: Colors.red,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Review Pendaftar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 10, thickness: 1),
                ],
              ),
              // Memisahkan Error agar Sticky di bagian atas Modal.
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WIDGET ERROR STICKY (Tidak ikut terscroll).
                    if (errorPesanWawancara.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorPesanWawancara,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Area konten yang bisa di-scroll.
                    Flexible(
                      child: SingleChildScrollView(
                        controller: modalScrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pendaftar.nama,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      pendaftar.id,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),

                            const Text(
                              "Informasi Detail",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.blueGrey.shade100,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                    "Waktu Daftar",
                                    pendaftar.tglDaftar,
                                  ),
                                  _buildDetailRow(
                                    "NIK",
                                    detailSiswa['nik'] ?? '-',
                                  ),
                                  _buildDetailRow(
                                    "No. Telepon",
                                    detailSiswa['telepon'] ?? '-',
                                  ),
                                  _buildDetailRow(
                                    "Domisili",
                                    detailSiswa['domisili'] ?? '-',
                                  ),
                                  _buildDetailRow(
                                    "Pendidikan",
                                    detailSiswa['pendidikan'] ?? '-',
                                  ),
                                  _buildDetailRow(
                                    "Asal Sekolah",
                                    detailSiswa['asal_sekolah'] ?? '-',
                                  ),
                                  _buildDetailRow(
                                    "Tahun Lulus",
                                    detailSiswa['tahun_lulus'] ?? '-',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            const Text(
                              "Berkas Persyaratan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                                  _buildFileTile(
                                    "Foto KTP / Kartu Pelajar",
                                    detailSiswa['file_ktp'],
                                  ),
                                  const Divider(height: 1),
                                  _buildFileTile(
                                    "Scan Rapor / Ijazah Terakhir",
                                    detailSiswa['file_rapor'],
                                  ),
                                  const Divider(height: 1),
                                  _buildFileTile(
                                    "Pas Foto 3x4",
                                    detailSiswa['file_foto'],
                                  ),
                                  const Divider(height: 1),
                                  _buildFileTile(
                                    "Surat Motivasi",
                                    detailSiswa['file_motivasi'],
                                  ),
                                  const Divider(height: 1),
                                  _buildFileTile(
                                    "Surat Keterangan Tidak Mampu",
                                    detailSiswa['file_sktm'],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            const Text(
                              "Update Status Pendaftaran",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: selectedStatus,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: statusOptions.map((String status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setStateDialog(() {
                                    selectedStatus = newValue;
                                    errorPesanWawancara = '';
                                  });

                                  // Auto-scroll ke bawah agar kolom revisi/wawancara terlihat.
                                  if (newValue == 'Revisi' || newValue == 'Wawancara') {
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      if (modalScrollController.hasClients) {
                                        modalScrollController.animateTo(
                                          modalScrollController.position.maxScrollExtent,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    });
                                  }
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
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            if (selectedStatus == 'Wawancara') ...[
                              const SizedBox(height: 15),
                              const Divider(color: Colors.black12),
                              const SizedBox(height: 15),
                              const Text(
                                "Pengaturan Jadwal Wawancara",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 15),

                              const Text(
                                "Metode Wawancara",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: selectedMetodeWawancara,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.blue.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                items: ['Daring', 'Luring'].map((String val) {
                                  return DropdownMenuItem(
                                    value: val,
                                    child: Text(val),
                                  );
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Pilih Tanggal",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: pickDate,
                                          icon: const Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                          ),
                                          label: Text(
                                            selectedDate == null
                                                ? "Pilih Tanggal"
                                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                            backgroundColor:
                                                Colors.blue.shade50,
                                            foregroundColor:
                                                Colors.blue.shade800,
                                            elevation: 0,
                                            side: BorderSide(
                                              color: Colors.blue.shade200,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Pilih Jam (24 Jam)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: pickTime,
                                          icon: const Icon(
                                            Icons.access_time,
                                            size: 18,
                                          ),
                                          label: Text(timeButtonText),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                            backgroundColor:
                                                Colors.blue.shade50,
                                            foregroundColor:
                                                Colors.blue.shade800,
                                            elevation: 0,
                                            side: BorderSide(
                                              color: Colors.blue.shade200,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              Text(
                                selectedMetodeWawancara == 'Daring'
                                    ? "Tautan Wawancara Daring"
                                    : "Alamat / Lokasi Wawancara",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: lokasiLinkController,
                                onChanged: (value) => updateJadwalString(),
                                decoration: InputDecoration(
                                  hintText: selectedMetodeWawancara == 'Daring'
                                      ? "Contoh: https://zoom.us/j/123456789"
                                      : "Contoh: Kantor VernonCorp, Ruang Meeting 1",
                                  prefixIcon: Icon(
                                    selectedMetodeWawancara == 'Daring'
                                        ? Icons.link_rounded
                                        : Icons.location_on_rounded,
                                    color: Colors.blue.shade700,
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade700,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                              if (selectedDate != null &&
                                  selectedTime != null) ...[
                                const SizedBox(height: 25),
                                TextFormField(
                                  controller: jadwalDisplayController,
                                  maxLines: null,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Pratinjau Pesan untuk Siswa",
                                    filled: true,
                                    fillColor: Colors.green.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.all(20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Cek validasi error.
                    if (selectedStatus == 'Wawancara' &&
                        (selectedDate == null ||
                            selectedTime == null ||
                            lokasiLinkController.text.trim().isEmpty)) {
                      setStateDialog(() {
                        errorPesanWawancara =
                            "Mohon lengkapi Tanggal, Jam, dan Tautan/Lokasi wawancara sebelum menyimpan!";
                      });
                      return;
                    }

                    // Kirim update status ke Supabase.
                    final error = await SupabasePendaftaranService.updateStatusPendaftar(
                      email: pendaftar.id,
                      newStatus: selectedStatus,
                      catatan: catatanController.text,
                      jadwalWawancara: selectedStatus == 'Wawancara'
                          ? jadwalDisplayController.text
                          : null,
                    );

                    if (error != null) {
                      if (context.mounted) showErrorSnackBar(context, error);
                      return;
                    }

                    setState(() {
                      listPendaftar[index].status = selectedStatus;
                    });

                    Navigator.pop(context);

                    showSuccessSnackBar(context, 'Berhasil update status ke $selectedStatus');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Simpan Keputusan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                const Text(
                  "Manajemen Pendaftar",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _loadData();
                    _loadAkunBelumLengkap();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black87),
                  label: const Text(
                    "Muat Ulang Data",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_turned_in_rounded),
                    SizedBox(width: 8),
                    Text("Sudah Melengkapi Berkas"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_late_rounded),
                    SizedBox(width: 8),
                    Text("Belum Melengkapi Berkas"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Sudah Melengkapi Berkas
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isLoadingData
                      ? const Center(child: CircularProgressIndicator())
                      : listPendaftar.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada pendaftar yang men-submit formulir.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : isMobile
                      ? _buildMobileView()
                      : _buildDesktopView(),
                ),
                // Tab 2: Belum Melengkapi Berkas
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isLoadingBelumLengkap
                      ? const Center(child: CircularProgressIndicator())
                      : listAkunBelumLengkap.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada akun siswa yang belum melengkapi berkas.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : isMobile
                      ? _buildMobileBelumLengkapView()
                      : _buildDesktopBelumLengkapView(),
                ),
              ],
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
                DataColumn(
                  label: Text(
                    "Waktu Daftar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Nama Siswa",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Aksi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: List.generate(listPendaftar.length, (index) {
                final p = listPendaftar[index];
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        p.tglDaftar,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            p.asalSekolah,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(_buildStatusBadge(p.status)),
                    DataCell(
                      ElevatedButton.icon(
                        onPressed: () => _showReviewDialog(p, index),
                        icon: const Icon(
                          Icons.search,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Review",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
          title: Text(
            p.nama,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.asalSekolah),
              const SizedBox(height: 5),
              _buildStatusBadge(p.status),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => _showReviewDialog(p, index),
          ),
        );
      },
    );
  }

  Widget _buildDesktopBelumLengkapView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columns: const [
                DataColumn(
                  label: Text(
                    "Waktu Registrasi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Nama & Email",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Durasi Tidak Aktif",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Aksi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: List.generate(listAkunBelumLengkap.length, (index) {
                final user = listAkunBelumLengkap[index];
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        _formatDate(user['created_at']),
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user['name'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user['email'] ?? '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(_buildRegistrationAgeBadge(user['created_at'])),
                    DataCell(
                      ElevatedButton.icon(
                        onPressed: () => _showDeleteDialog(user),
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Hapus Akun",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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

  Widget _buildMobileBelumLengkapView() {
    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: listAkunBelumLengkap.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = listAkunBelumLengkap[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            user['name'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['email'] ?? '-'),
              const SizedBox(height: 4),
              Text(
                "Registrasi: ${_formatDate(user['created_at'])}",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 6),
              _buildRegistrationAgeBadge(user['created_at']),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_forever_rounded,
              color: Colors.red.shade700,
              size: 24,
            ),
            onPressed: () => _showDeleteDialog(user),
          ),
        );
      },
    );
  }
}
