import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../core/app_colors.dart';
import '/../../data/mock_database.dart';

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

  // =========================================================
  // FORM ARTIKEL (TAMBAH / EDIT)
  // =========================================================
  void _showFormArtikel({Map<String, String>? artikelLama}) {
    final titleController = TextEditingController(
      text: artikelLama?['title'] ?? '',
    );

    final descController = TextEditingController(
      text: artikelLama?['desc'] ?? '',
    );

    String selectedKategori = artikelLama?['kategori'] ?? 'Berita';

    const List<String> kategoriOptions = [
      'Berita',
      'Pengumuman',
      'Inspirasi',
      'Edukasi',
    ];

    // ==============================
    // Inisialisasi Quill Controller
    // ==============================
    late quill.QuillController quillController;

    try {
      final content = artikelLama?['content'];

      if (content != null &&
          content.isNotEmpty &&
          content.trim().startsWith('[')) {
        // Data dalam format JSON Delta Quill
        final doc = quill.Document.fromJson(
          jsonDecode(content) as List<dynamic>,
        );

        quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        // Data teks biasa
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                artikelLama == null
                    ? 'Tambah Artikel Baru'
                    : 'Edit Artikel',
              ),
              content: SizedBox(
                width: 900,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Artikel',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kategori
                      DropdownButtonFormField<String>(
                        value: selectedKategori,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: kategoriOptions
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() {
                              selectedKategori = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      TextFormField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi Singkat',
                          hintText:
                              'Ringkasan artikel yang tampil di halaman depan',
                          border: OutlineInputBorder(),
                        ),
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

                      // Editor Container
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Toolbar
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: quill.QuillSimpleToolbar(
                                controller: quillController,
                                config:
                                    const quill.QuillSimpleToolbarConfig(
                                  showFontFamily: false,
                                  showFontSize: false,
                                  showSearchButton: false,
                                  showInlineCode: false,
                                  showAlignmentButtons: true, // Memunculkan Rata Kiri, Tengah, Kanan, Justify
                                  showListBullets: true,      // Memunculkan format Bullet Points
                                  showListNumbers: true,      // Memunculkan format Angka (1, 2, 3)
                                  showQuote: true,
                                ),
                              ),
                            ),

                            const Divider(height: 1),

                            // Editor
                            Container(
                              height: 400,
                              padding: const EdgeInsets.all(12),
                              color: Colors.white,
                              child: quill.QuillEditor.basic(
                                controller: quillController,
                                config:
                                    const quill.QuillEditorConfig(
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Judul dan deskripsi wajib diisi.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Simpan Quill Delta ke JSON String
                    final contentJson = jsonEncode(
                      quillController.document
                          .toDelta()
                          .toJson(),
                    );

                    final newData = <String, String>{
                      'title': titleController.text.trim(),
                      'desc': descController.text.trim(),
                      'content': contentJson,
                      'kategori': selectedKategori,
                      'date': artikelLama?['date'] ?? 'Hari ini',
                    };

                    if (artikelLama == null) {
                      MockDatabase.tambahArtikel(newData);
                    } else {
                      MockDatabase.editArtikel(
                        artikelLama['id']!,
                        newData,
                      );
                    }

                    _loadData();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // FORM GALERI
  // =========================================================
  void _showFormGaleri({Map<String, String>? galeriLama}) {
    final titleController = TextEditingController(
      text: galeriLama?['title'] ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            galeriLama == null
                ? 'Tambah Foto Galeri'
                : 'Edit Judul Foto',
          ),
          content: SizedBox(
            width: 400,
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul / Keterangan Foto',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                if (galeriLama == null) {
                  MockDatabase.tambahGaleri(
                    titleController.text.trim(),
                  );
                } else {
                  MockDatabase.editGaleri(
                    galeriLama['id']!,
                    titleController.text.trim(),
                  );
                }

                _loadData();
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelola Media & Publikasi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
              children: [
                _buildArtikelTab(),
                _buildGaleriTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TAB ARTIKEL
  // =========================================================
  Widget _buildArtikelTab() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showFormArtikel(),
              icon: const Icon(Icons.add),
              label: const Text('Tulis Artikel Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: _artikel.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  final a = _artikel[index];

                  return ListTile(
                    title: Text(
                      a['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${a['date'] ?? ''} • Kategori: ${a['kategori'] ?? '-'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () =>
                              _showFormArtikel(
                            artikelLama: a,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            MockDatabase.hapusArtikel(
                              a['id']!,
                            );
                            _loadData();
                          },
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

  // =========================================================
  // TAB GALERI
  // =========================================================
  Widget _buildGaleriTab() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showFormGaleri(),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Tambah Foto Galeri'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: _galeri.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final g = _galeri[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding:
                                const EdgeInsets.all(8),
                            decoration:
                                const BoxDecoration(
                              color: Colors.black54,
                              borderRadius:
                                  BorderRadius.vertical(
                                bottom:
                                    Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              g['title'] ?? '',
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 0,
                          right: 0,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    _showFormGaleri(
                                  galeriLama: g,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.redAccent,
                                ),
                                onPressed: () {
                                  MockDatabase
                                      .hapusGaleri(
                                    g['id']!,
                                  );
                                  _loadData();
                                },
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