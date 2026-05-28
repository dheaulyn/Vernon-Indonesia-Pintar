import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/snackbar_helper.dart';
import '../../services/supabase_auth_service.dart';

class RegisterDonaturScreen extends StatefulWidget {
  const RegisterDonaturScreen({super.key});

  @override
  State<RegisterDonaturScreen> createState() => _RegisterDonaturScreenState();
}

class _RegisterDonaturScreenState extends State<RegisterDonaturScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isAgreed = false;
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

  // 👇 FUNGSI YANG SUDAH DIPERBAIKI
  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) return;

    if (!_isAgreed) {
      setState(() {
        _errorMessage =
            'Anda harus menyetujui Syarat & Ketentuan untuk mendaftar.';
      });
      return;
    }

    // Validasi persyaratan password sebelum kirim ke server
    if (!_hasMinLength || !_hasUppercase || !_hasDigit) {
      setState(() {
        _errorMessage = 'Password belum memenuhi semua persyaratan.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Panggil register dan set role-nya sebagai 'donatur'
    String? error = await SupabaseAuthService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      'donatur',
      _phoneController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      // null = berhasil
      showSuccessSnackBar(context, 'Registrasi berhasil! Silakan masuk dengan akun Anda.');
      context.go('/login-donatur');
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
    _phoneController.dispose();
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
                  child: Container(
                    width: 500,
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header: Tombol Kembali & Logo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 👇 PERBAIKAN: Posisi tombol arrow_back
                              Transform.translate(
                                offset: const Offset(-12, 0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () => context.go('/login-donatur'),
                                  tooltip: 'Kembali',
                                ),
                              ),
                              Image.asset('assets/logo.png', height: 40),
                            ],
                          ),
                          const SizedBox(height: 30),

                          const Text(
                            'Daftar Akun Donatur',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentBlack,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Bergabunglah bersama VIP untuk mulai wujudkan perubahan nyata bagi generasi muda.',
                            style: TextStyle(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),

                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
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
                          _buildLabel('Nama Lengkap'),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'Masukkan nama lengkap Anda',
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                return newValue.copyWith(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                );
                              }),
                            ],
                            validator: (val) =>
                                val!.isEmpty ? 'Nama tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 20),

                          // Form Email & No HP
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Email'),
                                    _buildTextField(
                                      controller: _emailController,
                                      hint: 'contoh@mail.com',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return 'Email wajib diisi';
                                        }
                                        if (!val.contains('@')) {
                                          return 'Format email salah';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('No. Telepon'),
                                    _buildTextField(
                                      controller: _phoneController,
                                      hint: 'Contoh: 08123456789',
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Nomor Telepon tidak boleh kosong';
                                        if (val.length < 10 || val.length > 14) return 'Nomor Telepon tidak valid (10-14 digit)';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Form Password
                          _buildLabel('Password'),
                          _buildPasswordField(
                            controller: _passwordController,
                            hint: 'Min. 6 karakter, huruf besar & angka',
                            isVisible: _isPasswordVisible,
                            onVisibilityChanged: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                            onChanged: (val) => setState(() => _currentPassword = val),
                            validator: (val) {
                              if (val!.length < 6) return 'Password minimal 6 karakter';
                              if (!val.contains(RegExp(r'[A-Z]'))) return 'Harus ada huruf kapital';
                              if (!val.contains(RegExp(r'[0-9]'))) return 'Harus ada angka';
                              return null;
                            },
                          ),
                          // ✅ Indikator persyaratan password
                          if (_currentPassword.isNotEmpty) ..._buildPasswordChecklist(),
                          const SizedBox(height: 20),

                          // Form Konfirmasi Password
                          _buildLabel('Konfirmasi Password'),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            onChanged: (val) => setState(() => _currentConfirmPassword = val),
                            validator: (val) {
                              if (val!.isEmpty) return 'Wajib diisi';
                              if (val != _passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Ulangi password Anda',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                              errorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.redAccent, width: 1),
                              ),
                              suffixIcon: _currentConfirmPassword.isEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _passwordsMatch ? Icons.check_circle : Icons.cancel,
                                          color: _passwordsMatch ? Colors.green.shade500 : Colors.red.shade400,
                                          size: 22,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                            color: Colors.grey.shade600,
                                          ),
                                          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Checkbox Syarat & Ketentuan
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _isAgreed,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) =>
                                      setState(() => _isAgreed = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Saya menyetujui '),
                                      TextSpan(
                                        text: 'Syarat & Ketentuan',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: ' serta '),
                                      TextSpan(
                                        text: 'Kebijakan Privasi',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: ' Yayasan VIP.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),

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
                                      'DAFTAR SEBAGAI DONATUR',
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
                                onPressed: () => context.go('/login-donatur'),
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

                          const SizedBox(height: 15),
                          const Divider(color: Colors.black12),
                          const SizedBox(height: 15),

                          // Pintu Khusus Siswa
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Anda seorang siswa atau pendaftar beasiswa?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: OutlinedButton(
                                    onPressed: () => context.go('/register'),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      "Daftar sebagai Siswa",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // WIDGET BANTUAN UNTUK FORM
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.redAccent, width: 1),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: onVisibilityChanged,
        ),
      ),
    );
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
}
