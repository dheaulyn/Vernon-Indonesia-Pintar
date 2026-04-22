import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Performa",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 25),
          
          // 👇 LayoutBuilder untuk membuat kartu responsif
          LayoutBuilder(
            builder: (context, constraints) {
              // Jika dibuka di HP (layar sempit), tumpuk kartunya ke bawah
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    _statBox("Total Pendaftar", "1,240", Colors.blue, Icons.people_alt_rounded),
                    const SizedBox(height: 15),
                    _statBox("Menunggu Review", "85", Colors.orange, Icons.hourglass_empty_rounded),
                    const SizedBox(height: 15),
                    _statBox("Beasiswa Aktif", "2", Colors.green, Icons.school_rounded),
                  ],
                );
              }
              
              // Jika dibuka di Laptop (layar lebar), jejerkan kartunya menyamping
              return Row(
                children: [
                  Expanded(child: _statBox("Total Pendaftar", "1,240", Colors.blue, Icons.people_alt_rounded)),
                  const SizedBox(width: 20),
                  Expanded(child: _statBox("Menunggu Review", "85", Colors.orange, Icons.hourglass_empty_rounded)),
                  const SizedBox(width: 20),
                  Expanded(child: _statBox("Beasiswa Aktif", "2", Colors.green, Icons.school_rounded)),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // Area kosong untuk ditambahkan grafik/tabel terbaru nanti
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03), 
                  blurRadius: 10, 
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Center(
              child: Text(
                "Grafik Pendaftar Akan Tampil Di Sini",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }

  // WIDGET KARTU STATISTIK
  Widget _statBox(String title, String value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Ikon Berwarna
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          // Teks Statistik
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                value, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}