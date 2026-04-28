import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  Widget _buildMobileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'home') context.go('/');
        if (value == 'about') context.go('/tentang');
        if (value == 'program') context.go('/program');
        if (value == 'beasiswa') context.go('/beasiswa');
        if (value == 'faq') context.go('/faq');
        if (value == 'contact') context.go('/kontak');
        if (value == 'login') context.go('/login');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'home', child: Text('Beranda')),
        const PopupMenuItem<String>(value: 'about', child: Text('Tentang')),
        const PopupMenuItem<String>(value: 'program', child: Text('Program')),
        const PopupMenuItem<String>(value: 'beasiswa', child: Text('Beasiswa')),
        const PopupMenuItem<String>(value: 'faq', child: Text('FAQ')),
        const PopupMenuItem<String>(value: 'contact', child: Text('Kontak')),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'login',
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

  Widget _buildDesktopMenu(BuildContext context) {
    return Row(
      children: [
        _navbarItem("Beranda", () => context.go('/')),
        const SizedBox(width: 30),
        _navbarItem("Tentang", () => context.go('/tentang')),
        const SizedBox(width: 30),
        _navbarItem("Program", () => context.go('/program')),
        const SizedBox(width: 30),
        _navbarItem("Beasiswa", () => context.go('/beasiswa')),
        const SizedBox(width: 30),
        _navbarItem("FAQ", () => context.go('/faq')),
        const SizedBox(width: 30),
        _navbarItem("Kontak", () => context.go('/kontak')),
        const SizedBox(width: 40),

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
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

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
            _buildMobileMenu(context)
          else
            _buildDesktopMenu(context),
        ],
      ),
    );
  }
}