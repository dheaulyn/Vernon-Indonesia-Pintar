import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';
import '../../../../data/mock_database.dart';

class ProfilYayasanAdmin extends StatefulWidget {
  const ProfilYayasanAdmin({super.key});

  @override
  State<ProfilYayasanAdmin> createState() => _ProfilYayasanAdminState();
}

class _ProfilYayasanAdminState extends State<ProfilYayasanAdmin> {
  // Kunci form untuk validasi
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _visionController = TextEditingController();

  final List<TextEditingController> _missionControllers = [];
  String _imageBase64 = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = MockDatabase.getProfilYayasanData();
    setState(() {
      _titleController.text = data['title'] ?? '';
      _descController.text = data['description'] ?? '';
      _visionController.text = data['vision_text'] ?? '';
      _imageBase64 = data['image'] ?? '';

      _missionControllers.clear();
      if (data['mission_points'] != null) {
        List<dynamic> points = data['mission_points'];
        for (var point in points) {
          _missionControllers.add(
            TextEditingController(text: point.toString()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _visionController.dispose();
    for (var controller in _missionControllers) {
      controller.dispose();
    }
    super.dispose();
  }


  // FUNGSI DIALOG KONFIRMASI HAPUS
  void _confirmDelete(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay(String imageSource) {
    if (imageSource.isEmpty)
      return const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      );
    if (imageSource.startsWith('http'))
      return Image.network(imageSource, fit: BoxFit.cover);
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
    if (_formKey.currentState!.validate()) {
      List<String> updatedMissions = _missionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      MockDatabase.updateProfilYayasanData({
        'title': _titleController.text,
        'description': _descController.text,
        'vision_text': _visionController.text,
        'mission_points': updatedMissions,
        'image': _imageBase64,
      });

      showSuccessSnackBar(context, 'Profil Yayasan berhasil diperbarui!');
    } else {
      showErrorSnackBar(context, 'Penyimpanan gagal. Masih ada form yang kosong!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Profil Yayasan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. TENTANG KAMI & GAMBAR
                    // ==========================================
                    const Text(
                      "Judul Utama (Apa itu VIP?)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Judul tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Deskripsi Panjang",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Deskripsi tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 30),

                    // 👇 PANDUAN UKURAN GAMBAR DITAMBAHKAN DI SINI
                    Row(
                      children: [
                        const Text(
                          "Gambar Samping",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message:
                              "Gambar akan ditampilkan di sebelah deskripsi pada layar Desktop.",
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rekomendasi ukuran: 800 x 600 piksel (Landscape 4:3) agar proporsional dan tidak terpotong.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 👆 SELESAI PANDUAN UKURAN GAMBAR
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 250,
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imageBase64.isEmpty
                            ? const Center(
                                child: Text("Klik untuk Unggah Gambar"),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildImageDisplay(_imageBase64),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            setState(() => _imageBase64 = ''),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),

                    // ==========================================
                    // 2. VISI & MISI
                    // ==========================================
                    const Row(
                      children: [
                        Text("✨ ", style: TextStyle(fontSize: 18)),
                        Text(
                          "Teks Visi (Vision)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _visionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Teks Visi tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text("🚀 ", style: TextStyle(fontSize: 18)),
                            Text(
                              "Poin Misi (Mission)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _missionControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah Misi"),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: List.generate(_missionControllers.length, (
                          index,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: TextFormField(
                                    controller: _missionControllers[index],
                                    decoration: const InputDecoration(
                                      hintText: "Masukkan teks misi...",
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? 'Poin misi wajib diisi'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(
                                    'Hapus Poin Misi?',
                                    'Apakah Anda yakin ingin menghapus poin misi ini?',
                                    () {
                                      setState(() {
                                        _missionControllers[index].dispose();
                                        _missionControllers.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),

                    // ==========================================
                    // 3. TOMBOL SIMPAN
                    // ==========================================
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
