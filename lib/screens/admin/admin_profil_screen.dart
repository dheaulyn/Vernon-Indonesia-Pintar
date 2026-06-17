import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/supabase_auth_service.dart';
import '../../core/snackbar_helper.dart';

class AdminProfilScreen extends StatefulWidget {
  const AdminProfilScreen({super.key});

  @override
  State<AdminProfilScreen> createState() => _AdminProfilScreenState();
}

class _AdminProfilScreenState extends State<AdminProfilScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userData = SupabaseAuthService.currentUserData;
    if (userData != null) {
      _nameController.text = userData['name'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim().toUpperCase();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      showInfoSnackBar(context, 'Nama tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update Name
      final error = await SupabaseAuthService.updateProfileFields({'name': name});
      if (error != null) {
        if (mounted) showErrorSnackBar(context, error);
        return;
      }

      // Update Password if filled
      if (password.isNotEmpty) {
        if (password.length < 6) {
          if (mounted) showInfoSnackBar(context, 'Password minimal 6 karakter');
          return;
        }
        final pwdError = await SupabaseAuthService.changePassword(password);
        if (pwdError != null) {
          if (mounted) showErrorSnackBar(context, pwdError);
          return;
        }
        _passwordController.clear();
      }

      if (mounted) showSuccessSnackBar(context, 'Profil berhasil diperbarui');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = SupabaseAuthService.currentUserData;
    final role = userData?['role'] == 'super_admin' ? 'Super Admin' : 'Admin Konten';
    final email = userData?['email'] ?? '-';

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profil Saya",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Kelola data profil dan password Anda.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.person, size: 30, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return TextEditingValue(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan nama lengkap',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Ubah Password", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ketik password baru jika ingin mengubah password saat ini',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
