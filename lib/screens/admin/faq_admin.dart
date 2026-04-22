import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart'; 
import '../../../../data/faq_data.dart'; // Pastikan path ini mengarah ke faq_data.dart

class KelolaFAQPage extends StatefulWidget {
  const KelolaFAQPage({super.key});

  @override
  State<KelolaFAQPage> createState() => _KelolaFAQPageState();
}

class _KelolaFAQPageState extends State<KelolaFAQPage> {
  int selectedTabIndex = 0; 
  final TextEditingController _tanyaController = TextEditingController();
  final TextEditingController _jawabController = TextEditingController();

  // FUNGSI POP-UP FORM
  void _showFormDialog({int? indexToEdit}) {
    List<Map<String, String>> currentList = selectedTabIndex == 0 
        ? globalFaqStore.faqBerprestasi 
        : globalFaqStore.faqReguler;

    // Jika indexToEdit tidak kosong, berarti mode EDIT. Isi form dengan data lama.
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(indexToEdit != null ? "Edit FAQ" : "Tambah FAQ Baru"),
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
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // Logika Simpan
                if (indexToEdit != null) {
                  // Mode Edit
                  globalFaqStore.editFaq(selectedTabIndex, indexToEdit, _tanyaController.text, _jawabController.text);
                } else {
                  // Mode Tambah Baru
                  globalFaqStore.addFaq(selectedTabIndex, _tanyaController.text, _jawabController.text);
                }
                Navigator.pop(context); // Tutup dialog
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // FUNGSI HAPUS
  void _hapusFaq(int index) {
    globalFaqStore.removeFaq(selectedTabIndex, index);
  }

  @override
  Widget build(BuildContext context) {
    // 👇 KUNCI UTAMANYA ADA DI SINI: ListenableBuilder akan memantau perubahan
    return ListenableBuilder(
      listenable: globalFaqStore,
      builder: (context, child) {
        
        // Ambil data terbaru dari Gudang Data
        List<Map<String, String>> currentList = selectedTabIndex == 0 
            ? globalFaqStore.faqBerprestasi 
            : globalFaqStore.faqReguler;

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
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah FAQ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // TAB
              Row(
                children: [
                  _buildTabAdmin("Beasiswa Berprestasi", 0),
                  const SizedBox(width: 15),
                  _buildTabAdmin("Beasiswa Reguler", 1),
                ],
              ),
              const SizedBox(height: 20),

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
                                    icon: const Icon(Icons.edit, color: Colors.orange),
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

  Widget _buildTabAdmin(String title, int index) {
    bool isSelected = selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}