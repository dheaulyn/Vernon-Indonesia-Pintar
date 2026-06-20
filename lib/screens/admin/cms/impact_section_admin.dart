import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_colors.dart';
import '../../../core/snackbar_helper.dart';

class ImpactSectionAdmin extends StatefulWidget {
  const ImpactSectionAdmin({super.key});

  @override
  State<ImpactSectionAdmin> createState() => _ImpactSectionAdminState();
}

class _ImpactSectionAdminState extends State<ImpactSectionAdmin> {
  final _formKey = GlobalKey<FormState>();

  final _taglineController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _batchAktifController = TextEditingController();
  final _alumniBekerjaController = TextEditingController();
  final _labelDonasiController = TextEditingController();
  final _labelPenerimaController = TextEditingController();
  final _labelBatchController = TextEditingController();
  final _labelAlumniController = TextEditingController();

  int _sectionId = 1;
  bool _isLoading = true;
  bool _isSaving = false;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadDataFromSupabase();
  }

  Future<void> _loadDataFromSupabase() async {
    try {
      final response = await _supabase
          .from('cms_impact_section')
          .select()
          .order('id', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _sectionId = response['id'];
          _taglineController.text = response['tagline'] ?? '';
          _titleController.text = response['title'] ?? '';
          _subtitleController.text = response['subtitle'] ?? '';
          _batchAktifController.text =
              (response['stat_batch_aktif'] ?? 0).toString();
          _alumniBekerjaController.text =
              (response['stat_alumni_bekerja'] ?? 0).toString();
          _labelDonasiController.text =
              response['label_donasi'] ?? 'Total Donasi Terkumpul';
          _labelPenerimaController.text =
              response['label_penerima'] ?? 'Penerima Beasiswa';
          _labelBatchController.text =
              response['label_batch'] ?? 'Batch Aktif';
          _labelAlumniController.text =
              response['label_alumni'] ?? 'Alumni Bekerja';
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _batchAktifController.dispose();
    _alumniBekerjaController.dispose();
    _labelDonasiController.dispose();
    _labelPenerimaController.dispose();
    _labelBatchController.dispose();
    _labelAlumniController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(
        context,
        'Penyimpanan gagal. Masih ada form yang kosong!',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _supabase
          .from('cms_impact_section')
          .update({
            'tagline': _taglineController.text.trim(),
            'title': _titleController.text.trim(),
            'subtitle': _subtitleController.text.trim(),
            'stat_batch_aktif':
                int.tryParse(_batchAktifController.text.trim()) ?? 0,
            'stat_alumni_bekerja':
                int.tryParse(_alumniBekerjaController.text.trim()) ?? 0,
            'label_donasi': _labelDonasiController.text.trim(),
            'label_penerima': _labelPenerimaController.text.trim(),
            'label_batch': _labelBatchController.text.trim(),
            'label_alumni': _labelAlumniController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _sectionId);

      if (mounted) {
        showSuccessSnackBar(
          context,
          'Impact Section berhasil diperbarui!',
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Gagal menyimpan: ${e.toString()}');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Impact Section',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Atur teks judul, deskripsi, dan angka statistik pada section "Dampak Nyata" di halaman utama.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // ============================
            // CARD 1: Teks Header Section
            // ============================
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields_rounded,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Teks Header Section",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),

                    // Tagline
                    const Text(
                      "Tagline (Label Kecil)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _taglineController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Contoh: DAMPAK NYATA VIP",
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Tagline tidak boleh kosong'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      "Judul Utama",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            "Contoh: Jejak Langkah & Transparansi Kami",
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Judul tidak boleh kosong'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // Subtitle
                    const Text(
                      "Deskripsi / Subjudul",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subtitleController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            "Contoh: Setiap dukungan Anda telah membantu kami...",
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Deskripsi tidak boleh kosong'
                              : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ============================
            // CARD 2: Angka Statistik Manual
            // ============================
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Angka Statistik Manual",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Angka \"Total Donasi\" dan \"Penerima Beasiswa\" dihitung otomatis dari database. Anda hanya perlu mengisi angka berikut secara manual.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Divider(height: 30),

                    // Batch Aktif & Alumni Bekerja side by side
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jumlah Batch Aktif",
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _batchAktifController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "0",
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  if (int.tryParse(value.trim()) == null) {
                                    return 'Harus berupa angka';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jumlah Alumni Bekerja",
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _alumniBekerjaController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "0",
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  if (int.tryParse(value.trim()) == null) {
                                    return 'Harus berupa angka';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ============================
            // CARD 3: Label Kartu Statistik
            // ============================
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.label_rounded,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Label Kartu Statistik",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ubah teks label yang ditampilkan di bawah angka pada setiap kartu statistik.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Divider(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Label Donasi",
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _labelDonasiController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Total Donasi Terkumpul",
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Label tidak boleh kosong'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Label Penerima",
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _labelPenerimaController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Penerima Beasiswa",
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Label tidak boleh kosong'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Label Batch",
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _labelBatchController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Batch Aktif",
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Label tidak boleh kosong'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Label Alumni",
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _labelAlumniController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Alumni Bekerja",
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Label tidak boleh kosong'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ============================
            // TOMBOL SIMPAN
            // ============================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
