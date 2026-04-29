import 'package:flutter/material.dart';
import '../../../core/app_colors.dart'; // Sesuaikan titiknya jika error
import '../shared/custom_footer.dart'; // 👇 Import database bohongan dari file footer publik

class FooterAdmin extends StatefulWidget {
  const FooterAdmin({super.key});

  @override
  State<FooterAdmin> createState() => _FooterAdminState();
}

class _FooterAdminState extends State<FooterAdmin> {
  // Datanya sudah disamakan dengan desain web publikmu
  String _deskripsi =
      "Membangun generasi emas Indonesia melalui akses pendidikan yang merata dan berkualitas.";
  String _whatsapp = "+62 812-3456-7890";
  String _email = "info@vip.or.id";
  String _alamat =
      "Jl. Letjen Sutoyo No.102A, Bunulrejo, Kec. Blimbing, Kota Malang, Jawa Timur, Indonesia";

  // WIDGET BANTUAN UNTUK FORM INPUT
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // --- FUNGSI UPDATE TUNGGAL ---
  void _showEditForm() {
    TextEditingController descCtrl = TextEditingController(text: _deskripsi);
    TextEditingController waCtrl = TextEditingController(text: _whatsapp);
    TextEditingController emailCtrl = TextEditingController(text: _email);
    TextEditingController alamatCtrl = TextEditingController(text: _alamat);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Edit Footer & Kontak",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInputField(
                    controller: descCtrl,
                    label: "Deskripsi Yayasan",
                    maxLines: 3,
                  ),
                  _buildInputField(
                    controller: waCtrl,
                    label: "Nomor WhatsApp",
                    prefixIcon: Icons.phone,
                  ),
                  _buildInputField(
                    controller: emailCtrl,
                    label: "Alamat Email",
                    prefixIcon: Icons.email,
                  ),
                  _buildInputField(
                    controller: alamatCtrl,
                    label: "Alamat Lengkap",
                    maxLines: 3,
                    prefixIcon: Icons.location_on,
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 👇 INI POSISI YANG BENAR UNTUK TOMBOL SIMPAN
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // 1. Simpan perubahan ke variabel utama admin
                  _deskripsi = descCtrl.text;
                  _whatsapp = waCtrl.text;
                  _email = emailCtrl.text;
                  _alamat = alamatCtrl.text;

                  // 2. Kirim perubahan ke Web Publik (Real-time Simulasi)
                  DummyFooterDB.data.value = {
                    'deskripsi': descCtrl.text,
                    'whatsapp': 'WhatsApp: ${waCtrl.text}',
                    'email': 'Email: ${emailCtrl.text}',
                    'alamat': 'Alamat: ${alamatCtrl.text}',
                  };
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Info Kontak & Footer berhasil diperbarui!"),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "Simpan Perubahan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 15.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER HALAMAN
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              runSpacing: 15,
              children: [
                const Text(
                  "Manajemen Footer & Kontak",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showEditForm,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    "Edit Konten",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // AREA KONTEN TAMPILAN ADMIN
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tampilan Data Saat Ini:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInfoTile(
                        Icons.info_outline,
                        "Deskripsi Yayasan",
                        _deskripsi,
                      ),
                      const Divider(),
                      _buildInfoTile(
                        Icons.phone_android,
                        "WhatsApp",
                        _whatsapp,
                      ),
                      const Divider(),
                      _buildInfoTile(Icons.alternate_email, "Email", _email),
                      const Divider(),
                      _buildInfoTile(
                        Icons.location_city,
                        "Alamat Lengkap",
                        _alamat,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
