import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../data/mock_database.dart';

// Import halaman-halaman konten
import 'home_dashboard.dart';
import 'faq_admin.dart';
import 'jenis_beasiswa_admin.dart';

class LayoutDashboard extends StatefulWidget {
  const LayoutDashboard({super.key});

  @override
  State<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends State<LayoutDashboard> {
  int _currentTabIndex = 0;
  bool _isCollapsed = false; // Fitur lipat sidebar ala Portal Siswa

  final List<Widget> _adminPages = [
    const HomeDashboard(),
    const JenisBeasiswaAdmin(),
    const KelolaFAQPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    // Jika di mobile, paksa sidebar terlipat atau gunakan Drawer
    final bool isSidebarCollapsed = isMobile ? true : _isCollapsed;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Warna background sama persis
      appBar: _buildTopNavbar(), // Navbar sama persis
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar ala Portal Siswa
          _buildSidebar(isSidebarCollapsed),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _adminPages[_currentTabIndex],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: TOP NAVBAR (Persis Portal Siswa)
  // ==========================================
  PreferredSizeWidget _buildTopNavbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 10,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
          ),
          const SizedBox(width: 10),
          Image.asset('assets/logo.png', height: 32), // Logo VIP
          const SizedBox(width: 10),
          const Text(
            'ADMINISTRATOR VIP', // Judul diganti untuk Admin
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        // Menu Profil Akun
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: PopupMenuButton<String>(
            tooltip: 'Menu Akun',
            offset: const Offset(0, 45),
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Text(
                    MockDatabase.currentUser?['name'] ?? 'ADMIN VIP',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        Colors.blueAccent, // Beda warna avatar untuk admin
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                MockDatabase.logout();
                context.go('/login');
              }
            },
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  // ==========================================
  // WIDGET: SIDEBAR (Tema Gelap Portal Siswa)
  // ==========================================
  Widget _buildSidebar(bool isCollapsed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 70 : 260,
      color: const Color(0xFF2B3240), // Warna gelap sama
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.only(left: 23, bottom: 10),
                    child: Text(
                      'MENU ADMIN',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (isCollapsed) const SizedBox(height: 25),

                // Daftar Menu Admin
                _sidebarMenu(
                  Icons.grid_view_rounded,
                  "Home Dashboard",
                  0,
                  isCollapsed,
                ),
                _sidebarMenu(
                  Icons.auto_awesome_motion_rounded,
                  "Jenis Beasiswa",
                  1,
                  isCollapsed,
                ),
                _sidebarMenu(
                  Icons.help_center_rounded,
                  "Kelola FAQ",
                  2,
                  isCollapsed,
                ),

                const Spacer(),
                const Divider(color: Colors.white24),

                // Tombol Lihat Web Publik (Fitur Khusus Admin)
                _sidebarMenu(
                  Icons.public,
                  "Lihat Web Publik",
                  -2,
                  isCollapsed,
                  isWebLink: true,
                ),

                // Tombol Keluar
                _sidebarMenu(
                  Icons.power_settings_new_rounded,
                  "Keluar",
                  -1,
                  isCollapsed,
                  isLogout: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarMenu(
    IconData icon,
    String title,
    int index,
    bool isCollapsed, {
    bool isLogout = false,
    bool isWebLink = false,
  }) {
    final bool isActive = _currentTabIndex == index;
    final Color activeColor = isLogout
        ? Colors.redAccent
        : (isWebLink ? Colors.green : AppColors.primary);
    final Color inactiveColor = Colors.white54;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: isCollapsed ? title : '',
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: () {
            if (isLogout) {
              MockDatabase.logout();
              context.go('/login');
            } else if (isWebLink) {
              context.go('/'); // Pindah ke halaman beranda
            } else {
              setState(() => _currentTabIndex = index);
            }
          },
          child: Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withOpacity(0.15)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isActive ? activeColor : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? activeColor
                      : (isWebLink
                            ? Colors.green.withOpacity(0.7)
                            : inactiveColor),
                  size: 24,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : (isWebLink ? Colors.green : Colors.white70),
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
