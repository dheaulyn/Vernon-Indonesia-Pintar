import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👇 Import Supabase

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class TestimoniAdmin extends StatefulWidget {
  const TestimoniAdmin({super.key});

  @override
  State<TestimoniAdmin> createState() => _TestimoniAdminState();
}

class _TestimoniAdminState extends State<TestimoniAdmin> {
  // 👇 Ubah jadi dynamic untuk menampung data Supabase
  List<Map<String, dynamic>> _testimoniList = [];
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 👇 FUNGSI MENARIK DATA DARI SUPABASE
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
                    TextFormField(
                      controller: quoteController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Kutipan Testimoni',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Kutipan testimoni tidak boleh kosong'
                          : null,
                    ),
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
                            if (mounted)
                              showSuccessSnackBar(
                                context,
                                'Testimoni berhasil diperbarui!',
                              );
                          } else {
                            await _supabase
                                .from('testimonials')
                                .insert(newData);
                            if (mounted)
                              showSuccessSnackBar(
                                context,
                                'Testimoni baru berhasil ditambahkan!',
                              );
                          }
                          _loadData();
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted)
                            showErrorSnackBar(
                              context,
                              'Gagal menyimpan data: $e',
                            );
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

  // 👇 FUNGSI MENGHAPUS DATA DARI SUPABASE
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
                if (mounted)
                  showSuccessSnackBar(context, 'Testimoni berhasil dihapus!');
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
