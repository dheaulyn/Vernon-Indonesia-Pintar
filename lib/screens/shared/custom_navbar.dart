import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../screens/auth/login_screen.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onProgramTap;
  final VoidCallback onHomeTap;
  final VoidCallback onContactTap;

  const CustomNavbar({
    super.key,
    required this.onAboutTap,
    required this.onProgramTap,
    required this.onHomeTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 100,
            width: 150,
            fit: BoxFit.contain,
          ),

          Row(
            children: [
              _HoverNavItem(title: "Beranda", onTap: onHomeTap),
              _HoverNavItem(title: "Jenis Beasiswa", onTap: onProgramTap),
              _HoverNavItem(title: "Tentang Kami", onTap: onAboutTap),
              _HoverNavItem(title: "Kontak", onTap: onContactTap),

              const SizedBox(width: 20),

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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Portal Siswa",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}

class _HoverNavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HoverNavItem({required this.title, required this.onTap});

  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isHovered ? AppColors.primary : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
