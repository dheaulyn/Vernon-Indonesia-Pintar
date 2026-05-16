import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:file_picker/file_picker.dart';

import '../../../core/app_colors.dart';
import '../../../data/mock_database.dart';

class KelolaMediaAdmin extends StatefulWidget {
  const KelolaMediaAdmin({super.key});

  @override
  State<KelolaMediaAdmin> createState() => _KelolaMediaAdminState();
}

class _KelolaMediaAdminState extends State<KelolaMediaAdmin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, String>> _artikel = [];
  List<Map<String, String>> _galeri = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _artikel = MockDatabase.getSemuaArtikel();
      _galeri = MockDatabase.getSemuaGaleri();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // FUNGSI MENAMPILKAN PESAN BERHASIL (WARNA HIJAU & ROUNDED)
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

  // FUNGSI PINTAR: Menampilkan gambar
  Widget _buildImageDisplay(String imageSource, {BoxFit fit = BoxFit.cover}) {
    if (imageSource.isEmpty) {
      return const Center(child: Icon(Icons.image, color: Colors.grey, size: 40));
    }
    if (imageSource.startsWith('http')) {
      return Image.network(imageSource, fit: fit);
    } 
    try {
      return Image.memory(base64Decode(imageSource), fit: fit);
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.red));
    }
  }

  // FUNGSI UPLOAD
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

  // =========================================================
  // FORM ARTIKEL (TAMBAH / EDIT)
  // =========================================================
  void _showFormArtikel({Map<String, String>? artikelLama}) {
    final titleController = TextEditingController(text: artikelLama?['title'] ?? '');
    final descController = TextEditingController(text: artikelLama?['desc'] ?? '');
    
    String selectedKategori = artikelLama?['kategori'] ?? 'Berita';
    String selectedImage = artikelLama?['image'] ?? ''; 

    const List<String> kategoriOptions = ['Berita', 'Pengumuman', 'Inspirasi', 'Edukasi'];
    final formKey = GlobalKey<FormState>(); // Kunci form untuk validasi

    late quill.QuillController quillController;
    try {
      final content = artikelLama?['content'];
      if (content != null && content.isNotEmpty && content.trim().startsWith('[')) {
        final doc = quill.Document.fromJson(jsonDecode(content) as List<dynamic>);
        quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        final doc = quill.Document();
        if (content != null && content.isNotEmpty) {
          doc.insert(0, content);
        }
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(artikelLama == null ? 'Tambah Artikel Baru' : 'Edit Artikel', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 900,
                child: SingleChildScrollView(
                  child: Form( // Bungkus dengan Form
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Judul Artikel', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: selectedKategori,
                                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                                items: kategoriOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                                onChanged: (val) {
                                  if (val != null) setStateDialog(() => selectedKategori = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 👇 PANDUAN UKURAN GAMBAR ARTIKEL
                                  Text(
                                    "Rekomendasi ukuran sampul: 1280 x 720 piksel (Rasio 16:9)",
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      _pickImage((base64Image) {
                                        setStateDialog(() {
                                          selectedImage = base64Image;
                                        });
                                      });
                                    },
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 55,
                                            height: 55,
                                            color: Colors.grey.shade300,
                                            child: _buildImageDisplay(selectedImage),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(
                                              selectedImage.isEmpty ? "Klik untuk Upload Foto Sampul" : "Foto Sampul Berhasil Terpilih",
                                              style: TextStyle(
                                                color: selectedImage.isEmpty ? Colors.grey.shade600 : AppColors.primary,
                                                fontWeight: selectedImage.isEmpty ? FontWeight.normal : FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (selectedImage.isNotEmpty)
                                            IconButton(
                                              icon: const Icon(Icons.close, color: Colors.red),
                                              onPressed: () => setStateDialog(() => selectedImage = ''),
                                            )
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
                            hintText: 'Ringkasan artikel yang tampil di halaman depan',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 24),

                        const Text('Isi Artikel Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                                child: quill.QuillSimpleToolbar(
                                  controller: quillController,
                                  config: const quill.QuillSimpleToolbarConfig(
                                    showFontFamily: false, showFontSize: false, showSearchButton: false, showInlineCode: false,
                                    showAlignmentButtons: true, showListBullets: true, showListNumbers: true, showQuote: true,
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
                                  config: const quill.QuillEditorConfig(padding: EdgeInsets.zero),
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
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    // Validasi Form
                    if (formKey.currentState!.validate()) {
                      final contentJson = jsonEncode(quillController.document.toDelta().toJson());

                      final newData = <String, String>{
                        'title': titleController.text.trim(),
                        'desc': descController.text.trim(),
                        'content': contentJson,
                        'image': selectedImage, 
                        'kategori': selectedKategori,
                        'date': artikelLama?['date'] ?? 'Hari ini',
                      };

                      if (artikelLama == null) {
                        MockDatabase.tambahArtikel(newData);
                        _showSuccessMessage('Artikel baru berhasil ditambahkan!');
                      } else {
                        MockDatabase.editArtikel(artikelLama['id']!, newData);
                        _showSuccessMessage('Artikel berhasil diperbarui!');
                      }

                      _loadData();
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Simpan Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Hapus Artikel?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              MockDatabase.hapusArtikel(id);
              _loadData();
              Navigator.pop(context);
              _showSuccessMessage('Artikel berhasil dihapus!');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FORM GALERI (TAMBAH / EDIT)
  // =========================================================
  void _showFormGaleri({Map<String, String>? galeriLama}) {
    final titleController = TextEditingController(text: galeriLama?['title'] ?? '');
    String selectedImage = galeriLama?['image'] ?? '';
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(galeriLama == null ? 'Tambah Foto Galeri' : 'Edit Foto Galeri', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: Form( // Bungkus dengan Form
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, // 👇 Ubah agar teks rata kiri
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Judul / Keterangan Foto', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Keterangan foto wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      // 👇 PANDUAN UKURAN GAMBAR GALERI
                      Text(
                        "Rekomendasi ukuran foto: 1080 x 1080 piksel (Square) atau 1200 x 800 piksel agar tampil rapi dalam grid.",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 6),

                      InkWell(
                        onTap: () {
                          _pickImage((base64Image) {
                            setStateDialog(() {
                              selectedImage = base64Image;
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
                          child: selectedImage.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload_file, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 10),
                                    Text("Klik untuk Memilih Foto", style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildImageDisplay(selectedImage),
                                    Positioned(
                                      top: 5, right: 5,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white),
                                          onPressed: () => setStateDialog(() => selectedImage = ''),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (selectedImage.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda harus mengunggah foto!', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                        return;
                      }

                      final newData = {
                        'title': titleController.text.trim(),
                        'image': selectedImage,
                      };

                      if (galeriLama == null) {
                        MockDatabase.tambahGaleri(newData);
                        _showSuccessMessage('Foto baru berhasil ditambahkan!');
                      } else {
                        MockDatabase.editGaleri(galeriLama['id']!, newData);
                        _showSuccessMessage('Foto berhasil diperbarui!');
                      }

                      _loadData();
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
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
        title: const Text('Hapus Foto?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini dari galeri?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              MockDatabase.hapusGaleri(id);
              _loadData();
              Navigator.pop(context);
              _showSuccessMessage('Foto berhasil dihapus!');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD UTAMA
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kelola Media & Publikasi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [Tab(text: 'Kelola Artikel'), Tab(text: 'Kelola Galeri')],
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
              label: const Text('Tulis Artikel Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _artikel.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final a = _artikel[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      clipBehavior: Clip.antiAlias,
                      child: _buildImageDisplay(a['image'] ?? ''), 
                    ),
                    title: Text(a['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${a['date'] ?? ''} • Kategori: ${a['kategori'] ?? '-'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: 'Edit', onPressed: () => _showFormArtikel(artikelLama: a)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Hapus', onPressed: () => _confirmDeleteArtikel(a['id']!)),
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
              label: const Text('Tambah Foto Galeri', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: _galeri.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final g = _galeri[index];

                  return Container(
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageDisplay(g['image'] ?? ''), 

                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent]),
                            ),
                            child: Text(g['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: Row(
                            children: [
                              CircleAvatar(radius: 18, backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 16), onPressed: () => _showFormGaleri(galeriLama: g))),
                              const SizedBox(width: 5),
                              CircleAvatar(radius: 18, backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16), onPressed: () => _confirmDeleteGaleri(g['id']!))),
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