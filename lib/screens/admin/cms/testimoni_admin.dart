// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class TestimoniAdmin extends StatefulWidget {
  const TestimoniAdmin({super.key});

  @override
  State<TestimoniAdmin> createState() => _TestimoniAdminState();
}

class _TestimoniAdminState extends State<TestimoniAdmin> {
  List<Map<String, dynamic>> _testimoniList = [];
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  final _headerFormKey = GlobalKey<FormState>();
  final _headerTaglineController = TextEditingController();
  final _headerTitleController = TextEditingController();
  bool _isLoadingHeader = true;
  bool _isSavingHeader = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadHeaderData();
  }

  @override
  void dispose() {
    _headerTaglineController.dispose();
    _headerTitleController.dispose();
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
        _headerTaglineController.text = response['testimonial_tagline'] ?? '';
        _headerTitleController.text = response['testimonial_title'] ?? '';
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
        'testimonial_tagline': _headerTaglineController.text.trim(),
        'testimonial_title': _headerTitleController.text.trim(),
      }).eq('id', 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Judul section Testimoni berhasil diperbarui!"),
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

  // Fungsi menarik data dari Supabase.
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('testimonials')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _testimoniList = response;
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat testimoni: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFormDialog({Map<String, dynamic>? testimoni}) {
    final isEdit = testimoni != null;
    final nameController = TextEditingController(
      text: isEdit ? testimoni['name'] : '',
    );
    final roleController = TextEditingController(
      text: isEdit ? testimoni['role'] : '',
    );
    final quoteController = TextEditingController(
      text: isEdit ? testimoni['quote'] : '',
    );

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            isEdit ? 'Edit Testimoni' : 'Tambah Testimoni Baru',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText:
                            'Pekerjaan / Role (cth: Alumni Batch 1 - IT)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Pekerjaan/Role tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 15),

                    // 👇 BAGIAN YANG DIUBAH (BATASAN KARAKTER) 👇
                    TextFormField(
                      controller: quoteController,
                      maxLines: 4,
                      maxLength: 200, // Batasan input di layar Admin
                      decoration: const InputDecoration(
                        labelText: 'Kutipan Testimoni',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kutipan testimoni tidak boleh kosong';
                        }
                        if (value.length > 200) {
                          return 'Maksimal 200 karakter!';
                        }
                        return null;
                      },
                    ),

                    // 👆 SAMPAI SINI 👆
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setModalState(() => isSaving = true);

                        final newData = {
                          'name': nameController.text.trim(),
                          'role': roleController.text.trim(),
                          'quote': quoteController.text.trim(),
                        };

                        try {
                          if (isEdit) {
                            await _supabase
                                .from('testimonials')
                                .update(newData)
                                .eq('id', testimoni['id']);
                            if (mounted) {
                              showSuccessSnackBar(
                                context,
                                'Testimoni berhasil diperbarui!',
                              );
                            }
                          } else {
                            await _supabase
                                .from('testimonials')
                                .insert(newData);
                            if (mounted) {
                              showSuccessSnackBar(
                                context,
                                'Testimoni baru berhasil ditambahkan!',
                              );
                            }
                          }
                          _loadData();
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted) {
                            showErrorSnackBar(
                              context,
                              'Gagal menyimpan data: $e',
                            );
                          }
                        } finally {
                          setModalState(() => isSaving = false);
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan Testimoni',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi menghapus data dari Supabase.
  void _hapusTestimoni(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Hapus Testimoni?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus testimoni ini?'),
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
                await _supabase.from('testimonials').delete().eq('id', id);
                _loadData();
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  showSuccessSnackBar(context, 'Testimoni berhasil dihapus!');
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kelola Testimoni',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tambah Testimoni',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

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
                      "Kelola tagline dan judul section Testimoni di landing page",
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
                                hintText: "Contoh: CERITA PERUBAHAN",
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
                                hintText: "Contoh: Bukti Nyata Dampak VIP",
                              ),
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Judul tidak boleh kosong'
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

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_testimoniList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text("Belum ada testimoni. Silakan tambah baru."),
              ),
            )
          else
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _testimoniList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final testimoni = _testimoniList[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.format_quote,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      testimoni['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testimoni['role'] ?? '',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '"${testimoni['quote']}"',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showFormDialog(testimoni: testimoni),
                          tooltip: 'Edit Testimoni',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusTestimoni(testimoni['id']),
                          tooltip: 'Hapus Testimoni',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
