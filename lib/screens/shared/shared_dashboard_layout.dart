import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../data/mock_database.dart';
import '../../services/supabase_auth_service.dart';

class MenuModel {
  final IconData? icon;
  final String? title;
  final String? routePath;
  final bool isLogout;
  final bool isWebLink;
  final List<MenuModel>? subMenus;
  final Function()? onTap;

  final bool isHeader;
  final bool isDivider;

  MenuModel({
    this.icon,
    this.title,
    this.routePath,
    this.isLogout = false,
    this.isWebLink = false,
    this.subMenus,
    this.onTap,
    this.isHeader = false,
    this.isDivider = false,
  });
}

class SharedDashboardLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String roleText;
  final List<MenuModel> menuItems;
  final List<MenuModel>? bottomMenuItems;
  final String? activeRoute;

  const SharedDashboardLayout({
    super.key,
    required this.child,
    required this.title,
    required this.roleText,
    required this.menuItems,
    this.bottomMenuItems,
    this.activeRoute,
  });

  @override
  State<SharedDashboardLayout> createState() => _SharedDashboardLayoutState();
}

class _SharedDashboardLayoutState extends State<SharedDashboardLayout> {
  bool _isCollapsed = false;
  bool _isNotifOpen = false;
  bool _isNotifCleared = false;

  // Track expanded state for submenus by title
  final Map<String, bool> _expandedMenus = {};

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _hasUnreadNotif() {
    if (_isNotifCleared) return false;
    final user = MockDatabase.currentUser ?? {};
    final isRevisi = user['is_revisi'] == true;
    final status = user['admin_status'] ?? 'Menunggu Review';
    return isRevisi || (status != 'Menunggu Review' && status.isNotEmpty);
  }

  List<PopupMenuEntry<String>> _buildNotificationItems() {
    final user = MockDatabase.currentUser ?? {};
    final bool isRevisi = user['is_revisi'] == true;
    final String status = user['admin_status'] ?? 'Menunggu Review';
    final String catatan = user['catatan_revisi'] ?? '';

    List<PopupMenuEntry<String>> items = [
      const PopupMenuItem<String>(
        enabled: false,
        child: Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      const PopupMenuDivider(),
    ];

    if (_hasUnreadNotif()) {
      if (isRevisi) {
        items.add(
          PopupMenuItem<String>(
            value: 'go_status',
            child: SizedBox(
              width: 250,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revisi Diperlukan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          catatan,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        IconData statusIcon = Icons.info;
        Color statusColor = Colors.blue;

        if (status == 'Diterima') {
          statusIcon = Icons.check_circle;
          statusColor = Colors.green;
        }
        if (status == 'Ditolak') {
          statusIcon = Icons.cancel;
          statusColor = Colors.red;
        }

        items.add(
          PopupMenuItem<String>(
            value: 'go_status',
            child: SizedBox(
              width: 250,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Diperbarui',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status pendaftaran Anda saat ini: $status',
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      items.add(const PopupMenuDivider());
      items.add(
        PopupMenuItem<String>(
          value: 'clear',
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Tandai sudah dibaca',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      items.add(
        const PopupMenuItem<String>(
          enabled: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                "Belum ada notifikasi baru",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final bool isSidebarCollapsed = isMobile ? false : _isCollapsed;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildTopNavbar(isMobile),
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile, false)) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isMobile) _buildSidebar(isMobile, isSidebarCollapsed),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopNavbar(bool isMobile) {
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
              if (isMobile) {
                _scaffoldKey.currentState?.openDrawer();
              } else {
                setState(() {
                  _isCollapsed = !_isCollapsed;
                });
              }
            },
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/logo.png',
            height: 32,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.school, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Notifikasi',
          onOpened: () => setState(() => _isNotifOpen = true),
          onCanceled: () => setState(() => _isNotifOpen = false),
          offset: const Offset(0, 45),
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          icon: Badge(
            isLabelVisible: _hasUnreadNotif(),
            child: Icon(
              _isNotifOpen ? Icons.notifications : Icons.notifications_none,
              color: _isNotifOpen ? Colors.black : Colors.black54,
              size: 24,
            ),
          ),
          itemBuilder: (context) => _buildNotificationItems(),
          onSelected: (value) {
            setState(() => _isNotifOpen = false);
            if (value == 'clear') {
              setState(() => _isNotifCleared = true);
            } else if (value == 'go_status') {
              context.go('/status-beasiswa');
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
                  if (!isMobile)
                    Text(
                      MockDatabase.currentUser?['name'] ?? widget.roleText,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  if (!isMobile) const SizedBox(width: 15),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MockDatabase.currentUser?['name'] ?? widget.roleText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.roleText,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
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
                SupabaseAuthService.logout();
                context.go('/login');
              }
            },
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildSidebar(bool isMobile, bool isCollapsed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 70 : 260,
      color: const Color(0xFF2B3240),
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (!isCollapsed &&
                (widget.menuItems.isEmpty || !widget.menuItems.first.isHeader))
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
            if (isCollapsed) const SizedBox(height: 25),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.menuItems.map((menu) {
                    if (menu.isDivider) {
                      return const Divider(color: Colors.white24);
                    }
                    if (menu.isHeader) {
                      if (isCollapsed) return const SizedBox(height: 15);
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 23,
                          top: 15,
                          bottom: 10,
                        ),
                        child: Text(
                          menu.title ?? '',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      );
                    }
                    if (menu.subMenus != null && menu.subMenus!.isNotEmpty) {
                      return _buildExpandableMenu(menu, isCollapsed, isMobile);
                    }
                    return _sidebarMenu(menu, isCollapsed, isMobile);
                  }).toList(),
                ),
              ),
            ),
            if (widget.bottomMenuItems != null) ...[
              const Divider(color: Colors.white24),
              ...widget.bottomMenuItems!.map((menu) {
                return _sidebarMenu(menu, isCollapsed, isMobile);
              }),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableMenu(MenuModel menu, bool isCollapsed, bool isMobile) {
    final String menuTitle = menu.title ?? '';
    bool isExpanded = _expandedMenus[menuTitle] ?? false;

    // Check if any submenu is active
    bool isSubMenuActive = false;
    if (widget.activeRoute != null) {
      isSubMenuActive = menu.subMenus!.any(
        (sub) => sub.routePath == widget.activeRoute,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isCollapsed && menu.subMenus!.isNotEmpty) {
                final firstRoute = menu.subMenus!.first.routePath;
                if (firstRoute != null) context.go(firstRoute);
              } else {
                setState(() {
                  _expandedMenus[menuTitle] = !isExpanded;
                });
              }
            },
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: (isSubMenuActive && !isExpanded)
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  if (menu.icon != null)
                    Icon(
                      menu.icon,
                      color: isSubMenuActive
                          ? AppColors.primary
                          : Colors.white54,
                      size: 24,
                    ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        menu.title ?? '',
                        style: TextStyle(
                          color: isSubMenuActive
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: isSubMenuActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
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
        if (isExpanded && !isCollapsed) ...[
          ...menu.subMenus!.map((sub) {
            final isActive =
                widget.activeRoute != null &&
                widget.activeRoute == sub.routePath;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (sub.onTap != null) sub.onTap!();
                  if (sub.routePath != null) context.go(sub.routePath!);
                  if (isMobile) _scaffoldKey.currentState?.closeDrawer();
                },
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
                        color: isActive
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    sub.title ?? '',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _sidebarMenu(MenuModel menu, bool isCollapsed, bool isMobile) {
    final isActive =
        widget.activeRoute != null &&
        widget.activeRoute == menu.routePath &&
        !menu.isLogout &&
        !menu.isWebLink;
    final activeColor = menu.isLogout
        ? Colors.redAccent
        : (menu.isWebLink ? Colors.green : AppColors.primary);
    final inactiveColor = Colors.white54;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: isCollapsed ? (menu.title ?? '') : '',
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: () {
            if (menu.isLogout) {
              SupabaseAuthService.logout();
            }
            if (menu.onTap != null) menu.onTap!();

            if (menu.routePath != null) {
              context.go(menu.routePath!);
            }

            if (isMobile) _scaffoldKey.currentState?.closeDrawer();
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
                if (menu.icon != null)
                  Icon(
                    menu.icon,
                    color: isActive
                        ? activeColor
                        : (menu.isWebLink
                              ? Colors.green.withOpacity(0.7)
                              : inactiveColor),
                    size: 24,
                  ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      menu.title ?? '',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : (menu.isWebLink ? Colors.green : Colors.white70),
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
