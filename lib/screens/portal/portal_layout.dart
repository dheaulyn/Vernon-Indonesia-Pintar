import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
        icon: Icons.help_outline,
        title: 'Bantuan',
        isWebLink: true,
        onTap: () async {
          try {
            final supabase = Supabase.instance.client;
            final response = await supabase.from('cms_footer').select('whatsapp').limit(1).maybeSingle();
            
            String waLink = (response != null && response['whatsapp'] != null) 
                ? response['whatsapp'].toString()
                : "https://wa.me/";

            final uri = Uri.parse(waLink);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            debugPrint("Error launching WhatsApp: \$e");
          }
        },
      ),
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
