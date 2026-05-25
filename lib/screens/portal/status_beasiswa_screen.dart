import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_colors.dart';
import '../../core/snackbar_helper.dart';
import 'portal_layout.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/supabase_pendaftaran_service.dart';
import '../../services/api_wilayah_service.dart';
import 'package:url_launcher/url_launcher.dart';

class StatusBeasiswaScreen extends StatefulWidget {
  const StatusBeasiswaScreen({super.key});

  @override
  State<StatusBeasiswaScreen> createState() => _StatusBeasiswaScreenState();
}

class _StatusBeasiswaScreenState extends State<StatusBeasiswaScreen> {
  final _formKey = GlobalKey<FormState>();

  // ==========================================
  // CONTROLLER FORM
  // ==========================================
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _detailAlamatController = TextEditingController();

  late TextEditingController _nikController;
  late TextEditingController _asalSekolahController;
  late TextEditingController _tahunLulusController;

  String? _selectedPendidikan;
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;

  PlatformFile? _fileKtp;
  PlatformFile? _fileIjazah;
  PlatformFile? _fileSktm;
  PlatformFile? _fileFoto;
  PlatformFile? _fileMotivasi;

  bool _isLoading = false;
  bool _isReadOnly = true;
  bool _isRevisi = false;
  String _catatanRevisi = '';
  int _currentStep = 0;

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _regencies = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _villages = [];
  bool _isLoadingWilayah = true;

  @override
  void initState() {
    super.initState();
    final user = SupabaseAuthService.currentUserData ?? {};

    _currentStep = user['current_step'] ?? 0;
    _isRevisi = user['is_revisi'] == true;
    _catatanRevisi = user['catatan_revisi'] ?? '';

    // Form bisa diedit JIKA dalam mode revisi
    _isReadOnly = !_isRevisi;

    _nameController = TextEditingController(text: user['name'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _phoneController = TextEditingController(text: user['telepon'] ?? '');

    if (user['pendidikan'] != null &&
        ["SD", "SMP", "SMA"].contains(user['pendidikan'])) {
      _selectedPendidikan = user['pendidikan'];
    }

    if (user['pendidikan'] != null &&
        ["SD", "SMP", "SMA"].contains(user['pendidikan'])) {
      _selectedPendidikan = user['pendidikan'];
    }

    _nikController = TextEditingController(text: user['nik'] ?? '');
    _asalSekolahController =
        TextEditingController(text: user['asal_sekolah'] ?? '');
    _tahunLulusController =
        TextEditingController(text: user['tahun_lulus']?.toString() ?? '');

    _initWilayahData(user['domisili'] ?? '');
  }

  Future<void> _initWilayahData(String domisili) async {
    setState(() => _isLoadingWilayah = true);
    
    final provData = await ApiWilayahService.getProvinces();
    _provinces = provData;

    List<String> parts = domisili.split(', ');
    
    if (parts.length >= 4) {
      String provName = parts.last.trim();
      String kotaName = parts[parts.length - 2].trim();
      String kecName = parts[parts.length - 3].replaceAll('Kec. ', '').trim();
      String? kelName;
      
      if (parts.length >= 5) {
        kelName = parts[parts.length - 4].replaceAll('Kel. ', '').replaceAll('Desa ', '').trim();
        _detailAlamatController.text = parts.sublist(0, parts.length - 4).join(', ');
      } else {
        _detailAlamatController.text = parts.sublist(0, parts.length - 3).join(', ');
      }

      // Safe matching helper
      Map<String, dynamic>? findMatch(List<Map<String, dynamic>> list, String name) {
        try {
          return list.firstWhere((item) => (item['name'] as String).toUpperCase() == name.toUpperCase());
        } catch (e) {
          try {
             return list.firstWhere((item) => (item['name'] as String).toUpperCase().contains(name.toUpperCase()) || name.toUpperCase().contains((item['name'] as String).toUpperCase()));
          } catch(e) {
             return null;
          }
        }
      }

      final provMatch = findMatch(_provinces, provName);
      
      if (provMatch != null) {
        _selectedProvinsi = '${provMatch['id']}|${provMatch['name']}';
        _regencies = await ApiWilayahService.getRegencies(provMatch['id']);
        
        final kotaMatch = findMatch(_regencies, kotaName);
        
        if (kotaMatch != null) {
          _selectedKota = '${kotaMatch['id']}|${kotaMatch['name']}';
          _districts = await ApiWilayahService.getDistricts(kotaMatch['id']);
          
          final kecMatch = findMatch(_districts, kecName);
          
          if (kecMatch != null) {
            _selectedKecamatan = '${kecMatch['id']}|${kecMatch['name']}';
            _villages = await ApiWilayahService.getVillages(kecMatch['id']);
            
            if (kelName != null) {
              final kelMatch = findMatch(_villages, kelName);
              if (kelMatch != null) {
                _selectedKelurahan = '${kelMatch['id']}|${kelMatch['name']}';
              }
            }
          }
        }
      }
    } else {
      _detailAlamatController.text = domisili;
    }
    
    setState(() => _isLoadingWilayah = false);
  }

  Future<void> _loadRegencies(String provinceId) async {
    setState(() => _isLoadingWilayah = true);
    final data = await ApiWilayahService.getRegencies(provinceId);
    setState(() {
      _regencies = data;
      _isLoadingWilayah = false;
    });
  }

  Future<void> _loadDistricts(String regencyId) async {
    setState(() => _isLoadingWilayah = true);
    final data = await ApiWilayahService.getDistricts(regencyId);
    setState(() {
      _districts = data;
      _isLoadingWilayah = false;
    });
  }

  Future<void> _loadVillages(String districtId) async {
    setState(() => _isLoadingWilayah = true);
    final data = await ApiWilayahService.getVillages(districtId);
    setState(() {
      _villages = data;
      _isLoadingWilayah = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _detailAlamatController.dispose();
    _nikController.dispose();
    _asalSekolahController.dispose();
    _tahunLulusController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    if (_isReadOnly) return;

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // IMPORTANT for web to get bytes
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        PlatformFile file = result.files.first;
        switch (type) {
          case 'ktp':
            _fileKtp = file;
            break;
          case 'ijazah':
            _fileIjazah = file;
            break;
          case 'foto':
            _fileFoto = file;
            break;
          case 'motivasi':
            _fileMotivasi = file;
            break;
          case 'sktm':
            _fileSktm = file;
            break;
        }
      });
    }
  }

  void _submitRevisi() async {
    // Validasi Wajib
    if (!_formKey.currentState!.validate() ||
        _selectedProvinsi == null ||
        _selectedKota == null ||
        _selectedKecamatan == null ||
        _selectedKelurahan == null) {
      showErrorSnackBar(context, 'Mohon periksa kembali. Semua data wilayah wajib dipilih.');
      return;
    }

    setState(() => _isLoading = true);

    String getWilayahName(String? value) {
      if (value == null) return '';
      final parts = value.split('|');
      return parts.length > 1 ? parts[1] : value;
    }

    String provName = getWilayahName(_selectedProvinsi);
    String kotaName = getWilayahName(_selectedKota);
    String kecName = getWilayahName(_selectedKecamatan);
    String kelName = getWilayahName(_selectedKelurahan);

    // Menggabungkan kembali string domisili
    String domisiliLengkap =
        '${_detailAlamatController.text}, Kel. $kelName, Kec. $kecName, $kotaName, $provName';

    // Kirim revisi ke Supabase
    final error = await SupabasePendaftaranService.submitRevisi(
      nama: _nameController.text,
      nik: _nikController.text,
      telepon: _phoneController.text,
      domisili: domisiliLengkap,
      pendidikan: _selectedPendidikan ?? '',
      asalSekolah: _asalSekolahController.text,
      tahunLulus: _tahunLulusController.text,
      fileKtp: _fileKtp,
      fileRapor: _fileIjazah,
      fileFoto: _fileFoto,
      fileMotivasi: _fileMotivasi,
      fileSktm: _fileSktm,
    );

    setState(() {
      _isLoading = false;
      if (error == null) {
        _isRevisi = false;
        _isReadOnly = true;
        _currentStep = 1;
      }
    });

    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
    } else {
      showSuccessSnackBar(context, 'Revisi berhasil dikirim ke Admin!');
    }
  }

  // --- WIDGET STATUS ---
  String _getStatusText(int step) {
    switch (step) {
      case 0:
        return 'Belum Melengkapi Formulir Online';
      case 1:
        return 'Tahap 2: Menunggu Verifikasi Dokumen';
      case 2:
        return 'Tahap 3: Menunggu Jadwal Wawancara';
      case 3:
        return 'Tahap 4: Menunggu Pengumuman Hasil Seleksi';
      case 4:
        return 'Tahap 5: Lolos - Menunggu Orientasi & TTD';
      case 5:
        return 'Tahap 6: Sedang Menjalani Pelatihan Vokasi';
      case 6:
        return 'Lulus Program Pelatihan Vernon Edu';
      default:
        return 'Belum Melengkapi Formulir';
    }
  }

  String? _getFileNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      return Uri.decodeComponent(uri.pathSegments.last);
    } catch (e) {
      return 'Dokumen Tersimpan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final user = SupabaseAuthService.currentUserData ?? {};

    if (_currentStep == 0) {
      return PortalLayout(
        activeMenu: 'status_beasiswa',
        content: Center(
          child: Text(
            "Anda belum mendaftar. Silakan isi Formulir Beasiswa terlebih dahulu.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
      );
    }

    return PortalLayout(
      activeMenu: 'status_beasiswa',
      content: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status & Detail Pendaftaran',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // KARTU STATUS
            // ==========================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 20 : 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Anda Saat Ini:',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getStatusText(_currentStep),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 6.0,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.blue.shade700,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // 👇 KARTU JADWAL WAWANCARA (MUNCUL JIKA TAHAP 2)
            // ==========================================
            if (_currentStep == 2 &&
                SupabaseAuthService.currentUserData?['jadwal_wawancara'] != null &&
                SupabaseAuthService.currentUserData!['jadwal_wawancara']
                    .toString()
                    .isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Jadwal Wawancara Anda",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Silakan hadir tepat waktu sesuai dengan jadwal yang telah ditentukan oleh tim Yayasan:",
                      style: TextStyle(color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              SupabaseAuthService.currentUserData!['jadwal_wawancara'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "* Catat jadwal ini di kalender Anda. Tautan Google Meet / Detail Lokasi biasanya dikirimkan juga melalui Email.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // ==========================================
            // ALERT REVISI (MUNCUL JIKA DIMINTA ADMIN)
            // ==========================================
            if (_isRevisi)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          "Catatan Verifikator",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _catatanRevisi.isEmpty
                          ? "Harap perbaiki data/dokumen Anda di bawah ini lalu kirim ulang."
                          : _catatanRevisi,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            // ==========================================
            // FORM DATA (READ-ONLY ATAU REVISI)
            // ==========================================
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Data Pendaftaran Anda",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField("Nama Lengkap", _nameController),
                    _buildTextField("NIK", _nikController, isNumber: true),
                    _buildTextField(
                      "Email Aktif",
                      _emailController,
                      readOnly: true,
                    ), // Email selalu read-only
                    _buildTextField(
                      "Nomor HP",
                      _phoneController,
                      isNumber: true,
                    ),

                    const Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "Alamat Domisili",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    _buildDropdownWilayah(
                      label: "Provinsi",
                      hint: "Pilih Provinsi",
                      items: _provinces,
                      value: _provinces.any((p) => '${p['id']}|${p['name']}' == _selectedProvinsi)
                          ? _selectedProvinsi
                          : null,
                      onChanged: _isReadOnly
                          ? null
                          : (val) {
                              setState(() {
                                _selectedProvinsi = val;
                                _selectedKota = null;
                                _selectedKecamatan = null;
                                _selectedKelurahan = null;
                                _regencies = [];
                                _districts = [];
                                _villages = [];
                              });
                              if (val != null) {
                                _loadRegencies(val.split('|')[0]);
                              }
                            },
                    ),

                    _buildDropdownWilayah(
                      label: "Kota / Kabupaten",
                      hint: _selectedProvinsi == null
                          ? "Pilih Provinsi Terlebih Dahulu"
                          : "Pilih Kota/Kabupaten",
                      items: _regencies,
                      value: _regencies.any((p) => '${p['id']}|${p['name']}' == _selectedKota)
                          ? _selectedKota
                          : null,
                      onChanged: _isReadOnly
                          ? null
                          : (val) {
                              setState(() {
                                _selectedKota = val;
                                _selectedKecamatan = null;
                                _selectedKelurahan = null;
                                _districts = [];
                                _villages = [];
                              });
                              if (val != null) {
                                _loadDistricts(val.split('|')[0]);
                              }
                            },
                    ),

                    _buildDropdownWilayah(
                      label: "Kecamatan",
                      hint: _selectedKota == null
                          ? "Pilih Kota Terlebih Dahulu"
                          : "Pilih Kecamatan",
                      items: _districts,
                      value: _districts.any((p) => '${p['id']}|${p['name']}' == _selectedKecamatan)
                          ? _selectedKecamatan
                          : null,
                      onChanged: _isReadOnly
                          ? null
                          : (val) {
                              setState(() {
                                _selectedKecamatan = val;
                                _selectedKelurahan = null;
                                _villages = [];
                              });
                              if (val != null) {
                                _loadVillages(val.split('|')[0]);
                              }
                            },
                    ),

                    _buildDropdownWilayah(
                      label: "Kelurahan / Desa",
                      hint: _selectedKecamatan == null
                          ? "Pilih Kecamatan Terlebih Dahulu"
                          : "Pilih Kelurahan/Desa",
                      items: _villages,
                      value: _villages.any((p) => '${p['id']}|${p['name']}' == _selectedKelurahan)
                          ? _selectedKelurahan
                          : null,
                      onChanged: _isReadOnly
                          ? null
                          : (val) {
                              setState(() {
                                _selectedKelurahan = val;
                              });
                            },
                    ),

                    _buildTextField(
                      "Detail Jalan & RT/RW",
                      _detailAlamatController,
                    ),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 30),

                    const Text(
                      "Riwayat Pendidikan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildDropdownPendidikan(),
                    _buildTextField("Asal Sekolah", _asalSekolahController),
                    _buildTextField(
                      "Tahun Lulus",
                      _tahunLulusController,
                      isNumber: true,
                    ),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 30),

                    // ==========================================
                    // BAGIAN DOKUMEN
                    // ==========================================
                    const Text(
                      "Dokumen Pendukung Tersimpan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildFileUploadField(
                      label: "Fotokopi KTP / Kartu Pelajar (Wajib)",
                      hint: "Pilih file KTP...",
                      fileName: _fileKtp?.name ?? _getFileNameFromUrl(user['file_ktp']),
                      fileUrl: _fileKtp == null ? user['file_ktp'] : null,
                      onTap: () => _pickFile('ktp'),
                    ),
                    _buildFileUploadField(
                      label: "Fotokopi Ijazah / SKL Terakhir (Wajib)",
                      hint: "Pilih file Ijazah/SKL...",
                      fileName: _fileIjazah?.name ?? _getFileNameFromUrl(user['file_rapor']),
                      fileUrl: _fileIjazah == null ? user['file_rapor'] : null,
                      onTap: () => _pickFile('ijazah'),
                    ),
                    _buildFileUploadField(
                      label: "Pas Foto 3x4 Terbaru (Wajib)",
                      hint: "Pilih file Pas Foto...",
                      fileName: _fileFoto?.name ?? _getFileNameFromUrl(user['file_foto']),
                      fileUrl: _fileFoto == null ? user['file_foto'] : null,
                      onTap: () => _pickFile('foto'),
                    ),
                    _buildFileUploadField(
                      label: "Surat Motivasi Tulis Tangan (Wajib)",
                      hint: "Pilih file Surat Motivasi...",
                      fileName: _fileMotivasi?.name ?? _getFileNameFromUrl(user['file_motivasi']),
                      fileUrl: _fileMotivasi == null ? user['file_motivasi'] : null,
                      onTap: () => _pickFile('motivasi'),
                    ),
                    _buildFileUploadField(
                      label: "Surat Keterangan Tidak Mampu / SKTM (Wajib)",
                      hint: "Pilih file SKTM...",
                      fileName: _fileSktm?.name ?? _getFileNameFromUrl(user['file_sktm']),
                      fileUrl: _fileSktm == null ? user['file_sktm'] : null,
                      onTap: () => _pickFile('sktm'),
                    ),

                    if (!_isReadOnly) ...[
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRevisi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "KIRIM ULANG REVISI",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BANTUAN UI
  // ==========================================

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool readOnly = false,
  }) {
    bool isFieldReadOnly = _isReadOnly || readOnly;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: isFieldReadOnly,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            style: TextStyle(
              color: isFieldReadOnly ? Colors.black54 : Colors.black87,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isFieldReadOnly
                      ? Colors.transparent
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isFieldReadOnly
                      ? Colors.transparent
                      : AppColors.primary,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: isFieldReadOnly ? Colors.grey.shade100 : Colors.white,
            ),
            validator: isFieldReadOnly
                ? null
                : (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label tidak boleh kosong';
                    }
                    return null;
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownWilayah({
    required String label,
    required String hint,
    required List<Map<String, dynamic>> items,
    required String? value,
    required ValueChanged<String?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isReadOnly
                      ? Colors.transparent
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isReadOnly ? Colors.transparent : AppColors.primary,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: _isReadOnly
                  ? Colors.grey.shade100
                  : (items.isEmpty ? Colors.grey.shade100 : Colors.white),
            ),
            hint: Text(
              hint,
              style: TextStyle(
                color: _isReadOnly ? Colors.black54 : Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: _isReadOnly ? Colors.transparent : Colors.grey.shade700,
            ),
            items: items.isEmpty
                ? null
                : items.map((item) {
                    final valStr = '${item['id']}|${item['name']}';
                    return DropdownMenuItem(
                      value: valStr,
                      child: Text(item['name'] ?? ''),
                    );
                  }).toList(),
            onChanged: onChanged,
            validator: _isReadOnly
                ? null
                : (val) => val == null ? '$label harus dipilih' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPendidikan() {
    List<String> pItems = ["SD", "SMP", "SMA"];
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pendidikan Terakhir",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: pItems.contains(_selectedPendidikan)
                ? _selectedPendidikan
                : null,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isReadOnly
                      ? Colors.transparent
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isReadOnly ? Colors.transparent : AppColors.primary,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: _isReadOnly ? Colors.grey.shade100 : Colors.white,
            ),
            hint: const Text("-- Pilih Pendidikan --"),
            icon: Icon(
              Icons.arrow_drop_down,
              color: _isReadOnly ? Colors.transparent : Colors.grey.shade700,
            ),
            items: const [
              DropdownMenuItem(value: "SD", child: Text("SD / Sederajat")),
              DropdownMenuItem(value: "SMP", child: Text("SMP / Sederajat")),
              DropdownMenuItem(
                value: "SMA",
                child: Text("SMA / SMK / Sederajat"),
              ),
            ],
            onChanged: _isReadOnly
                ? null
                : (value) => setState(() => _selectedPendidikan = value),
            validator: _isReadOnly
                ? null
                : (value) => value == null
                      ? 'Pendidikan Terakhir harus dipilih'
                      : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadField({
    required String label,
    required String hint,
    required String? fileName,
    String? fileUrl,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _isReadOnly ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isReadOnly ? Colors.transparent : Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isReadOnly ? Icons.insert_drive_file : Icons.upload_file_rounded,
                  color: fileName != null
                      ? (_isReadOnly ? Colors.blue : AppColors.primary)
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    fileName ?? hint,
                    style: TextStyle(
                      color: fileName != null
                          ? (_isReadOnly ? Colors.black54 : Colors.black87)
                          : Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: fileName != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (fileUrl != null) ...[
                  InkWell(
                    onTap: () async {
                      final uri = Uri.tryParse(fileUrl);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new, size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            "Buka",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (fileName != null && fileUrl == null)
                  const Icon(Icons.check_circle, color: Colors.green, size: 22)
                else if (!_isReadOnly)
                  InkWell(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        fileUrl != null ? "Ganti File" : "Pilih File",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
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
