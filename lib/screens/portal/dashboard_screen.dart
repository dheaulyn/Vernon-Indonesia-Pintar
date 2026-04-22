import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'portal_layout.dart'; 
import 'form_beasiswa_screen.dart';
import 'status_beasiswa_screen.dart'; 
import '../../data/mock_database.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ==========================================
  // VARIABEL & CONTROLLER PROFIL
  // ==========================================
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _domisiliController;
  late TextEditingController _teleponController;
  late TextEditingController _ptController;
  late TextEditingController _strataController; // 
  late TextEditingController _prodiController;
  late TextEditingController _semesterController;
  late TextEditingController _ipkController;

  @override
  void initState() {
    super.initState();
    final user = MockDatabase.currentUser ?? {};
    
    _nameController = TextEditingController(text: user['name'] ?? 'SISWA VIP');
    _emailController = TextEditingController(text: user['email'] ?? 'siswa@email.com');
    _domisiliController = TextEditingController(text: user['domisili'] ?? '');
    _teleponController = TextEditingController(text: user['telepon'] ?? user['whatsapp'] ?? ''); 
    _ptController = TextEditingController(text: user['pt'] ?? '');
    _strataController = TextEditingController(text: user['strata'] ?? ''); // 
    _prodiController = TextEditingController(text: user['prodi'] ?? '');
    _semesterController = TextEditingController(text: user['semester'] ?? '');
    _ipkController = TextEditingController(text: user['ipk'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _domisiliController.dispose();
    _teleponController.dispose(); 
    _ptController.dispose();
    _strataController.dispose(); // 
    _prodiController.dispose();
    _semesterController.dispose();
    _ipkController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false; 
      if (MockDatabase.currentUser != null) {
        MockDatabase.currentUser!['name'] = _nameController.text.toUpperCase();
        MockDatabase.currentUser!['email'] = _emailController.text;
        MockDatabase.currentUser!['domisili'] = _domisiliController.text;
        MockDatabase.currentUser!['telepon'] = _teleponController.text;
        MockDatabase.currentUser!['pt'] = _ptController.text;
        MockDatabase.currentUser!['strata'] = _strataController.text; 
        MockDatabase.currentUser!['prodi'] = _prodiController.text;
        MockDatabase.currentUser!['semester'] = _semesterController.text;
        MockDatabase.currentUser!['ipk'] = _ipkController.text; 
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDatabase.currentUser ?? {};
    final bool isRegistered = user['is_registered'] == true;
    
    // Data untuk header profil
    final currentName = user['name'] ?? 'SISWA VIP';
    final currentEmail = user['email'] ?? 'siswa@email.com';

    return PortalLayout(
      activeMenu: 'dashboard', 
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Siswa',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // 1. KARTU STATUS PENDAFTARAN (DINAMIS)
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isRegistered ? Colors.green.shade200 : Colors.grey.shade300),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                              color: isRegistered ? Colors.green.shade50 : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isRegistered ? 'Berkas Sedang Diproses' : 'Belum Melengkapi Berkas',
                              style: TextStyle(
                                color: isRegistered ? Colors.green.shade700 : Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (isRegistered) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const StatusBeasiswaScreen()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FormBeasiswaScreen()),
                            );
                          }
                        },
                        icon: Icon(isRegistered ? Icons.insert_chart_outlined : Icons.edit_document),
                        label: Text(isRegistered ? 'Cek Status Pengajuan' : 'Lengkapi Data Diri dan Berkas Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered ? Colors.green.shade600 : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    isRegistered ? 'Progres Anda: 3 dari 3 Tahap Selesai' : 'Progres Anda: 0 dari 3 Tahap Selesai',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: isRegistered ? 1.0 : 0.1, 
                    backgroundColor: Colors.grey.shade200,
                    color: isRegistered ? Colors.green : AppColors.primary,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ==========================================
            // 2. KARTU PROFIL SAYA (DIGABUNG KE DASHBOARD)
            // ==========================================
            const Text(
              'Profil Siswa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentEmail,
                        style: const TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Informasi Pribadi & Pendidikan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (!_isEditing) {
                              _nameController.text = user['name'] ?? 'SISWA VIP';
                              _emailController.text = user['email'] ?? 'siswa@email.com';
                              _domisiliController.text = user['domisili'] ?? '';
                              _teleponController.text = user['telepon'] ?? user['whatsapp'] ?? ''; 
                              _ptController.text = user['pt'] ?? '';
                              _strataController.text = user['strata'] ?? '';
                              _prodiController.text = user['prodi'] ?? '';
                              _semesterController.text = user['semester'] ?? '';
                              _ipkController.text = user['ipk'] ?? ''; 
                            }
                          });
                        },
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit_document,
                          color: _isEditing ? Colors.red : AppColors.primary,
                        ),
                        label: Text(
                          _isEditing ? 'Batal Edit' : 'Edit Profil',
                          style: TextStyle(
                            color: _isEditing ? Colors.red : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  _buildProfileField('Nama Lengkap', _nameController),
                  _buildProfileField('Email', _emailController),
                  _buildProfileField('Nomor Telepon', _teleponController),
                  _buildProfileField('Alamat Lengkap', _domisiliController),
                  const SizedBox(height: 10),
                  _buildProfileField('Perguruan Tinggi', _ptController),
                  // 👇 Strata di Profil
                  _buildProfileField('Strata / Jenjang', _strataController),
                  _buildProfileField('Program Studi', _prodiController),
                  _buildProfileField('Semester', _semesterController),
                  _buildProfileField('IPK', _ipkController),

                  if (_isEditing) ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _saveProfile, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ==========================================
            // 3. KARTU INFORMASI PENTING
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
                  Text('• Pastikan Anda menyiapkan scan KTP, Transkrip Nilai, dan Portofolio sebelum mengisi formulir.', style: TextStyle(height: 1.5)),
                  Text('• Batas akhir pengumpulan berkas adalah tanggal 30 Mei 2026.', style: TextStyle(height: 1.5)),
                  Text('• Jika mengalami kendala teknis, silakan hubungi WhatsApp admin VIP.', style: TextStyle(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN UNTUK FORM PROFIL
  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: !_isEditing,
              style: TextStyle(color: _isEditing ? Colors.black87 : Colors.black54),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _isEditing ? Colors.grey.shade400 : Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}