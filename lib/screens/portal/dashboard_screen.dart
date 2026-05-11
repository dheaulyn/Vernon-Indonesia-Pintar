import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import 'portal_layout.dart'; 
import '../../data/mock_database.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRevisiStatus();
    });
  }

  void _checkRevisiStatus() {
    final user = MockDatabase.currentUser ?? {};
    
    if (user['is_revisi'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
                SizedBox(width: 10),
                Text("Revisi Diperlukan!", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              "Tim verifikator telah memeriksa berkas Anda dan menemukan ada data atau dokumen yang harus diperbaiki agar bisa lanjut ke tahap berikutnya.\n\nSilakan cek catatan lengkapnya sekarang.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Nanti Saja", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                  context.go('/status-beasiswa'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text("Perbaiki Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
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

  String _getStatusText(int step, bool isRevisi) {
    if (isRevisi) return 'Perhatian: Revisi Dokumen Diperlukan!';
    
    switch (step) {
      case 0: return 'Belum Melengkapi Formulir Online';
      case 1: return 'Tahap 2: Menunggu Verifikasi Dokumen';
      case 2: return 'Tahap 3: Menunggu Jadwal Wawancara';
      case 3: return 'Tahap 4: Menunggu Pengumuman Hasil Seleksi';
      case 4: return 'Tahap 5: Lolos - Menunggu Orientasi & TTD';
      case 5: return 'Tahap 6: Sedang Menjalani Pelatihan Vokasi';
      case 6: return 'Lulus Program Pelatihan Vernon Edu';
      default: return 'Belum Melengkapi Formulir';
    }
  }

  Color _getStatusColor(int step, bool isRevisi) {
    if (isRevisi) return Colors.red.shade700;
    if (step == 0) return Colors.deepOrange;
    if (step >= 1 && step <= 3) return Colors.blue.shade700;
    return Colors.green.shade700;
  }

  Color _getStatusBgColor(int step, bool isRevisi) {
    if (isRevisi) return Colors.red.shade50;
    if (step == 0) return Colors.orange.shade50;
    if (step >= 1 && step <= 3) return Colors.blue.shade50;
    return Colors.green.shade50;
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDatabase.currentUser ?? {};
    
    final bool isRegistered = user['is_registered'] == true;
    final int currentStep = user['current_step'] ?? (isRegistered ? 1 : 0);
    final bool isRevisi = user['is_revisi'] == true; 
    
    // 👇 LOGIKA BARU PENGECEKAN STATUS DITOLAK
    final bool isDitolak = user['admin_status'] == 'Ditolak';
    
    final currentName = user['name'] ?? 'Siswa VIP';
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return PortalLayout(
      activeMenu: 'dashboard', 
      content: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Siswa',
              style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Halo, $currentName! Selamat datang di Portal Beasiswa VIP.',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // BANNER JADWAL WAWANCARA (SEMBUNYIKAN JIKA DITOLAK)
            // ==========================================
            if (!isDitolak && currentStep == 2 && user['jadwal_wawancara'] != null && user['jadwal_wawancara'].toString().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: isMobile 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 30),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Selamat! Anda Lolos Wawancara",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Jadwal: ${user['jadwal_wawancara']}",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/status-beasiswa'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Cek Detail Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 40),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selamat! Anda Lolos ke Tahap Wawancara",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Jadwal Anda: ${user['jadwal_wawancara']}",
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => context.go('/status-beasiswa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Cek Detail Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
              ),
              const SizedBox(height: 30),
            ],

            // ==========================================
            // 1. KARTU STATUS PENDAFTARAN
            // ==========================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 20 : 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  // 👇 BORDER MERAH JIKA DITOLAK ATAU REVISI
                  color: isDitolak ? Colors.red.shade200 : (isRevisi ? Colors.red.shade300 : (currentStep > 0 ? Colors.blue.shade200 : Colors.grey.shade300))
                ),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: isDitolak 
                ? _buildStatusDitolak() // 👇 PANGGIL WIDGET DITOLAK
                : (isMobile ? _buildStatusMobile(currentStep, isRevisi) : _buildStatusDesktop(currentStep, isRevisi)),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // 2. COLLAPSE DATA PENDAFTAR
            // ==========================================
            if (currentStep > 0) ...[
              _buildDataPendaftarCollapse(user),
              const SizedBox(height: 30),
            ],

            // ==========================================
            // 3. ALUR PENDAFTARAN BEASISWA (TIMELINE)
            // ==========================================
            // 👇 SEMBUNYIKAN TIMELINE JIKA DITOLAK KARENA PROGRES BERHENTI
            if (!isDitolak) ...[
              const Text(
                'Alur Seleksi Beasiswa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildAlurPendaftaran(currentStep, isRevisi),
              const SizedBox(height: 30),
            ],

            // ==========================================
            // 4. KARTU INFORMASI PENTING
            // ==========================================
            const Text(
              'Informasi Penting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Pastikan Anda telah melengkapi seluruh persyaratan sebelum menekan tombol kirim pendaftaran.', style: TextStyle(height: 1.5)),
                  SizedBox(height: 8),
                  Text('• Kelulusan tahap berkas dan undangan wawancara akan diumumkan melalui dashboard ini.', style: TextStyle(height: 1.5)),
                  SizedBox(height: 8),
                  Text('• Jika mengalami kendala teknis, silakan hubungi WhatsApp admin VIP di menu Bantuan.', style: TextStyle(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 👇 WIDGET BARU KHUSUS STATUS DITOLAK
  // ==========================================
  Widget _buildStatusDitolak() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.cancel_rounded, color: Colors.red.shade600, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mohon Maaf, Anda Belum Lolos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terima kasih atas partisipasi dan antusiasme Anda mengikuti seleksi Beasiswa Vernon Indonesia Pintar (VIP) 2026. Setelah melalui proses evaluasi yang ketat, dengan berat hati kami sampaikan bahwa Anda belum dapat melanjutkan ke tahap berikutnya pada periode ini.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Jangan patah semangat! Terus kembangkan potensi Anda dan silakan mencoba kembali di program beasiswa kami selanjutnya.',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET TIMELINE ALUR PENDAFTARAN
  // ==========================================
  Widget _buildAlurPendaftaran(int currentStep, bool isRevisi) {
    final List<String> stages = [
      "Pengisian Formulir Online",
      "Verifikasi Berkas & Dokumen",
      "Seleksi Wawancara",
      "Pengumuman Kelulusan",
      "Orientasi & Penandatanganan Kontrak",
      "Pelatihan Vokasi Dimulai"
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stages.length, (index) {
          bool isDone = false;
          bool isActive = false;
          bool isError = false;

          if (currentStep == 0) {
            if (index == 0) isActive = true;
          } else if (currentStep >= 6) {
            isDone = true; 
          } else {
            if (index < currentStep) isDone = true;
            if (index == currentStep) isActive = true;
            
            if (index == 1 && isRevisi) {
               isDone = false;
               isActive = true;
               isError = true;
            }
          }

          return _buildTimelineStep(
            title: stages[index],
            isDone: isDone,
            isActive: isActive,
            isError: isError,
            isLast: index == stages.length - 1,
            stepNumber: (index + 1).toString(),
          );
        }),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required bool isDone,
    required bool isActive,
    required bool isError,
    required bool isLast,
    required String stepNumber,
  }) {
    Color circleColor = Colors.grey.shade200;
    Color lineAndTextColor = Colors.grey.shade500;
    Widget circleContent = Text(stepNumber, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold));

    if (isDone) {
      circleColor = Colors.green;
      lineAndTextColor = Colors.green;
      circleContent = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isError) {
      circleColor = Colors.red;
      lineAndTextColor = Colors.red;
      circleContent = const Icon(Icons.priority_high, color: Colors.white, size: 16);
    } else if (isActive) {
      circleColor = AppColors.primary;
      lineAndTextColor = AppColors.primary;
      circleContent = Text(stepNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: circleContent),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: isDone ? Colors.green : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isActive || isError ? FontWeight.bold : FontWeight.normal,
                    color: isActive || isDone || isError ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
                if (isError)
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text("Perlu perbaikan berkas!", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                if (isActive && !isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text("Tahap saat ini", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET BANTUAN UI LAINNYA
  // ==========================================

  Widget _buildDataPendaftarCollapse(Map<String, dynamic> user) {
    final tglDaftar = _formatDate(user['tgl_daftar']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: Colors.white,
            backgroundColor: Colors.white,
            iconColor: AppColors.primary,
            collapsedIconColor: Colors.grey.shade600,
            leading: Icon(Icons.assignment_ind_rounded, color: AppColors.primary),
            title: const Text(
              "Lihat Data Pendaftaran Anda",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            children: [
              const Divider(height: 1, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Tanggal Daftar", tglDaftar),
                    _buildDetailRow("Nama Lengkap", user['name'] ?? '-'),
                    _buildDetailRow("NIK", user['nik'] ?? '-'),
                    _buildDetailRow("Email", user['email'] ?? '-'),
                    _buildDetailRow("Nomor HP", user['telepon'] ?? '-'),
                    _buildDetailRow("Domisili", user['domisili'] ?? '-'),
                    _buildDetailRow("Pendidikan", user['pendidikan'] ?? '-'),
                    _buildDetailRow("Asal Sekolah", user['asal_sekolah'] ?? '-'),
                    _buildDetailRow("Tahun Lulus", user['tahun_lulus'] ?? '-'),
                    
                    const SizedBox(height: 20),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 15),
                    const Text("Dokumen Pendukung Tersimpan:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 15),
                    
                    _buildFileRow("KTP / Kartu Pelajar", user['file_ktp']),
                    _buildFileRow("Ijazah / SKL Terakhir", user['file_rapor']),
                    _buildFileRow("Pas Foto 3x4", user['file_foto']),
                    _buildFileRow("Surat Motivasi", user['file_motivasi']),
                    _buildFileRow("Surat Keterangan Tidak Mampu (SKTM)", user['file_sktm']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ),
          const Text(":  ", style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value, 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String? fileName) {
    bool hasFile = fileName != null && fileName.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ),
          const Text(":  ", style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Row(
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cancel, 
                  color: hasFile ? Colors.green : Colors.red, 
                  size: 16
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasFile ? fileName : "Belum Diunggah", 
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: 14, 
                      color: hasFile ? Colors.blue.shade700 : Colors.red
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDesktop(int step, bool isRevisi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Pendaftaran Beasiswa VIP 2026',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(step, isRevisi),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(step, isRevisi),
                      style: TextStyle(
                        color: _getStatusColor(step, isRevisi),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (step == 0) {
                  context.go('/form-beasiswa');
                } else {
                  context.go('/status-beasiswa');
                }
              },
              icon: Icon(step == 0 ? Icons.edit_document : (isRevisi ? Icons.warning_rounded : Icons.fact_check_outlined)),
              label: Text(step == 0 ? 'Lengkapi Berkas Sekarang' : (isRevisi ? 'Perbaiki Berkas' : 'Cek Detail Status')),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRevisi ? Colors.red.shade600 : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildProgressBar(step, isRevisi),
      ],
    );
  }

  Widget _buildStatusMobile(int step, bool isRevisi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pendaftaran Beasiswa VIP 2026',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusBgColor(step, isRevisi),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(step, isRevisi),
            style: TextStyle(
              color: _getStatusColor(step, isRevisi),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (step == 0) {
                context.go('/form-beasiswa');
              } else {
                context.go('/status-beasiswa');
              }
            },
            icon: Icon(step == 0 ? Icons.edit_document : (isRevisi ? Icons.warning_rounded : Icons.fact_check_outlined)),
            label: Text(step == 0 ? 'Lengkapi Berkas Sekarang' : (isRevisi ? 'Perbaiki Berkas' : 'Cek Detail Status')),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRevisi ? Colors.red.shade600 : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 25),
        _buildProgressBar(step, isRevisi),
      ],
    );
  }

  Widget _buildProgressBar(int step, bool isRevisi) {
    int displayStep = step == 0 ? 0 : step + 1;
    
    String progressText = '';
    if (step == 0) {
      progressText = 'Tahap 0 dari 6: Belum Mengisi Form';
    } else if (isRevisi) {
      progressText = 'Tahap $displayStep dari 6: Menunggu Perbaikan Anda';
    } else {
      progressText = 'Tahap $displayStep dari 6: ${_getStatusText(step, false).split(": ").last}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          progressText,
          style: TextStyle(
            color: isRevisi ? Colors.red.shade700 : Colors.black54, 
            fontSize: 13,
            fontWeight: isRevisi ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: step == 0 ? 0.05 : (displayStep / 6.0),
          backgroundColor: Colors.grey.shade200,
          color: _getStatusColor(step, isRevisi),
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}