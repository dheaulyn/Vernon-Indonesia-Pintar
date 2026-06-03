import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/snackbar_helper.dart';

import '../../../../services/supabase_donasi_service.dart';

class FormDonasiView extends StatefulWidget {
  final bool isMobile;
  final Map<String, dynamic> user;
  final VoidCallback onDonasiSuccess;

  const FormDonasiView({
    super.key,
    required this.isMobile,
    required this.user,
    required this.onDonasiSuccess,
  });

  @override
  State<FormDonasiView> createState() => _FormDonasiViewState();
}

class _FormDonasiViewState extends State<FormDonasiView> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedNominal = 100000;
  bool _isAnonymous = false;
  final TextEditingController _customNominalController =
      TextEditingController();

  @override
  void dispose() {
    _customNominalController.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNGSI POPUP METODE PEMBAYARAN
  // =========================================================================
  void _showPaymentMethodDialog(int nominal) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    String selectedMethod = 'QRIS';
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                width: widget.isMobile ? double.infinity : 500,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. header dialog.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pilih Pembayaran",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (!isProcessing)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(dialogContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. konten tengah.
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ringkasan Donasi.
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Total Tagihan",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormatter.format(nominal),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  if (_isAnonymous) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "Donasi Anonim",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Pilihan Metode.
                            const Text(
                              "Metode Pembayaran",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 15),

                            _buildPaymentOption(
                              "QRIS",
                              "Scan QR Code",
                              Icons.qr_code_scanner,
                              selectedMethod,
                              (val) =>
                                  setStateDialog(() => selectedMethod = val),
                            ),
                            _buildPaymentOption(
                              "Transfer Bank (VA)",
                              "BCA, Mandiri, BNI, BRI",
                              Icons.account_balance_outlined,
                              selectedMethod,
                              (val) =>
                                  setStateDialog(() => selectedMethod = val),
                            ),
                            _buildPaymentOption(
                              "E-Wallet",
                              "GoPay, OVO, DANA",
                              Icons.account_balance_wallet_outlined,
                              selectedMethod,
                              (val) =>
                                  setStateDialog(() => selectedMethod = val),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. tombol bayar.
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setStateDialog(() => isProcessing = true);

                                // Simulasi loading Payment Gateway.
                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );

                                // Eksekusi ke Supabase cloud.
                                try {
                                  // Tentukan nama donatur.
                                  String namaDonatur = _isAnonymous
                                      ? 'tanpa nama'
                                      : (widget.user['name'] ?? 'Donatur VIP');

                                  // Kirim ke database.
                                  await SupabaseDonationService.kirimDonasiKeCloud(
                                    namaDonatur,
                                    'Program Karir Kurikulum 10 Bulan VIP',
                                    nominal,
                                  );

                                  // Jika sukses.
                                  if (context.mounted) {
                                    Navigator.pop(
                                      dialogContext,
                                    );
                                    showSuccessSnackBar(
                                      context,
                                      'Pembayaran berhasil dikonfirmasi!',
                                    );

                                    // Pindah ke halaman riwayat atau reset form.
                                    widget.onDonasiSuccess();
                                  }
                                } catch (e) {
                                  // Jika terjadi error (misal internet mati).
                                  if (context.mounted) {
                                    setStateDialog(() => isProcessing = false);
                                    showErrorSnackBar(
                                      context,
                                      'Transaksi gagal. Coba lagi! ($e)',
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "BAYAR SEKARANG",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(
    String title,
    String subtitle,
    IconData icon,
    String groupValue,
    Function(String) onChanged,
  ) {
    bool isSelected = title == groupValue;
    return GestureDetector(
      onTap: () => onChanged(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade500,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            // ignore: deprecated_member_use
            Radio<String>(
              value: title,
              groupValue: groupValue,
              activeColor: AppColors.primary,
              onChanged: (val) => onChanged(val!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 20 : 32,
        vertical: 8,
      ),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.isMobile
              ? Column(children: [_buildDarkSection(), _buildFormSection()])
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: _buildDarkSection()),
                      Expanded(flex: 6, child: _buildFormSection()),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDarkSection() {
    return Container(
      color: const Color(0xFF333333),
      padding: EdgeInsets.all(widget.isMobile ? 30 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "DONATUR VIP",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Investasi Nyata Masa Depan Bangsa",
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 32 : 40,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Setiap rupiah yang Anda berikan adalah kepingan harapan bagi seorang siswa untuk meraih kemandirian ekonomi.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildFeatureBullet(
            "Aman & Terpercaya",
            "Sistem pembayaran terenkripsi",
            Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 25),
          _buildFeatureBullet(
            "Laporan Transparan",
            "Pantau penggunaan dana di dashboard",
            Icons.analytics_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String title, String subtitle, IconData iconData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 30 : 50),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Donasi Sekarang",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Lengkapi formulir di bawah untuk berdonasi.",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            const Text(
              "Pilih Nominal",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRadioNominal(100000, "Rp 100.000"),
                _buildRadioNominal(250000, "Rp 250.000"),
                _buildRadioNominal(500000, "Rp 500.000"),
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
                if (_selectedNominal != null) {
                  setState(() => _selectedNominal = null);
                }
              },
              onChanged: (value) {
                if (_selectedNominal != null) {
                  setState(() => _selectedNominal = null);
                }
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
              decoration: _inputStyle(
                "Nominal Lainnya (Min 10.000)",
                prefixText: "Rp ",
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Data Diri",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 15),

            TextFormField(
              initialValue: widget.user['name'],
              decoration: _inputStyle("Nama Lengkap"),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama Lengkap wajib diisi'
                  : null,
            ),
            const SizedBox(height: 15),

            widget.isMobile
                ? Column(
                    children: [
                      TextFormField(
                        initialValue: widget.user['email'],
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputStyle("Email (untuk invoice)"),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        initialValue: widget.user['whatsapp'] ?? widget.user['telepon'],
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputStyle("No. Telepon"),
                        validator: _validatePhone,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.user['email'],
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputStyle("Email (untuk invoice)"),
                          validator: _validateEmail,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.user['whatsapp'] ?? widget.user['telepon'],
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _inputStyle("No. Telepon"),
                          validator: _validatePhone,
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 15),

            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _isAnonymous,
                    activeColor: AppColors.primary,
                    onChanged: (bool? value) =>
                        setState(() => _isAnonymous = value ?? false),
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
                    int finalNominal;
                    if (_selectedNominal != null) {
                      finalNominal = _selectedNominal!;
                    } else {
                      String rawStr = _customNominalController.text.replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );
                      finalNominal = int.parse(rawStr);
                    }

                    // Panggil dialog pilihan metode pembayaran.
                    _showPaymentMethodDialog(finalNominal);
                  } else {
                    showErrorSnackBar(
                      context,
                      'Mohon lengkapi data dengan benar sebelum melanjutkan.',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PILIH METODE PEMBAYARAN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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
    if (value == null || value.trim().isEmpty) return 'Nomor Telepon tidak boleh kosong';
    if (value.length < 10 || value.length > 14) return 'Nomor Telepon tidak valid (10-14 digit)';
    return null;
  }

  Widget _buildRadioNominal(int value, String label) {
    bool isSelected = _selectedNominal == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedNominal = value;
          _customNominalController.clear();
        }),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: [
            // ignore: deprecated_member_use
            Radio<int>(
              value: value,
              groupValue: _selectedNominal,
              activeColor: Colors.black87,
              onChanged: (int? newValue) => setState(() {
                _selectedNominal = newValue;
                _customNominalController.clear();
              }),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2B2B2B)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: widget.isMobile ? 12 : 14,
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
      prefixStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');
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
