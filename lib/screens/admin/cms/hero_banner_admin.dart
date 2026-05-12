import 'package:flutter/material.dart';
import '../../../../../core/app_colors.dart';
import '../../../../../data/hero_banner_data.dart';

class HeroBannerAdmin extends StatefulWidget {
  const HeroBannerAdmin({super.key});

  @override
  State<HeroBannerAdmin> createState() => _HeroBannerAdminState();
}

class _HeroBannerAdminState extends State<HeroBannerAdmin> {
  final TextEditingController _sub1Controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sub2Controller = TextEditingController();
  bool _isOpen = true; 

  @override
  void initState() {
    super.initState();
    _sub1Controller.text = globalHeroBannerStore.heroSubtitle1;
    _titleController.text = globalHeroBannerStore.heroTitle;
    _sub2Controller.text = globalHeroBannerStore.heroSubtitle2Base; // Ambil teks dasar
    _isOpen = globalHeroBannerStore.isRegistrationOpen; 
  }

  void _simpanPerubahan() {
    globalHeroBannerStore.updateHeroBanner(
      _sub1Controller.text,
      _titleController.text,
      _sub2Controller.text, // Kirim teks dasar
      _isOpen, 
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hero Banner berhasil diperbarui!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kelola Hero Banner", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATUS SAKELAR
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isOpen ? Colors.green : Colors.red),
                    ),
                    child: SwitchListTile(
                      title: Text("Status Pendaftaran", style: TextStyle(fontWeight: FontWeight.bold, color: _isOpen ? Colors.green[800] : Colors.red[800])),
                      subtitle: Text(_isOpen ? "Status: DIBUKA" : "Status: DITUTUP"),
                      value: _isOpen,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        setState(() => _isOpen = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildInputLabel("Teks Kecil Atas (Subtitle 1)"),
                  TextField(controller: _sub1Controller, decoration: const InputDecoration(border: OutlineInputBorder())),
                  const SizedBox(height: 20),

                  _buildInputLabel("Judul Utama"),
                  TextField(controller: _titleController, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder())),
                  const SizedBox(height: 20),

                  _buildInputLabel("Teks Dasar Bawah (Contoh: Pendaftaran Beasiswa 2026)"),
                  TextField(
                    controller: _sub2Controller, 
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Masukkan teks tanpa kata 'Dibuka/Ditutup'",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sistem akan otomatis menambahkan kata '${_isOpen ? 'Telah Dibuka' : 'Telah Ditutup'}' di akhir teks ini.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _simpanPerubahan,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
  }
}