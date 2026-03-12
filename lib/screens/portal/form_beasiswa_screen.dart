import 'package:flutter/material.dart';
import '../../core/app_colors.dart'; // Sesuaikan path jika berbeda
import 'dashboard_screen.dart'; // Untuk navigasi kembali

class FormBeasiswaScreen extends StatefulWidget {
  const FormBeasiswaScreen({super.key});

  @override
  State<FormBeasiswaScreen> createState() => _FormBeasiswaScreenState();
}

class _FormBeasiswaScreenState extends State<FormBeasiswaScreen> {
  // Menyimpan status posisi step saat ini
  int _currentStep = 0;

  String? _jenisBeasiswaDipilih;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.accentBlack,
        elevation: 1,
        title: const Text(
          'Lengkapi Berkas Pendaftaran',
          style: TextStyle(fontWeight: FontWeight.bold),
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
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          // Widget Stepper Bawaan Flutter
          child: Stepper(
            type: StepperType.horizontal, // Bentuk horizontal cocok untuk web
            currentStep: _currentStep,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: () {
              final isLastStep = _currentStep == _getSteps().length - 1;
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
                margin: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        isLastStep ? 'KIRIM PENDAFTARAN' : 'SELANJUTNYA',
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('KEMBALI'),
                      ),
                  ],
                ),
              );
            },
            steps: _getSteps(),
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
        title: const Text('Biodata Diri'),
        content: Column(
          children: [
            _buildDropdownField(
              'Pilih Program Beasiswa',
              'Pilih jenis beasiswa',
            ),
            const SizedBox(height: 20),
            _buildTextField('Nama Lengkap', 'Masukkan nama sesuai identitas'),
            const SizedBox(height: 16),
            _buildTextField('Nomor WhatsApp Aktif', 'Contoh: 08123456789'),
            const SizedBox(height: 16),
            _buildTextField('Alamat Domisili', 'Contoh: Malang', maxLines: 3),
          ],
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: const Text('Pendidikan'),
        content: Column(
          children: [
            _buildTextField(
              'Nama Universitas/Sekolah',
              'Contoh: Universitas Bhinneka Nusantara',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Program Studi / Jurusan',
              'Contoh: Sistem Informasi',
            ),
            const SizedBox(height: 16),
            _buildTextField('IPK / Nilai Rata-rata Saat Ini', 'Contoh: 3.85'),
          ],
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: const Text('Unggah Berkas'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unggah dokumen berikut dalam format PDF (Maks. 5MB per file):',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildFileUploadRow('Scan KTP / Kartu Pelajar'),
            const SizedBox(height: 16),
            _buildFileUploadRow('Transkrip Nilai / Rapor Terakhir'),
            const SizedBox(height: 16),
            _buildFileUploadRow('Portofolio / Sertifikat Prestasi'),
          ],
        ),
      ),
    ];
  }

  // WIDGET BANTUAN UNTUK TEXTFIELD
  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint) {
    // 👇 Pindahkan list pilihan ke dalam fungsi ini
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
          initialValue:
              _jenisBeasiswaDipilih, // Pastikan variabel ini sudah ada di atas
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          hint: Text(hint, style: const TextStyle(color: Colors.black38)),
          // 👇 Gunakan daftarPilihan di sini
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
      padding: const EdgeInsets.all(16),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementasi File Picker (mengambil file dari komputer)
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Pilih File'),
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
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pendaftaran Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Berkas pendaftaran Anda telah masuk ke sistem kami. Silakan pantau status pendaftaran secara berkala melalui Dashboard.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Tutup dialog dan kembali ke Dashboard
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'KEMBALI KE DASHBOARD',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
