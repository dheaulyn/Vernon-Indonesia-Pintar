import 'package:flutter/material.dart';
// import '../../../core/app_colors.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'status_beasiswa_screen.dart';
import '../../data/mock_database.dart'; 

class PortalLayout extends StatefulWidget {
  final Widget content;
  final String activeMenu;

  const PortalLayout({
    super.key,
    required this.content,
    required this.activeMenu,
  });

  @override
  State<PortalLayout> createState() => _PortalLayoutState();
}

class _PortalLayoutState extends State<PortalLayout> {
  bool _isCollapsed = false;
  bool _isNotifOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6F9,
      ), 
      appBar: _buildTopNavbar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(context),
          Expanded(child: widget.content),
        ],
      ),
    );
  }

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
            'PORTAL SISWA',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Notifikasi',
          onOpened: () {
            setState(() => _isNotifOpen = true);
          },
          onCanceled: () {
            setState(() => _isNotifOpen = false);
          },
          offset: const Offset(0, 45),
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          icon: Icon(
            _isNotifOpen ? Icons.notifications : Icons.notifications_none,
            color: _isNotifOpen ? Colors.black : Colors.black54,
            size: 24,
          ),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              enabled: false,
              child: Text(
                'Notifikasi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'clear',
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Hapus seluruh notifikasi',
                  style: TextStyle(color: Colors.blue.shade600, fontSize: 13),
                ),
              ),
            ),
          ],
          onSelected: (value) {
            setState(() => _isNotifOpen = false);
            if (value == 'clear') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi berhasil dihapus'),
                ),
              );
            }
          },
        ),
        const SizedBox(width: 15),

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
                    MockDatabase.currentUser?['name'] ?? 'SISWA VIP',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 70 : 260,
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

                if (!_isCollapsed)
                  const Padding(
                    padding: EdgeInsets.only(left: 23, bottom: 10),
                    child: Text(
                      'MENU',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                if (_isCollapsed) const SizedBox(height: 25),

                _sidebarMenu(
                  context,
                  Icons.home,
                  'Beranda',
                  targetMenu: 'dashboard',
                  targetScreen: const DashboardScreen(),
                ),
                _sidebarMenu(
                  context,
                  Icons.assignment,
                  'Status Beasiswa',
                  targetMenu: 'status',
                  targetScreen: const StatusBeasiswaScreen(),
                ),
                

                const Spacer(),
                const Divider(color: Colors.white24),

                _sidebarMenu(
                  context,
                  Icons.logout,
                  'Keluar',
                  targetMenu: 'logout',
                  targetScreen: const LoginScreen(),
                  isLogout:
                      true, 
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
    BuildContext context,
    IconData icon,
    String title, {
    required String targetMenu,
    required Widget targetScreen,
    bool isLogout = false,
  }) {
    final isActive = widget.activeMenu == targetMenu;
    final activeColor = isLogout ? Colors.redAccent : Colors.red.shade600;
    final inactiveColor = Colors.white54;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: _isCollapsed ? title : '',
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: () {
            
            if (isLogout) {
              MockDatabase.logout();
            }

            if (!isActive) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, anim1, anim2) => targetScreen,
                  transitionDuration: Duration.zero,
                ),
              );
            }
          },
          child: Container(
            width: 260,
            padding: const EdgeInsets.only(
              left: 19,
              right: 20,
              top: 14,
              bottom: 14,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.15)
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
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),

                if (!_isCollapsed) ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
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
