import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import '../../../data/models/program_model.dart';
import '../../../core/app_colors.dart';

class ProgramCard extends StatelessWidget {
  final ProgramModel program;
  final VoidCallback onHomeTap;
  final VoidCallback onProgramTap;
  
  const ProgramCard({
    super.key,
    required this.program,
    required this.onHomeTap,
    required this.onProgramTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: double.infinity, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Hero(
              tag: program.judul,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  program.imageUrl,
                  height: isMobile ? 180 : 220, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: isMobile ? 180 : 220,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 20.0 : 25.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.judul,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 18 : 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    program.deskripsi,
                    style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 14 : 15, height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 25 : 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // PERBAIKAN: Menggunakan judul sebagai URL pengganti ID
                        String urlAman = program.judul.toLowerCase().replaceAll(' ', '-');
                        context.go('/program/$urlAman', extra: program);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 15 : 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                      ),
                      child: Text(
                        "LIHAT DETAIL",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}