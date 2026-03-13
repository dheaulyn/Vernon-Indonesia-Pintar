import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'dashboard_screen.dart';
import '../../data/mock_database.dart'; // 👇 Import MockDatabase untuk fitur Auto-Fill

class FormBeasiswaScreen extends StatefulWidget {
  const FormBeasiswaScreen({super.key});

  @override
  State<FormBeasiswaScreen> createState() => _FormBeasiswaScreenState();
}

class _FormBeasiswaScreenState extends State<FormBeasiswaScreen> {
  int _currentStep = 0;
  String? _jenisBeasiswaDipilih;

  // 👇 1. Siapkan Controller untuk menangkap dan mengisi data form
  late TextEditingController _nameController;
  late TextEditingController _whatsappController;
  late TextEditingController _domisiliController;
  late TextEditingController _ptController;
  late TextEditingController _prodiController;
  late TextEditingController _ipkController;

  @override
  void initState() {
    super.initState();
    // 👇 2. Fitur AUTO-FILL: Ambil data dari sesi user yang sedang login!
    final user = MockDatabase.currentUser ?? {};

    _nameController = TextEditingController(text: user['name'] ?? '');
    _whatsappController = TextEditingController(text: user['whatsapp'] ?? '');
    _domisiliController = TextEditingController(text: user['domisili'] ?? '');
    _ptController = TextEditingController(text: user['pt'] ?? '');
    _prodiController = TextEditingController(text: user['prodi'] ?? '');
    _ipkController = TextEditingController(
      text: '',
    ); // IPK biasanya selalu diisi manual saat daftar
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _domisiliController.dispose();
    _ptController.dispose();
    _prodiController.dispose();
    _ipkController.dispose();
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
          width: 800, // Membatasi lebar agar rapi di desktop/web
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            // Sedikit memodifikasi tema Stepper agar sesuai dengan warna Primary aplikasi
            data: ThemeData(
              colorScheme: ColorScheme.light(primary: AppColors.primary),
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              onStepContinue: () {
                final isLastStep = _currentStep == _getSteps().length - 1;

                // Jika Step 1 (Biodata), validasi apakah Jenis Beasiswa sudah dipilih
                if (_currentStep == 0 && _jenisBeasiswaDipilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Silakan pilih Program Beasiswa terlebih dahulu!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // Jangan lanjut ke step berikutnya
                }

                if (isLastStep) {
                  // TODO: Kirim data ke API / Backend
                  _showSuccessDialog();
                } else {
                  setState(() => _currentStep += 1);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isLastStep ? 'KIRIM PENDAFTARAN' : 'SELANJUTNYA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'KEMBALI',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  // DAFTAR LANGKAH-LANGKAH (STEPS)
  List<Step> _getSteps() {
    return [
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: const Text(
          'Biodata Diri',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              _buildDropdownField(
                'Pilih Program Beasiswa',
                'Pilih jenis beasiswa yang ingin dilamar',
              ),
              const SizedBox(height: 25),
              _buildTextField(
                'Nama Lengkap',
                'Masukkan nama sesuai identitas',
                _nameController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Nomor WhatsApp Aktif',
                'Contoh: 08123456789',
                _whatsappController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Alamat Domisili',
                'Contoh: Malang',
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
        title: const Text(
          'Pendidikan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              _buildTextField(
                'Nama Universitas/Sekolah',
                'Contoh: Universitas Bhinneka Nusantara',
                _ptController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Program Studi / Jurusan',
                'Contoh: Sistem Informasi',
                _prodiController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'IPK / Nilai Rata-rata Saat Ini',
                'Contoh: 3.85',
                _ipkController,
              ),
            ],
          ),
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: const Text(
          'Unggah Berkas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Unggah dokumen berikut dalam format PDF (Maks. 5MB per file). Pastikan dokumen dapat terbaca dengan jelas.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
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
              _buildFileUploadRow('Portofolio / Sertifikat Prestasi'),
            ],
          ),
        ),
      ),
    ];
  }

  // 👇 3. WIDGET TEXTFIELD YANG SUDAH MENERIMA CONTROLLER
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // Hubungkan dengan controller
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint) {
    final List<String> daftarPilihan = [
      'Beasiswa Prestasi',
      'Beasiswa Reguler',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _jenisBeasiswaDipilih,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.black38, fontSize: 14),
          ),
          items: daftarPilihan.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _jenisBeasiswaDipilih = newValue;
            });
          },
        ),
      ],
    );
  }

  // WIDGET BANTUAN UNTUK UPLOAD FILE
  Widget _buildFileUploadRow(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text(
              'Pilih File',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DIALOG KETIKA SELESAI
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI KE DASHBOARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
