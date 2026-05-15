import 'package:flutter/material.dart';
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

  void _showFormDialog({Map<String, dynamic>? partner}) {
    final isEdit = partner != null;
    final nameController = TextEditingController(text: isEdit ? partner['name'] : '');
    IconData selectedIcon = isEdit ? IconData(partner['icon'], fontFamily: 'MaterialIcons') : Icons.business_rounded;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(isEdit ? 'Edit Partner' : 'Tambah Partner'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Perusahaan/Instansi', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                const Text("Pilih Ikon Representatif:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    Icons.business_rounded, Icons.account_balance_rounded, Icons.school_rounded,
                    Icons.language_rounded, Icons.computer_rounded, Icons.foundation_rounded,
                    Icons.group_rounded, Icons.handshake_rounded
                  ].map((icon) {
                    return ChoiceChip(
                      selected: selectedIcon == icon,
                      label: Icon(icon, color: selectedIcon == icon ? Colors.white : Colors.grey),
                      selectedColor: AppColors.primary,
                      onSelected: (selected) => setModalState(() => selectedIcon = icon),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final data = {'name': nameController.text, 'icon': selectedIcon.codePoint};
                  if (isEdit) {
                    MockDatabase.editPartner(partner['id'], data);
                    _showSuccessMessage('Partner berhasil diperbarui');
                  } else {
                    MockDatabase.tambahPartner(data);
                    _showSuccessMessage('Partner berhasil ditambah');
                  }
                  _loadData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
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
                label: const Text('Tambah Partner', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
              )
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.2
              ),
              itemCount: _partners.length,
              itemBuilder: (context, index) {
                final p = _partners[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconData(p['icon'], fontFamily: 'MaterialIcons'), size: 40, color: AppColors.primary),
                      const SizedBox(height: 10),
                      Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: () => _showFormDialog(partner: p), icon: const Icon(Icons.edit, size: 18, color: Colors.blue)),
                          IconButton(
                            onPressed: () {
                              MockDatabase.hapusPartner(p['id']);
                              _loadData();
                              _showSuccessMessage('Partner dihapus');
                            }, 
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red)
                          ),
                        ],
                      )
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