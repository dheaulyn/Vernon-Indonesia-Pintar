import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart'; 
import '../../../../data/mock_database.dart'; 

class FooterAdmin extends StatefulWidget {
  const FooterAdmin({super.key});

  @override
  State<FooterAdmin> createState() => _FooterAdminState();
}

class _FooterAdminState extends State<FooterAdmin> {
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
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _showEditForm() {
    final currentData = MockDatabase.footerData.value;

    TextEditingController descCtrl = TextEditingController(text: currentData['deskripsi'] ?? '');
    TextEditingController alamatCtrl = TextEditingController(text: currentData['alamat'] ?? '');
    TextEditingController waCtrl = TextEditingController(text: currentData['whatsapp'] ?? '');
    TextEditingController emailCtrl = TextEditingController(text: currentData['email'] ?? '');
    TextEditingController igCtrl = TextEditingController(text: currentData['instagram'] ?? ''); 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.edit_note_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 10),
                  Text("Edit Footer & Kontak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                  _buildInputField(controller: descCtrl, label: "Deskripsi Yayasan", maxLines: 3),
                  _buildInputField(controller: alamatCtrl, label: "Alamat Lengkap", maxLines: 3, prefixIcon: Icons.location_on),
                  const SizedBox(height: 10),
                  const Text("Tautan Ikon (Sosial Media)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildInputField(controller: waCtrl, label: "Link WhatsApp (cth: https://wa.me/628...)", prefixIcon: Icons.phone),
                  _buildInputField(controller: igCtrl, label: "Link Instagram (cth: https://instagram.com/...)", prefixIcon: Icons.camera_alt),
                  _buildInputField(controller: emailCtrl, label: "Alamat Email", prefixIcon: Icons.email),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                MockDatabase.footerData.value = {
                  'deskripsi': descCtrl.text,
                  'alamat': alamatCtrl.text,
                  'whatsapp': waCtrl.text,
                  'instagram': igCtrl.text, 
                  'email': emailCtrl.text,
                };

                Navigator.pop(context);
                // 👇 PERUBAHAN: Menyesuaikan SnackBar agar sama persis dengan FAQ
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Info Kontak & Footer berhasil diperbarui!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating, // Membuatnya mengambang
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)), // Ujung rounded
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              ),
              child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              runSpacing: 15,
              children: [
                const Text("Manajemen Footer & Kontak", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _showEditForm,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("Edit Konten", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: const StadiumBorder()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tampilan Data Saat Ini:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 20),

                      ValueListenableBuilder<Map<String, String>>(
                        valueListenable: MockDatabase.footerData,
                        builder: (context, footerData, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoTile(Icons.info_outline, "Deskripsi Yayasan", footerData['deskripsi'] ?? '-'),
                              const Divider(),
                              _buildInfoTile(Icons.location_city, "Alamat Tampil", footerData['alamat'] ?? '-'),
                              const Divider(),
                              _buildInfoTile(Icons.link, "Tautan WhatsApp", footerData['whatsapp'] ?? '-'),
                              const Divider(),
                              _buildInfoTile(Icons.link, "Tautan Instagram", footerData['instagram'] ?? '-'),
                              const Divider(),
                              _buildInfoTile(Icons.link, "Alamat Email", footerData['email'] ?? '-'),
                            ],
                          );
                        },
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
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}