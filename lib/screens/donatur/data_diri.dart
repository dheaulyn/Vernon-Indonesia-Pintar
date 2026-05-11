import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class DataDiriView extends StatelessWidget {
  final bool isMobile;
  final Map<String, dynamic> user;

  const DataDiriView({super.key, required this.isMobile, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: 8,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Utama",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              _buildProfileTextField("Nama Lengkap", user['name']),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildProfileTextField(
                      "Email (Tidak bisa diubah)",
                      user['email'],
                      isReadOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProfileTextField(
                      "No. WhatsApp",
                      "081234567890",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),

              const Text(
                "Data Tambahan (Opsional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Data ini membantu kami untuk pendataan demografi donatur.",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              _buildProfileTextField(
                "Pekerjaan / Instansi",
                "PT Karya Anak Bangsa",
              ),
              const SizedBox(height: 24),

              _buildProfileTextField(
                "Alamat Lengkap",
                "Jl. Sudirman No. 45, Jakarta Selatan",
                maxLines: 3,
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data berhasil diperbarui!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ), // Ruang ekstra agar tombol panah tidak menabrak batas konten
      ],
    );
  }

  Widget _buildProfileTextField(
    String label,
    String initialValue, {
    bool isReadOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: isReadOnly,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 14,
            color: isReadOnly ? Colors.grey.shade600 : Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
