import 'package:flutter/material.dart';
import '../../../../../core/app_colors.dart'; 
import '../../../../../data/faq_data.dart'; 

class KelolaFAQPage extends StatefulWidget {
  const KelolaFAQPage({super.key});

  @override
  State<KelolaFAQPage> createState() => _KelolaFAQPageState();
}

class _KelolaFAQPageState extends State<KelolaFAQPage> {
  final TextEditingController _tanyaController = TextEditingController();
  final TextEditingController _jawabController = TextEditingController();

  // FUNGSI POP-UP FORM (TAMBAH / EDIT)
  void _showFormDialog({int? indexToEdit}) {
    List<Map<String, String>> currentList = globalFaqStore.faqList;

    if (indexToEdit != null) {
      _tanyaController.text = currentList[indexToEdit]["tanya"]!;
      _jawabController.text = currentList[indexToEdit]["jawab"]!;
    } else {
      _tanyaController.clear();
      _jawabController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            indexToEdit != null ? "Edit FAQ" : "Tambah FAQ Baru",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 500, 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tanyaController, 
                  decoration: const InputDecoration(labelText: "Pertanyaan", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _jawabController, 
                  maxLines: 4, 
                  decoration: const InputDecoration(labelText: "Jawaban", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                // Cegah simpan jika kosong
                if (_tanyaController.text.trim().isEmpty || _jawabController.text.trim().isEmpty) {
                  return;
                }

                if (indexToEdit != null) {
                  globalFaqStore.editFaq(indexToEdit, _tanyaController.text, _jawabController.text);
                  _showSuccessMessage("FAQ berhasil diperbarui!");
                } else {
                  globalFaqStore.addFaq(_tanyaController.text, _jawabController.text);
                  _showSuccessMessage("FAQ baru berhasil ditambahkan!");
                }
                Navigator.pop(context); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // FUNGSI HAPUS (DENGAN KONFIRMASI)
  void _hapusFaq(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Hapus FAQ?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus pertanyaan ini dari daftar FAQ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              globalFaqStore.removeFaq(index);
              Navigator.pop(context);
              _showSuccessMessage("FAQ berhasil dihapus!");
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // FUNGSI MENAMPILKAN PESAN BERHASIL (WARNA HIJAU)
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // Membuat snackbar mengambang
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: globalFaqStore,
      builder: (context, child) {
        
        List<Map<String, String>> currentList = globalFaqStore.faqList;

        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
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
                    label: const Text("Tambah FAQ", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // LIST FAQ
              Expanded(
                child: currentList.isEmpty
                    ? const Center(child: Text("Belum ada data FAQ. Silakan tambah baru."))
                    : ListView.builder(
                        itemCount: currentList.length,
                        itemBuilder: (context, index) {
                          final item = currentList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(20),
                              title: Text(item["tanya"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(item["jawab"]!, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: "Edit",
                                    onPressed: () => _showFormDialog(indexToEdit: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: "Hapus",
                                    onPressed: () => _hapusFaq(index),
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
    );
  }
}