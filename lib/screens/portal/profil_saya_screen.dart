import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'portal_layout.dart';

// 👇 1. UBAH MENJADI STATEFUL WIDGET
class ProfilSayaScreen extends StatefulWidget {
  const ProfilSayaScreen({super.key});

  @override
  State<ProfilSayaScreen> createState() => _ProfilSayaScreenState();
}

class _ProfilSayaScreenState extends State<ProfilSayaScreen> {
  // 👇 2. VARIABEL PENYIMPAN STATUS EDIT
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
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

            // Kartu Header (Foto & Info Singkat)
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
                      const Text(
                        'Rudolph Benjamin Gaspersz',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'rudolph.bg@email.com',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementasi ganti foto
                        },
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
                  // 👇 3. HEADER INFORMASI PRIBADI & TOMBOL EDIT
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
                      // Tombol Edit Profil
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing =
                                !_isEditing; // Membalik status (Buka/Tutup)
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

                  _buildProfileField(
                    'Nama Lengkap',
                    'Rudolph Benjamin Gaspersz',
                  ),
                  _buildProfileField('Domisili', 'Malang'),
                  _buildProfileField('Nomor WhatsApp', '+62 812-3456-7890'),

                  const SizedBox(height: 40),

                  const Text(
                    'Informasi Pendidikan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),

                  _buildProfileField(
                    'Perguruan Tinggi',
                    'Universitas Bhinneka Nusantara',
                  ),
                  _buildProfileField('Program Studi', 'Sistem Informasi'),
                  _buildProfileField('Semester Saat Ini', 'Semester 6'),

                  // 👇 4. TOMBOL SIMPAN HANYA MUNCUL SAAT MODE EDIT AKTIF
                  if (_isEditing) ...[
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Aksi Simpan
                          setState(() {
                            _isEditing =
                                false; // Matikan mode edit setelah disimpan
                          });

                          // Tampilkan notifikasi sukses
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil diperbarui!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
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

  // 👇 5. LOGIKA FORM DINAMIS (BISA DISABLED/ENABLED)
  Widget _buildProfileField(String label, String initialValue) {
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
              initialValue: initialValue,
              readOnly: !_isEditing, // Mengunci form jika _isEditing = false
              style: TextStyle(
                color: _isEditing
                    ? Colors.black87
                    : Colors.black54, // Teks sedikit pudar jika terkunci
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                // Ubah warna latar belakang agar jelas mana yang bisa diedit
                fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  // Hilangkan garis border jika sedang terkunci agar terlihat rapi
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
