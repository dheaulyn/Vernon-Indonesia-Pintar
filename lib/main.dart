import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

// --- IMPORT PUBLIK ---
import 'screens/home/home_screen.dart';
import 'screens/home/widgets/faq_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/portal/dashboard_screen.dart';
import 'screens/portal/status_beasiswa_screen.dart';
import 'screens/program_detail_screen.dart';
import 'screens/home/widgets/profil_yayasan.dart';
import 'screens/portal/form_beasiswa.dart';
import 'screens/home/fund_pool_screen.dart';
import 'screens/donatur/donatur_dashboard_screen.dart';
import 'screens/auth/login_donatur_screen.dart';
import 'screens/auth/register_donatur_screen.dart';
import 'screens/media/media_screen.dart';
import 'screens/media/artikel/artikel_detail_screen.dart';

// --- IMPORT ADMIN ---
import 'screens/admin/auth/login_admin_screen.dart';
import 'screens/admin/layout_dashboard.dart';
import 'screens/admin/home_dashboard.dart';
import 'screens/admin/manajemen_pendaftar_admin.dart';
import 'screens/admin/cms/hero_banner_admin.dart';
import 'screens/admin/cms/about_section_admin.dart';
import 'screens/admin/cms/profil_yayasan_admin.dart';
import 'screens/admin/cms/program_detail_admin.dart';
import 'screens/admin/cms/media_admin.dart';
import 'screens/admin/cms/testimoni_admin.dart';
import 'screens/admin/cms/faq_admin.dart';
import 'screens/admin/cms/footer_admin.dart';
import 'screens/admin/cms/partners_admin.dart';

void main() {
  usePathUrlStrategy();
  runApp(const YayasanApp());
}

// ======================================================
// ROUTER CONFIGURATION
// ======================================================
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // --------------------------------------------------
    // 1. RUTE PUBLIK (USER/GUEST)
    // --------------------------------------------------
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/pusat-bantuan', builder: (context, state) => const FAQScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/portal', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/login-donatur', builder: (context, state) => const LoginDonaturScreen()),
    GoRoute(path: '/register-donatur', builder: (context, state) => const RegisterDonaturScreen()),
    GoRoute(path: '/dashboard-donatur', builder: (context, state) => const DonaturDashboardScreen()),
    GoRoute(path: '/admin-login', builder: (context, state) => const LoginAdminScreen()),
    GoRoute(path: '/profil-yayasan', builder: (context, state) => const ProfilYayasanScreen()),
    GoRoute(path: '/form-beasiswa', builder: (context, state) => const FormBeasiswaScreen()),
    GoRoute(path: '/status-beasiswa', builder: (context, state) => const StatusBeasiswaScreen()),
    GoRoute(path: '/fund-pool', builder: (context, state) => const FundPoolScreen()),
    GoRoute(path: '/donasi', builder: (context, state) => const DonaturDashboardScreen()),
    GoRoute(path: '/program', builder: (context, state) => const ProgramDetailScreen()),
    GoRoute(path: '/media', name: 'media', builder: (context, state) => const MediaScreen()),
    GoRoute(
      path: '/media/artikel',
      builder: (context, state) {
        final artikelData = state.extra as Map<String, String>?;
        return artikelData != null ? ArtikelDetailScreen(artikel: artikelData) : const MediaScreen();
      },
    ),

    // --------------------------------------------------
    // 2. RUTE ADMIN (MENGGUNAKAN SHELL ROUTE)
    // --------------------------------------------------
    ShellRoute(
      builder: (context, state, child) {
        // 'child' adalah halaman aktif (seperti HomeDashboard, HeroBannerAdmin, dll)
        // yang akan disuntikkan ke dalam LayoutDashboard
        return LayoutDashboard(child: child);
      },
      routes: [
        GoRoute(path: '/admin-dashboard', builder: (context, state) => const HomeDashboard()),
        GoRoute(path: '/admin-pendaftar', builder: (context, state) => const ManajemenPendaftarAdmin()),
        GoRoute(path: '/cms-hero-banner', builder: (context, state) => const HeroBannerAdmin()),
        GoRoute(path: '/cms-about', builder: (context, state) => const AboutSectionAdmin()),
        GoRoute(path: '/cms-profil', builder: (context, state) => const ProfilYayasanAdmin()),
        GoRoute(path: '/cms-program', builder: (context, state) => const ProgramDetailAdmin()),
        GoRoute(path: '/cms-media', builder: (context, state) => const KelolaMediaAdmin()),
        GoRoute(path: '/cms-testimoni', builder: (context, state) => const TestimoniAdmin()),
        GoRoute(path: '/cms-faq', builder: (context, state) => const KelolaFAQPage()),
        GoRoute(path: '/cms-footer', builder: (context, state) => const FooterAdmin()),
        GoRoute(path: '/cms-partners', builder: (context, state) => const PartnersAdmin()),
      ],
    ),

    // --------------------------------------------------
    // RUTE DINAMIS (SCROLL KE SECTION)
    // --------------------------------------------------
    GoRoute(
      path: '/:section',
      builder: (context, state) {
        final section = state.pathParameters['section'];
        return HomeScreen(targetSection: section);
      },
    ),
  ],
);

// ======================================================
// MAIN APP CLASS
// ======================================================
class YayasanApp extends StatelessWidget {
  const YayasanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vernon Indonesia Pintar',
      debugShowCheckedModeBanner: false,

      // Konfigurasi Localization untuk Quill & Flutter
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
      locale: const Locale('id'),

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFE53935),
      ),

      routerConfig: _router,
    );
  }
}