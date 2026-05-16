import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/app_colors.dart';
import '../../../../data/mock_database.dart';

class PartnersAdmin extends StatefulWidget {
  const PartnersAdmin({super.key});

  @override
  State<PartnersAdmin> createState() => _PartnersAdminState();
}

class _PartnersAdminState extends State<PartnersAdmin> {
  List<Map<String, dynamic>> _partners = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _partners = MockDatabase.getSemuaPartner();
    });
  }

  // FUNGSI MENAMPILKAN PESAN BERHASIL (WARNA HIJAU)
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // FUNGSI MENAMPILKAN PESAN PERINGATAN (WARNA MERAH)
  void _showWarningMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  // FUNGSI DIALOG KONFIRMASI HAPUS
  void _confirmDeletePartner(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Hapus Partner?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus partner ini dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              MockDatabase.hapusPartner(id);
              _loadData();
              Navigator.pop(context);
              _showSuccessMessage('Partner berhasil dihapus!');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // FUNGSI MENAMPILKAN GAMBAR (MENDUKUNG BASE64 & URL)
  // Dilengkapi errorBuilder agar tidak crash jika link gambar 404
  Widget _buildImageDisplay(String imageSource) {
    if (imageSource.isEmpty) {
      return const Center(child: Icon(Icons.image, color: Colors.grey, size: 40));
    } else if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource, 
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
      );
    } else {
      try {
        return Image.memory(base64Decode(imageSource), fit: BoxFit.contain);
      } catch (e) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.red, size: 40));
      }
    }
  }

  // FUNGSI UPLOAD GAMBAR
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

  // FORM DIALOG TAMBAH / EDIT
  void _showFormDialog({Map<String, dynamic>? partner}) {
    final isEdit = partner != null;
    final nameController = TextEditingController(text: isEdit ? partner['name'] : '');
    String selectedImage = isEdit ? (partner['image'] ?? '') : '';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(isEdit ? 'Edit Partner' : 'Tambah Partner', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    decoration: const InputDecoration(labelText: 'Nama Perusahaan/Instansi', border: OutlineInputBorder()),
                    validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  const Text("Logo Partner", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    "Format disarankan: PNG Transparan. Agar proporsional, gunakan rasio 1:1 atau gambar horizontal.",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),

                  // KOTAK UPLOAD GAMBAR
                  InkWell(
                    onTap: () {
                      _pickImage((base64Image) {
                        setModalState(() {
                          selectedImage = base64Image;
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
                      child: selectedImage.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                Text("Klik untuk Upload Logo", style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildImageDisplay(selectedImage),
                                Positioned(
                                  top: -5, right: -5,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 16,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                      onPressed: () => setModalState(() => selectedImage = ''),
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
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (selectedImage.isEmpty) {
                    _showWarningMessage('Harap upload logo perusahaan!');
                    return;
                  }

                  final data = {
                    'name': nameController.text.trim(), 
                    'image': selectedImage,
                  };

                  if (isEdit) {
                    MockDatabase.editPartner(partner['id'], data);
                    _showSuccessMessage('Partner berhasil diperbarui');
                  } else {
                    MockDatabase.tambahPartner(data);
                    _showSuccessMessage('Partner berhasil ditambahkan');
                  }
                  _loadData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
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
              const Text('Kelola Partner Kerja Sama', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Tambah Partner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              )
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: _partners.isEmpty 
              ? const Center(child: Text("Belum ada partner. Silakan tambah baru."))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.1
                  ),
                  itemCount: _partners.length,
                  itemBuilder: (context, index) {
                    final p = _partners[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                child: _buildImageDisplay(p['image'] ?? ''),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              p['name'] ?? '', 
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: "Edit",
                                  onPressed: () => _showFormDialog(partner: p), 
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue)
                                ),
                                IconButton(
                                  tooltip: "Hapus",
                                  onPressed: () => _confirmDeletePartner(p['id']), 
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red)
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
              ),
          )
        ],
      ),
    );
  }
}