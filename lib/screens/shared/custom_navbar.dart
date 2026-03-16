import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../auth/login_screen.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onProgramTap;
  final VoidCallback? onContactTap;
  final VoidCallback? onFAQTap; // Tambahan fungsi untuk klik FAQ

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LOGO KIRI
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

          // MENU TENGAH DAN TOMBOL KANAN
          Row(
            children: [
              _navbarItem("Beranda", onHomeTap),
              const SizedBox(width: 30),
              _navbarItem("Jenis Beasiswa", onProgramTap),
              const SizedBox(width: 30),
              _navbarItem("Tentang Kami", onAboutTap),
              const SizedBox(width: 30),

              // TAMPILKAN MENU FAQ
              _navbarItem("FAQ", onFAQTap),

              const SizedBox(width: 30),
              _navbarItem("Kontak", onContactTap),
              const SizedBox(width: 40),

              // TOMBOL PORTAL SISWA
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
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
          ),
        ],
      ),
    );
  }

  Widget _navbarItem(String title, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap, // Menjalankan fungsi yang dikirim dari home_screen
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
