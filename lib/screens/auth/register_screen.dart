import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/snackbar_helper.dart';
import '../../services/supabase_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentPassword = '';
  String _currentConfirmPassword = '';

  // Cek persyaratan password
  bool get _hasMinLength => _currentPassword.length >= 6;
  bool get _hasUppercase => _currentPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _currentPassword.contains(RegExp(r'[0-9]'));
  bool get _passwordsMatch =>
      _currentConfirmPassword.isNotEmpty &&
      _currentPassword == _currentConfirmPassword;

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Semua kolom wajib diisi!';
        _isLoading = false;
      });
      return;
    }

    // Validasi persyaratan password sebelum kirim ke server
    if (!_hasMinLength || !_hasUppercase || !_hasDigit) {
      setState(() {
        _errorMessage = 'Password belum memenuhi semua persyaratan.';
        _isLoading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _errorMessage = 'Password dan Konfirmasi Password tidak cocok!';
        _isLoading = false;
      });
      return;
    }

    // Panggil register untuk mendaftarkan akun siswa
    final error = await SupabaseAuthService.register(name, email, password);

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      if (!mounted) return;

      showSuccessSnackBar(context, 'Pendaftaran berhasil! Silakan masuk dengan akun baru Anda.');

      // Menggunakan go_router untuk kembali ke halaman login
      context.go('/login');
    } else {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: const Color(
        0xFFFBFBFB,
      ), // Background menyatu dengan layar
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Kembali & Logo (Sama dengan Login)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  context.go('/login');
                                },
                                tooltip: 'Kembali ke Halaman Login',
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
                            ),
                            Image.asset('assets/logo.png', height: 40),
                          ],
                        ),
                        const SizedBox(height: 40),

                        const Text(
                          'Daftar Akun Siswa',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Buat akun portal siswa untuk mendaftar dan memantau status beasiswa VIP.',
                          style: TextStyle(color: Colors.black54, height: 1.4),
                        ),
                        const SizedBox(height: 35),

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                        // Form Nama Lengkap
                        const Text(
                          'Nama Lengkap',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Sesuai KTP / Kartu Pelajar',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Form Email
                        const Text(
                          'Email Aktif',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'contoh@email.com',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Form Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          onChanged: (val) => setState(() => _currentPassword = val),
                          decoration: InputDecoration(
                            hintText: 'Min. 6 karakter, huruf besar & angka',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                          ),
                        ),
                        // ✅ Indikator persyaratan password
                        if (_currentPassword.isNotEmpty) ..._buildPasswordChecklist(),
                        const SizedBox(height: 20),

                        // Form Konfirmasi Password
                        const Text(
                          'Konfirmasi Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          onChanged: (val) => setState(() => _currentConfirmPassword = val),
                          decoration: InputDecoration(
                            hintText: 'Masukkan ulang password',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _currentConfirmPassword.isEmpty
                                    ? Colors.grey.shade300
                                    : _passwordsMatch
                                        ? Colors.green.shade400
                                        : Colors.red.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _currentConfirmPassword.isEmpty
                                    ? AppColors.primary
                                    : _passwordsMatch
                                        ? Colors.green.shade500
                                        : Colors.red.shade400,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: _currentConfirmPassword.isEmpty
                                ? IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () => setState(
                                      () => _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _passwordsMatch
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: _passwordsMatch
                                            ? Colors.green.shade500
                                            : Colors.red.shade400,
                                        size: 22,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () => setState(
                                          () => _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
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
                                    'DAFTAR SEKARANG',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Navigasi ke Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun?',
                              style: TextStyle(fontSize: 14),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text(
                                'Masuk di sini',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
