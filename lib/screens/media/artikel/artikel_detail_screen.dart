import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '/../core/app_colors.dart';
import '../../shared/custom_navbar.dart';
import '../../shared/custom_footer.dart';

class ArtikelDetailScreen extends StatefulWidget {
  final Map<String, String> artikel;

  const ArtikelDetailScreen({
    super.key,
    required this.artikel,
  });

  @override
  State<ArtikelDetailScreen> createState() => _ArtikelDetailScreenState();
}

class _ArtikelDetailScreenState extends State<ArtikelDetailScreen> {
  quill.QuillController? _quillController;
  bool _isRichText = false;

  @override
  void initState() {
    super.initState();
    _initQuill();
  }

  // =========================================================
  // MEMBACA DATA QUILL DELTA JSON
  // =========================================================
  void _initQuill() {
    final content = widget.artikel['content'] ?? '';

    // Jika konten berupa JSON Delta Quill
    if (content.trim().startsWith('[')) {
      try {
        final List<dynamic> jsonData =
            jsonDecode(content.trim()) as List<dynamic>;

        final document = quill.Document.fromJson(jsonData);

        _quillController = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );

        _isRichText = true;
        return;
      } catch (e) {
        debugPrint('Gagal membaca format Quill: $e');
      }
    }

    // Fallback ke teks biasa
    _isRichText = false;
    _quillController = null;
  }

  @override
  void dispose() {
    _quillController?.dispose();
    super.dispose();
  }

  // 👇 FUNGSI PINTAR: Untuk merender gambar URL maupun Base64
  Widget _buildImageDisplay(String imageSource, {BoxFit fit = BoxFit.cover}) {
    if (imageSource.isEmpty) {
      return const Icon(Icons.image_rounded, size: 80, color: Colors.black12);
    }
    if (imageSource.startsWith('http')) {
      return Image.network(imageSource, fit: fit);
    } 
    try {
      return Image.memory(base64Decode(imageSource), fit: fit);
    } catch (e) {
      return const Icon(Icons.broken_image, size: 80, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final String imageSource = widget.artikel['image'] ?? ''; // 👇 Ambil data gambar

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(),

            // =================================================
            // KONTEN ARTIKEL
            // =================================================
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: EdgeInsets.all(isMobile ? 20 : 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tombol kembali
                    InkWell(
                      onTap: () => context.go('/media'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kembali ke Media',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Kategori dan tanggal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.artikel['kategori'] ?? 'Berita',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          widget.artikel['date'] ?? '-',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Judul artikel
                    Text(
                      widget.artikel['title'] ?? 'Judul Artikel Tidak Ditemukan',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 36,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 👇 MENAMPILKAN HERO IMAGE ARTIKEL
                    Container(
                      width: double.infinity,
                      height: isMobile ? 200 : 400,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias, // Wajib agar ujung gambar melengkung
                      child: _buildImageDisplay(imageSource),
                    ),

                    const SizedBox(height: 40),

                    // =================================================
                    // KONTEN ARTIKEL (QUILL / TEXT BIASA)
                    // =================================================
                    if (_isRichText && _quillController != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AbsorbPointer(
                          child: quill.QuillEditor.basic(
                            controller: _quillController!,
                            config: const quill.QuillEditorConfig(
                              showCursor: false,
                              expands: false,
                              padding: EdgeInsets.zero,
                              scrollable: false,
                              autoFocus: false,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        widget.artikel['content'] ?? widget.artikel['desc'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: Colors.black87,
                        ),
                      ),

                    const SizedBox(height: 60),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 20),

                    // Share section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bagikan artikel ini:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.link, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}