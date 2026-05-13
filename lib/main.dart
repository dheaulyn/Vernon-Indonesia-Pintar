import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';


import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'screens/home/home_screen.dart';
import 'screens/home/widgets/faq_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/portal/dashboard_screen.dart';
import 'screens/portal/status_beasiswa_screen.dart';
import 'screens/program_detail_screen.dart';
import 'screens/admin/auth/login_admin_screen.dart';
import 'screens/admin/layout_dashboard.dart';
// import 'data/models/program_model.dart';
import 'screens/home/widgets/profil_yayasan.dart';
import 'screens/portal/form_beasiswa.dart';
import 'screens/home/fund_pool_screen.dart';
import 'screens/donatur/donatur_dashboard_screen.dart';
import 'screens/auth/login_donatur_screen.dart';
import 'screens/auth/register_donatur_screen.dart';
import 'screens/media/media_screen.dart';
import 'screens/media/artikel/artikel_detail_screen.dart';

void main() {
  usePathUrlStrategy();
  runApp(const YayasanApp());
}

// ======================================================
// ROUTER
// ======================================================
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/pusat-bantuan',
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

    GoRoute(
      path: '/admin',
      builder: (context, state) => const LayoutDashboard(),
    ),

    GoRoute(
      path: '/login-donatur',
      builder: (context, state) => const LoginDonaturScreen(),
    ),

    GoRoute(
      path: '/register-donatur',
      builder: (context, state) => const RegisterDonaturScreen(),
    ),

    GoRoute(
      path: '/dashboard-donatur',
      builder: (context, state) => const DonaturDashboardScreen(),
    ),

    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const LoginAdminScreen(),
    ),

    GoRoute(
      path: '/profil-yayasan',
      builder: (context, state) => const ProfilYayasanScreen(),
    ),

    GoRoute(
      path: '/form-beasiswa',
      builder: (context, state) => const FormBeasiswaScreen(),
    ),

    GoRoute(
      path: '/status-beasiswa',
      builder: (context, state) => const StatusBeasiswaScreen(),
    ),

    GoRoute(
      path: '/fund-pool',
      builder: (context, state) => const FundPoolScreen(),
    ),

    GoRoute(
      path: '/donasi',
      builder: (context, state) => const DonaturDashboardScreen(),
    ),

    GoRoute(
      path: '/program',
      builder: (context, state) => const ProgramDetailScreen(),
    ),

    GoRoute(
      path: '/media',
      name: 'media',
      builder: (context, state) => const MediaScreen(),
    ),

    GoRoute(
      path: '/media/artikel',
      builder: (context, state) {
        final artikelData = state.extra as Map<String, String>?;

        if (artikelData == null) {
          return const MediaScreen();
        }

        return ArtikelDetailScreen(
          artikel: artikelData,
        );
      },
    ),

    // RUTE DINAMIS
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
// APP
// ======================================================
class YayasanApp extends StatelessWidget {
  const YayasanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vernon Indonesia Pintar',
      debugShowCheckedModeBanner: false,

      // ==========================================
      // WAJIB UNTUK FLUTTER QUILL
      // ==========================================
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

      // ==========================================
      // THEME
      // ==========================================
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFE53935),
      ),

      // ==========================================
      // ROUTER
      // ==========================================
      routerConfig: _router,
    );
  }
}