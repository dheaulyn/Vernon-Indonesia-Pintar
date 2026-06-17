import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/shared_dashboard_layout.dart';

// Catatan: Anda TIDAK perlu lagi mengimpor halaman-halaman (HomeDashboard, dll) di file ini,
// karena halaman-halaman tersebut akan dipanggil di file konfigurasi router Anda.

import '../../services/supabase_auth_service.dart';

class LayoutDashboard extends StatelessWidget {
  final Widget child;

  const LayoutDashboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final role = SupabaseAuthService.currentUserData?['role'];
    final isSuperAdmin = role == 'super_admin';

    final menuItems = <MenuModel>[];

    if (isSuperAdmin) {
      menuItems.addAll([
        MenuModel(title: "MENU ADMIN", isHeader: true),
        MenuModel(
          icon: Icons.grid_view_rounded,
          title: "Home Dashboard",
          routePath: "/admin-dashboard",
        ),
        MenuModel(
          icon: Icons.admin_panel_settings_rounded,
          title: "Manajemen Admin",
          routePath: "/admin-manajemen-admin",
        ),
        MenuModel(
          icon: Icons.people_alt_rounded,
          title: "Data Pendaftar",
          routePath: "/admin-pendaftar",
        ),
        MenuModel(
          icon: Icons.volunteer_activism_rounded,
          title: "Manajemen Donasi",
          subMenus: [
            MenuModel(
              icon: Icons.chevron_right,
              title: "Riwayat Dana Masuk",
              routePath: "/admin-donasi-masuk",
            ),
            MenuModel(
              icon: Icons.chevron_right,
              title: "Riwayat Dana Keluar",
              routePath: "/admin-donasi-keluar",
            ),
            MenuModel(
              icon: Icons.chevron_right,
              title: "Penyaluran Dana",
              routePath: "/admin-donasi-salurkan",
            ),
          ],
        ),
        MenuModel(isDivider: true),
      ]);
    }

    menuItems.addAll([
      MenuModel(title: "KONTEN WEBSITE (CMS)", isHeader: true),
      MenuModel(
        icon: Icons.image_rounded,
        title: "Kelola Hero Banner",
        routePath: "/cms-hero-banner",
      ),
      MenuModel(
        icon: Icons.info_outline_rounded,
        title: "Kelola Tentang Kami",
        routePath: "/cms-about",
      ),
      MenuModel(
        icon: Icons.account_balance_rounded,
        title: "Kelola Profil Yayasan",
        routePath: "/cms-profil",
      ),
      MenuModel(
        icon: Icons.format_list_numbered_rtl_rounded,
        title: "Kelola Detail Program",
        routePath: "/cms-program",
      ),
      MenuModel(
        icon: Icons.article_rounded,
        title: "Kelola Media",
        routePath: "/cms-media",
      ),
      MenuModel(
        icon: Icons.handshake_rounded,
        title: "Kelola Partner",
        routePath: "/cms-partners",
      ),
      MenuModel(
        icon: Icons.format_quote_rounded,
        title: "Kelola Testimoni",
        routePath: "/cms-testimoni",
      ),
      MenuModel(
        icon: Icons.help_center_rounded,
        title: "Kelola FAQ",
        routePath: "/cms-faq",
      ),
      MenuModel(
        icon: Icons.contact_mail_rounded,
        title: "Kelola Footer",
        routePath: "/cms-footer",
      ),
    ]);

    final bottomMenuItems = [
      MenuModel(
        icon: Icons.person,
        title: "Profil Saya",
        routePath: "/admin-profil",
      ),
      MenuModel(
        icon: Icons.public,
        title: "Lihat Web Publik",
        routePath: "/",
        isWebLink: true,
      ),
      MenuModel(
        icon: Icons.power_settings_new_rounded,
        title: "Keluar",
        routePath: "/login-admin",
        isLogout: true,
      ),
    ];

    return SharedDashboardLayout(
      title: 'ADMINISTRATOR VIP',
      roleText: isSuperAdmin ? 'SUPER ADMIN VIP' : 'ADMIN KONTEN VIP',
      menuItems: menuItems,
      bottomMenuItems: bottomMenuItems,
      activeRoute: currentRoute,
      child: child,
    );
  }
}
