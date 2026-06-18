import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/snackbar_helper.dart';
import '../../services/supabase_auth_service.dart';
class ManajemenAdminScreen extends StatefulWidget {
  const ManajemenAdminScreen({super.key});

  @override
  State<ManajemenAdminScreen> createState() => _ManajemenAdminScreenState();
}

class _ManajemenAdminScreenState extends State<ManajemenAdminScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _adminList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .inFilter('role', ['admin', 'super_admin', 'nonaktif']);

      setState(() {
        final list = List<Map<String, dynamic>>.from(response);
        final currentUserId = SupabaseAuthService.currentUserData?['id'];

        list.sort((a, b) {
          final roleA = a['role'] ?? '';
          final roleB = b['role'] ?? '';
          
          if (roleA == 'nonaktif' && roleB != 'nonaktif') return 1;
          if (roleA != 'nonaktif' && roleB == 'nonaktif') return -1;

          if (roleA == 'super_admin' && roleB != 'super_admin') return -1;
          if (roleA != 'super_admin' && roleB == 'super_admin') return 1;

          final nameA = (a['name'] ?? '').toString().toLowerCase();
          final nameB = (b['name'] ?? '').toString().toLowerCase();
          return nameA.compareTo(nameB);
        });
        
        if (currentUserId != null) {
          final currentUserIndex = list.indexWhere((admin) => admin['id'] == currentUserId);
          if (currentUserIndex != -1) {
            final currentUser = list.removeAt(currentUserIndex);
            list.insert(0, currentUser);
          }
        }
        
        _adminList = list;
      });
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Gagal memuat data admin: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'admin'; // Default admin biasa
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Admin Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
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
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Admin Konten (CMS)'),
                        ),
                        DropdownMenuItem(
                          value: 'super_admin',
                          child: Text('Super Admin (Full Akses)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRole = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final name = nameController.text.trim().toUpperCase();
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (name.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty) {
                            showInfoSnackBar(
                              context,
                              'Mohon lengkapi semua data',
                            );
                            return;
                          }

                          if (password.length < 6) {
                            showInfoSnackBar(
                              context,
                              'Password minimal 6 karakter',
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          try {
                            // Panggil RPC untuk membuat admin di background
                            await _supabase.rpc(
                              'create_new_admin',
                              params: {
                                'p_email': email,
                                'p_password': password,
                                'p_name': name,
                                'p_role': selectedRole,
                              },
                            );

                            if (mounted) {
                              Navigator.pop(context);
                              showSuccessSnackBar(
                                context,
                                'Admin berhasil ditambahkan',
                              );
                              _fetchAdmins(); // Refresh data
                            }
                          } catch (e) {
                            if (mounted) {
                              showErrorSnackBar(
                                context,
                                'Gagal menambahkan admin: ${e.toString().replaceAll("Exception:", "")}',
                              );
                            }
                          } finally {
                            if (mounted)
                              setDialogState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final nameController = TextEditingController(text: admin['name'] ?? '');
    String selectedRole = admin['role'] ?? 'admin';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Admin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
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
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Admin Konten (CMS)'),
                        ),
                        DropdownMenuItem(
                          value: 'super_admin',
                          child: Text('Super Admin (Full Akses)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRole = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final name = nameController.text.trim().toUpperCase();
                          if (name.isEmpty) {
                            showInfoSnackBar(context, 'Nama tidak boleh kosong');
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          try {
                            await _supabase.from('profiles').update({
                              'name': name,
                              'role': selectedRole,
                            }).eq('id', admin['id']);

                            if (mounted) {
                              Navigator.pop(context);
                              showSuccessSnackBar(context, 'Data admin berhasil diperbarui');
                              _fetchAdmins();
                            }
                          } catch (e) {
                            if (mounted) showErrorSnackBar(context, 'Gagal memperbarui admin: $e');
                          } finally {
                            if (mounted) setDialogState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleAdminStatus(Map<String, dynamic> admin) {
    final isNonaktif = admin['role'] == 'nonaktif';
    final targetRole = isNonaktif ? 'admin' : 'nonaktif';
    final actionText = isNonaktif ? 'mengaktifkan' : 'menonaktifkan';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isNonaktif ? 'Aktifkan' : 'Nonaktifkan'} Admin'),
        content: Text('Apakah Anda yakin ingin $actionText admin ${admin['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _supabase.from('profiles').update({'role': targetRole}).eq('id', admin['id']);
                if (mounted) {
                  showSuccessSnackBar(context, 'Admin berhasil di${isNonaktif ? 'aktifkan' : 'nonaktifkan'}');
                  _fetchAdmins();
                }
              } catch (e) {
                if (mounted) {
                  showErrorSnackBar(context, 'Gagal $actionText admin: $e');
                  setState(() => _isLoading = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isNonaktif ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isNonaktif ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
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
                    "Manajemen Admin",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Kelola akses Super Admin dan Admin Konten.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddAdminDialog,
                icon: const Icon(Icons.add),
                label: const Text("Tambah Admin Baru"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _adminList.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada data admin.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _adminList.length,
                    itemBuilder: (context, index) {
                      final admin = _adminList[index];
                      final role = admin['role'] ?? 'admin';
                      final isSuper = role == 'super_admin';
                      final isNonaktif = role == 'nonaktif';
                      final currentUserId = SupabaseAuthService.currentUserData?['id'];
                      final isCurrentUser = admin['id'] == currentUserId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: CircleAvatar(
                            backgroundColor: isNonaktif
                                ? Colors.grey.shade200
                                : isSuper
                                    ? Colors.purple.shade50
                                    : Colors.blue.shade50,
                            child: Icon(
                              isNonaktif
                                  ? Icons.block
                                  : isSuper
                                      ? Icons.admin_panel_settings
                                      : Icons.person,
                              color: isNonaktif
                                  ? Colors.grey.shade600
                                  : isSuper
                                      ? Colors.purple
                                      : Colors.blue,
                            ),
                          ),
                          title: Text(
                            admin['name'] ?? '-',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isNonaktif ? TextDecoration.lineThrough : null,
                              color: isNonaktif ? Colors.grey : Colors.black,
                            ),
                          ),
                          subtitle: Text(admin['email'] ?? '-'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isNonaktif
                                      ? Colors.grey.shade100
                                      : isSuper
                                          ? Colors.purple.shade50
                                          : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isNonaktif
                                        ? Colors.grey.shade300
                                        : isSuper
                                            ? Colors.purple.shade200
                                            : Colors.blue.shade200,
                                  ),
                                ),
                                child: Text(
                                  isNonaktif ? "Nonaktif" : isSuper ? "Super Admin" : "Admin Konten",
                                  style: TextStyle(
                                    color: isNonaktif
                                        ? Colors.grey.shade600
                                        : isSuper
                                            ? Colors.purple
                                            : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (!isCurrentUser) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black54),
                                  onPressed: () => _showEditAdminDialog(admin),
                                  tooltip: 'Edit Admin',
                                ),
                                IconButton(
                                  icon: Icon(
                                    isNonaktif ? Icons.restore : Icons.block,
                                    color: isNonaktif ? Colors.green : Colors.red,
                                  ),
                                  onPressed: () => _toggleAdminStatus(admin),
                                  tooltip: isNonaktif ? 'Aktifkan Admin' : 'Nonaktifkan Admin',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
