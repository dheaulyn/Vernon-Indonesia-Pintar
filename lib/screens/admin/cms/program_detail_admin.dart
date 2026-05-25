import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👇 Import Supabase

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

class ProgramDetailAdmin extends StatefulWidget {
  const ProgramDetailAdmin({super.key});

  @override
  State<ProgramDetailAdmin> createState() => _ProgramDetailAdminState();
}

class _ProgramDetailAdminState extends State<ProgramDetailAdmin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<ReqController> _reqControllers = [];
  final List<TimelineController> _timelineControllers = [];

  bool _isLoading = true;
  bool _isSaving = false;
  int _programId = 1; // ID baris di tabel programs

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDataFromSupabase();
  }

  // 👇 FUNGSI MENARIK DATA DARI SUPABASE
  Future<void> _loadDataFromSupabase() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('programs')
          .select()
          .order('id', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _programId = response['id'];

        // Load Requirements (Syarat & Ketentuan)
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

        // Load Timeline (Alur Pendaftaran)
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

  // FUNGSI DIALOG KONFIRMASI HAPUS
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

  // 👇 FUNGSI MENYIMPAN DATA KE SUPABASE
  Future<void> _saveData() async {
    setState(() => _isSaving = true);

    try {
      // 1. Kumpulkan data Requirements dan bungkus ke format yang pas
      List<Map<String, dynamic>> updatedReqs = _reqControllers
          .map((reqCtrl) {
            return {
              "title": reqCtrl.titleCtrl.text.trim(),
              "points": reqCtrl.pointsCtrl
                  .map((p) => p.text.trim())
                  .where((text) => text.isNotEmpty)
                  .toList(),
            };
          })
          .where(
            (req) =>
                req['title'].toString().isNotEmpty ||
                (req['points'] as List).isNotEmpty,
          )
          .toList();

      // 2. Kumpulkan data Timeline
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

      // 3. Tembak ke Supabase (Otomatis menjadi tipe data JSONB di database)
      await _supabase
          .from('programs')
          .update({
            'syarat_ketentuan': updatedReqs,
            'alur_pendaftaran': updatedTimeline,
          })
          .eq('id', _programId);

      if (mounted)
        showSuccessSnackBar(context, 'Detail Program berhasil diperbarui!');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kelola Detail Program',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  _isSaving ? "MENYIMPAN..." : "SIMPAN SEMUA",
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
          const SizedBox(height: 20),

          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Syarat & Ketentuan'),
                Tab(text: 'Alur Pendaftaran'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildRequirementsTab(), _buildTimelineTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: SYARAT & KETENTUAN
  // ==========================================
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
                  "Tambah Kategori Syarat Baru",
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
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Hapus Kategori",
                      onPressed: () => _confirmDelete(
                        'Hapus Kategori Syarat?',
                        'Apakah Anda yakin ingin menghapus kategori ini beserta seluruh poin syarat di dalamnya?',
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
                          tooltip: "Hapus Poin",
                          onPressed: () => _confirmDelete(
                            'Hapus Poin Persyaratan?',
                            'Apakah Anda yakin ingin menghapus poin persyaratan ini?',
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

  // ==========================================
  // TAB 2: ALUR PENDAFTARAN
  // ==========================================
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
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "Hapus Langkah",
                  onPressed: () => _confirmDelete(
                    'Hapus Langkah Alur?',
                    'Apakah Anda yakin ingin menghapus langkah ini dari alur pendaftaran?',
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
