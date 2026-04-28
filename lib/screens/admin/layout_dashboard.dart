import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../data/mock_database.dart';

// Import halaman-halaman konten
import 'home_dashboard.dart';
import 'faq_admin.dart';
import 'jenis_beasiswa_admin.dart';
import 'hero_banner_admin.dart'; // Pastikan file ini juga dibuat kembali nanti

class LayoutDashboard extends StatefulWidget {
  const LayoutDashboard({super.key});

  @override
  State<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends State<LayoutDashboard> {
  int _currentTabIndex = 0;
  bool _isCollapsed = false; 

  final List<Widget> _adminPages = [
    const HomeDashboard(),         // Index 0
    const JenisBeasiswaAdmin(),    // Index 1
    const KelolaFAQPage(),         // Index 2
    const HeroBannerAdmin(),       // Index 3: Halaman Kelola Hero Banner Asli
    const Center(child: Text("Halaman Kelola Footer (Sedang Dibangun)", style: TextStyle(fontSize: 20))), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    // Jika di mobile, paksa sidebar terlipat atau gunakan Drawer
    final bool isSidebarCollapsed = isMobile ? true : _isCollapsed;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), 
      appBar: _buildTopNavbar(), 
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
  // WIDGET: TOP NAVBAR
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
          Image.asset('assets/logo.png', height: 32),
          const SizedBox(width: 10),
          const Text(
            'ADMINISTRATOR VIP',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
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
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
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
                    Text('Keluar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
  // WIDGET: SIDEBAR
  // ==========================================
  Widget _buildSidebar(bool isCollapsed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 70 : 260,
      color: const Color(0xFF2B3240),
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
                
                // ==========================================
                // KATEGORI 1: MENU ADMIN
                // ==========================================
                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.only(left: 23, bottom: 10),
                    child: Text(
                      'MENU ADMIN',
                      style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                if (isCollapsed) const SizedBox(height: 25),

                _sidebarMenu(Icons.grid_view_rounded, "Home Dashboard", 0, isCollapsed),
                
                const SizedBox(height: 15),

                // ==========================================
                // KATEGORI 2: MENU CMS
                // ==========================================
                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.only(left: 23, bottom: 10),
                    child: Text(
                      'KONTEN WEBSITE (CMS)',
                      style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                if (isCollapsed) const SizedBox(height: 10),

                _sidebarMenu(Icons.auto_awesome_motion_rounded, "Jenis Beasiswa", 1, isCollapsed),
                _sidebarMenu(Icons.help_center_rounded, "Kelola FAQ", 2, isCollapsed),
                _sidebarMenu(Icons.image_rounded, "Kelola Hero Banner", 3, isCollapsed),
                _sidebarMenu(Icons.contact_mail_rounded, "Kelola Footer", 4, isCollapsed),

                const Spacer(),
                const Divider(color: Colors.white24),

                // ==========================================
                // SISTEM & KELUAR
                // ==========================================
                _sidebarMenu(Icons.public, "Lihat Web Publik", -2, isCollapsed, isWebLink: true),
                _sidebarMenu(Icons.power_settings_new_rounded, "Keluar", -1, isCollapsed, isLogout: true),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarMenu(IconData icon, String title, int index, bool isCollapsed, {bool isLogout = false, bool isWebLink = false}) {
    final bool isActive = _currentTabIndex == index;
    final Color activeColor = isLogout ? Colors.redAccent : (isWebLink ? Colors.green : AppColors.primary);
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
              context.go('/'); 
            } else {
              setState(() => _currentTabIndex = index);
            }
          },
          child: Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
              border: Border(left: BorderSide(color: isActive ? activeColor : Colors.transparent, width: 4)),
            ),
            child: Row(
              children: [
                Icon(icon, color: isActive ? activeColor : (isWebLink ? Colors.green.withOpacity(0.7) : inactiveColor), size: 24),
                if (!isCollapsed) ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isActive ? Colors.white : (isWebLink ? Colors.green : Colors.white70),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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