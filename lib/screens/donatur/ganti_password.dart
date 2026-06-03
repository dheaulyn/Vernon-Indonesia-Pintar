import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👇 Import Supabase
import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

// 👇 Ubah jadi StatefulWidget
class GantiPasswordView extends StatefulWidget {
  final bool isMobile;

  const GantiPasswordView({super.key, required this.isMobile});

  @override
  State<GantiPasswordView> createState() => _GantiPasswordViewState();
}

class _GantiPasswordViewState extends State<GantiPasswordView> {
  // 1. Siapkan controller untuk password
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 2. FUNGSI UNTUK MENGGANTI PASSWORD
  Future<void> _updatePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi dasar
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showErrorSnackBar(context, 'Password baru tidak boleh kosong!');
      return;
    }
    if (newPassword.length < 6) {
      showErrorSnackBar(context, 'Password baru minimal 6 karakter!');
      return;
    }
    if (newPassword != confirmPassword) {
      showErrorSnackBar(context, 'Konfirmasi password tidak cocok!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil fungsi bawaan Supabase untuk update password user yang sedang login
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        showSuccessSnackBar(context, 'Password berhasil diperbarui!');
        // Kosongkan form setelah sukses
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Gagal memperbarui password: $e');
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
                "Pastikan password baru Anda menggunakan kombinasi huruf dan angka agar lebih aman.",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 30),

              /* Catatan: Di Supabase, kita tidak butuh 'Password Lama' jika user 
                 sudah terautentikasi (login). Jadi kita sembunyikan/hapus field tersebut 
                 dan fokus ke Password Baru saja. */
              _buildPasswordField("Password Baru", _newPasswordController),
              const SizedBox(height: 24),
              _buildPasswordField(
                "Konfirmasi Password Baru",
                _confirmPasswordController,
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
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
                          "Perbarui Password",
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
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
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
          controller: controller, // 👇 Pasang controller di sini
          obscureText: true,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
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
