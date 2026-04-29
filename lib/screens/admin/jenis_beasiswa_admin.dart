import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../data/dummy_data.dart';
import '../../../data/models/program_model.dart';

class JenisBeasiswaAdmin extends StatefulWidget {
  const JenisBeasiswaAdmin({super.key});

  @override
  State<JenisBeasiswaAdmin> createState() => _JenisBeasiswaAdminState();
}

class _JenisBeasiswaAdminState extends State<JenisBeasiswaAdmin> {
  List<ProgramModel> listBeasiswa = DummyData.listProgram;

  // ==========================================
  // WIDGET 1: INPUT TEKS BIASA (Judul & Deskripsi)
  // ==========================================
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET 2: INPUT DAFTAR DINAMIS (Benefit & Syarat)
  // ==========================================
  Widget _buildDynamicListField({
    required String label,
    required List<TextEditingController> controllers,
    required void Function(VoidCallback)
    dialogSetState, // Butuh fungsi ini untuk update pop-up
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      hintText: "Masukkan poin...",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      isDense: true, // Biar kotaknya tidak terlalu tinggi
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol hapus poin (muncul kalau kotaknya lebih dari 1)
                if (controllers.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.redAccent,
                    ),
                    tooltip: "Hapus Poin",
                    onPressed: () =>
                        dialogSetState(() => controllers.removeAt(index)),
                  )
                else
                  const SizedBox(
                    width: 40,
                  ), // Jaga jarak kalau tidak ada tombol hapus
              ],
            ),
          );
        }),
        // Tombol Tambah Poin Baru
        TextButton.icon(
          onPressed: () =>
              dialogSetState(() => controllers.add(TextEditingController())),
          icon: Icon(Icons.add, color: AppColors.primary, size: 18),
          label: Text(
            "Tambah Poin Baru",
            style: TextStyle(color: AppColors.primary),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- FUNGSI CREATE (TAMBAH DATA) ---
  void _showAddForm() {
    TextEditingController judulCtrl = TextEditingController();
    TextEditingController deskripsiCtrl = TextEditingController();

    // Ubah jadi List karena kita butuh banyak kotak
    List<TextEditingController> benefitCtrls = [TextEditingController()];
    List<TextEditingController> syaratCtrls = [TextEditingController()];

    showDialog(
      context: context,
      builder: (context) {
        // 👇 StatefulBuilder agar pop-up bisa me-refresh dirinya sendiri saat tambah kotak
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: AppColors.primary),
                      const SizedBox(width: 10),
                      const Text(
                        "Tambah Beasiswa",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInputField(
                        controller: judulCtrl,
                        label: "Judul Beasiswa",
                      ),
                      _buildInputField(
                        controller: deskripsiCtrl,
                        label: "Deskripsi Singkat",
                        maxLines: 3,
                      ),

                      // 👇 Panggil fungsi kotak dinamis
                      _buildDynamicListField(
                        label: "Benefit Beasiswa",
                        controllers: benefitCtrls,
                        dialogSetState: setStateDialog,
                      ),
                      _buildDynamicListField(
                        label: "Persyaratan Pendaftaran",
                        controllers: syaratCtrls,
                        dialogSetState: setStateDialog,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      listBeasiswa.add(
                        ProgramModel(
                          id: 'bea-${DateTime.now().millisecondsSinceEpoch}',
                          judul: judulCtrl.text,
                          deskripsi: deskripsiCtrl.text,
                          // 👇 Kumpulkan semua teks dari kotak, buang yang kosong
                          benefit: benefitCtrls
                              .map((c) => c.text)
                              .where((t) => t.trim().isNotEmpty)
                              .toList(),
                          syarat: syaratCtrls
                              .map((c) => c.text)
                              .where((t) => t.trim().isNotEmpty)
                              .toList(),
                          imageUrl: 'assets/beareguler.png',
                        ),
                      );
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Beasiswa ditambahkan!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Simpan Data",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- FUNGSI UPDATE (EDIT DATA) ---
  void _showEditForm(ProgramModel program, int index) {
    TextEditingController judulCtrl = TextEditingController(
      text: program.judul,
    );
    TextEditingController deskripsiCtrl = TextEditingController(
      text: program.deskripsi,
    );

    // Pecah data lama menjadi banyak kotak
    List<TextEditingController> benefitCtrls = program.benefit.isNotEmpty
        ? program.benefit.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController()];

    List<TextEditingController> syaratCtrls = program.syarat.isNotEmpty
        ? program.syarat.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController()];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.orange, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        "Edit Beasiswa",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInputField(
                        controller: judulCtrl,
                        label: "Judul Beasiswa",
                      ),
                      _buildInputField(
                        controller: deskripsiCtrl,
                        label: "Deskripsi Singkat",
                        maxLines: 3,
                      ),

                      _buildDynamicListField(
                        label: "Benefit Beasiswa",
                        controllers: benefitCtrls,
                        dialogSetState: setStateDialog,
                      ),
                      _buildDynamicListField(
                        label: "Persyaratan Pendaftaran",
                        controllers: syaratCtrls,
                        dialogSetState: setStateDialog,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      listBeasiswa[index] = ProgramModel(
                        id: program.id,
                        judul: judulCtrl.text,
                        deskripsi: deskripsiCtrl.text,
                        benefit: benefitCtrls
                            .map((c) => c.text)
                            .where((t) => t.trim().isNotEmpty)
                            .toList(),
                        syarat: syaratCtrls
                            .map((c) => c.text)
                            .where((t) => t.trim().isNotEmpty)
                            .toList(),
                        imageUrl: program.imageUrl,
                      );
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Data diperbarui!"),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- FUNGSI DELETE (HAPUS DATA) ---
  void _deleteBeasiswa(int index, String judul) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Konfirmasi Hapus"),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus '$judul'?\nData yang dihapus tidak bisa dikembalikan.",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                listBeasiswa.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Beasiswa dihapus!"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Hapus Data",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(15),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(
                    label: Text(
                      "Judul",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Deskripsi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Aksi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: List.generate(listBeasiswa.length, (index) {
                  final item = listBeasiswa[index];
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          item.judul,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 400,
                          child: Text(
                            item.deskripsi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              tooltip: "Edit",
                              onPressed: () => _showEditForm(item, index),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Hapus",
                              onPressed: () =>
                                  _deleteBeasiswa(index, item.judul),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileView() {
    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: listBeasiswa.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = listBeasiswa[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            title: Text(
              item.judul,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                item.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _showEditForm(item, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBeasiswa(index, item.judul),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 15.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              runSpacing: 15,
              children: [
                const Text(
                  "Kelola Jenis Beasiswa",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddForm,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Tambah Beasiswa",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: listBeasiswa.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada data beasiswa.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : isMobile
                  ? _buildMobileView()
                  : _buildDesktopView(),
            ),
          ),
        ],
      ),
    );
  }
}
