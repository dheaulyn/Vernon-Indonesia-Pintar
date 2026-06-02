import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../services/supabase_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  /// Parameter opsional untuk menentukan dari halaman login mana user datang.
  /// Jika 'donatur', tombol kembali mengarah ke /login-donatur.
  final String? from;

  const ForgotPasswordScreen({super.key, this.from});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _errorMessage = '';
  String _currentPassword = '';
  String _currentConfirmPassword = '';

  /// 0 = form verifikasi identitas (email + nama)
  /// 1 = form password baru
  /// 2 = sukses
  int _step = 0;

  // Cek persyaratan password
  bool get _hasMinLength => _currentPassword.length >= 6;
  bool get _hasUppercase => _currentPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _currentPassword.contains(RegExp(r'[0-9]'));
  bool get _passwordsMatch =>
      _currentConfirmPassword.isNotEmpty &&
      _currentPassword == _currentConfirmPassword;

  /// Step 1: Validasi input email & nama, lalu lanjut ke step password
  void _handleVerifyIdentity() {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || name.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan nama lengkap tidak boleh kosong!';
      });
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Format email tidak valid!';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _step = 1;
    });
  }

  /// Step 2: Reset password via RPC
  Future<void> _handleResetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // Validasi persyaratan password
    if (!_hasMinLength || !_hasUppercase || !_hasDigit) {
      setState(() {
        _errorMessage = 'Password belum memenuhi semua persyaratan.';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _errorMessage = 'Password dan Konfirmasi Password tidak cocok!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final error = await SupabaseAuthService.verifyAndResetPassword(
      _emailController.text.trim(),
      _nameController.text.trim(),
      password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      setState(() {
        _step = 2;
      });
    } else {
      // Jika nama atau email salah, kembali ke step 0
      if (error.contains('tidak ditemukan') || error.contains('tidak cocok')) {
        setState(() {
          _step = 0;
          _errorMessage = error;
        });
      } else {
        setState(() {
          _errorMessage = error;
        });
      }
    }
  }

  String get _backRoute {
    if (widget.from == 'donatur') return '/login-donatur';
    return '/login';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_step),
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
                      child: _buildCurrentStep(),
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

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildVerifyIdentityStep();
      case 1:
        return _buildNewPasswordStep();
      case 2:
        return _buildSuccessStep();
      default:
        return _buildVerifyIdentityStep();
    }
  }

  // ============================================================
  // STEP 0: Verifikasi Identitas (Email + Nama Lengkap)
  // ============================================================
  Widget _buildVerifyIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: Tombol kembali & Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Transform.translate(
              offset: const Offset(-8, 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => context.go(_backRoute),
                tooltip: 'Kembali ke Login',
              ),
            ),
            Image.asset('assets/logo.png', height: 40),
          ],
        ),
        const SizedBox(height: 40),

        // Ikon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Lupa Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.accentBlack,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Masukkan email dan nama lengkap Anda yang terdaftar untuk memverifikasi identitas.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),

        // Error message
        _buildErrorMessage(),

        // Step indicator
        _buildStepIndicator(0),
        const SizedBox(height: 24),

        // Form Email
        const Text(
          'Email',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hint: 'Masukkan email terdaftar',
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 20),

        // Form Nama Lengkap
        const Text(
          'Nama Lengkap',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(
                text: newValue.text.toUpperCase(),
                selection: newValue.selection,
              );
            }),
          ],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleVerifyIdentity(),
          decoration: _inputDecoration(
            hint: 'Sesuai saat pendaftaran',
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 12),

        // Info box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nama lengkap harus sama persis dengan yang Anda daftarkan.',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Tombol Lanjut
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _handleVerifyIdentity,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'LANJUTKAN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Link kembali ke login
        Center(
          child: TextButton.icon(
            onPressed: () => context.go(_backRoute),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text(
              'Kembali ke halaman login',
              style: TextStyle(fontSize: 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 1: Buat Password Baru
  // ============================================================
  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: Tombol kembali & Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Transform.translate(
              offset: const Offset(-8, 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _step = 0;
                    _errorMessage = '';
                  });
                },
                tooltip: 'Kembali ke Verifikasi',
              ),
            ),
            Image.asset('assets/logo.png', height: 40),
          ],
        ),
        const SizedBox(height: 40),

        // Ikon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.vpn_key_outlined,
            size: 28,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Buat Password Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.accentBlack,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Silakan buat password baru untuk akun Anda.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),

        // Error message
        _buildErrorMessage(),

        // Step indicator
        _buildStepIndicator(1),
        const SizedBox(height: 24),

        // Form Password Baru
        const Text(
          'Password Baru',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          onChanged: (val) => setState(() => _currentPassword = val),
          decoration: InputDecoration(
            hintText: 'Min. 6 karakter, huruf besar & angka',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.lock_outline,
                color: Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
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
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),

        // Checklist password
        if (_currentPassword.isNotEmpty) ..._buildPasswordChecklist(),
        const SizedBox(height: 20),

        // Form Konfirmasi Password
        const Text(
          'Konfirmasi Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          onChanged: (val) => setState(() => _currentConfirmPassword = val),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleResetPassword(),
          decoration: InputDecoration(
            hintText: 'Masukkan ulang password baru',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.lock_outline,
                color: Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
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
                horizontal: 16, vertical: 16),
            suffixIcon: _currentConfirmPassword.isEmpty
                ? IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => setState(() =>
                        _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible),
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
                        onPressed: () => setState(() =>
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 28),

        // Tombol Reset
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.6),
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
                    'RESET PASSWORD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Link kembali ke step sebelumnya
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _step = 0;
                _errorMessage = '';
              });
            },
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text(
              'Kembali ke verifikasi identitas',
              style: TextStyle(fontSize: 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2: Sukses
  // ============================================================
  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ikon sukses
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 44,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Password Berhasil Direset!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.accentBlack,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        Text(
          'Password akun Anda telah berhasil diubah. Silakan masuk menggunakan password baru Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // Tampilkan email
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _emailController.text.trim(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Tombol ke halaman login
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () => context.go(_backRoute),
            icon: const Icon(Icons.login, size: 20),
            label: const Text(
              'MASUK SEKARANG',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WIDGET BANTUAN
  // ============================================================

  /// Step indicator (2 langkah)
  Widget _buildStepIndicator(int activeStep) {
    return Row(
      children: [
        _buildStepDot(0, activeStep, 'Verifikasi'),
        Expanded(
          child: Container(
            height: 2,
            color: activeStep >= 1
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
        ),
        _buildStepDot(1, activeStep, 'Password Baru'),
      ],
    );
  }

  Widget _buildStepDot(int step, int activeStep, String label) {
    final isActive = step <= activeStep;
    final isCurrent = step == activeStep;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 3)
                : null,
          ),
          child: Center(
            child: isActive && step < activeStep
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? AppColors.primary : Colors.grey.shade500,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Error message widget
  Widget _buildErrorMessage() {
    if (_errorMessage.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Input decoration helper
  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade500, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// Password checklist
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
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
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
}
