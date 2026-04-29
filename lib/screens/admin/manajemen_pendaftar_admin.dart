import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

// ==========================================
// 1. MODEL DATA SEMENTARA
// ==========================================
class PendaftarModel {
  final String id;
  final String nama;
  final String asalSekolah;
  final String tglDaftar;
  String status; // 'Menunggu Review', 'Wawancara', 'Diterima', 'Ditolak'

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

class _ManajemenPendaftarAdminState extends State<ManajemenPendaftarAdmin> {
  // ==========================================
  // 2. DATA DUMMY SEMENTARA
  // ==========================================
  List<PendaftarModel> listPendaftar = [
    PendaftarModel(
      id: 'VIP-001',
      nama: 'Budi Santoso',
      asalSekolah: 'SMAN 1 Malang',
      tglDaftar: '28 Apr 2026',
      status: 'Menunggu Review',
    ),
    PendaftarModel(
      id: 'VIP-002',
      nama: 'Siti Aminah',
      asalSekolah: 'SMK Telkom Malang',
      tglDaftar: '27 Apr 2026',
      status: 'Wawancara',
    ),
    PendaftarModel(
      id: 'VIP-003',
      nama: 'Andi Wijaya',
      asalSekolah: 'SMAN 3 Malang',
      tglDaftar: '25 Apr 2026',
      status: 'Diterima',
    ),
    PendaftarModel(
      id: 'VIP-004',
      nama: 'Rina Melati',
      asalSekolah: 'SMA Brawijaya',
      tglDaftar: '24 Apr 2026',
      status: 'Ditolak',
    ),
  ];

  // ==========================================
  // WIDGET BANTUAN: LABEL WARNA STATUS
  // ==========================================
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Menunggu Review':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Wawancara':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'Diterima':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Ditolak':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
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

  // ==========================================
  // FUNGSI REVIEW & UBAH STATUS PENDAFTAR
  // ==========================================
  void _showReviewDialog(PendaftarModel pendaftar, int index) {
    String selectedStatus = pendaftar.status;
    // 👇 Status "Lolos Berkas" sudah dihilangkan dari opsi dropdown
    final List<String> statusOptions = [
      'Menunggu Review',
      'Wawancara',
      'Diterima',
      'Ditolak',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_ind_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Review Pendaftar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // INFO SISWA
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Expanded(
                            child: Column(
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
                                  "${pendaftar.id} • ${pendaftar.asalSekolah}",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // SECTION BERKAS
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
                            ListTile(
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              title: const Text("Scan Rapor Semester 1-5"),
                              trailing: TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Mengunduh Rapor..."),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text("Unduh"),
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              title: const Text("Surat Rekomendasi Sekolah"),
                              trailing: TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Mengunduh Surat..."),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text("Unduh"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // SECTION UBAH STATUS
                      const Text(
                        "Update Status Pendaftaran",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
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
                            setStateDialog(() => selectedStatus = newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Tutup",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      listPendaftar[index].status = selectedStatus;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Status berhasil diupdate!"),
                        backgroundColor: Colors.green,
                      ),
                    );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fitur Export ke Excel segera hadir!"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_download, color: Colors.black87),
                  label: const Text(
                    "Export Data",
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

          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: listPendaftar.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada pendaftar.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
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
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(15),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(
                    label: Text(
                      "Tgl Daftar",
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
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
}
