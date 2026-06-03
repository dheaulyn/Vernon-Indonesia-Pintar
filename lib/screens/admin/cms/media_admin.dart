// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../core/snackbar_helper.dart';

class KelolaMediaAdmin extends StatefulWidget {
  const KelolaMediaAdmin({super.key});

  @override
  State<KelolaMediaAdmin> createState() => _KelolaMediaAdminState();
}

class _KelolaMediaAdminState extends State<KelolaMediaAdmin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _artikel = [];
  List<Map<String, dynamic>> _galeri = [];
  bool _isLoading = true;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  // =========================================================================
  // 1. MENGAMBIL DATA DARI TABEL ARTIKEL
  // =========================================================================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        // Pisahkan data berdasarkan Kategori.
        _artikel = response.where((e) => e['category'] != 'Galeri').toList();
        _galeri = response.where((e) => e['category'] == 'Galeri').toList();
      });
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNGSI: MENAMPILKAN GAMBAR (URL ATAU BYTES LOKAL)
  // =========================================================================
  Widget _buildImageDisplay({
    String url = '',
    Uint8List? bytes,
    BoxFit fit = BoxFit.cover,
  }) {
    if (bytes != null) {
      return Image.memory(bytes, fit: fit);
    }
    if (url.isNotEmpty && url.startsWith('http')) {
      return Image.network(url, fit: fit);
    }
    return const Center(child: Icon(Icons.image, color: Colors.grey, size: 40));
  }

  // =========================================================================
  // FUNGSI UPLOAD FILE KE DIALOG
  // =========================================================================
  Future<void> _pickImageForDialog(
    Function(Uint8List bytes, String ext) onPicked,
  ) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      onPicked(
        result.files.first.bytes!,
        result.files.first.extension ?? 'png',
      );
    }
  }

  // =========================================================================
  // FORM ARTIKEL (TAMBAH / EDIT)
  // =========================================================================
  void _showFormArtikel({Map<String, dynamic>? artikelLama}) {
    final titleController = TextEditingController(
      text: artikelLama?['title'] ?? '',
    );
    final descController = TextEditingController(
      text: artikelLama?['description'] ?? '',
    );

    String selectedKategori = artikelLama?['category'] ?? 'Berita';
    String currentImageUrl = artikelLama?['image_url'] ?? '';

    // Variabel untuk menyimpan gambar baru jika admin memilih dari penyimpanan lokal.
    Uint8List? newImageBytes;
    String? newImageExt;
    bool isSaving = false;

    const List<String> kategoriOptions = [
      'Berita',
      'Pengumuman',
      'Inspirasi',
      'Edukasi',
    ];
    final formKey = GlobalKey<FormState>();

    late quill.QuillController quillController;
    try {
      final content = artikelLama?['content'];
      if (content != null &&
          content.isNotEmpty &&
          content.trim().startsWith('[')) {
        final doc = quill.Document.fromJson(
          jsonDecode(content) as List<dynamic>,
        );
        quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        final doc = quill.Document();
        if (content != null && content.isNotEmpty) doc.insert(0, content);
        quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (_) {
      quillController = quill.QuillController.basic();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                artikelLama == null ? 'Tambah Artikel Baru' : 'Edit Artikel',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 900,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Judul Artikel',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Judul tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedKategori,
                                decoration: const InputDecoration(
                                  labelText: 'Kategori',
                                  border: OutlineInputBorder(),
                                ),
                                items: kategoriOptions
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setStateDialog(
                                      () => selectedKategori = val,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Rekomendasi ukuran sampul: 1280 x 720 piksel (Rasio 16:9)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      _pickImageForDialog((bytes, ext) {
                                        setStateDialog(() {
                                          newImageBytes = bytes;
                                          newImageExt = ext;
                                          currentImageUrl =
                                              '';
                                        });
                                      });
                                    },
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 55,
                                            height: 55,
                                            color: Colors.grey.shade300,
                                            child: _buildImageDisplay(
                                              url: currentImageUrl,
                                              bytes: newImageBytes,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(
                                              (currentImageUrl.isEmpty &&
                                                      newImageBytes == null)
                                                  ? "Klik untuk Upload Foto Sampul"
                                                  : "Foto Sampul Berhasil Terpilih",
                                              style: TextStyle(
                                                color:
                                                    (currentImageUrl.isEmpty &&
                                                        newImageBytes == null)
                                                    ? Colors.grey.shade600
                                                    : AppColors.primary,
                                                fontWeight:
                                                    (currentImageUrl.isEmpty &&
                                                        newImageBytes == null)
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (currentImageUrl.isNotEmpty ||
                                              newImageBytes != null)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  setStateDialog(() {
                                                    currentImageUrl = '';
                                                    newImageBytes = null;
                                                  }),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: descController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi Singkat',
                            hintText:
                                'Ringkasan artikel yang tampil di halaman depan',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Deskripsi tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Isi Artikel Lengkap',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: quill.QuillSimpleToolbar(
                                  controller: quillController,
                                  config: const quill.QuillSimpleToolbarConfig(
                                    showFontFamily: false,
                                    showFontSize: false,
                                    showSearchButton: false,
                                    showInlineCode: false,
                                    showAlignmentButtons: true,
                                    showListBullets: true,
                                    showListNumbers: true,
                                    showQuote: true,
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              Container(
                                height: 400,
                                padding: const EdgeInsets.all(12),
                                color: Colors.white,
                                child: quill.QuillEditor.basic(
                                  controller: quillController,
                                  config: const quill.QuillEditorConfig(
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateDialog(() => isSaving = true);
                            try {
                              String finalImageUrl = currentImageUrl;

                              // Jika ada gambar baru, upload ke Storage.
                              if (newImageBytes != null) {
                                final fileName =
                                    'artikel_${DateTime.now().millisecondsSinceEpoch}.$newImageExt';
                                await _supabase.storage
                                    .from('cms_images')
                                    .uploadBinary(
                                      fileName,
                                      newImageBytes!,
                                      fileOptions: const FileOptions(
                                        upsert: true,
                                      ),
                                    );
                                finalImageUrl = _supabase.storage
                                    .from('cms_images')
                                    .getPublicUrl(fileName);
                              }

                              final contentJson = jsonEncode(
                                quillController.document.toDelta().toJson(),
                              );
                              // Format tanggal hari ini cth: 10 Mei 2026.
                              final String todayDate = DateFormat(
                                'dd MMM yyyy',
                                'id_ID',
                              ).format(DateTime.now());

                              final newData = {
                                'title': titleController.text.trim(),
                                'description': descController.text.trim(),
                                'content': contentJson,
                                'image_url': finalImageUrl,
                                'category': selectedKategori,
                                'date': artikelLama?['date'] ?? todayDate,
                              };

                              if (artikelLama == null) {
                                // Karena id adalah UUID text, kita generate ID unik memakai timestamp.
                                newData['id'] =
                                    'art-${DateTime.now().millisecondsSinceEpoch}';
                                await _supabase
                                    .from('articles')
                                    .insert(newData);
                                if (mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    'Artikel baru berhasil ditambahkan!',
                                  );
                                }
                              } else {
                                await _supabase
                                    .from('articles')
                                    .update(newData)
                                    .eq('id', artikelLama['id']);
                                if (mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    'Artikel berhasil diperbarui!',
                                  );
                                }
                              }

                              _loadData();
                              if (mounted) Navigator.pop(dialogContext);
                            } catch (e) {
                              if (mounted) {
                                showErrorSnackBar(
                                  context,
                                  'Terjadi kesalahan: $e',
                                );
                              }
                            } finally {
                              setStateDialog(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Artikel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteArtikel(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Hapus Artikel?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
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
            onPressed: () async {
              try {
                await _supabase.from('articles').delete().eq('id', id);
                _loadData();
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  showSuccessSnackBar(context, 'Artikel berhasil dihapus!');
                }
              } catch (e) {
                if (mounted) showErrorSnackBar(context, 'Gagal menghapus: $e');
              }
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

  // =========================================================================
  // FORM GALERI (TAMBAH / EDIT)
  // =========================================================================
  void _showFormGaleri({Map<String, dynamic>? galeriLama}) {
    final titleController = TextEditingController(
      text: galeriLama?['title'] ?? '',
    );

    String currentImageUrl = galeriLama?['image_url'] ?? '';
    Uint8List? newImageBytes;
    String? newImageExt;
    bool isSaving = false;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                galeriLama == null ? 'Tambah Foto Galeri' : 'Edit Foto Galeri',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul / Keterangan Foto',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Keterangan foto wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Rekomendasi ukuran foto: 1080 x 1080 piksel (Square) atau 1200 x 800 piksel agar tampil rapi dalam grid.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () {
                          _pickImageForDialog((bytes, ext) {
                            setStateDialog(() {
                              newImageBytes = bytes;
                              newImageExt = ext;
                              currentImageUrl = '';
                            });
                          });
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              (currentImageUrl.isEmpty && newImageBytes == null)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Klik untuk Memilih Foto",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildImageDisplay(
                                      url: currentImageUrl,
                                      bytes: newImageBytes,
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => setStateDialog(() {
                                            currentImageUrl = '';
                                            newImageBytes = null;
                                          }),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            if (currentImageUrl.isEmpty &&
                                newImageBytes == null) {
                              showErrorSnackBar(
                                context,
                                'Anda harus mengunggah foto!',
                              );
                              return;
                            }

                            setStateDialog(() => isSaving = true);
                            try {
                              String finalImageUrl = currentImageUrl;
                              if (newImageBytes != null) {
                                final fileName =
                                    'galeri_${DateTime.now().millisecondsSinceEpoch}.$newImageExt';
                                await _supabase.storage
                                    .from('cms_images')
                                    .uploadBinary(
                                      fileName,
                                      newImageBytes!,
                                      fileOptions: const FileOptions(
                                        upsert: true,
                                      ),
                                    );
                                finalImageUrl = _supabase.storage
                                    .from('cms_images')
                                    .getPublicUrl(fileName);
                              }

                              final String todayDate = DateFormat(
                                'dd MMM yyyy',
                                'id_ID',
                              ).format(DateTime.now());

                              final newData = {
                                'title': titleController.text.trim(),
                                'image_url': finalImageUrl,
                                'category':
                                    'Galeri',
                                'description': '',
                                'content': '',
                                'date': galeriLama?['date'] ?? todayDate,
                              };

                              if (galeriLama == null) {
                                newData['id'] =
                                    'gal-${DateTime.now().millisecondsSinceEpoch}';
                                await _supabase
                                    .from('articles')
                                    .insert(newData);
                                if (mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    'Foto baru berhasil ditambahkan!',
                                  );
                                }
                              } else {
                                await _supabase
                                    .from('articles')
                                    .update(newData)
                                    .eq('id', galeriLama['id']);
                                if (mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    'Foto berhasil diperbarui!',
                                  );
                                }
                              }

                              _loadData();
                              if (mounted) Navigator.pop(dialogContext);
                            } catch (e) {
                              if (mounted) {
                                showErrorSnackBar(
                                  context,
                                  'Terjadi kesalahan: $e',
                                );
                              }
                            } finally {
                              setStateDialog(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteGaleri(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Hapus Foto?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus foto ini dari galeri?',
        ),
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
            onPressed: () async {
              try {
                await _supabase.from('articles').delete().eq('id', id);
                _loadData();
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  showSuccessSnackBar(context, 'Foto berhasil dihapus!');
                }
              } catch (e) {
                if (mounted) showErrorSnackBar(context, 'Gagal menghapus: $e');
              }
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

  // =========================================================================
  // BUILD UTAMA
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelola Media & Publikasi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Kelola Artikel'),
                Tab(text: 'Kelola Galeri'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildArtikelTab(), _buildGaleriTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtikelTab() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showFormArtikel(),
              icon: const Icon(Icons.add),
              label: const Text(
                'Tulis Artikel Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _artikel.isEmpty
                  ? const Center(child: Text("Belum ada artikel."))
                  : ListView.separated(
                      itemCount: _artikel.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final a = _artikel[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildImageDisplay(
                              url: a['image_url'] ?? '',
                            ),
                          ),
                          title: Text(
                            a['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${a['date'] ?? ''} • Kategori: ${a['category'] ?? '-'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Edit',
                                onPressed: () =>
                                    _showFormArtikel(artikelLama: a),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Hapus',
                                onPressed: () =>
                                    _confirmDeleteArtikel(a['id']!),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaleriTab() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showFormGaleri(),
              icon: const Icon(Icons.add_a_photo),
              label: const Text(
                'Tambah Foto Galeri',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _galeri.isEmpty
                  ? const Center(child: Text("Belum ada foto galeri."))
                  : GridView.builder(
                      itemCount: _galeri.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final g = _galeri[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildImageDisplay(url: g['image_url'] ?? ''),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black87,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    g['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        onPressed: () =>
                                            _showFormGaleri(galeriLama: g),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                          size: 16,
                                        ),
                                        onPressed: () =>
                                            _confirmDeleteGaleri(g['id']!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
