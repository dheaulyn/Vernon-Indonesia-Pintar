import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:flutter_web_plugins/url_strategy.dart'; 

// --- 1. IMPORT SEMUA HALAMAN ---
import 'screens/home/home_screen.dart';
import 'screens/home/widgets/faq_screen.dart'; 
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/portal/dashboard_screen.dart';
import 'screens/program_detail_screen.dart'; 
import 'screens/admin/layout_dashboard.dart'; 
import 'data/models/program_model.dart'; 

void main() {
  usePathUrlStrategy(); 
  runApp(const YayasanApp());
}

// --- 2. PETA RUTE WEBSITE (ROUTER) ---
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // RUTE UTAMA (BERANDA)
    GoRoute(
      path: '/', 
      builder: (context, state) => const HomeScreen(),
    ),
    
    // RUTE STATIS (HALAMAN BERBEDA)
    // Kita ganti URL halaman penuhnya menjadi pusat-bantuan
    GoRoute(
      path: '/pusat-bantuan', 
      builder: (context, state) => const FAQScreen()),
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
    GoRoute(
      path: '/admin', 
      builder: (context, state) => const LayoutDashboard(),
    ),
    
    // RUTE DETAIL PROGRAM (DENGAN DATA EXTRA)
    GoRoute(
      path: '/program/:id', 
      builder: (context, state) {
        final dataProgram = state.extra as ProgramModel?;
        if (dataProgram == null) return const HomeScreen(); 

        return ProgramDetailScreen(
          program: dataProgram,
        ); 
      },
    ),

    // --- MANTRA: RUTE DINAMIS UNTUK SEKSI HOMESCREEN ---
    // Letakkan di paling bawah agar tidak "memakan" rute /login atau /faq
    GoRoute(
      path: '/:section', 
      builder: (context, state) {
        final section = state.pathParameters['section'];
        return HomeScreen(targetSection: section);
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