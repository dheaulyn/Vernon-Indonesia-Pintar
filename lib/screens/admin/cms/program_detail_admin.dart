import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class ReqController {
  TextEditingController titleCtrl;
  List<TextEditingController> pointsCtrl;
  ReqController(this.titleCtrl, this.pointsCtrl);
}

class TimelineController {
  TextEditingController titleCtrl;
  TextEditingController descCtrl;
  TimelineController(this.titleCtrl, this.descCtrl);
}

class PhaseController {
  TextEditingController phaseCtrl; // Cth: "FASE 1"
  TextEditingController titleCtrl; // Cth: "Pelatihan Intensif"
  TextEditingController descCtrl; // Cth: "Membangun fondasi..."
  List<TextEditingController> itemsCtrl; // Poin-poin di dalamnya
  PhaseController(
    this.phaseCtrl,
    this.titleCtrl,
    this.descCtrl,
    this.itemsCtrl,
  );
}

class ProgramDetailAdmin extends StatefulWidget {
  const ProgramDetailAdmin({super.key});

  @override
  State<ProgramDetailAdmin> createState() => _ProgramDetailAdminState();
}

class _ProgramDetailAdminState extends State<ProgramDetailAdmin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<TextEditingController> _fasilitasControllers = [];
  final List<PhaseController> _phaseControllers = [];
  final List<ReqController> _reqControllers = [];
  final List<TimelineController> _timelineControllers = [];

  bool _isLoading = true;
  bool _isSaving = false;
  final int _programId = 1;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Sekarang ada 4 Tab.
    _tabController = TabController(length: 4, vsync: this);
    _loadDataFromSupabase();
  }

  Future<void> _loadDataFromSupabase() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('programs')
          .select()
          .eq('id', _programId)
          .maybeSingle();

      if (response != null) {
        // 1. Load Fasilitas.
        _fasilitasControllers.clear();
        final fasData = response['fasilitas'];
        if (fasData != null && fasData is List) {
          for (var fas in fasData) {
            _fasilitasControllers.add(
              TextEditingController(text: fas.toString()),
            );
          }
        }

        // 2. Load Fase Program.
        _phaseControllers.clear();
        final phaseData = response['fase_program'];
        if (phaseData != null && phaseData is List) {
          for (var phase in phaseData) {
            List<TextEditingController> items = [];
            if (phase['items'] != null && phase['items'] is List) {
              for (var item in phase['items']) {
                items.add(TextEditingController(text: item.toString()));
              }
            }
            _phaseControllers.add(
              PhaseController(
                TextEditingController(text: phase['phase']?.toString() ?? ''),
                TextEditingController(text: phase['title']?.toString() ?? ''),
                TextEditingController(text: phase['desc']?.toString() ?? ''),
                items,
              ),
            );
          }
        }

        // 3. Load Syarat & Ketentuan.
        _reqControllers.clear();
        final reqData = response['syarat_ketentuan'];
        if (reqData != null && reqData is List) {
          for (var req in reqData) {
            List<TextEditingController> pts = [];
            if (req['points'] != null && req['points'] is List) {
              for (var pt in req['points']) {
                pts.add(TextEditingController(text: pt.toString()));
              }
            }
            _reqControllers.add(
              ReqController(
                TextEditingController(text: req['title']?.toString() ?? ''),
                pts,
              ),
            );
          }
        }

        // 4. Load Alur Pendaftaran.
        _timelineControllers.clear();
        final timelineData = response['alur_pendaftaran'];
        if (timelineData != null && timelineData is List) {
          for (var step in timelineData) {
            _timelineControllers.add(
              TimelineController(
                TextEditingController(text: step['title']?.toString() ?? ''),
                TextEditingController(
                  text: step['description']?.toString() ?? '',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
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
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
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

  Future<void> _saveData() async {
    setState(() => _isSaving = true);

    try {
      // Data Fasilitas.
      List<String> updatedFasilitas = _fasilitasControllers
          .map((ctrl) => ctrl.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // Data Fase.
      List<Map<String, dynamic>> updatedPhases = _phaseControllers
          .map((phase) {
            return {
              "phase": phase.phaseCtrl.text.trim(),
              "title": phase.titleCtrl.text.trim(),
              "desc": phase.descCtrl.text.trim(),
              "items": phase.itemsCtrl
                  .map((i) => i.text.trim())
                  .where((t) => t.isNotEmpty)
                  .toList(),
            };
          })
          .where((p) => p['title'].toString().isNotEmpty)
          .toList();

      // Data Syarat.
      List<Map<String, dynamic>> updatedReqs = _reqControllers
          .map((reqCtrl) {
            return {
              "title": reqCtrl.titleCtrl.text.trim(),
              "points": reqCtrl.pointsCtrl
                  .map((p) => p.text.trim())
                  .where((t) => t.isNotEmpty)
                  .toList(),
            };
          })
          .where(
            (req) =>
                req['title'].toString().isNotEmpty ||
                (req['points'] as List).isNotEmpty,
          )
          .toList();

      // Data Alur.
      List<Map<String, String>> updatedTimeline = _timelineControllers
          .map((timeCtrl) {
            return {
              "title": timeCtrl.titleCtrl.text.trim(),
              "description": timeCtrl.descCtrl.text.trim(),
            };
          })
          .where(
            (step) =>
                step['title']!.isNotEmpty || step['description']!.isNotEmpty,
          )
          .toList();

      // Update ke Supabase.
      await _supabase
          .from('programs')
          .update({
            'fasilitas': updatedFasilitas,
            'fase_program': updatedPhases,
            'syarat_ketentuan': updatedReqs,
            'alur_pendaftaran': updatedTimeline,
          })
          .eq('id', _programId);

      if (mounted) {
        showSuccessSnackBar(context, 'Data Program VIP berhasil diperbarui!');
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kelola Konten Program',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Program Karir VIP (10 Bulan)',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveData,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving ? "MENYIMPAN..." : "SIMPAN PERUBAHAN",
                  style: const TextStyle(
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
          const SizedBox(height: 30),

          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Fasilitas'),
                Tab(text: 'Fase Program'),
                Tab(text: 'Syarat & Ketentuan'),
                Tab(text: 'Alur Pendaftaran'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFasilitasTab(),
                _buildFaseTab(),
                _buildRequirementsTab(),
                _buildTimelineTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FASILITAS
  // =========================================================================
  Widget _buildFasilitasTab() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.all(25),
        itemCount: _fasilitasControllers.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          if (index == _fasilitasControllers.length) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(
                  () => _fasilitasControllers.add(TextEditingController()),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Tambah Fasilitas Baru",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
              ),
            );
          }
          return Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.primary),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: _fasilitasControllers[index],
                  decoration: const InputDecoration(
                    labelText: "Nama Fasilitas (Cth: Uang Saku Bulanan)",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(
                  'Hapus Fasilitas?',
                  'Yakin ingin menghapus fasilitas ini?',
                  () => setState(() => _fasilitasControllers.removeAt(index)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================================
  // FASE PROGRAM
  // =========================================================================
  Widget _buildFaseTab() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.all(25),
        itemCount: _phaseControllers.length + 1,
        separatorBuilder: (_, _) => const Divider(height: 40),
        itemBuilder: (context, index) {
          if (index == _phaseControllers.length) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(
                  () => _phaseControllers.add(
                    PhaseController(
                      TextEditingController(),
                      TextEditingController(),
                      TextEditingController(),
                      [TextEditingController()],
                    ),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Tambah Fase Baru",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
              ),
            );
          }
          final phase = _phaseControllers[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Detail Fase",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        'Hapus Fase?',
                        'Yakin ingin menghapus fase ini?',
                        () => setState(() => _phaseControllers.removeAt(index)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: phase.phaseCtrl,
                        decoration: const InputDecoration(
                          labelText: "Label (Cth: FASE 1)",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: phase.titleCtrl,
                        decoration: const InputDecoration(
                          labelText: "Judul Fase (Cth: Pelatihan Intensif)",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phase.descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Deskripsi Singkat",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Materi / Poin Fase:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...List.generate(phase.itemsCtrl.length, (pIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phase.itemsCtrl[pIndex],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _confirmDelete(
                            'Hapus Poin?',
                            'Yakin ingin menghapus poin materi ini?',
                            () => setState(
                              () => phase.itemsCtrl.removeAt(pIndex),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(
                    () => phase.itemsCtrl.add(TextEditingController()),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Tambah Poin Materi"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // SYARAT & KETENTUAN
  // =========================================================================
  Widget _buildRequirementsTab() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.all(25),
        itemCount: _reqControllers.length + 1,
        separatorBuilder: (_, _) => const Divider(height: 40),
        itemBuilder: (context, index) {
          if (index == _reqControllers.length) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(
                  () => _reqControllers.add(
                    ReqController(TextEditingController(), [
                      TextEditingController(),
                    ]),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Tambah Kategori Syarat",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
              ),
            );
          }
          final req = _reqControllers[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: req.titleCtrl,
                        decoration: const InputDecoration(
                          labelText: "Judul Kategori (Cth: Syarat Umum)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        'Hapus Kategori?',
                        'Yakin menghapus kategori ini?',
                        () => setState(() => _reqControllers.removeAt(index)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "Poin Persyaratan:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...List.generate(req.pointsCtrl.length, (pIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: req.pointsCtrl[pIndex],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _confirmDelete(
                            'Hapus Poin?',
                            'Yakin menghapus poin ini?',
                            () =>
                                setState(() => req.pointsCtrl.removeAt(pIndex)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(
                    () => req.pointsCtrl.add(TextEditingController()),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Tambah Poin"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // ALUR PENDAFTARAN
  // =========================================================================
  Widget _buildTimelineTab() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.all(25),
        itemCount: _timelineControllers.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          if (index == _timelineControllers.length) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(
                  () => _timelineControllers.add(
                    TimelineController(
                      TextEditingController(),
                      TextEditingController(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Tambah Langkah Alur",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
              ),
            );
          }
          final step = _timelineControllers[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: step.titleCtrl,
                        decoration: const InputDecoration(
                          labelText: "Judul Langkah",
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: step.descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Deskripsi",
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(
                    'Hapus Langkah?',
                    'Yakin menghapus langkah ini?',
                    () => setState(() => _timelineControllers.removeAt(index)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
