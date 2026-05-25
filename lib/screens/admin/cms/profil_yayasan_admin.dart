import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class ProfilYayasanAdmin extends StatefulWidget {
  const ProfilYayasanAdmin({super.key});

  @override
  State<ProfilYayasanAdmin> createState() => _ProfilYayasanAdminState();
}

class _ProfilYayasanAdminState extends State<ProfilYayasanAdmin> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _visionController = TextEditingController();

  // 👇 List controller dinamis untuk menampung banyak Misi
  List<TextEditingController> _missionControllers = [];

  String _currentImageUrl = '';
  Uint8List? _selectedImageBytes;
  String? _selectedImageExt;

  int _profileId = 1;
  bool _isLoading = true;
  bool _isSaving = false;

  final _supabase = Supabase.instance.client;

  
  @override
  void initState() {
    super.initState();
    _loadDataFromSupabase();
  }

  // 👇 1. KONEKSI DATA FROM SUPABASE
  Future<void> _loadDataFromSupabase() async {
    try {
      final response = await _supabase
          .from('cms_foundation_profiles')
          .select()
          .order('id', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _profileId = response['id'];
          _titleController.text = response['title'] ?? '';
          _descController.text = response['description'] ?? '';
          _visionController.text = response['vision'] ?? '';
          _currentImageUrl = response['image_url'] ?? '';

          // Bongkar array JSONMisi menjadi List TextEditingController
          final List<dynamic> internalMissions = response['missions'] ?? [];
          _missionControllers = internalMissions
              .map((m) => TextEditingController(text: m.toString()))
              .toList();
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
    _visionController.dispose();
    for (var controller in _missionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 👇 2. MANAJEMEN MISI DINAMIS (TAMBAH / HAPUS BARIS)
  void _addMissionField() {
    setState(() {
      _missionControllers.add(TextEditingController());
    });
  }

  void _removeMissionField(int index) {
    setState(() {
      _missionControllers[index].dispose();
      _missionControllers.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes!;
        _selectedImageExt = result.files.first.extension ?? 'png';
        _currentImageUrl = '';
      });
    }
  }

  Widget _buildImageDisplay() {
    if (_selectedImageBytes != null) {
      return Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    } else if (_currentImageUrl.isNotEmpty) {
      return Image.network(_currentImageUrl, fit: BoxFit.cover);
    }
    return const Center(child: Text("Klik untuk Unggah Gambar"));
  }

  // 👇 3. PROSES SAVE COMPREHENSIVE KONTEN KE CLOUD
  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(
        context,
        'Penyimpanan gagal. Mohon lengkapi seluruh formulir!',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String finalImageUrl = _currentImageUrl;

      if (_selectedImageBytes != null) {
        final fileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.$_selectedImageExt';
        await _supabase.storage
            .from('cms_images')
            .uploadBinary(
              fileName,
              _selectedImageBytes!,
              fileOptions: const FileOptions(upsert: true),
            );
        finalImageUrl = _supabase.storage
            .from('cms_images')
            .getPublicUrl(fileName);
      }

      // Kumpulkan teks dari semua inputan misi yang diisi admin
      List<String> textMissions = _missionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      await _supabase
          .from('cms_foundation_profiles')
          .update({
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'vision': _visionController.text.trim(),
            'missions':
                textMissions, // Supabase otomatis merubah List ke format JSONB Array
            'image_url': finalImageUrl,
          })
          .eq('id', _profileId);

      if (mounted) {
        showSuccessSnackBar(context, 'Profil Yayasan berhasil diperbarui!');
        setState(() {
          _currentImageUrl = finalImageUrl;
          _selectedImageBytes = null;
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal menyimpan data: $e');
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
                          ? 'Judul utama tidak boleh kosong'
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
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Text(
                          "Gambar Samping",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message:
                              "Rekomendasi ukuran: 800 x 600 piksel (Landscape 4:3) agar proporsional dan tidak terpotong.",
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
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

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Divider(),
                    ),

                    const Text(
                      "✨ Teks Visi (Vision)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _visionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Visi tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 25),

                    // ========================================================
                    // BAGIAN LIST MISI DINAMIS (Sesuai Gambar Screenshot 4)
                    // ========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "🚀 Poin Misi (Mission)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addMissionField,
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "Tambah Misi",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_missionControllers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            "Belum ada poin misi. Klik 'Tambah Misi' untuk menambah.",
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _missionControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _missionControllers[index],
                                    decoration: InputDecoration(
                                      hintText:
                                          "Tuliskan poin misi ke-${index + 1}",
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                        ? 'Poin misi tidak boleh kosong'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                CircleAvatar(
                                  backgroundColor: Colors.red.shade50,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeMissionField(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfileData,
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
