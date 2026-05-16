import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/app_colors.dart';
import '../../../../data/mock_database.dart'; 

class HeroBannerAdmin extends StatefulWidget {
  const HeroBannerAdmin({super.key});

  @override
  State<HeroBannerAdmin> createState() => _HeroBannerAdminState();
}

class _HeroBannerAdminState extends State<HeroBannerAdmin> {
  // 👇 Kunci form untuk validasi
  final _formKey = GlobalKey<FormState>();

  final _taglineController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  String _heroImageBase64 = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final heroData = MockDatabase.getHomeHeroData();
    setState(() {
      _taglineController.text = heroData['tagline'] ?? '';
      _titleController.text = heroData['title'] ?? '';
      _subtitleController.text = heroData['subtitle'] ?? '';
      _heroImageBase64 = heroData['image'] ?? '';
    });
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  // 👇 FUNGSI MENAMPIL PESAN BERHASIL (WARNA HIJAU & ROUNDED)
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

  // Menampilkan gambar (Bisa baca URL dummy atau Base64 hasil upload lokal)
  Widget _buildImageDisplay(String imageSource) {
    if (imageSource.isEmpty) return const Center(child: Icon(Icons.image, color: Colors.grey, size: 40));
    if (imageSource.startsWith('http')) return Image.network(imageSource, fit: BoxFit.cover);
    try {
      return Image.memory(base64Decode(imageSource), fit: BoxFit.cover);
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.red));
    }
  }

  Future<void> _pickImage(Function(String) onImagePicked) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true, 
    );

    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      final base64String = base64Encode(bytes);
      onImagePicked(base64String);
    }
  }

  void _saveHeroBanner() {
    // 👇 Cek validasi sebelum menyimpan
    if (_formKey.currentState!.validate()) {
      MockDatabase.updateHomeHeroData({
        'tagline': _taglineController.text.trim(),
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'image': _heroImageBase64,
      });
      _showSuccessMessage('Hero Banner berhasil diperbarui!');
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
            const Text('Kelola Hero Banner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 2, // 👇 Menambah sedikit bayangan agar seragam
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Teks Kecil (Tagline)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _taglineController, 
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Tagline tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text("Judul Utama (Gunakan \\n untuk baris baru)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController, 
                      maxLines: 3, 
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Your Support\\nUnlocks\\nEqual Futures"),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Judul Utama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text("Sub-judul (Teks Panjang)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subtitleController, 
                      maxLines: 3, 
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Sub-judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 20),

                    // 👇 PANDUAN UKURAN GAMBAR DITAMBAHKAN DI SINI
                    Row(
                      children: [
                        const Text("Gambar Latar Belakang", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: "Gambar akan ditampilkan penuh (full-width) di beranda.",
                          child: Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rekomendasi ukuran: 1920 x 1080 piksel (Landscape) agar tidak pecah di layar Desktop.",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    // 👆 SELESAI PANDUAN UKURAN GAMBAR

                    InkWell(
                      onTap: () {
                        _pickImage((base64Image) {
                          setState(() => _heroImageBase64 = base64Image);
                        });
                      },
                      child: Container(
                        height: 200, width: 400,
                        decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: _heroImageBase64.isEmpty
                            ? const Center(child: Text("Klik untuk Unggah Gambar"))
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildImageDisplay(_heroImageBase64),
                                  Positioned(
                                    top: 10, right: 10,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _heroImageBase64 = '')),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _saveHeroBanner,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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