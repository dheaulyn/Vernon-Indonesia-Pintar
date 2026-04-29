import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
// import 'package:go_router/go_router.dart';
import '../shared/custom_navbar.dart';
import '../shared/custom_footer.dart';
// import '../../core/app_colors.dart';

class DonasiScreen extends StatefulWidget {
  const DonasiScreen({super.key});

  @override
  State<DonasiScreen> createState() => _DonasiScreenState();
}

class _DonasiScreenState extends State<DonasiScreen> {
  final _formKey = GlobalKey<FormState>(); 
  
  int? _selectedNominal = 100000; 
  bool _isAnonymous = false;
  final TextEditingController _customNominalController = TextEditingController();

  @override
  void dispose() {
    _customNominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            
            Center(
              child: Container(
                width: isMobile ? screenWidth * 0.9 : 1000,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias, 
                child: isMobile 
                    ? Column(
                        children: [
                          _buildDarkSection(isMobile),
                          _buildFormSection(isMobile),
                        ],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 4, child: _buildDarkSection(isMobile)),
                            Expanded(flex: 6, child: _buildFormSection(isMobile)),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 100),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: SEKSI KIRI (GELAP)
  // ==========================================
  Widget _buildDarkSection(bool isMobile) {
    return Container(
      color: const Color(0xFF333333),
      padding: EdgeInsets.all(isMobile ? 30 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "DONATUR VIP",
            style: TextStyle(color: Color(0xFFE31E24), fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 20),
          Text(
            "Investasi Nyata Masa Depan Bangsa",
            style: TextStyle(
              color: Colors.white, 
              fontSize: isMobile ? 32 : 40, 
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Setiap rupiah yang Anda berikan adalah kepingan harapan bagi seorang siswa untuk meraih kemandirian ekonomi.",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 40),
          
          // 👇 PEMBARUAN: Memasukkan Icon ke dalam fungsi
          _buildFeatureBullet(
            "Aman & Terpercaya", 
            "Sistem pembayaran terenkripsi", 
            Icons.lock_outline_rounded, // Ikon gembok/keamanan
          ),
          const SizedBox(height: 25),
          _buildFeatureBullet(
            "Laporan Transparan", 
            "Pantau penggunaan dana di dashboard", 
            Icons.analytics_outlined, // Ikon grafik/transparansi
          ),
        ],
      ),
    );
  }

  // 👇 PEMBARUAN: Menambahkan parameter iconData
  Widget _buildFeatureBullet(String title, String subtitle, IconData iconData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE31E24),
            shape: BoxShape.circle,
          ),
          // 👇 Memunculkan ikon putih di tengah lingkaran merah
          child: Icon(iconData, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 5),
              Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
            ],
          ),
        )
      ],
    );
  }

  // ==========================================
  // WIDGET: SEKSI KANAN (FORMULIR PUTIH)
  // ==========================================
  Widget _buildFormSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 30 : 50),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Donasi Sekarang",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Lengkapi formulir di bawah untuk berdonasi.",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            
            const SizedBox(height: 30),
            
            const Text("Pilih Nominal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRadioNominal(100000, "Rp 100.000", isMobile),
                _buildRadioNominal(250000, "Rp 250.000", isMobile),
                _buildRadioNominal(500000, "Rp 500.000", isMobile),
              ],
            ),
            const SizedBox(height: 15),
            
            TextFormField(
              controller: _customNominalController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyFormat(), 
              ],
              onTap: () {
                if (_selectedNominal != null) setState(() => _selectedNominal = null);
              },
              onChanged: (value) {
                if (_selectedNominal != null) setState(() => _selectedNominal = null);
              },
              validator: (value) {
                if (_selectedNominal == null) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  String rawNumeric = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (rawNumeric.isEmpty || int.parse(rawNumeric) < 10000) {
                    return 'Minimal donasi Rp 10.000';
                  }
                }
                return null;
              },
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              decoration: _inputStyle("Nominal Lainnya (Min 10.000)", prefixText: "Rp "),
            ),

            const SizedBox(height: 30),

            const Text("Data Diri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 15),
            
            TextFormField(
              decoration: _inputStyle("Nama Lengkap"),
              validator: (value) => value == null || value.trim().isEmpty ? 'Nama Lengkap wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            
            isMobile 
              ? Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputStyle("Email (untuk invoice)"),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: _inputStyle("No. WhatsApp"),
                      validator: _validatePhone,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputStyle("Email (untuk invoice)"),
                        validator: _validateEmail,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: _inputStyle("No. WhatsApp"),
                        validator: _validatePhone,
                      ),
                    ),
                  ],
                ),
                
            const SizedBox(height: 15),

            Row(
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: Checkbox(
                    value: _isAnonymous,
                    activeColor: const Color(0xFFE31E24),
                    onChanged: (bool? value) {
                      setState(() => _isAnonymous = value ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Sembunyikan nama saya dari publik (Anonim)",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Simulasi Pembayaran"),
                        content: const Text("Formulir valid! Fitur pembayaran akan segera diintegrasikan dengan Payment Gateway."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(child: Text('Mohon lengkapi data dengan benar sebelum melanjutkan.')),
                          ],
                        ),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating, 
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31E24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("LANJUT KE PEMBAYARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'No WA wajib diisi';
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value)) return 'Hanya boleh berisi angka';
    if (value.length < 9) return 'Nomor terlalu pendek';
    return null;
  }

  Widget _buildRadioNominal(int value, String label, bool isMobile) {
    bool isSelected = _selectedNominal == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNominal = value;
            _customNominalController.clear();
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedNominal,
              activeColor: Colors.black87,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedNominal = newValue;
                  _customNominalController.clear();
                });
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2B2B2B) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14, 
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.normal),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

class CurrencyFormat extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    int count = 0;
    for (int i = numericOnly.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = numericOnly[i] + formatted;
      count++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}