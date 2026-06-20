import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/app_colors.dart';

class ProgramListAdmin extends StatefulWidget {
  const ProgramListAdmin({super.key});

  @override
  State<ProgramListAdmin> createState() => _ProgramListAdminState();
}

class _ProgramListAdminState extends State<ProgramListAdmin> {
  final _supabase = Supabase.instance.client;

  final _headerFormKey = GlobalKey<FormState>();
  final _headerTaglineController = TextEditingController();
  final _headerTitleController = TextEditingController();
  final _headerSubtitleController = TextEditingController();
  bool _isLoadingHeader = true;
  bool _isSavingHeader = false;

  @override
  void initState() {
    super.initState();
    _loadHeaderData();
  }

  @override
  void dispose() {
    _headerTaglineController.dispose();
    _headerTitleController.dispose();
    _headerSubtitleController.dispose();
    super.dispose();
  }

  Future<void> _loadHeaderData() async {
    try {
      final response = await _supabase
          .from('cms_section_headers')
          .select()
          .eq('id', 1)
          .maybeSingle();

      if (response != null) {
        _headerTaglineController.text = response['program_tagline'] ?? '';
        _headerTitleController.text = response['program_title'] ?? '';
        _headerSubtitleController.text = response['program_subtitle'] ?? '';
      }
    } catch (e) {
      debugPrint("Gagal load header data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHeader = false;
        });
      }
    }
  }

  Future<void> _saveHeaderData() async {
    if (!_headerFormKey.currentState!.validate()) return;

    setState(() => _isSavingHeader = true);
    try {
      await _supabase.from('cms_section_headers').update({
        'program_tagline': _headerTaglineController.text.trim(),
        'program_title': _headerTitleController.text.trim(),
        'program_subtitle': _headerSubtitleController.text.trim(),
      }).eq('id', 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Judul section Program berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan judul section: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingHeader = false);
      }
    }
  }

  // Fungsi untuk menghapus data dengan konfirmasi
  Future<void> _hapusProgram(int id, String namaProgram) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          'Apakah Anda yakin ingin menghapus program "$namaProgram"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('programs').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Program berhasil dihapus!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _generateSlug(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'[\s-]+'), '-');
  }

  Future<void> _duplikasiProgram(int id, String namaProgram) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Duplikasi Program",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Seluruh data program "$namaProgram" akan disalin menjadi program baru. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Duplikasi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _supabase
            .from('programs')
            .select()
            .eq('id', id)
            .maybeSingle();

        if (response == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Program tidak ditemukan."),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final countRes = await _supabase.from('programs').select('id');

        final duplicatedData = Map<String, dynamic>.from(response);
        duplicatedData.remove('id');
        duplicatedData.remove('updated_at');
        final newNama = 'Salinan - ${duplicatedData['nama_program'] ?? ''}';
        duplicatedData['nama_program'] = newNama;
        duplicatedData['slug'] = _generateSlug(newNama);
        duplicatedData['sort_order'] = countRes.length;

        await _supabase.from('programs').insert(duplicatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Program berhasil diduplikasi!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menduplikasi: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // HEADER & TOMBOL TAMBAH PROGRAM
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kelola Daftar Program",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tambah, edit, atau hapus program yang akan ditampilkan di web publik",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/cms-program/add');
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Tambah Program Baru",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ==========================================
            // HEADER SETTINGS (CMS)
            // ==========================================
            _isLoadingHeader
                ? const Center(child: LinearProgressIndicator())
                : Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: const Text(
                        "Pengaturan Judul Section (Beranda)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Kelola tagline, judul, dan sub-judul section Program di landing page",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      leading: const Icon(Icons.settings_applications_rounded, color: AppColors.primary),
                      childrenPadding: const EdgeInsets.all(20),
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      children: [
                        Form(
                          key: _headerFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tagline / Kategori",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _headerTaglineController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Contoh: PROGRAM UNGGULAN",
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Tagline tidak boleh kosong'
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Judul Utama (Title)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _headerTitleController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Contoh: Program Beasiswa & Pelatihan VIP",
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Judul tidak boleh kosong'
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Sub-judul / Deskripsi (Subtitle)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _headerSubtitleController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Tuliskan deskripsi singkat mengenai program...",
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Sub-judul tidak boleh kosong'
                                        : null,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isSavingHeader ? null : _saveHeaderData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isSavingHeader
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "SIMPAN JUDUL SECTION",
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
                      ],
                    ),
                  ),

            // ==========================================
            // LIST/TABEL PROGRAM (REAL-TIME DARI SUPABASE)
            // ==========================================
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _supabase
                      .from('programs')
                      .stream(primaryKey: ['id'])
                      .order('id', ascending: true),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final programs = snapshot.data ?? [];

                    if (programs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Belum ada data program. Silakan tambah program baru.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: programs.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final prog = programs[index];
                        final id = prog['id'] as int;
                        final namaProgram =
                            prog['nama_program'] ?? 'Tanpa Judul';
                        final kategori = prog['kategori'] ?? '-';

                        return ListTile(
                          // 👇 UBAH ICON DI SINI 👇
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey.shade100,
                              child: Image.network(
                                (prog['thumbnail_url'] != null &&
                                        prog['thumbnail_url']
                                            .toString()
                                            .isNotEmpty)
                                    ? prog['thumbnail_url'].toString()
                                    : 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          title: Text(
                            namaProgram,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Kategori: $kategori",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Duplikasi",
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () =>
                                    _duplikasiProgram(id, namaProgram),
                              ),
                               IconButton(
                                tooltip: "Edit Program",
                                icon: const Icon(
                                  Icons.edit_document,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  final slug =
                                      prog['slug']?.toString() ?? id.toString();
                                  context.go('/cms-program/edit/$slug');
                                },
                              ),
                              IconButton(
                                tooltip: "Hapus Program",
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _hapusProgram(id, namaProgram),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
