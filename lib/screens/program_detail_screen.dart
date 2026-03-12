import 'package:flutter/material.dart';
import '../../data/models/program_model.dart';
import '../../core/app_colors.dart';
import '../screens/auth/login_screen.dart';

class ProgramDetailScreen extends StatelessWidget {
  final ProgramModel program;
  final VoidCallback onHomeTap;
  final VoidCallback onProgramTap;

  const ProgramDetailScreen({
    super.key,
    required this.program,
    required this.onHomeTap,
    required this.onProgramTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 450,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(program.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 130),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        program.judul.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                onHomeTap,
                              );
                            },
                            child: const Text(
                              "Home",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "  /  ",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 15,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                onProgramTap,
                              );
                            },
                            child: const Text(
                              "Jenis Beasiswa",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            "  /  ${program.judul}",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 60,
                    left: 60,
                    right: 60,
                    bottom: 80,
                  ),
                  padding: const EdgeInsets.all(60),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.deskripsi,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 60),

                      _buildModernSection(
                        "Benefit Beasiswa",
                        program.benefit,
                        Icons.stars_rounded,
                        Colors.orange,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Divider(color: Colors.black12, thickness: 1),
                      ),
                      _buildModernSection(
                        "Persyaratan Pendaftaran",
                        program.syarat,
                        Icons.check_circle,
                        Colors.green,
                      ),

                      const SizedBox(height: 60),
                      Center(
                        child: SizedBox(
                          height: 55,
                          width: 300,
                          child: ElevatedButton(
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                              shadowColor: AppColors.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            child: const Text(
                              "DAFTAR SEKARANG",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(
    String title,
    List<String> items,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: 24),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
