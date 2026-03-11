import 'package:flutter/material.dart';
import '../../data/models/program_model.dart';
import '../../core/app_colors.dart';

class ProgramDetailScreen extends StatelessWidget {
  final ProgramModel program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                program.judul,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Hero(
                tag: program.judul,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(program.imageUrl, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tentang Program",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    program.deskripsi,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildPremiumCard(
                    title: "Cakupan Beasiswa",
                    items: program.benefit,
                    icon: Icons.auto_awesome,
                    accentColor: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  _buildPremiumCard(
                    title: "Persyaratan",
                    items: program.syarat,
                    icon: Icons.assignment_turned_in_outlined,
                    accentColor: AppColors.primary,
                  ),

                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accentColor.withOpacity(0.1),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(),
          ),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
