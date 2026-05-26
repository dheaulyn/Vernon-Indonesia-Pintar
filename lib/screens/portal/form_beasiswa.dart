import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_colors.dart';
import '../../core/snackbar_helper.dart';
import 'portal_layout.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/supabase_pendaftaran_service.dart';
import '../../services/api_wilayah_service.dart';

class FormBeasiswaScreen extends StatefulWidget {
  const FormBeasiswaScreen({super.key});

  @override
  State<FormBeasiswaScreen> createState() => _FormBeasiswaScreenState();
}

class _FormBeasiswaScreenState extends State<FormBeasiswaScreen> {
  final _formKey = GlobalKey<FormState>();

  // ==========================================
  // CONTROLLER FORM
  // ==========================================
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _detailAlamatController = TextEditingController();

  final _nikController = TextEditingController();
  final _asalSekolahController = TextEditingController();
  final _tahunLulusController = TextEditingController();

  String? _selectedPendidikan;
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _regencies = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _villages = [];


  // State untuk menyimpan objek file yang diunggah
  PlatformFile? _fileKtp;
  PlatformFile? _fileIjazah;
  PlatformFile? _fileSktm;
  PlatformFile? _fileFoto;
  PlatformFile? _fileMotivasi;

  // 👇 VARIABEL STATE BARU UNTUK VALIDASI DOKUMEN
  bool _hasAttemptedSubmit = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    final user = SupabaseAuthService.currentUserData ?? {};

    _nameController = TextEditingController(text: user['name'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _phoneController = TextEditingController(
      text: user['telepon'] ?? user['whatsapp'] ?? '',
    );

    if (user['pendidikan'] != null &&
        ["SD", "SMP", "SMA"].contains(user['pendidikan'])) {
      _selectedPendidikan = user['pendidikan'];
    }
  }

  Future<void> _loadProvinces() async {
    final data = await ApiWilayahService.getProvinces();
    setState(() {
      _provinces = data;
    });
  }

  Future<void> _loadRegencies(String provinceId) async {
    final data = await ApiWilayahService.getRegencies(provinceId);
    setState(() {
      _regencies = data;
    });
  }

  Future<void> _loadDistricts(String regencyId) async {
    final data = await ApiWilayahService.getDistricts(regencyId);
    setState(() {
      _districts = data;
    });
  }

  Future<void> _loadVillages(String districtId) async {
    final data = await ApiWilayahService.getVillages(districtId);
    setState(() {
      _villages = data;
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
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // IMPORTANT for web to get bytes
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;

      // VALIDASI UKURAN FILE MAKSIMAL 2MB (2 * 1024 * 1024 bytes)
      if (file.size > 2 * 1024 * 1024) {
        if (mounted) {
          showErrorSnackBar(context, 'Ukuran file maksimal 2MB. Silakan kompres atau pilih file lain.');
        }
        return;
      }

      setState(() {
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

  void _submitForm() async {
    setState(() {
      _hasAttemptedSubmit = true; // Tandai bahwa user sudah mencoba submit
    });

    if (!_formKey.currentState!.validate() ||
        _selectedProvinsi == null ||
        _selectedKota == null ||
        _selectedKecamatan == null ||
        _selectedKelurahan == null ||
        _fileKtp == null ||
        _fileIjazah == null ||
        _fileFoto == null ||
        _fileMotivasi == null ||
        _fileSktm == null) {
      showErrorSnackBar(context, 'Mohon periksa kembali. Ada data wajib atau dokumen yang belum lengkap.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String getWilayahName(String? value) {
      if (value == null) return '';
      final parts = value.split('|');
      return parts.length > 1 ? parts[1] : value;
    }

    String provName = getWilayahName(_selectedProvinsi);
    String kotaName = getWilayahName(_selectedKota);
    String kecName = getWilayahName(_selectedKecamatan);
    String kelName = getWilayahName(_selectedKelurahan);

    // Gabungkan domisili lengkap
    String domisiliLengkap =
        '${_detailAlamatController.text}, Kel. $kelName, Kec. $kecName, $kotaName, $provName';

    // Kirim data pendaftaran ke Supabase
    final error = await SupabasePendaftaranService.submitPendaftaran(
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
    });

    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(30),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Pengiriman Berhasil!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              "Berkas pendaftaran dan dokumen pendukung Anda telah berhasil diterima. Silakan pantau status seleksi Anda melalui menu Status Beasiswa.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/portal');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Tutup",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseAuthService.currentUserData ?? {};
    final int currentStep = user['current_step'] ?? 0;
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    if (currentStep > 0) {
      return PortalLayout(
        activeMenu: 'form_beasiswa',
        content: Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Anda Sudah Mendaftar!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Berkas pendaftaran Anda sedang dalam proses. Silakan gunakan menu Status Beasiswa untuk memantau perkembangan, melihat riwayat data, atau melakukan revisi dokumen.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => context.go('/status-beasiswa'),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text(
                    "Lihat Status Beasiswa",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PortalLayout(
      activeMenu: 'form_beasiswa',
      content: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formulir Pendaftaran Beasiswa',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lengkapi data di bawah ini dengan jujur dan unggah dokumen pendukung Anda.',
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 30),

            _buildTahapanSeleksi(isMobile),
            const SizedBox(height: 30),

            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // SECTION 1: DATA DIRI & KONTAK
                    // ==========================================
                    _buildSectionTitle("1", "Data Diri & Kontak"),
                    const SizedBox(height: 20),

                    _buildTextField(
                      "Nama Lengkap",
                      "Sesuai KTP / Kartu Pelajar",
                      _nameController,
                    ),
                    _buildTextField(
                      "Nomor Induk Kependudukan (NIK)",
                      "16 Digit NIK",
                      _nikController,
                      isNumber: true,
                      maxLength: 16,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'NIK tidak boleh kosong';
                        if (v.length != 16) return 'NIK harus tepat 16 digit';
                        return null;
                      },
                    ),
                    _buildTextField(
                      "Email Aktif",
                      "contoh@email.com",
                      _emailController,
                      isEmail: true,
                      readOnly: true,
                    ),
                    _buildTextField(
                      "Nomor Telepon",
                      "Contoh: 08123456789",
                      _phoneController,
                      isPhone: true,
                      maxLength: 14,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Nomor HP tidak boleh kosong';
                        if (v.length < 10 || v.length > 14) return 'Nomor HP tidak valid (10-14 digit)';
                        return null;
                      },
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
                      value: _selectedProvinsi,
                      onChanged: (val) {
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
                          final id = val.split('|')[0];
                          _loadRegencies(id);
                        }
                      },
                    ),

                    _buildDropdownWilayah(
                      label: "Kota / Kabupaten",
                      hint: _selectedProvinsi == null
                          ? "Pilih Provinsi Terlebih Dahulu"
                          : "Pilih Kota/Kabupaten",
                      items: _regencies,
                      value: _selectedKota,
                      onChanged: (val) {
                        setState(() {
                          _selectedKota = val;
                          _selectedKecamatan = null;
                          _selectedKelurahan = null;
                          _districts = [];
                          _villages = [];
                        });
                        if (val != null) {
                          final id = val.split('|')[0];
                          _loadDistricts(id);
                        }
                      },
                    ),

                    _buildDropdownWilayah(
                      label: "Kecamatan",
                      hint: _selectedKota == null
                          ? "Pilih Kota Terlebih Dahulu"
                          : "Pilih Kecamatan",
                      items: _districts,
                      value: _selectedKecamatan,
                      onChanged: (val) {
                        setState(() {
                          _selectedKecamatan = val;
                          _selectedKelurahan = null;
                          _villages = [];
                        });
                        if (val != null) {
                          final id = val.split('|')[0];
                          _loadVillages(id);
                        }
                      },
                    ),

                    _buildDropdownWilayah(
                      label: "Kelurahan / Desa",
                      hint: _selectedKecamatan == null
                          ? "Pilih Kecamatan Terlebih Dahulu"
                          : "Pilih Kelurahan/Desa",
                      items: _villages,
                      value: _selectedKelurahan,
                      onChanged: (val) {
                        setState(() {
                          _selectedKelurahan = val;
                        });
                      },
                    ),

                    _buildTextField(
                      "Detail Jalan & RT/RW",
                      "Contoh: Jl. Soekarno Hatta No.9, RT 01/RW 02",
                      _detailAlamatController,
                    ),

                    const SizedBox(height: 40),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 40),

                    // ==========================================
                    // SECTION 2: RIWAYAT PENDIDIKAN
                    // ==========================================
                    _buildSectionTitle("2", "Riwayat Pendidikan"),
                    const SizedBox(height: 20),

                    _buildDropdownPendidikan(),
                    _buildTextField(
                      "Asal Sekolah",
                      "Nama SMP / SMA / SMK",
                      _asalSekolahController,
                    ),
                    _buildTextField(
                      "Tahun Lulus",
                      "Contoh: 2024",
                      _tahunLulusController,
                      isNumber: true,
                      maxLength: 4,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Tahun Lulus tidak boleh kosong';
                        if (v.length != 4) return 'Tahun Lulus harus 4 digit';
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 40),

                    // ==========================================
                    // SECTION 3: UNGGAH BERKAS DOKUMEN
                    // ==========================================
                    _buildSectionTitle("3", "Unggah Berkas Dokumen"),
                    const SizedBox(height: 10),
                    Text(
                      "Pastikan berkas dapat dibaca dengan jelas. Format yang didukung: PDF/JPG/PNG (Maks 2MB).",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildFileUploadField(
                      label: "Fotokopi KTP / Kartu Pelajar (Wajib)",
                      hint: "Pilih file KTP...",
                      fileName: _fileKtp?.name,
                      onTap: () => _pickFile('ktp'),
                    ),
                    _buildFileUploadField(
                      label: "Fotokopi Ijazah / SKL Terakhir (Wajib)",
                      hint: "Pilih file Ijazah/SKL...",
                      fileName: _fileIjazah?.name,
                      onTap: () => _pickFile('ijazah'),
                    ),
                    _buildFileUploadField(
                      label: "Pas Foto 3x4 Terbaru (2 lembar) (Wajib)",
                      hint: "Pilih file Pas Foto...",
                      fileName: _fileFoto?.name,
                      onTap: () => _pickFile('foto'),
                    ),
                    _buildFileUploadField(
                      label: "Surat Motivasi Tulis Tangan (1 halaman) (Wajib)",
                      hint: "Pilih file Surat Motivasi...",
                      fileName: _fileMotivasi?.name,
                      onTap: () => _pickFile('motivasi'),
                    ),
                    _buildFileUploadField(
                      label: "Surat Keterangan Tidak Mampu / SKTM (Wajib)",
                      hint: "Pilih file SKTM...",
                      fileName: _fileSktm?.name,
                      onTap: () => _pickFile('sktm'),
                    ),

                    const SizedBox(height: 40),

                    // ==========================================
                    // TOMBOL SUBMIT
                    // ==========================================
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "KIRIM PENDAFTARAN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
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

  Widget _buildSectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isEmail = false,
    bool isPhone = false,
    bool isNumber = false,
    bool readOnly = false,
    int? maxLength,
    String? Function(String?)? validator,
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
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : ((isPhone || isNumber)
                      ? TextInputType.number
                      : TextInputType.text),
            inputFormatters: [
              if (isPhone || isNumber) FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
            ],
            style: TextStyle(
              color: readOnly ? Colors.grey.shade700 : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: readOnly ? Colors.grey.shade300 : AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade50,
            ),
            validator: validator ?? (value) {
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
    required ValueChanged<String?> onChanged,
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
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: items.isEmpty
                  ? Colors.grey.shade100
                  : Colors.grey.shade50,
            ),
            hint: Text(
              hint,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            items: items.isEmpty
                ? null
                : items.map((item) {
                    final valStr = '${item['id']}|${item['name']}';
                    return DropdownMenuItem(
                      value: valStr,
                      child: Text(item['name'] ?? ''),
                    );
                  }).toList(),
            onChanged: items.isEmpty ? null : onChanged,
            validator: (val) => val == null ? '$label harus dipilih' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPendidikan() {
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
            initialValue: _selectedPendidikan,
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
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            hint: const Text("-- Pilih Pendidikan --"),
            items: const [
              DropdownMenuItem(value: "SD", child: Text("SD / Sederajat")),
              DropdownMenuItem(value: "SMP", child: Text("SMP / Sederajat")),
              DropdownMenuItem(
                value: "SMA",
                child: Text("SMA / SMK / Sederajat"),
              ),
            ],
            onChanged: (value) => setState(() => _selectedPendidikan = value),
            validator: (value) =>
                value == null ? 'Pendidikan Terakhir harus dipilih' : null,
          ),
        ],
      ),
    );
  }

  // 👇 PERBAIKAN WIDGET FILE UPLOAD DENGAN VALIDASI VISUAL
  Widget _buildFileUploadField({
    required String label,
    required String hint,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    // Cek apakah file kosong dan user sudah pernah klik "Kirim Pendaftaran"
    bool hasError =
        _hasAttemptedSubmit && (fileName == null || fileName.isEmpty);

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
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: hasError ? Colors.red.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                // 👇 Border menjadi merah jika hasError true
                border: Border.all(
                  color: hasError ? Colors.redAccent : Colors.grey.shade300,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.upload_file_rounded,
                    color: fileName != null
                        ? AppColors.primary
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      fileName ?? hint,
                      style: TextStyle(
                        color: fileName != null
                            ? Colors.black87
                            : Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: fileName != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fileName != null)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 22,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Pilih File",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 👇 Munculkan pesan error (teks merah) di bawah box jika belum diisi
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Text(
                "Dokumen ini wajib diunggah",
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTahapanSeleksi(bool isMobile) {
    final List<Map<String, String>> tahapan = [
      {
        "step": "1",
        "title": "Pengisian formulir pendaftaran online",
        "desc":
            "Isi data diri lengkap melalui website VIP. Lampirkan foto dokumen persyaratan.",
      },
      {
        "step": "2",
        "title": "Verifikasi dokumen & kelayakan administrasi",
        "desc":
            "Tim VIP memverifikasi kelengkapan dokumen dan kesesuaian kriteria usia serta ekonomi.",
      },
      {
        "step": "3",
        "title": "Wawancara langsung dengan tim yayasan",
        "desc":
            "Tahap penentu kelulusan seleksi. Tim yayasan menilai secara langsung kemampuan, karakter, dan kesungguhan calon penerima.",
      },
      {
        "step": "4",
        "title": "Pengumuman hasil seleksi",
        "desc":
            "Hasil seleksi diumumkan melalui website VIP. Calon penerima yang lolos menerima Surat Penetapan Beasiswa resmi.",
      },
      {
        "step": "5",
        "title": "Orientasi & penandatanganan perjanjian",
        "desc":
            "Penerima beasiswa menghadiri sesi orientasi dan menandatangani surat komitmen mengikuti pelatihan hingga penempatan kerja.",
      },
      {
        "step": "6",
        "title": "Mulai pelatihan vokasi di Vernon Edu",
        "desc":
            "Program resmi dimulai. Pelatihan intensif 10 bulan mencakup keterampilan barista, digital marketing, administrasi, atau bidang lain sesuai minat & kebutuhan industri.",
      },
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                "Alur Pendaftaran & Seleksi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ...List.generate(tahapan.length, (index) {
            bool isLast = index == tahapan.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue,
                    child: Text(
                      tahapan[index]["step"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tahapan[index]["title"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          tahapan[index]["desc"]!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
