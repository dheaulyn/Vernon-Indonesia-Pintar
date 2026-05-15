import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../data/mock_database.dart'; // Sesuaikan path

class TestimoniAdmin extends StatefulWidget {
  const TestimoniAdmin({super.key});

  @override
  State<TestimoniAdmin> createState() => _TestimoniAdminState();
}

class _TestimoniAdminState extends State<TestimoniAdmin> {
  List<Map<String, String>> _testimoniList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _testimoniList = MockDatabase.getSemuaTestimoni();
    });
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

  void _showFormDialog({Map<String, String>? testimoni}) {
    final isEdit = testimoni != null;
    final nameController = TextEditingController(text: isEdit ? testimoni['name'] : '');
    final roleController = TextEditingController(text: isEdit ? testimoni['role'] : '');
    final quoteController = TextEditingController(text: isEdit ? testimoni['quote'] : '');

    // 👇 Kunci form untuk validasi
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          isEdit ? 'Edit Testimoni' : 'Tambah Testimoni Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            // 👇 Bungkus dengan Widget Form
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController, 
                    decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: roleController, 
                    decoration: const InputDecoration(labelText: 'Pekerjaan / Role (cth: Alumni Batch 1 - IT)', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pekerjaan/Role tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: quoteController, 
                    maxLines: 4, 
                    decoration: const InputDecoration(labelText: 'Kutipan Testimoni', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kutipan testimoni tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              // 👇 Cek apakah form valid saat tombol ditekan
              if (formKey.currentState!.validate()) {
                final newData = {
                  'name': nameController.text.trim(),
                  'role': roleController.text.trim(),
                  'quote': quoteController.text.trim(),
                };

                if (isEdit) {
                  MockDatabase.editTestimoni(testimoni['id']!, newData);
                  _showSuccessMessage('Testimoni berhasil diperbarui!');
                } else {
                  MockDatabase.tambahTestimoni(newData);
                  _showSuccessMessage('Testimoni baru berhasil ditambahkan!');
                }
                _loadData();
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan Testimoni', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _hapusTestimoni(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Hapus Testimoni?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus testimoni ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              MockDatabase.hapusTestimoni(id);
              _loadData();
              Navigator.pop(context);
              _showSuccessMessage('Testimoni berhasil dihapus!');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              const Text('Kelola Testimoni', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Tambah Testimoni', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: const StadiumBorder(),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    child: const Icon(Icons.format_quote, color: AppColors.primary),
                  ),
                  title: Text(testimoni['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(testimoni['role'] ?? '', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text('"${testimoni['quote']}"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(testimoni: testimoni),
                        tooltip: 'Edit Testimoni',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusTestimoni(testimoni['id']!),
                        tooltip: 'Hapus Testimoni',
                      ),
                    ],
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