import 'package:flutter/material.dart';
import '../shared/shared_dashboard_layout.dart';

class PortalLayout extends StatelessWidget {
  final Widget content;
  final String activeMenu;

  const PortalLayout({
    super.key,
    required this.content,
    required this.activeMenu,
  });

  @override
  Widget build(BuildContext context) {
    // Map activeMenu to routePath for SharedDashboardLayout
    String? activeRoute;
    if (activeMenu == 'dashboard') activeRoute = '/portal';
    if (activeMenu == 'form_beasiswa') activeRoute = '/form-beasiswa';
    if (activeMenu == 'status_beasiswa') activeRoute = '/status-beasiswa';

    final menuItems = [
      MenuModel(icon: Icons.home, title: 'Beranda', routePath: '/portal'),
      MenuModel(
        icon: Icons.edit_document,
        title: 'Form Beasiswa',
        routePath: '/form-beasiswa',
      ),
      MenuModel(
        icon: Icons.fact_check_outlined,
        title: 'Status Beasiswa',
        routePath: '/status-beasiswa',
      ),
    ];

    final bottomMenuItems = [
      MenuModel(
        icon: Icons.logout,
        title: 'Keluar',
        routePath: '/login',
        isLogout: true,
      ),
    ];

    return SharedDashboardLayout(
      title: 'PORTAL SISWA',
      roleText: 'SISWA VIP',
      menuItems: menuItems,
      bottomMenuItems: bottomMenuItems,
      activeRoute: activeRoute,
      child: content,
    );
  }
}
