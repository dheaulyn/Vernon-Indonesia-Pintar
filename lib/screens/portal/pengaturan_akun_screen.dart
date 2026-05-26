import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_colors.dart';
import '../../core/snackbar_helper.dart';
import 'portal_layout.dart';
import '../../services/supabase_auth_service.dart';

class PengaturanAkunScreen extends StatefulWidget {
  const PengaturanAkunScreen({super.key});

  @override
  State<PengaturanAkunScreen> createState() => _PengaturanAkunScreenState();
}

class _PengaturanAkunScreenState extends State<PengaturanAkunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  String _currentPassword = '';
  String _currentConfirmPassword = '';

  // Cek persyaratan password
  bool get _hasMinLength => _currentPassword.length >= 6;
  bool get _hasUppercase => _currentPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _currentPassword.contains(RegExp(r'[0-9]'));
  bool get _passwordsMatch =>
      _currentConfirmPassword.isNotEmpty &&
      _currentPassword == _currentConfirmPassword;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() => _isUploadingAvatar = true);
        
        final error = await SupabaseAuthService.uploadAvatar(result.files.single);
        
        setState(() => _isUploadingAvatar = false);

        if (error == null) {
          if (mounted) showSuccessSnackBar(context, 'Foto profil berhasil diperbarui!');
        } else {
          if (mounted) showErrorSnackBar(context, error);
        }
      }
    } catch (e) {
      setState(() => _isUploadingAvatar = false);
      if (mounted) showErrorSnackBar(context, 'Terjadi kesalahan saat memilih foto: \$e');
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await SupabaseAuthService.changePassword(_passwordController.text);

    setState(() => _isLoading = false);

    if (mounted) {
      if (error == null) {
        showSuccessSnackBar(context, 'Password berhasil diubah!');
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _currentPassword = '';
          _currentConfirmPassword = '';
        });
      } else {
        showErrorSnackBar(context, error);
      }
    }
  }

  List<Widget> _buildPasswordChecklist() {
    return [
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Persyaratan Password:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            _buildCheckItem('Minimal 6 karakter', _hasMinLength),
            _buildCheckItem('Mengandung huruf kapital (A-Z)', _hasUppercase),
            _buildCheckItem('Mengandung angka (0-9)', _hasDigit),
          ],
        ),
      ),
    ];
  }

  Widget _buildCheckItem(String text, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15,
            color: passed ? Colors.green.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: passed ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: passed ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseAuthService.currentUserData ?? {};
    final email = user['email'] ?? 'Tidak diketahui';
    final name = user['name'] ?? 'Siswa';
    final String? avatarUrl = user['avatar_url'] as String?;

    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return PortalLayout(
      activeMenu: 'pengaturan_akun', // Custom non-sidebar menu
      content: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pengaturan Akun",
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentBlack,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Ubah kata sandi Anda untuk menjaga keamanan akun.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // ==========================================
              // FOTO PROFIL
              // ==========================================
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    if (_isUploadingAvatar)
                      const Positioned.fill(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ==========================================
              // INFORMASI AKUN
              // ==========================================
              const Text(
                "Informasi Akun",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              _buildReadOnlyField("Nama Lengkap", name),
              const SizedBox(height: 20),
              _buildReadOnlyField(
                "Email",
                email,
                helperText: "Email digunakan sebagai identitas login dan tidak dapat diubah.",
              ),
              const SizedBox(height: 40),

              // ==========================================
              // UBAH PASSWORD
              // ==========================================
              const Text(
                "Ubah Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              
              _buildPasswordField(
                "Password Baru",
                _passwordController,
                _obscurePassword,
                (val) => setState(() => _obscurePassword = val),
                onChanged: (val) => setState(() => _currentPassword = val),
              ),
              if (_currentPassword.isNotEmpty) ..._buildPasswordChecklist(),
              const SizedBox(height: 20),
              
              _buildPasswordField(
                "Konfirmasi Password Baru",
                _confirmPasswordController,
                _obscureConfirmPassword,
                (val) => setState(() => _obscureConfirmPassword = val),
                onChanged: (val) => setState(() => _currentConfirmPassword = val),
                isConfirm: true,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: isMobile ? double.infinity : 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            helperText: helperText,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    Function(bool) toggleObscure, {
    Function(String)? onChanged,
    bool isConfirm = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '\$label tidak boleh kosong';
            }
            if (!isConfirm) {
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Harus mengandung huruf kapital (A-Z)';
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Harus mengandung angka (0-9)';
              }
            }
            if (isConfirm && value != _passwordController.text) {
              return 'Konfirmasi password tidak cocok';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isConfirm 
                  ? (_currentConfirmPassword.isEmpty
                      ? Colors.grey.shade300
                      : _passwordsMatch
                          ? Colors.green.shade400
                          : Colors.red.shade300)
                  : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isConfirm
                    ? (_currentConfirmPassword.isEmpty
                        ? AppColors.primary
                        : _passwordsMatch
                            ? Colors.green.shade500
                            : Colors.red.shade400)
                    : AppColors.primary,
                width: 1.5,
              ),
            ),
            suffixIcon: isConfirm && _currentConfirmPassword.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _passwordsMatch ? Icons.check_circle : Icons.cancel,
                        color: _passwordsMatch
                            ? Colors.green.shade500
                            : Colors.red.shade400,
                        size: 22,
                      ),
                      IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => toggleObscure(!obscureText),
                      ),
                    ],
                  )
                : IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => toggleObscure(!obscureText),
                  ),
          ),
        ),
      ],
    );
  }
}
