import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_colors.dart';
import 'portal_layout.dart'; 
import '../../data/mock_database.dart';

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
  
  final _nikController = TextEditingController();
  final _asalSekolahController = TextEditingController();
  final _tahunLulusController = TextEditingController();
  
  String? _selectedPendidikan;
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;

  String? _fileNameKtp;
  String? _fileNameIjazah;
  String? _fileNameSktm;
  String? _fileNameFoto;
  String? _fileNameMotivasi;

  bool _isLoading = false;
  bool _isReadOnly = true;
  bool _isRevisi = false;
  String _catatanRevisi = '';
  int _currentStep = 0;

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
    
    _currentStep = user['current_step'] ?? 0;
    _isRevisi = user['is_revisi'] == true;
    _catatanRevisi = user['catatan_revisi'] ?? '';
    
    // Form bisa diedit JIKA dalam mode revisi
    _isReadOnly = !_isRevisi;

    _nameController = TextEditingController(text: user['name'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _phoneController = TextEditingController(text: user['telepon'] ?? '');
    _nikController.text = user['nik'] ?? '';
    _asalSekolahController.text = user['asal_sekolah'] ?? '';
    _tahunLulusController.text = user['tahun_lulus'] ?? '';
    
    if (user['pendidikan'] != null && ["SD", "SMP", "SMA"].contains(user['pendidikan'])) {
      _selectedPendidikan = user['pendidikan'];
    }

    // PEMECAH STRING DOMISILI CERDAS & AMAN
    String domisili = user['domisili'] ?? '';
    List<String> parts = domisili.split(', ');
    if (parts.length >= 4) {
      _selectedProvinsi = parts.last;
      _selectedKota = parts[parts.length - 2];
      _selectedKecamatan = parts[parts.length - 3].replaceAll('Kec. ', '');
      _detailAlamatController.text = parts.sublist(0, parts.length - 3).join(', ');
    } else {
      _detailAlamatController.text = domisili;
    }

    // Muat data file yang sudah pernah diunggah
    if (_currentStep > 0) {
      _fileNameKtp = user['file_ktp'];
      _fileNameIjazah = user['file_rapor'];
      _fileNameFoto = user['file_foto'];
      _fileNameMotivasi = user['file_motivasi'];
      _fileNameSktm = user['file_sktm'];
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

  // 👇 FUNGSI UNTUK MEMILIH FILE DARI PERANGKAT (KHUSUS SAAT REVISI)
  Future<void> _pickFile(String type) async {
    if (_isReadOnly) return;

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

  void _submitRevisi() async {
    // Validasi Wajib
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
          content: Text('Mohon periksa kembali. Semua data dan dokumen wajib diisi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (MockDatabase.currentUser != null) {
      MockDatabase.currentUser!['name'] = _nameController.text.toUpperCase();
      MockDatabase.currentUser!['telepon'] = _phoneController.text;
      
      // Menggabungkan kembali string domisili
      String domisiliLengkap = '${_detailAlamatController.text}, Kec. $_selectedKecamatan, $_selectedKota, $_selectedProvinsi';
      MockDatabase.currentUser!['domisili'] = domisiliLengkap;
      
      MockDatabase.currentUser!['pendidikan'] = _selectedPendidikan;
      MockDatabase.currentUser!['nik'] = _nikController.text;
      MockDatabase.currentUser!['asal_sekolah'] = _asalSekolahController.text;
      MockDatabase.currentUser!['tahun_lulus'] = _tahunLulusController.text;

      // 👇 SIMPAN NAMA FILE REVISI KE DATABASE
      MockDatabase.currentUser!['file_ktp'] = _fileNameKtp;
      MockDatabase.currentUser!['file_rapor'] = _fileNameIjazah;
      MockDatabase.currentUser!['file_foto'] = _fileNameFoto;
      MockDatabase.currentUser!['file_motivasi'] = _fileNameMotivasi;
      MockDatabase.currentUser!['file_sktm'] = _fileNameSktm;
      
      // Panggil fungsi resmi dari MockDatabase
      MockDatabase.submitRevisiSiswa(); 
    }

    setState(() {
      _isLoading = false;
      _isRevisi = false;
      _isReadOnly = true;
      _currentStep = 1; 
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revisi berhasil dikirim ke Admin!'), backgroundColor: Colors.green));
  }

  // --- WIDGET STATUS ---
  String _getStatusText(int step) {
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

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    // Jika belum daftar (step 0), jangan tampilkan form di sini
    if (_currentStep == 0) {
      return PortalLayout(
        activeMenu: 'status_beasiswa', 
        content: Center(
          child: Text("Anda belum mendaftar. Silakan isi Formulir Beasiswa terlebih dahulu.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        )
      );
    }

    // GENERATE LIST ITEM DENGAN AMAN UNTUK MENCEGAH ERROR DROPDOWN
    List<String> provItems = _dataWilayah.keys.toList();
    List<String> kotaItems = _dataWilayah[_selectedProvinsi]?.keys.toList() ?? [];
    List<String> kecItems = _dataWilayah[_selectedProvinsi]?[_selectedKota] ?? [];

    return PortalLayout(
      activeMenu: 'status_beasiswa', 
      content: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status & Detail Pendaftaran', style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // ==========================================
            // KARTU STATUS
            // ==========================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 20 : 30),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status Anda Saat Ini:', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 10),
                  Text(_getStatusText(_currentStep), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 6.0,
                    backgroundColor: Colors.grey.shade200, color: Colors.blue.shade700, minHeight: 8, borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // 👇 KARTU JADWAL WAWANCARA (MUNCUL JIKA TAHAP 2)
            // ==========================================
            if (_currentStep == 2 && MockDatabase.currentUser?['jadwal_wawancara'] != null && MockDatabase.currentUser!['jadwal_wawancara'].toString().isNotEmpty)
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
                        Icon(Icons.event_available_rounded, color: Colors.blue.shade700, size: 28),
                        const SizedBox(width: 10),
                        Text("Jadwal Wawancara Anda", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text("Silakan hadir tepat waktu sesuai dengan jadwal yang telah ditentukan oleh tim Yayasan:", style: TextStyle(color: Colors.black87, height: 1.5)),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_filled_rounded, color: Colors.blue.shade400),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              MockDatabase.currentUser!['jadwal_wawancara'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("* Catat jadwal ini di kalender Anda. Tautan Google Meet / Detail Lokasi biasanya dikirimkan juga melalui Email.", style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

            // ==========================================
            // ALERT REVISI (MUNCUL JIKA DIMINTA ADMIN)
            // ==========================================
            if (_isRevisi)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200, width: 2), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.warning_rounded, color: Colors.red), SizedBox(width: 10), Text("Catatan Verifikator", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16))]),
                    const SizedBox(height: 10),
                    Text(_catatanRevisi.isEmpty ? "Harap perbaiki data/dokumen Anda di bawah ini lalu kirim ulang." : _catatanRevisi, style: TextStyle(color: Colors.red.shade900, fontSize: 14, height: 1.5)),
                  ],
                ),
              ),

            // ==========================================
            // FORM DATA (READ-ONLY ATAU REVISI)
            // ==========================================
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Data Pendaftaran Anda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    _buildTextField("Nama Lengkap", _nameController),
                    _buildTextField("NIK", _nikController, isNumber: true),
                    _buildTextField("Email Aktif", _emailController, readOnly: true), // Email selalu read-only
                    _buildTextField("Nomor HP", _phoneController, isNumber: true),
                    
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text("Alamat Domisili", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    
                    _buildDropdownWilayah(
                      label: "Provinsi",
                      hint: "Pilih Provinsi",
                      items: provItems,
                      value: provItems.contains(_selectedProvinsi) ? _selectedProvinsi : null,
                      onChanged: _isReadOnly ? null : (val) {
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
                      items: kotaItems,
                      value: kotaItems.contains(_selectedKota) ? _selectedKota : null,
                      onChanged: _isReadOnly ? null : (val) {
                        setState(() {
                          _selectedKota = val;
                          _selectedKecamatan = null; 
                        });
                      },
                    ),
                    
                    _buildDropdownWilayah(
                      label: "Kecamatan",
                      hint: _selectedKota == null ? "Pilih Kota Terlebih Dahulu" : "Pilih Kecamatan",
                      items: kecItems,
                      value: kecItems.contains(_selectedKecamatan) ? _selectedKecamatan : null,
                      onChanged: _isReadOnly ? null : (val) {
                        setState(() {
                          _selectedKecamatan = val;
                        });
                      },
                    ),

                    _buildTextField("Detail Jalan & RT/RW", _detailAlamatController),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 30),

                    const Text("Riwayat Pendidikan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    _buildDropdownPendidikan(),
                    _buildTextField("Asal Sekolah", _asalSekolahController),
                    _buildTextField("Tahun Lulus", _tahunLulusController, isNumber: true),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 30),

                    // ==========================================
                    // BAGIAN DOKUMEN
                    // ==========================================
                    const Text("Dokumen Pendukung Tersimpan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    _buildFileUploadField(
                      label: "Fotokopi KTP / Kartu Pelajar (Wajib)", 
                      hint: "Pilih file KTP...", 
                      fileName: _fileNameKtp, 
                      onTap: () => _pickFile('ktp'),
                    ),
                    _buildFileUploadField(
                      label: "Fotokopi Ijazah / SKL Terakhir (Wajib)", 
                      hint: "Pilih file Ijazah/SKL...", 
                      fileName: _fileNameIjazah, 
                      onTap: () => _pickFile('ijazah'), 
                    ),
                    _buildFileUploadField(
                      label: "Pas Foto 3x4 Terbaru (Wajib)", 
                      hint: "Pilih file Pas Foto...", 
                      fileName: _fileNameFoto, 
                      onTap: () => _pickFile('foto'), 
                    ),
                    _buildFileUploadField(
                      label: "Surat Motivasi Tulis Tangan (Wajib)", 
                      hint: "Pilih file Surat Motivasi...", 
                      fileName: _fileNameMotivasi, 
                      onTap: () => _pickFile('motivasi'), 
                    ),
                    _buildFileUploadField(
                      label: "Surat Keterangan Tidak Mampu / SKTM (Wajib)", 
                      hint: "Pilih file SKTM...", 
                      fileName: _fileNameSktm, 
                      onTap: () => _pickFile('sktm'), 
                    ),

                    if (!_isReadOnly) ...[
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRevisi,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("KIRIM ULANG REVISI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                    ]
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool readOnly = false}) {
    bool isFieldReadOnly = _isReadOnly || readOnly; 
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller, readOnly: isFieldReadOnly,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(color: isFieldReadOnly ? Colors.black54 : Colors.black87),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isFieldReadOnly ? Colors.transparent : Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isFieldReadOnly ? Colors.transparent : AppColors.primary, width: 1.5)),
              filled: true, fillColor: isFieldReadOnly ? Colors.grey.shade100 : Colors.white,
            ),
            validator: isFieldReadOnly ? null : (value) {
              if (value == null || value.trim().isEmpty) return '$label tidak boleh kosong';
              return null; 
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownWilayah({
    required String label, required String hint, required List<String> items, required String? value, required ValueChanged<String?>? onChanged,
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
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _isReadOnly ? Colors.transparent : Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _isReadOnly ? Colors.transparent : AppColors.primary, width: 1.5)),
              filled: true, fillColor: _isReadOnly ? Colors.grey.shade100 : (items.isEmpty ? Colors.grey.shade100 : Colors.white),
            ),
            hint: Text(hint, style: TextStyle(color: _isReadOnly ? Colors.black54 : Colors.grey.shade500, fontSize: 14)),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: _isReadOnly ? Colors.transparent : Colors.grey.shade700), 
            items: items.isEmpty ? null : items.map((String item) {
              return DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: _isReadOnly ? Colors.black54 : Colors.black87)));
            }).toList(),
            onChanged: onChanged,
            validator: _isReadOnly ? null : (val) => val == null ? '$label harus dipilih' : null,
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
          const Text("Pendidikan Terakhir", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: pItems.contains(_selectedPendidikan) ? _selectedPendidikan : null, 
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _isReadOnly ? Colors.transparent : Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _isReadOnly ? Colors.transparent : AppColors.primary, width: 1.5)),
              filled: true, fillColor: _isReadOnly ? Colors.grey.shade100 : Colors.white,
            ),
            hint: const Text("-- Pilih Pendidikan --"),
            icon: Icon(Icons.arrow_drop_down, color: _isReadOnly ? Colors.transparent : Colors.grey.shade700),
            items: const [
              DropdownMenuItem(value: "SD", child: Text("SD / Sederajat")),
              DropdownMenuItem(value: "SMP", child: Text("SMP / Sederajat")),
              DropdownMenuItem(value: "SMA", child: Text("SMA / SMK / Sederajat")),
            ],
            onChanged: _isReadOnly ? null : (value) => setState(() => _selectedPendidikan = value),
            validator: _isReadOnly ? null : (value) => value == null ? 'Pendidikan Terakhir harus dipilih' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadField({
    required String label, required String hint, required String? fileName, required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _isReadOnly ? null : onTap, 
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _isReadOnly ? Colors.grey.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isReadOnly ? Colors.transparent : Colors.grey.shade300, width: 1.0),
              ),
              child: Row(
                children: [
                  Icon(
                    _isReadOnly ? Icons.insert_drive_file : Icons.upload_file_rounded, 
                    color: fileName != null ? (_isReadOnly ? Colors.blue : AppColors.primary) : Colors.grey.shade400
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      fileName ?? hint,
                      style: TextStyle(
                        color: fileName != null ? (_isReadOnly ? Colors.black54 : Colors.black87) : Colors.grey.shade400,
                        fontSize: 14, fontWeight: fileName != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fileName != null)
                    const Icon(Icons.check_circle, color: Colors.green, size: 22)
                  else if (!_isReadOnly)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                      child: const Text("Pilih Ulang", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}