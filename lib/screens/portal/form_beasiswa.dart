import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:file_picker/file_picker.dart'; // 👇 Tambahkan import ini
import '../../core/app_colors.dart';
import 'portal_layout.dart'; 
import '../../data/mock_database.dart';

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

  // State untuk menyimpan nama file yang diunggah
  String? _fileNameKtp;
  String? _fileNameIjazah;
  String? _fileNameSktm;
  String? _fileNameFoto;
  String? _fileNameMotivasi;

  bool _isLoading = false;

  // DATA DUMMY WILAYAH INDONESIA
  final Map<String, Map<String, List<String>>> _dataWilayah = {
    "Jawa Timur": {
      "Kota Malang": ["Lowokwaru", "Blimbing", "Klojen", "Sukun", "Kedungkandang"],
      "Kabupaten Malang": ["Singosari", "Kepanjen", "Lawang", "Pakis", "Dau", "Karangploso"],
      "Kota Surabaya": ["Gubeng", "Tegalsari", "Sukolilo", "Wonokromo"],
    },
    "Jawa Barat": {
      "Kota Bandung": ["Coblong", "Cidadap", "Andir", "Buahbatu"],
      "Kota Bogor": ["Bogor Tengah", "Bogor Timur", "Bogor Utara"],
    },
    "DKI Jakarta": {
      "Jakarta Selatan": ["Tebet", "Setiabudi", "Kebayoran Baru", "Pancoran"],
      "Jakarta Pusat": ["Menteng", "Tanah Abang", "Senen", "Cempaka Putih"],
    }
  };

  @override
  void initState() {
    super.initState();
    final user = MockDatabase.currentUser ?? {};
    
    _nameController = TextEditingController(text: user['name'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _phoneController = TextEditingController(text: user['telepon'] ?? user['whatsapp'] ?? '');
    
    if (user['pendidikan'] != null && ["SD", "SMP", "SMA"].contains(user['pendidikan'])) {
      _selectedPendidikan = user['pendidikan'];
    }
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

  // 👇 FUNGSI UNTUK MEMILIH FILE DARI PERANGKAT
  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        String fileName = result.files.first.name;
        switch (type) {
          case 'ktp': _fileNameKtp = fileName; break;
          case 'ijazah': _fileNameIjazah = fileName; break;
          case 'foto': _fileNameFoto = fileName; break;
          case 'motivasi': _fileNameMotivasi = fileName; break;
          case 'sktm': _fileNameSktm = fileName; break;
        }
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || 
        _selectedProvinsi == null ||
        _selectedKota == null ||
        _selectedKecamatan == null ||
        _fileNameKtp == null || 
        _fileNameIjazah == null ||
        _fileNameFoto == null ||
        _fileNameMotivasi == null ||
        _fileNameSktm == null) { 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Mohon periksa kembali. Ada data wajib atau dokumen yang belum lengkap.')),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating, 
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (MockDatabase.currentUser != null) {
      MockDatabase.currentUser!['name'] = _nameController.text.toUpperCase();
      MockDatabase.currentUser!['telepon'] = _phoneController.text;
      
      String domisiliLengkap = '${_detailAlamatController.text}, Kec. $_selectedKecamatan, $_selectedKota, $_selectedProvinsi';
      MockDatabase.currentUser!['domisili'] = domisiliLengkap;
      
      MockDatabase.currentUser!['pendidikan'] = _selectedPendidikan;
      MockDatabase.currentUser!['nik'] = _nikController.text;
      MockDatabase.currentUser!['asal_sekolah'] = _asalSekolahController.text;
      MockDatabase.currentUser!['tahun_lulus'] = _tahunLulusController.text;
      
      // 👇 SIMPAN NAMA FILE KE DATABASE
      MockDatabase.currentUser!['file_ktp'] = _fileNameKtp;
      MockDatabase.currentUser!['file_rapor'] = _fileNameIjazah;
      MockDatabase.currentUser!['file_foto'] = _fileNameFoto;
      MockDatabase.currentUser!['file_motivasi'] = _fileNameMotivasi;
      MockDatabase.currentUser!['file_sktm'] = _fileNameSktm;

      MockDatabase.currentUser!['tgl_daftar'] = DateTime.now().toIso8601String();
      
      MockDatabase.currentUser!['is_registered'] = true;
      MockDatabase.currentUser!['current_step'] = 1; 
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    
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
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDatabase.currentUser ?? {};
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
                  style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => context.go('/status-beasiswa'),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text("Lihat Status Beasiswa", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
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
              style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold),
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
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
                    
                    _buildTextField("Nama Lengkap", "Sesuai KTP / Kartu Pelajar", _nameController),
                    _buildTextField("Nomor Induk Kependudukan (NIK)", "16 Digit NIK", _nikController, isNumber: true),
                    _buildTextField("Email Aktif", "contoh@email.com", _emailController, isEmail: true, readOnly: true),
                    _buildTextField("Nomor HP / WhatsApp Aktif", "08xxxxxxxxxx", _phoneController, isPhone: true),
                    
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text("Alamat Domisili", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    
                    _buildDropdownWilayah(
                      label: "Provinsi",
                      hint: "Pilih Provinsi",
                      items: _dataWilayah.keys.toList(),
                      value: _selectedProvinsi,
                      onChanged: (val) {
                        setState(() {
                          _selectedProvinsi = val;
                          _selectedKota = null; 
                          _selectedKecamatan = null; 
                        });
                      },
                    ),
                    
                    _buildDropdownWilayah(
                      label: "Kota / Kabupaten",
                      hint: _selectedProvinsi == null ? "Pilih Provinsi Terlebih Dahulu" : "Pilih Kota/Kabupaten",
                      items: _selectedProvinsi != null ? _dataWilayah[_selectedProvinsi]!.keys.toList() : [],
                      value: _selectedKota,
                      onChanged: (val) {
                        setState(() {
                          _selectedKota = val;
                          _selectedKecamatan = null; 
                        });
                      },
                    ),
                    
                    _buildDropdownWilayah(
                      label: "Kecamatan",
                      hint: _selectedKota == null ? "Pilih Kota Terlebih Dahulu" : "Pilih Kecamatan",
                      items: _selectedKota != null ? _dataWilayah[_selectedProvinsi]![_selectedKota]! : [],
                      value: _selectedKecamatan,
                      onChanged: (val) {
                        setState(() {
                          _selectedKecamatan = val;
                        });
                      },
                    ),

                    _buildTextField("Detail Jalan & RT/RW", "Contoh: Jl. Soekarno Hatta No.9, RT 01/RW 02", _detailAlamatController),

                    const SizedBox(height: 40),
                    const Divider(color: Colors.black12), 
                    const SizedBox(height: 40),

                    // ==========================================
                    // SECTION 2: RIWAYAT PENDIDIKAN
                    // ==========================================
                    _buildSectionTitle("2", "Riwayat Pendidikan"), 
                    const SizedBox(height: 20),

                    _buildDropdownPendidikan(),
                    _buildTextField("Asal Sekolah", "Nama SMP / SMA / SMK", _asalSekolahController),
                    _buildTextField("Tahun Lulus", "Contoh: 2024", _tahunLulusController, isNumber: true),

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
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 25),
                    
                    _buildFileUploadField(
                      label: "Fotokopi KTP / Kartu Pelajar (Wajib)", 
                      hint: "Pilih file KTP...", 
                      fileName: _fileNameKtp, 
                      onTap: () => _pickFile('ktp'), // 👇 Diubah ke _pickFile
                    ),
                    _buildFileUploadField(
                      label: "Fotokopi Ijazah / SKL Terakhir (Wajib)", 
                      hint: "Pilih file Ijazah/SKL...", 
                      fileName: _fileNameIjazah, 
                      onTap: () => _pickFile('ijazah'), // 👇 Diubah ke _pickFile
                    ),
                    _buildFileUploadField(
                      label: "Pas Foto 3x4 Terbaru (Wajib)", 
                      hint: "Pilih file Pas Foto...", 
                      fileName: _fileNameFoto, 
                      onTap: () => _pickFile('foto'), // 👇 Diubah ke _pickFile
                    ),
                    _buildFileUploadField(
                      label: "Surat Motivasi Tulis Tangan (Wajib)", 
                      hint: "Pilih file Surat Motivasi...", 
                      fileName: _fileNameMotivasi, 
                      onTap: () => _pickFile('motivasi'), // 👇 Diubah ke _pickFile
                    ),
                    _buildFileUploadField(
                      label: "Surat Keterangan Tidak Mampu / SKTM (Wajib)", 
                      hint: "Pilih file SKTM...", 
                      fileName: _fileNameSktm, 
                      onTap: () => _pickFile('sktm'), // 👇 Diubah ke _pickFile
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "KIRIM PENDAFTARAN",
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
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
          width: 35, height: 35,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(number, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(
    String label, 
    String hint, 
    TextEditingController controller, 
    {bool isEmail = false, bool isPhone = false, bool isNumber = false, bool readOnly = false}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: isEmail ? TextInputType.emailAddress : ((isPhone || isNumber) ? TextInputType.number : TextInputType.text),
            style: TextStyle(color: readOnly ? Colors.grey.shade700 : Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: readOnly ? Colors.grey.shade300 : AppColors.primary, width: 1.5)),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return '$label tidak boleh kosong';
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
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              filled: true, fillColor: items.isEmpty ? Colors.grey.shade100 : Colors.grey.shade50,
            ),
            hint: Text(hint, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            items: items.isEmpty ? null : items.map((String item) {
              return DropdownMenuItem(value: item, child: Text(item));
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
          const Text("Pendidikan Terakhir", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPendidikan,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              filled: true, fillColor: Colors.grey.shade50,
            ),
            hint: const Text("-- Pilih Pendidikan --"),
            items: const [
              DropdownMenuItem(value: "SD", child: Text("SD / Sederajat")),
              DropdownMenuItem(value: "SMP", child: Text("SMP / Sederajat")),
              DropdownMenuItem(value: "SMA", child: Text("SMA / SMK / Sederajat")),
            ],
            onChanged: (value) => setState(() => _selectedPendidikan = value),
            validator: (value) => value == null ? 'Pendidikan Terakhir harus dipilih' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadField({
    required String label, 
    required String hint, 
    required String? fileName, 
    required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.upload_file_rounded, color: fileName != null ? AppColors.primary : Colors.grey.shade400),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      fileName ?? hint,
                      style: TextStyle(
                        color: fileName != null ? Colors.black87 : Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: fileName != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fileName != null)
                    const Icon(Icons.check_circle, color: Colors.green, size: 22)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                      child: const Text("Pilih File", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTahapanSeleksi(bool isMobile) {
    final List<Map<String, String>> tahapan = [
      {"step": "1", "title": "Pengisian Formulir Online", "desc": "Isi data diri lengkap melalui website VIP. Lampirkan foto dokumen persyaratan."},
      {"step": "2", "title": "Verifikasi Dokumen & Kelayakan", "desc": "Tim VIP memverifikasi kelengkapan dokumen dan kesesuaian kriteria usia serta ekonomi."},
      {"step": "3", "title": "Wawancara Langsung", "desc": "Tahap penentu kelulusan. Tim yayasan menilai langsung kemampuan, karakter, dan kesungguhan calon."},
      {"step": "4", "title": "Pengumuman Hasil Seleksi", "desc": "Hasil diumumkan melalui website. Calon yang lolos menerima Surat Penetapan Beasiswa resmi."},
      {"step": "5", "title": "Orientasi & Penandatanganan", "desc": "Sesi orientasi dan penandatanganan komitmen mengikuti pelatihan hingga penempatan kerja."},
      {"step": "6", "title": "Mulai Pelatihan Vokasi", "desc": "Pelatihan intensif 10 bulan di Vernon Edu (keterampilan barista, digital marketing, dll)."},
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
              Text("Alur Pendaftaran & Seleksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
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
                    radius: 14, backgroundColor: Colors.blue,
                    child: Text(tahapan[index]["step"]!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tahapan[index]["title"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                        const SizedBox(height: 5),
                        Text(tahapan[index]["desc"]!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
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