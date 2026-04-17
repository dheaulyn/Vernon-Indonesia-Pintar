import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
// Import halaman-halaman konten
import 'home/home_dashboard.dart'; 
import 'faq/faq_admin.dart';
import 'jenis_beasiswa/jenis_beasiswa_admin.dart';

class LayoutDashboard extends StatefulWidget {
  const LayoutDashboard({super.key});

  @override
  State<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends State<LayoutDashboard> {
  // Index untuk mengontrol halaman mana yang aktif
  int _currentTabIndex = 0;

  // Daftar halaman konten yang akan dipanggil
  final List<Widget> _adminPages = [
    const HomeDashboard(), // 👇 Pastikan ini TIDAK dikomentari (karena filenya sudah kita buat)
    
    // 👇 Gunakan halaman sementara jika file aslinya belum kamu buat
    const Center(child: Text("Halaman Kelola Beasiswa (Sedang Dibangun)", style: TextStyle(fontSize: 20))), 
    const Center(child: Text("Halaman Kelola FAQ (Sedang Dibangun)", style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      // Drawer untuk tampilan Mobile
      drawer: isMobile ? Drawer(child: _buildSidebar()) : null,
      body: Row(
        children: [
          // Sidebar permanen untuk tampilan Desktop
          if (!isMobile) SizedBox(width: 280, child: _buildSidebar()),
          
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(isMobile),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _adminPages[_currentTabIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildAdminLogo(),
          const Divider(indent: 20, endIndent: 20),
          const SizedBox(height: 20),
          _menuTile(Icons.grid_view_rounded, "Home Dashboard", 0),
          _menuTile(Icons.auto_awesome_motion_rounded, "Jenis Beasiswa", 1),
          _menuTile(Icons.help_center_rounded, "Kelola FAQ", 2),
          const Spacer(),
          _menuTile(Icons.power_settings_new_rounded, "Keluar", -1, isExit: true),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, int index, {bool isExit = false}) {
    bool isSelected = _currentTabIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        onTap: () {
          if (isExit) {
            Navigator.pop(context);
          } else {
            setState(() => _currentTabIndex = index);
            if (MediaQuery.of(context).size.width < 1100) Navigator.pop(context);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        leading: Icon(
          icon, 
          color: isExit ? Colors.red : (isSelected ? AppColors.primary : Colors.grey),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isExit ? Colors.red : (isSelected ? AppColors.primary : Colors.grey[700]),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isMobile) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: isMobile ? Colors.white : Colors.transparent,
      child: Row(
        children: [
          if (isMobile)
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }),
          const Text(
            "Admin Panel VIP",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person_outline, color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _buildAdminLogo() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.blue, size: 30),
          const SizedBox(width: 10),
          const Text("VIP ADMIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}