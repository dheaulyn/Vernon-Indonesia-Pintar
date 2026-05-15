import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/app_colors.dart'; 
import '../../../../data/mock_database.dart'; 

class AboutSectionAdmin extends StatefulWidget {
  const AboutSectionAdmin({super.key});

  @override
  State<AboutSectionAdmin> createState() => _AboutSectionAdminState();
}

class _AboutSectionAdminState extends State<AboutSectionAdmin> {
  // 👇 Kunci form untuk validasi
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _imageBase64 = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = MockDatabase.getAboutSectionData();
    setState(() {
      _titleController.text = data['title'] ?? '';
      _descController.text = data['description'] ?? '';
      _imageBase64 = data['image'] ?? '';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // 👇 FUNGSI MENAMPILKAN PESAN BERHASIL (WARNA HIJAU & ROUNDED)
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // Membuatnya mengambang
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)), // Ujung rounded
        ),
      ),
    );
  }

  // 👇 FUNGSI MENAMPILKAN PESAN PERINGATAN (WARNA MERAH & ROUNDED)
  void _showWarningMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(String imageSource) {
    if (imageSource.isEmpty) return const Center(child: Icon(Icons.image, color: Colors.grey, size: 40));
    if (imageSource.startsWith('http')) return Image.network(imageSource, fit: BoxFit.cover);
    try {
      return Image.memory(base64Decode(imageSource), fit: BoxFit.cover);
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.red));
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true, 
    );

    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  void _saveData() {
    // 👇 Cek validasi sebelum menyimpan
    if (_formKey.currentState!.validate()) {
      MockDatabase.updateAboutSectionData({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'image': _imageBase64,
      });

      _showSuccessMessage('About Section Beranda berhasil diperbarui!');
    } else {
      _showWarningMessage('Penyimpanan gagal. Masih ada form yang kosong!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey, // 👇 Daftarkan form key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kelola Tentang Kami', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. TEKS UTAMA
                    // ==========================================
                    const Text("Judul Utama", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController, 
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Contoh: Membantu Anak Bangsa Meraih Mimpi"
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController, 
                      maxLines: 4, 
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Contoh: Vernon Indonesia Pintar bukan sekadar yayasan..."
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 30),

                    // ==========================================
                    // 2. UPLOAD GAMBAR
                    // ==========================================
                    const Text("Gambar Samping", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 250, width: 400,
                        decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: _imageBase64.isEmpty
                            ? const Center(child: Text("Klik untuk Unggah Gambar"))
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildImageDisplay(_imageBase64),
                                  Positioned(
                                    top: 10, right: 10,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _imageBase64 = '')),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ==========================================
                    // TOMBOL SIMPAN
                    // ==========================================
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}