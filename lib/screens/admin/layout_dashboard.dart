import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../data/mock_database.dart';

// Catatan: Anda TIDAK perlu lagi mengimpor halaman-halaman (HomeDashboard, dll) di file ini,
// karena halaman-halaman tersebut akan dipanggil di file konfigurasi router Anda.

class LayoutDashboard extends StatefulWidget {
  final Widget
  child; // 👇 Menampung halaman konten yang disuntikkan oleh router

  const LayoutDashboard({super.key, required this.child});

  @override
  State<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends State<LayoutDashboard> {
  bool _isCollapsed = false;
  // 👇 STATE BARU: Mengatur status buka/tutup dropdown Manajemen Donasi
  bool _isDonasiExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final bool isSidebarCollapsed = isMobile ? true : _isCollapsed;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildTopNavbar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebar(isSidebarCollapsed),
          Expanded(
            // 👇 Menampilkan halaman berdasarkan route URL saat ini
            child: widget.child,
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
          Image.asset(
            'assets/logo.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.school),
          ),
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
  // WIDGET: SIDEBAR
  // ==========================================
  Widget _buildSidebar(bool isCollapsed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 70 : 260,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF2B3240),
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
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
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  if (isCollapsed) const SizedBox(height: 25),

                  _sidebarMenu(
                    Icons.grid_view_rounded,
                    "Home Dashboard",
                    "/admin-dashboard",
                    isCollapsed,
                  ),

                  _sidebarMenu(
                    Icons.people_alt_rounded,
                    "Data Pendaftar",
                    "/admin-pendaftar",
                    isCollapsed,
                  ),

                  // 👇 REVISI: SEKARANG BERBENTUK DROPDOWN MENU KELOLA DONASI
                  _buildDropdownDonasi(isCollapsed),

                  const SizedBox(height: 15),

                  // ==========================================
                  // KATEGORI 2: MENU CMS
                  // ==========================================
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.only(left: 23, bottom: 10),
                      child: Text(
                        'KONTEN WEBSITE (CMS)',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  if (isCollapsed) const SizedBox(height: 10),

                  _sidebarMenu(
                    Icons.image_rounded,
                    "Kelola Hero Banner",
                    "/cms-hero-banner",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.info_outline_rounded,
                    "Kelola Tentang Kami",
                    "/cms-about",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.account_balance_rounded,
                    "Kelola Profil Yayasan",
                    "/cms-profil",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.format_list_numbered_rtl_rounded,
                    "Kelola Detail Program",
                    "/cms-program",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.article_rounded,
                    "Kelola Media",
                    "/cms-media",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.handshake_rounded,
                    "Kelola Partner",
                    "/cms-partners",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.format_quote_rounded,
                    "Kelola Testimoni",
                    "/cms-testimoni",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.help_center_rounded,
                    "Kelola FAQ",
                    "/cms-faq",
                    isCollapsed,
                  ),
                  _sidebarMenu(
                    Icons.contact_mail_rounded,
                    "Kelola Footer",
                    "/cms-footer",
                    isCollapsed,
                  ),

                  const SizedBox(height: 40),
                  const Divider(color: Colors.white24),

                  // ==========================================
                  // SISTEM & KELUAR
                  // ==========================================
                  _sidebarMenu(
                    Icons.public,
                    "Lihat Web Publik",
                    "/",
                    isCollapsed,
                    isWebLink: true,
                  ),
                  _sidebarMenu(
                    Icons.power_settings_new_rounded,
                    "Keluar",
                    "/login",
                    isCollapsed,
                    isLogout: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FUNGSI KHUSUS: MEMBUAT MENU DROPDOWN SUB-MENU
  // ==========================================
  Widget _buildDropdownDonasi(bool isCollapsed) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    // Cek apakah salah satu sub-menu donasi sedang aktif saat ini
    bool isSubMenuKeyActive = currentRoute.startsWith('/admin-donasi-');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isCollapsed) {
                // Kalau menu mengecil, langsung lempar ke sub-menu utama
                context.go('/admin-donasi-masuk');
              } else {
                setState(() {
                  _isDonasiExpanded = !_isDonasiExpanded;
                });
              }
            },
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isSubMenuKeyActive && !_isDonasiExpanded
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.volunteer_activism_rounded,
                    color: isSubMenuKeyActive
                        ? AppColors.primary
                        : Colors.white54,
                    size: 24,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Manajemen Donasi",
                        style: TextStyle(
                          color: isSubMenuKeyActive
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: isSubMenuKeyActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      _isDonasiExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Rincian sub-menu anak, hanya muncul jika dropdown dibuka dan sidebar sedang lebar
        if (_isDonasiExpanded && !isCollapsed) ...[
          _buildSubMenuListItem("Riwayat Dana Masuk", "/admin-donasi-masuk"),
          _buildSubMenuListItem("Riwayat Dana Keluar", "/admin-donasi-keluar"),
          _buildSubMenuListItem("Penyaluran Dana", "/admin-donasi-salurkan"),
        ],
      ],
    );
  }

  // Widget Pembuat Item Anak Sub-Menu
  Widget _buildSubMenuListItem(String title, String routePath) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final bool isActive = currentRoute == routePath;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(routePath),
        child: Container(
          width: 260,
          padding: const EdgeInsets.only(
            left: 59,
            right: 20,
            top: 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // Widget Pembuat Menu Utama (Sidebar Standar)
  Widget _sidebarMenu(
    IconData icon,
    String title,
    String routePath,
    bool isCollapsed, {
    bool isLogout = false,
    bool isWebLink = false,
  }) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final bool isActive = currentRoute == routePath && !isLogout && !isWebLink;

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
              context.go('/');
            } else {
              context.go(routePath);
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
