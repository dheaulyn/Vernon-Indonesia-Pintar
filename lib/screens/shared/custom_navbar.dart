import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Tambahkan mesin rute
import '../../core/app_colors.dart';
// import '../auth/login_screen.dart'; <--- INI SUDAH DIHAPUS

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onProgramTap;
  final VoidCallback? onContactTap;
  final VoidCallback? onFAQTap; 

  const CustomNavbar({
    super.key,
    this.onHomeTap,
    this.onAboutTap,
    this.onProgramTap,
    this.onContactTap,
    this.onFAQTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 40,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, size: 40, color: Colors.black),
              ),
            ],
          ),
          if (isMobile)
            _buildMobileMenu(context)
          else
            _buildDesktopMenu(context),
        ],
      ),
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'home') onHomeTap?.call();
        if (value == 'program') onProgramTap?.call();
        if (value == 'about') onAboutTap?.call();
        if (value == 'faq') onFAQTap?.call();
        if (value == 'contact') onContactTap?.call();
        
        // UBAH: Menggunakan GoRouter untuk versi Mobile
        if (value == 'login') {
          context.go('/login'); 
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'home', child: Text('Beranda')),
        const PopupMenuItem<String>(value: 'program', child: Text('Jenis Beasiswa')),
        const PopupMenuItem<String>(value: 'about', child: Text('Tentang Kami')),
        const PopupMenuItem<String>(value: 'faq', child: Text('FAQ')),
        const PopupMenuItem<String>(value: 'contact', child: Text('Kontak')),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'login',
          child: Text(
            'Portal Siswa',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopMenu(BuildContext context) {
    return Row(
      children: [
        _navbarItem("Beranda", onHomeTap),
        const SizedBox(width: 30),
        _navbarItem("Jenis Beasiswa", onProgramTap),
        const SizedBox(width: 30),
        _navbarItem("Tentang Kami", onAboutTap),
        const SizedBox(width: 30),
        _navbarItem("FAQ", onFAQTap),
        const SizedBox(width: 30),
        _navbarItem("Kontak", onContactTap),
        const SizedBox(width: 40),

        ElevatedButton(
          // UBAH: Menggunakan GoRouter untuk versi Desktop
          onPressed: () {
            context.go('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Portal Siswa",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _navbarItem(String title, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap, 
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}