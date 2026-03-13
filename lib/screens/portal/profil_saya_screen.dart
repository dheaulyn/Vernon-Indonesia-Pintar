import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'portal_layout.dart';
import '../../data/mock_database.dart'; // 👇 Pastikan MockDatabase di-import

class ProfilSayaScreen extends StatefulWidget {
  const ProfilSayaScreen({super.key});

  @override
  State<ProfilSayaScreen> createState() => _ProfilSayaScreenState();
}

class _ProfilSayaScreenState extends State<ProfilSayaScreen> {
  bool _isEditing = false;

  // 👇 1. Buat Controller untuk Form yang bisa diedit
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _domisiliController;
  late TextEditingController _whatsappController;
  late TextEditingController _ptController;
  late TextEditingController _prodiController;
  late TextEditingController _semesterController;

  @override
  void initState() {
    super.initState();
    // 👇 2. Isi Controller dengan data dari MockDatabase saat halaman dibuka
    final user = MockDatabase.currentUser ?? {};

    _nameController = TextEditingController(text: user['name'] ?? 'SISWA VIP');
    _emailController = TextEditingController(
      text: user['email'] ?? 'siswa@email.com',
    );

    // Data dummy tambahan (Karena di register kita hanya simpan nama, email, password)
    _domisiliController = TextEditingController(
      text: user['domisili'] ?? 'Malang',
    );
    _whatsappController = TextEditingController(
      text: user['whatsapp'] ?? '+62 812-3456-7890',
    );
    _ptController = TextEditingController(
      text: user['pt'] ?? 'Bhinneka Nusantara Malang University',
    );
    _prodiController = TextEditingController(
      text: user['prodi'] ?? 'Information Systems',
    );
    _semesterController = TextEditingController(
      text: user['semester'] ?? 'Semester 6',
    );
  }

  @override
  void dispose() {
    // Bersihkan memori controller
    _nameController.dispose();
    _emailController.dispose();
    _domisiliController.dispose();
    _whatsappController.dispose();
    _ptController.dispose();
    _prodiController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  // 👇 3. Fungsi untuk menyimpan perubahan ke MockDatabase
  void _saveProfile() {
    setState(() {
      _isEditing = false; // Matikan mode edit

      // Update data di MockDatabase.currentUser
      if (MockDatabase.currentUser != null) {
        MockDatabase.currentUser!['name'] = _nameController.text.toUpperCase();
        MockDatabase.currentUser!['email'] = _emailController.text;
        MockDatabase.currentUser!['domisili'] = _domisiliController.text;
        MockDatabase.currentUser!['whatsapp'] = _whatsappController.text;
        MockDatabase.currentUser!['pt'] = _ptController.text;
        MockDatabase.currentUser!['prodi'] = _prodiController.text;
        MockDatabase.currentUser!['semester'] = _semesterController.text;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data untuk tampilan non-form
    final currentName = MockDatabase.currentUser?['name'] ?? 'SISWA VIP';
    final currentEmail =
        MockDatabase.currentUser?['email'] ?? 'siswa@email.com';

    return PortalLayout(
      activeMenu: 'profil',
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil Saya',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kelola informasi data diri dan riwayat pendidikan Anda di sini.',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // 👇 4. Kartu Header (Tampilannya langsung terhubung ke nama/email saat ini)
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
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentName, // Teks Dinamis
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentEmail, // Teks Dinamis
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Ganti Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Form Data Diri & Pendidikan
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
                        'Informasi Pribadi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;

                            // Jika batal edit, kembalikan nilai controller ke asalnya
                            if (!_isEditing) {
                              final user = MockDatabase.currentUser ?? {};
                              _nameController.text =
                                  user['name'] ?? 'SISWA VIP';
                              _emailController.text =
                                  user['email'] ?? 'siswa@email.com';
                              _domisiliController.text =
                                  user['domisili'] ?? 'Malang';
                              _whatsappController.text =
                                  user['whatsapp'] ?? '+62 812-3456-7890';
                              _ptController.text =
                                  user['pt'] ??
                                  'Bhinneka Nusantara Malang University';
                              _prodiController.text =
                                  user['prodi'] ?? 'Information Systems';
                              _semesterController.text =
                                  user['semester'] ?? 'Semester 6';
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
                        style: TextButton.styleFrom(
                          backgroundColor: _isEditing
                              ? Colors.red.shade50
                              : AppColors.primary.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // 👇 5. Gunakan _buildProfileField dengan passing controller-nya
                  _buildProfileField('Nama Lengkap', _nameController),
                  _buildProfileField(
                    'Email',
                    _emailController,
                  ), // Tambahan untuk merubah email
                  _buildProfileField('Domisili', _domisiliController),
                  _buildProfileField('Nomor WhatsApp', _whatsappController),

                  const SizedBox(height: 40),

                  const Text(
                    'Informasi Pendidikan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),

                  _buildProfileField('Perguruan Tinggi', _ptController),
                  _buildProfileField('Program Studi', _prodiController),
                  _buildProfileField('Semester Saat Ini', _semesterController),

                  if (_isEditing) ...[
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _saveProfile, // Panggil fungsi simpan
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 👇 6. _buildProfileField sekarang menerima TextEditingController, bukan String biasa
  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller, // Hubungkan controller
              readOnly: !_isEditing,
              style: TextStyle(
                color: _isEditing ? Colors.black87 : Colors.black54,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isEditing
                        ? Colors.grey.shade400
                        : Colors.transparent,
                  ),
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
