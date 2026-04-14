import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Mesin rute baru
import 'package:flutter_web_plugins/url_strategy.dart'; // Pembersih tanda '#' di URL

// --- 1. PANGGIL SEMUA HALAMAN DI SINI ---
import 'screens/home/home_screen.dart';
import 'screens/home/widgets/faq_screen.dart'; 
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/portal/dashboard_screen.dart';
import 'screens/program_detail_screen.dart'; 

// --- PANGGIL MODEL DATA ---
// Ini wajib dipanggil agar main.dart mengenali apa itu 'ProgramModel'
import 'data/models/program_model.dart'; 

void main() {
  // MANTRA WEB: Menghilangkan tanda pagar (#) agar URL bersih
  usePathUrlStrategy(); 
  runApp(const YayasanApp());
}

// --- 2. BUAT PETA RUTE WEBSITE ---
final GoRouter _router = GoRouter(
  initialLocation: '/', // Saat web dibuka, langsung ke Home
  routes: [
    GoRoute(
      path: '/', 
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/tentang-kami', 
      builder: (context, state) => const HomeScreen(targetSection: 'tentang-kami'),
    ),
    GoRoute(
      path: '/jenis-beasiswa', 
      builder: (context, state) => const HomeScreen(targetSection: 'jenis-beasiswa'),
    ),
    GoRoute(
      path: '/kontak', 
      builder: (context, state) => const HomeScreen(targetSection: 'kontak'),
    ),
    GoRoute(
      path: '/panduan-pendaftaran', 
      builder: (context, state) => const HomeScreen(targetSection: 'panduan-pendaftaran'),
    ),
    GoRoute(
      path: '/faq', 
      builder: (context, state) => const FAQScreen(),
    ),
    GoRoute(
      path: '/login', 
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register', 
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/portal', 
      builder: (context, state) => const DashboardScreen(),
    ),
    
    // --- PERBAIKAN RUTE DINAMIS DETAIL PROGRAM ---
    GoRoute(
      path: '/program/:id', 
      builder: (context, state) {
        // 1. Menangkap data 'extra' yang dilempar dari halaman sebelumnya
        // Jika data kosong (misal karena user me-refresh web), kita siapkan penanganan sementaranya
        final dataProgram = state.extra as ProgramModel?;

        // Jika data tidak sengaja kosong, kembalikan saja ke Beranda (Home)
        if (dataProgram == null) {
          return HomeScreen(); 
        }

        // 2. Memasukkan 3 syarat wajib ke dalam halaman detail
        return ProgramDetailScreen(
          program: dataProgram, // Syarat 1: Data model program
          onHomeTap: () {
            context.go('/'); // Syarat 2: Aksi jika klik tombol Home
          },
          onProgramTap: () {
            context.go('/portal'); // Syarat 3: Aksi jika klik tombol Program
          },
        ); 
      },
    ),
  ],
);

// --- 3. PONDASI UTAMA ---
class YayasanApp extends StatelessWidget {
  const YayasanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vernon Indonesia Pintar',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFE53935),
      ),
      routerConfig: _router, 
    );
  }
}