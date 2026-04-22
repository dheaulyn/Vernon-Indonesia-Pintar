import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../../core/app_colors.dart';
import 'dashboard_screen.dart';
import '../../data/mock_database.dart'; 


class CurrencyFormat extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');

    
    int value = int.parse(numericOnly);
    String formatted = 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class FormBeasiswaScreen extends StatefulWidget {
  const FormBeasiswaScreen({super.key});

  @override
  State<FormBeasiswaScreen> createState() => _FormBeasiswaScreenState();
}

class _FormBeasiswaScreenState extends State<FormBeasiswaScreen> {
  int _currentStep = 0;
  

  String? _jenisBeasiswaDipilih;
  String? _strataDipilih; 

  
  late TextEditingController _nameController;
  late TextEditingController _teleponController;
  late TextEditingController _domisiliController;
  late TextEditingController _ptController;
  late TextEditingController _prodiController;
  late TextEditingController _semesterController; 
  late TextEditingController _ipkController;

  late TextEditingController _prestasiController;
  late TextEditingController _pekerjaanOrtuController;
  late TextEditingController _penghasilanOrtuController;

  @override
  void initState() {
    super.initState();
    final user = MockDatabase.currentUser ?? {};

    _nameController = TextEditingController(text: user['name'] ?? '');
    _teleponController = TextEditingController(text: user['telepon'] ?? '');
    _domisiliController = TextEditingController(text: user['domisili'] ?? '');
    _ptController = TextEditingController(text: user['pt'] ?? '');
    _prodiController = TextEditingController(text: user['prodi'] ?? '');
    _semesterController = TextEditingController(text: user['semester'] ?? ''); 
    _ipkController = TextEditingController(text: ''); 
    
    
    _strataDipilih = user['strata'];
    
    _prestasiController = TextEditingController(text: '');
    _pekerjaanOrtuController = TextEditingController(text: '');
    _penghasilanOrtuController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teleponController.dispose();
    _domisiliController.dispose();
    _ptController.dispose();
    _prodiController.dispose();
    _semesterController.dispose(); 
    _ipkController.dispose();
    _prestasiController.dispose();
    _pekerjaanOrtuController.dispose();
    _penghasilanOrtuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.accentBlack,
        elevation: 1,
        title: const Text(
          'Lengkapi Berkas Pendaftaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: Container(
          width: 800, 
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(primary: AppColors.primary),
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              onStepContinue: () {
                final isLastStep = _currentStep == _getSteps().length - 1;

                if (_currentStep == 0 && _jenisBeasiswaDipilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silakan pilih Program Beasiswa terlebih dahulu!'), backgroundColor: Colors.red),
                  );
                  return; 
                }
                
                
                if (_currentStep == 1 && _strataDipilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silakan pilih Strata/Jenjang Pendidikan terlebih dahulu!'), backgroundColor: Colors.red),
                  );
                  return; 
                }

                if (isLastStep) {
                  if (MockDatabase.currentUser != null) {
                    MockDatabase.currentUser!['name'] = _nameController.text.toUpperCase();
                    MockDatabase.currentUser!['telepon'] = _teleponController.text;
                    MockDatabase.currentUser!['domisili'] = _domisiliController.text;
                    MockDatabase.currentUser!['strata'] = _strataDipilih; // 👇 Simpan Strata ke database
                    MockDatabase.currentUser!['pt'] = _ptController.text;
                    MockDatabase.currentUser!['prodi'] = _prodiController.text;
                    MockDatabase.currentUser!['semester'] = _semesterController.text; 
                    MockDatabase.currentUser!['ipk'] = _ipkController.text;
                    MockDatabase.currentUser!['jenis_beasiswa'] = _jenisBeasiswaDipilih;
                    
                    if (_jenisBeasiswaDipilih == 'Beasiswa Prestasi') {
                       MockDatabase.currentUser!['prestasi'] = _prestasiController.text;
                    } else {
                       MockDatabase.currentUser!['pekerjaan_ortu'] = _pekerjaanOrtuController.text;
                       MockDatabase.currentUser!['penghasilan_ortu'] = _penghasilanOrtuController.text;
                    }

                    MockDatabase.currentUser!['is_registered'] = true; 
                  }
                  _showSuccessDialog();
                } else {
                  setState(() => _currentStep += 1);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep -= 1);
              },
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                final isLastStep = _currentStep == _getSteps().length - 1;
                return Container(
                  margin: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isLastStep ? 'KIRIM PENDAFTARAN' : 'SELANJUTNYA',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('KEMBALI', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
              steps: _getSteps(),
            ),
          ),
        ),
      ),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: const Text('Biodata Diri', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              
              _buildGenericDropdown(
                label: 'Pilih Program Beasiswa',
                hint: 'Pilih jenis beasiswa yang ingin dilamar',
                value: _jenisBeasiswaDipilih,
                items: ['Beasiswa Prestasi', 'Beasiswa Reguler'],
                onChanged: (newValue) {
                  setState(() {
                    _jenisBeasiswaDipilih = newValue;
                  });
                },
              ),
              
              _buildRequirementBox(),

              const SizedBox(height: 25),
              _buildTextField('Nama Lengkap', 'Masukkan nama sesuai identitas', _nameController),
              const SizedBox(height: 20),
              _buildTextField('Nomor Telepon', 'Contoh: 08123456789', _teleponController, isNumberOnly: true),
              const SizedBox(height: 20),
              _buildTextField(
                 'Alamat Lengkap Domisili', 
                 'Contoh: Jl. Raya Tlogomas No. 246, RT 01/RW 02, Kec. Lowokwaru, Kota Malang 65144', 
                 _domisiliController, 
                 maxLines: 3,
               ),
            ],
          ),
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: const Text('Pendidikan & Info', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              
              _buildGenericDropdown(
                label: 'Strata / Jenjang Pendidikan',
                hint: 'Pilih Strata Pendidikan Anda',
                value: _strataDipilih,
                items: ['D3', 'D4', 'S1', 'S2', 'S3'],
                onChanged: (newValue) {
                  setState(() {
                    _strataDipilih = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildTextField('Nama Universitas/Sekolah', 'Contoh: Universitas Bhinneka Nusantara', _ptController),
              const SizedBox(height: 20),
              _buildTextField('Program Studi / Jurusan', 'Contoh: Sistem Informasi', _prodiController),
              const SizedBox(height: 20),
              
              _buildTextField('Semester Saat Ini', 'Contoh angka saja: 6', _semesterController, isNumberOnly: true, maxLength: 2),
              const SizedBox(height: 20),
              
              _buildTextField('IPK / Nilai Rata-rata Saat Ini', 'Contoh: 3.85', _ipkController, isDecimal: true),
              
              if (_jenisBeasiswaDipilih == 'Beasiswa Prestasi') ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildTextField('Prestasi Tertinggi yang Diraih', 'Contoh: Juara 1 Lomba Web Design Nasional 2025', _prestasiController, maxLines: 2),
              ] else if (_jenisBeasiswaDipilih == 'Beasiswa Reguler') ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildTextField('Pekerjaan Orang Tua / Wali', 'Contoh: Wiraswasta / Petani / PNS', _pekerjaanOrtuController),
                const SizedBox(height: 20),
                _buildTextField('Penghasilan Orang Tua per Bulan', 'Ketik angka, otomatis Rp...', _penghasilanOrtuController, isCurrency: true),
              ]
            ],
          ),
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: const Text('Unggah Berkas', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Unggah dokumen berikut dalam format PDF (Maks. 5MB per file). Dokumen wajib disesuaikan dengan jenis beasiswa yang dipilih.',
                        style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              
              _buildFileUploadRow('Scan KTP / Kartu Pelajar'),
              const SizedBox(height: 16),
              _buildFileUploadRow('Transkrip Nilai / Rapor Terakhir'),
              const SizedBox(height: 16),

              if (_jenisBeasiswaDipilih == 'Beasiswa Prestasi') ...[
                _buildFileUploadRow('Sertifikat Kejuaraan / Prestasi (Wajib)'),
              ] else if (_jenisBeasiswaDipilih == 'Beasiswa Reguler') ...[
                _buildFileUploadRow('Slip Gaji Orang Tua / Surat Keterangan Tidak Mampu (SKTM)'),
                const SizedBox(height: 16),
                _buildFileUploadRow('Foto Rumah Tampak Depan'),
              ]
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildRequirementBox() {
    if (_jenisBeasiswaDipilih == null) return const SizedBox.shrink();

    final List<String> reqPrestasi = [
      'Merupakan siswa/mahasiswa aktif di jenjang pendidikan formal (SMA/SMK/MA atau Perguruan Tinggi).',
      'Memiliki prestasi akademik minimal peringkat 10 besar di sekolah atau IPK minimal 3.5 untuk mahasiswa.',
      'Memiliki prestasi non-akademik yang diakui secara resmi (misalnya juara lomba tingkat kota, provinsi, nasional, atau internasional).',
      'Mempunyai motivasi kuat untuk terus berprestasi dan berkontribusi positif bagi masyarakat.',
      'Tidak sedang menerima beasiswa lain yang bersifat tumpang tindih dengan program ini.'
    ];

    final List<String> reqReguler = [
      'Merupakan siswa/mahasiswa aktif di jenjang pendidikan formal (SMA/SMK/MA atau Perguruan Tinggi).',
      'Memiliki kondisi ekonomi keluarga yang kurang mampu (dibuktikan dengan surat keterangan tidak mampu dari kelurahan/desa).',
      'Memiliki motivasi kuat untuk terus belajar dan berkontribusi positif bagi masyarakat.',
      'Tidak sedang menerima beasiswa lain yang bersifat tumpang tindih dengan program ini.'
    ];

    List<String> activeRequirements = _jenisBeasiswaDipilih == 'Beasiswa Prestasi' ? reqPrestasi : reqReguler;

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Persyaratan Pendaftaran:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
          ),
          const SizedBox(height: 12),
          ...activeRequirements.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    req,
                    style: TextStyle(color: Colors.green.shade900, height: 1.4, fontSize: 13),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    String hint, 
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumberOnly = false,
    bool isDecimal = false,
    bool isCurrency = false,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, 
          maxLines: maxLines,
          maxLength: maxLength, 
          keyboardType: isNumberOnly || isDecimal || isCurrency ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            if (isNumberOnly) FilteringTextInputFormatter.digitsOnly, 
            if (isDecimal) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), 
            if (isCurrency) CurrencyFormat(), 
          ],
          decoration: InputDecoration(
            hintText: hint,
            counterText: '', 
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }


  Widget _buildGenericDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          hint: Text(hint, style: const TextStyle(color: Colors.black38, fontSize: 14)),
          items: items.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFileUploadRow(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( 
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          const SizedBox(width: 15),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Pilih File', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 25),
              const Text(
                'Pendaftaran Berhasil!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Berkas pendaftaran Anda telah masuk ke sistem kami. Silakan pantau status pendaftaran secara berkala melalui Dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('KEMBALI KE DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}