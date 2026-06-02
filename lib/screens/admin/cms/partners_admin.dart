// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👇 Import Supabase

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class PartnersAdmin extends StatefulWidget {
  const PartnersAdmin({super.key});

  @override
  State<PartnersAdmin> createState() => _PartnersAdminState();
}

class _PartnersAdminState extends State<PartnersAdmin> {
  List<Map<String, dynamic>> _partners = [];
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
          .from('partners')
          .select()
          .order('sort_order', ascending: true);

      if (mounted) {
        setState(() {
          _partners = response;
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat partner: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 👇 FUNGSI MENGHAPUS DATA DARI SUPABASE
  void _confirmDeletePartner(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Hapus Partner?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus partner ini dari daftar?',
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
                await _supabase.from('partners').delete().eq('id', id);
                _loadData();
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  showSuccessSnackBar(context, 'Partner berhasil dihapus!');
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

  // FUNGSI MENAMPILKAN GAMBAR (MENDUKUNG BYTES LOKAL & URL SUPABASE)
  Widget _buildImageDisplay({String url = '', Uint8List? bytes}) {
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.contain);
    }
    if (url.isNotEmpty && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
        ),
      );
    }
    return const Center(child: Icon(Icons.image, color: Colors.grey, size: 40));
  }

  // 👇 FUNGSI UPLOAD GAMBAR UNTUK SUPABASE STORAGE
  Future<void> _pickImage(
    Function(Uint8List bytes, String ext) onImagePicked,
  ) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      onImagePicked(
        result.files.first.bytes!,
        result.files.first.extension ?? 'png',
      );
    }
  }

  // FORM DIALOG TAMBAH / EDIT
  void _showFormDialog({Map<String, dynamic>? partner}) {
    final isEdit = partner != null;
    final nameController = TextEditingController(
      text: isEdit ? partner['name'] : '',
    );

    // Sesuaikan dengan nama kolom di database 'image_url'
    String currentImageUrl = isEdit ? (partner['image_url'] ?? '') : '';
    Uint8List? newImageBytes;
    String? newImageExt;
    bool isSaving = false;

    final formKey = GlobalKey<FormState>();

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
            isEdit ? 'Edit Partner' : 'Tambah Partner',
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
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Perusahaan/Instansi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Logo Partner",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Format disarankan: PNG Transparan. Agar proporsional, gunakan rasio 1:1 atau gambar horizontal.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // KOTAK UPLOAD GAMBAR
                  InkWell(
                    onTap: () {
                      _pickImage((bytes, ext) {
                        setModalState(() {
                          newImageBytes = bytes;
                          newImageExt = ext;
                          currentImageUrl = ''; // Hapus preview lama
                        });
                      });
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (currentImageUrl.isEmpty && newImageBytes == null)
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
                                  "Klik untuk Upload Logo",
                                  style: TextStyle(color: Colors.grey.shade600),
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
                                  top: -5,
                                  right: -5,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 16,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      onPressed: () => setModalState(() {
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
                        if (currentImageUrl.isEmpty && newImageBytes == null) {
                          showErrorSnackBar(
                            context,
                            'Harap upload logo perusahaan!',
                          );
                          return;
                        }

                        setModalState(() => isSaving = true);

                        try {
                          String finalImageUrl = currentImageUrl;

                          // Upload ke Supabase Storage jika ada gambar baru
                          if (newImageBytes != null) {
                            final fileName =
                                'partner_${DateTime.now().millisecondsSinceEpoch}.$newImageExt';
                            await _supabase.storage
                                .from('cms_images')
                                .uploadBinary(
                                  fileName,
                                  newImageBytes!,
                                  fileOptions: const FileOptions(upsert: true),
                                );
                            finalImageUrl = _supabase.storage
                                .from('cms_images')
                                .getPublicUrl(fileName);
                          }

                          final Map<String, dynamic> data = {
                            'name': nameController.text.trim(),
                            'image_url': finalImageUrl,
                          };

                          if (isEdit) {
                            await _supabase
                                .from('partners')
                                .update(data)
                                .eq('id', partner['id']);
                            if (mounted) {
                              showSuccessSnackBar(
                                context,
                                'Partner berhasil diperbarui',
                              );
                            }
                          } else {
                            data['sort_order'] = _partners.length;
                            await _supabase.from('partners').insert(data);
                            if (mounted) {
                              showSuccessSnackBar(
                                context,
                                'Partner berhasil ditambahkan',
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
                      'Simpan',
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
                'Kelola Partner Kerja Sama',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tambah Partner',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _partners.isEmpty
                ? const Center(
                    child: Text("Belum ada partner. Silakan tambah baru."),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 4,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) async {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _partners.removeAt(oldIndex);
                        _partners.insert(newIndex, item);
                      });

                      try {
                        for (int i = 0; i < _partners.length; i++) {
                          await _supabase
                              .from('partners')
                              .update({'sort_order': i})
                              .eq('id', _partners[i]['id']);
                        }
                        if (mounted) {
                          showSuccessSnackBar(
                            context,
                            'Urutan partner berhasil diperbarui!',
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          showErrorSnackBar(
                            context,
                            'Gagal menyimpan urutan: $e',
                          );
                        }
                      }
                    },
                    itemCount: _partners.length,
                    itemBuilder: (context, index) {
                      final p = _partners[index];
                      return Card(
                        key: ValueKey(p['id']),
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: _buildImageDisplay(url: p['image_url'] ?? ''),
                          ),
                          title: Text(
                            p['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Edit",
                                onPressed: () => _showFormDialog(partner: p),
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              IconButton(
                                tooltip: "Hapus",
                                onPressed: () => _confirmDeletePartner(p['id']),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(
                                  Icons.drag_handle_rounded,
                                  color: Colors.grey,
                                ),
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
