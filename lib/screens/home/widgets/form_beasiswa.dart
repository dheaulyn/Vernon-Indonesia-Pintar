import 'package:flutter/material.dart';
import '../../shared/custom_navbar.dart';
import '/core/app_colors.dart';

class FormBeasiswaScreen extends StatefulWidget {
  const FormBeasiswaScreen({super.key});

  @override
  State<FormBeasiswaScreen> createState() => _FormBeasiswaScreenState();
}

class _FormBeasiswaScreenState extends State<FormBeasiswaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPendidikan;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      // 👇 1. GANTI LATAR BELAKANG SCROLLABLE MENJADI PUTIH BERSIH
      backgroundColor: Colors.white,
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. HEADER BANNER
            _buildHeader(isMobile),
            
            // 3. KONTEN FORMULIR
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 50,
                // Di Desktop form akan berada di tengah dan tidak terlalu lebar
                horizontal: isMobile ? 20 : screenWidth * 0.2, 
              ),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 20 : 40),
                decoration: BoxDecoration(
                  // 👇 2. KOTAK FORMULIR TETAP PUTIH BERSIH
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // 👇 3. BAYANGAN LEMBUT ALA PROFIL (SEDIKIT LEBIH PROPORSIONAL)
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                  // 👇 4. OPTIONAL: TAMBAHKAN BORDER ABU-ABU TIPIS SEPERTI FAQ PROFIL
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1: DATA PRIBADI
                      _buildSectionTitle("1", "Data Pribadi"),
                      const SizedBox(height: 20),
                      _buildTextField("Nama Lengkap", "Masukkan nama lengkap Anda"),
                      _buildTextField("Email Aktif", "contoh@email.com", isEmail: true),
                      _buildTextField("Nomor WhatsApp", "08xxxxxxxxxx", isPhone: true),
                      _buildTextField("Kota Domisili", "Masukkan kota tempat tinggal saat ini"),
                      _buildDropdownPendidikan(),

                      const SizedBox(height: 40),
                      const Divider(color: Colors.black12,), // Divider lebih tipis
                      const SizedBox(height: 40),

                      // SECTION 2: KONDISI & MOTIVASI
                      _buildSectionTitle("2", "Kondisi & Motivasi"),
                      const SizedBox(height: 20),
                      _buildTextField("Ceritakan singkat kondisi ekonomi keluarga Anda", "Jelaskan secara singkat...", maxLines: 4),
                      _buildTextField("Mengapa Anda layak mendapatkan beasiswa ini?", "Jelaskan motivasi dan alasan Anda...", maxLines: 4),

                      const SizedBox(height: 40),

                      // TAHAPAN SELEKSI BOX
                      _buildTahapanSeleksi(isMobile),

                      const SizedBox(height: 40),

                      // TOMBOL SUBMIT
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Aksi ketika form valid
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Formulir berhasil dikirim!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "KIRIM PENDAFTARAN SEKARANG",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. FOOTER LENGKAP
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: HEADER BANNER (Gaya Premium FAQ/Profil)
  // ==========================================
  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 50 : 80, horizontal: 20),
      decoration: BoxDecoration(
        // 👇 5. GANTI HEADER MENJADI LIGHT GRADIENT PRIMER SEPERTI FAQ PUSAT BANTUAN
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Text(
            "Pendaftaran Beasiswa",
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 15),
          Text(
            "Mulai Langkahmu Bersama VIP",
            textAlign: TextAlign.center,
            // 👇 6. WARNA TEKS JADI HITAM KARENA BACKGROUND TERANG
            style: TextStyle(fontSize: isMobile ? 28 : 40, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Text(
            "Lengkapi data di bawah ini dengan jujur dan teliti.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: SECTION TITLE (Angka & Judul)
  // ==========================================
  Widget _buildSectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          width: 35, height: 35,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(number, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ==========================================
  // WIDGET: INPUT FIELD (Teks)
  // ==========================================
  Widget _buildTextField(String label, String hint, {int maxLines = 1, bool isEmail = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Field ini tidak boleh kosong';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: DROPDOWN PENDIDIKAN
  // ==========================================
  Widget _buildDropdownPendidikan() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pendidikan Terakhir", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPendidikan,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              filled: true, fillColor: Colors.grey.shade50,
            ),
            hint: const Text("Pilih Pendidikan..."),
            items: const [
              DropdownMenuItem(value: "SD", child: Text("SD / Sederajat")),
              DropdownMenuItem(value: "SMP", child: Text("SMP / Sederajat")),
              DropdownMenuItem(value: "SMA", child: Text("SMA / SMK / Sederajat")),
            ],
            onChanged: (value) => setState(() => _selectedPendidikan = value),
            validator: (value) => value == null ? 'Pilih pendidikan terakhir Anda' : null,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: INFO TAHAPAN SELEKSI
  // ==========================================
  Widget _buildTahapanSeleksi(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tahapan Seleksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
          const SizedBox(height: 15),
          isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tahapanItem("1", "Pendaftaran Online"),
                  const SizedBox(height: 10),
                  _tahapanItem("2", "Wawancara & Tes"),
                  const SizedBox(height: 10),
                  _tahapanItem("3", "Pengumuman"),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _tahapanItem("1", "Pendaftaran Online"),
                  const Icon(Icons.arrow_right_alt, color: Colors.blue),
                  _tahapanItem("2", "Wawancara & Tes"),
                  const Icon(Icons.arrow_right_alt, color: Colors.blue),
                  _tahapanItem("3", "Pengumuman"),
                ],
              )
        ],
      ),
    );
  }

  Widget _tahapanItem(String step, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 12, backgroundColor: Colors.blue, child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  // ==========================================
  // WIDGET: FOOTER LENGKAP (SERAGAM)
  // ==========================================
  Widget _buildFooter(bool isMobile) {
    Widget aboutFooter = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text("VERNON INDONESIA PINTAR", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Text("Membangun generasi emas Indonesia melalui akses pendidikan yang merata dan berkualitas.", textAlign: isMobile ? TextAlign.center : TextAlign.left, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
      ],
    );

    Widget contactFooter = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text("HUBUNGI KAMI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _footerLink("WhatsApp: +62 812-3456-7890", isMobile),
        _footerLink("Email: info@vip.or.id", isMobile),
        _footerLink("Alamat: Jl. Letjen Sutoyo No.102A, Bunulrejo, Kec. Blimbing, Kota Malang, Jawa Timur, Indonesia", isMobile),
      ],
    );

    return Container(
      width: double.infinity, color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: isMobile ? 30 : 50),
      child: Column(
        children: [
          if (isMobile) Column(children: [aboutFooter, const SizedBox(height: 40), contactFooter])
          else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: aboutFooter), const SizedBox(width: 50), Expanded(child: contactFooter)]),
          SizedBox(height: isMobile ? 30 : 50),
          Text("© 2026 Vernon Indonesia Pintar. All Rights Reserved.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _footerLink(String title, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(onTap: () {}, child: Text(title, textAlign: isMobile ? TextAlign.center : TextAlign.left, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15))),
    );
  }
}