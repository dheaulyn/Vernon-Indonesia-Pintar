import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

class DataDiriView extends StatefulWidget {
  final bool isMobile;
  final Map<String, dynamic> user;

  const DataDiriView({super.key, required this.isMobile, required this.user});

  @override
  State<DataDiriView> createState() => _DataDiriViewState();
}

class _DataDiriViewState extends State<DataDiriView> {
  late TextEditingController _nameController;
  late TextEditingController _teleponController;
  late TextEditingController _pekerjaanController;
  late TextEditingController _alamatController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name'] ?? '');
    _teleponController = TextEditingController(
      text: widget.user['telepon'] ?? widget.user['whatsapp'] ?? '',
    );
    _pekerjaanController = TextEditingController(
      text: widget.user['pekerjaan'] ?? '',
    );
    _alamatController = TextEditingController(
      text: widget.user['domisili'] ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant DataDiriView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.user != oldWidget.user) {
      if (_nameController.text != (widget.user['name'] ?? '')) {
        _nameController.text = widget.user['name'] ?? '';
      }

      final newPhone = widget.user['telepon'] ?? widget.user['whatsapp'] ?? '';
      if (_teleponController.text != newPhone) {
        _teleponController.text = newPhone;
      }

      if (_pekerjaanController.text != (widget.user['pekerjaan'] ?? '')) {
        _pekerjaanController.text = widget.user['pekerjaan'] ?? '';
      }

      if (_alamatController.text != (widget.user['domisili'] ?? '')) {
        _alamatController.text = widget.user['domisili'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teleponController.dispose();
    _pekerjaanController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'Sesi login habis, silakan login kembali.';
      await Supabase.instance.client
          .from('profiles')
          .update({
            'name': _nameController.text.trim(),
            'telepon': _teleponController.text.trim(),
            'pekerjaan': _pekerjaanController.text.trim().isEmpty
                ? null
                : _pekerjaanController.text.trim(),
            'domisili': _alamatController.text.trim().isEmpty
                ? null
                : _alamatController.text.trim(),
          })
          .eq('id', userId);

      if (mounted) {
        showSuccessSnackBar(context, 'Data berhasil diperbarui!');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 20 : 32,
        vertical: 8,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Utama",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileTextField(
                "Nama Lengkap",
                controller: _nameController,
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildProfileTextField(
                      "Email (Tidak bisa diubah)",
                      initialValue: widget.user['email'],
                      isReadOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProfileTextField(
                      "No. Telepon",
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),

              const Text(
                "Data Tambahan (Opsional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Data ini membantu kami untuk pendataan demografi donatur.",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              _buildProfileTextField(
                "Pekerjaan / Instansi",
                controller: _pekerjaanController,
              ),
              const SizedBox(height: 24),
              _buildProfileTextField(
                "Alamat Lengkap",
                controller: _alamatController,
                maxLines: 3,
              ),

              const SizedBox(height: 40),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanPerubahan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProfileTextField(
    String label, {
    TextEditingController? controller,
    String? initialValue,
    bool isReadOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: isReadOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 14,
            color: isReadOnly ? Colors.grey.shade600 : Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
