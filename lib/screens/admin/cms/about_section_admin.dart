import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👇 Import Supabase

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class AboutSectionAdmin extends StatefulWidget {
  const AboutSectionAdmin({super.key});

  @override
  State<AboutSectionAdmin> createState() => _AboutSectionAdminState();
}

class _AboutSectionAdminState extends State<AboutSectionAdmin> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // 👇 Variabel untuk menyimpan URL gambar dari DB, dan File gambar baru dari laptop
  String _currentImageUrl = '';
  Uint8List? _selectedImageBytes;
  String? _selectedImageExt;

  int _sectionId = 1; // ID baris di tabel
  bool _isLoading = true;
  bool _isSaving = false;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadDataFromSupabase();
  }

  // 👇 1. MENGAMBIL DATA DARI SUPABASE
  Future<void> _loadDataFromSupabase() async {
    try {
      final response = await _supabase
          .from('cms_about_us')
          .select()
          .order('id', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _sectionId = response['id'];
          _titleController.text = response['title'] ?? '';
          _descController.text = response['description'] ?? '';
          _currentImageUrl = response['image_url'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // 👇 2. FUNGSI UNTUK MEMILIH FILE GAMBAR DARI LOKAL
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes!;
        _selectedImageExt = result.files.first.extension ?? 'png';
        _currentImageUrl = ''; // Hapus gambar lama dari tampilan
      });
    }
  }

  // Menampilkan gambar (URL dari DB atau Bytes dari lokal)
  Widget _buildImageDisplay() {
    if (_selectedImageBytes != null) {
      return Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    } else if (_currentImageUrl.isNotEmpty) {
      return Image.network(_currentImageUrl, fit: BoxFit.cover);
    }
    return const Center(child: Text("Klik untuk Unggah Gambar"));
  }

  // 👇 3. FUNGSI SIMPAN KE STORAGE LALU KE DATABASE
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(
        context,
        'Penyimpanan gagal. Masih ada form yang kosong!',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String finalImageUrl = _currentImageUrl;

      // Jika admin memilih gambar baru, upload ke Storage dulu!
      if (_selectedImageBytes != null) {
        final fileName =
            'about_${DateTime.now().millisecondsSinceEpoch}.$_selectedImageExt';

        // Upload ke bucket 'cms_images'
        await _supabase.storage
            .from('cms_images')
            .uploadBinary(
              fileName,
              _selectedImageBytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        // Dapatkan URL Publiknya
        finalImageUrl = _supabase.storage
            .from('cms_images')
            .getPublicUrl(fileName);
      }

      // Update tabel di database
      await _supabase
          .from('cms_about_us')
          .update({
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'image_url': finalImageUrl,
          })
          .eq('id', _sectionId);

      if (mounted) {
        showSuccessSnackBar(
          context,
          'About Section Beranda berhasil diperbarui!',
        );
        setState(() {
          _currentImageUrl = finalImageUrl;
          _selectedImageBytes = null; // Reset file picker
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Gagal menyimpan: ${e.toString()}');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Tentang Kami',
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
                    const Text(
                      "Judul Utama",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Contoh: Membantu Anak Bangsa Meraih Mimpi",
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Judul tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Deskripsi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            "Contoh: Vernon Indonesia Pintar bukan sekadar yayasan...",
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Deskripsi tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        const Text(
                          "Gambar Samping",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message:
                              "Gambar ini akan ditampilkan di sebelah teks 'Tentang Kami' pada layar Desktop.",
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
                      "Rekomendasi ukuran: 1000 x 750 piksel (Landscape) agar proporsional dan tidak pecah.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),

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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildImageDisplay(),
                            if (_currentImageUrl.isNotEmpty ||
                                _selectedImageBytes != null)
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
                                    onPressed: () => setState(() {
                                      _currentImageUrl = '';
                                      _selectedImageBytes = null;
                                    }),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
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
