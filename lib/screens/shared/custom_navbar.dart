import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  // ==========================================
  // MENU HP (MOBILE)
  // ==========================================
  Widget _buildMobileMenu(BuildContext context, String currentPath) {
    final bool isDonasiActive = currentPath == '/donasi';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        context.go(value);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _mobileMenuItem('Beranda', '/', currentPath),
        _mobileMenuItem('Tentang', '/tentang', currentPath),
        _mobileMenuItem('Program', '/program', currentPath),
        _mobileMenuItem('Beasiswa', '/beasiswa', currentPath),
        _mobileMenuItem('Fund Pool', '/fund-pool', currentPath),
        _mobileMenuItem('FAQ', '/faq', currentPath),
        _mobileMenuItem('Kontak', '/kontak', currentPath),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: '/donasi',
          child: Text(
            'Donasi',
            style: TextStyle(
              // 👇 Merah menyala kalau aktif, agak pudar kalau tidak
              color: isDonasiActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: '/login',
          child: Text(
            'Login',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _mobileMenuItem(
    String title,
    String path,
    String currentPath,
  ) {
    final bool isActive = currentPath == path;
    return PopupMenuItem<String>(
      value: path,
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.primary : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // ==========================================
  // MENU DESKTOP / LAPTOP
  // ==========================================
  Widget _buildDesktopMenu(BuildContext context, String currentPath) {
    final bool isDonasiActive = currentPath == '/donasi';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _navbarItem(context, "Beranda", '/', currentPath),
        const SizedBox(width: 30),
        _navbarItem(context, "Tentang", '/tentang', currentPath),
        const SizedBox(width: 30),
        _navbarItem(context, "Program", '/program', currentPath),
        const SizedBox(width: 30),
        _navbarItem(context, "Beasiswa", '/beasiswa', currentPath),
        const SizedBox(width: 30),
        _navbarItem(context, "Fund Pool", '/fund-pool', currentPath),
        const SizedBox(width: 30),
        _navbarItem(context, "FAQ", '/faq', currentPath),
        const SizedBox(width: 30),
        _navbarItem(context, "Kontak", '/kontak', currentPath),
        const SizedBox(width: 40),

        // ==========================================
        // TOMBOL DONASI (OUTLINE DINAMIS)
        // ==========================================
        OutlinedButton(
          onPressed: () => context.go('/donasi'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              // 👇 Garis merah terang jika aktif, merah transparan jika tidak
              color: isDonasiActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.4),
              width: isDonasiActive
                  ? 2.0
                  : 1.2, // Sedikit lebih tebal kalau lagi aktif
            ),
            // 👇 Kasih efek background merah super tipis kalau lagi aktif
            backgroundColor: isDonasiActive
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Donasi",
            style: TextStyle(
              // 👇 Teks merah terang jika aktif, merah pudar jika tidak
              color: isDonasiActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 15),

        // TOMBOL LOGIN (FILLED) - Biarkan merah solid agar jadi Fokus Utama
        ElevatedButton(
          onPressed: () => context.go('/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Login",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _navbarItem(
    BuildContext context,
    String title,
    String path,
    String currentPath,
  ) {
    final bool isActive = currentPath == path;

    return InkWell(
      onTap: () => context.go(path),
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.black87,
              fontSize: 15,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 30 : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final String currentPath = GoRouterState.of(context).uri.path;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 50,
        vertical: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                mouseCursor: SystemMouseCursors.click,
                child: Image.asset(
                  'assets/logo.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.school, size: 40, color: Colors.black),
                ),
              ),
            ],
          ),
          if (isMobile)
            _buildMobileMenu(context, currentPath)
          else
            _buildDesktopMenu(context, currentPath),
        ],
      ),
    );
  }
}
