import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👇 Import Supabase

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class HeroBannerAdmin extends StatefulWidget {
  const HeroBannerAdmin({super.key});

  @override
  State<HeroBannerAdmin> createState() => _HeroBannerAdminState();
}

class _HeroBannerAdminState extends State<HeroBannerAdmin> {
  final _formKey = GlobalKey<FormState>();

  final _taglineController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  // 👇 Variabel untuk menyimpan URL gambar dari DB, dan File gambar baru dari laptop
  String _currentImageUrl = '';
  Uint8List? _selectedImageBytes;
  String? _selectedImageExt;

  int _bannerId = 1; // ID baris di tabel
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
          .from('cms_hero_banners')
          .select()
          .order('id', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _bannerId = response['id'];
          _taglineController.text = response['tagline'] ?? '';
          _titleController.text = response['title'] ?? '';
          _subtitleController.text = response['subtitle'] ?? '';
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
    _taglineController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  // 👇 2. FUNGSI UNTUK MEMILIH FILE GAMBAR (MENYIMPAN BYTES, BUKAN BASE64)
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true, // Penting untuk Web
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
      // Tampilkan gambar yang baru dipilih dari laptop
      return Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    } else if (_currentImageUrl.isNotEmpty) {
      // Tampilkan gambar yang sudah ada di database
      return Image.network(_currentImageUrl, fit: BoxFit.cover);
    }
    return const Center(child: Text("Klik untuk Unggah Gambar"));
  }

  // 👇 3. FUNGSI SIMPAN KE STORAGE LALU KE DATABASE
  Future<void> _saveHeroBanner() async {
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
            'hero_${DateTime.now().millisecondsSinceEpoch}.$_selectedImageExt';

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
          .from('cms_hero_banners')
          .update({
            'tagline': _taglineController.text.trim(),
            'title': _titleController.text.trim(),
            'subtitle': _subtitleController.text.trim(),
            'image_url': finalImageUrl,
          })
          .eq('id', _bannerId);

      if (mounted) {
        showSuccessSnackBar(context, 'Hero Banner berhasil diperbarui!');
        setState(() {
          _currentImageUrl = finalImageUrl;
          _selectedImageBytes = null; // Reset file picker
        });
      }
    } catch (e) {
      if (mounted)
        showErrorSnackBar(context, 'Gagal menyimpan: ${e.toString()}');
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
              'Kelola Hero Banner',
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
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Teks Kecil (Tagline)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _taglineController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Tagline tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Judul Utama (Gunakan \\n untuk baris baru)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Your Support\\nUnlocks\\nEqual Futures",
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Judul Utama tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Sub-judul (Teks Panjang)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subtitleController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Sub-judul tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Text(
                          "Gambar Latar Belakang",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message:
                              "Gambar akan ditampilkan penuh (full-width) di beranda.",
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
                      "Rekomendasi ukuran: 1920 x 1080 piksel (Landscape) agar tidak pecah di layar Desktop.",
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
                        height: 200,
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
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveHeroBanner,
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
