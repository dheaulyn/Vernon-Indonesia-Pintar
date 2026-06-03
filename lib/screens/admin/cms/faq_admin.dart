// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class KelolaFAQPage extends StatefulWidget {
  const KelolaFAQPage({super.key});

  @override
  State<KelolaFAQPage> createState() => _KelolaFAQPageState();
}

class _KelolaFAQPageState extends State<KelolaFAQPage> {
  final TextEditingController _tanyaController = TextEditingController();
  final TextEditingController _jawabController = TextEditingController();

  List<Map<String, dynamic>> _faqList = [];
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fungsi untuk menarik data dari database Supabase.
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('faqs')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _faqList = response;
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat FAQ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi pop-up form (tambah / edit).
  void _showFormDialog({Map<String, dynamic>? faqToEdit}) {
    final isEdit = faqToEdit != null;

    if (isEdit) {
      // Sesuaikan dengan nama kolom di Supabase ('question' & 'answer').
      _tanyaController.text = faqToEdit["question"] ?? '';
      _jawabController.text = faqToEdit["answer"] ?? '';
    } else {
      _tanyaController.clear();
      _jawabController.clear();
    }

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              isEdit ? "Edit FAQ" : "Tambah FAQ Baru",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _tanyaController,
                      decoration: const InputDecoration(
                        labelText: "Pertanyaan",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Pertanyaan tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _jawabController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Jawaban",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Jawaban tidak boleh kosong'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
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
                            "question": _tanyaController.text.trim(),
                            "answer": _jawabController.text.trim(),
                          };

                          try {
                            if (isEdit) {
                              await _supabase
                                  .from('faqs')
                                  .update(newData)
                                  .eq('id', faqToEdit['id']);
                              if (mounted) {
                                showSuccessSnackBar(
                                  context,
                                  'FAQ berhasil diperbarui!',
                                );
                              }
                            } else {
                              await _supabase.from('faqs').insert(newData);
                              if (mounted) {
                                showSuccessSnackBar(
                                  context,
                                  'FAQ baru berhasil ditambahkan!',
                                );
                              }
                            }

                            _loadData();
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            if (mounted) {
                              showErrorSnackBar(context, 'Gagal menyimpan: $e');
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
                        "Simpan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi hapus (dengan konfirmasi).
  void _hapusFaq(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Hapus FAQ?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pertanyaan ini dari daftar FAQ?',
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
                await _supabase.from('faqs').delete().eq('id', id);
                _loadData();
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  showSuccessSnackBar(context, 'FAQ berhasil dihapus!');
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
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Manajemen Konten FAQ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Tambah FAQ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _faqList.isEmpty
                ? const Center(
                    child: Text("Belum ada data FAQ. Silakan tambah baru."),
                  )
                : ListView.builder(
                    itemCount: _faqList.length,
                    itemBuilder: (context, index) {
                      final item = _faqList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          title: Text(
                            item["question"] ??
                                '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              item["answer"] ??
                                  '',
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: "Edit",
                                onPressed: () =>
                                    _showFormDialog(faqToEdit: item),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: "Hapus",
                                onPressed: () => _hapusFaq(item["id"]),
                              ),
                            ],
                          ),
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
