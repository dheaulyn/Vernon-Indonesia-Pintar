import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_auth_service.dart';
import '../shared/shared_dashboard_layout.dart';

import 'dashboard_view.dart';
import 'form_donasi_view.dart';
import 'riwayat_donasi.dart';
import 'laporan_view.dart';
import 'data_diri.dart';
import 'ganti_password.dart';

class DonaturDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DonaturDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DonaturDashboardScreen> createState() => _DonaturDashboardScreenState();
}

class _DonaturDashboardScreenState extends State<DonaturDashboardScreen> {
  late Map<String, dynamic> user;

  late int _selectedIndex;

  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    user = SupabaseAuthService.currentUserData ?? {};

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showBackToTopButton) {
        setState(() => _showBackToTopButton = true);
      } else if (_scrollController.offset <= 300 && _showBackToTopButton) {
        setState(() => _showBackToTopButton = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DonaturDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Mengarahkan ke rute login khusus donatur.
  void _handleLogout() {
    SupabaseAuthService.logout();
    context.go('/login-donatur');
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    final menuItems = [
      MenuModel(
        icon: Icons.home_filled,
        title: "Beranda",
        routePath: "/dashboard-donatur?index=0",
        onTap: () => setState(() => _selectedIndex = 0),
      ),
      MenuModel(
        icon: Icons.volunteer_activism,
        title: "Formulir Donasi",
        routePath: "/dashboard-donatur?index=1",
        onTap: () => setState(() => _selectedIndex = 1),
      ),
      MenuModel(
        icon: Icons.receipt_long_rounded,
        title: "Riwayat Donasi",
        routePath: "/dashboard-donatur?index=2",
        onTap: () => setState(() => _selectedIndex = 2),
      ),
      MenuModel(
        icon: Icons.pie_chart_outline,
        title: "Laporan Transparan",
        routePath: "/dashboard-donatur?index=3",
        onTap: () => setState(() => _selectedIndex = 3),
      ),
      MenuModel(
        icon: Icons.person_rounded,
        title: "Akun Saya",
        subMenus: [
          MenuModel(
            icon: Icons.chevron_right,
            title: "Data Diri",
            routePath: "/dashboard-donatur?index=4",
            onTap: () => setState(() => _selectedIndex = 4),
          ),
          MenuModel(
            icon: Icons.chevron_right,
            title: "Ganti Password",
            routePath: "/dashboard-donatur?index=5",
            onTap: () => setState(() => _selectedIndex = 5),
          ),
        ],
      ),
    ];

    final bottomMenuItems = [
      MenuModel(
        icon: Icons.logout_rounded,
        title: "Keluar",
        isLogout: true,
        routePath: "/login-donatur",
        onTap: _handleLogout,
      ),
    ];

    return SharedDashboardLayout(
      title: "PORTAL DONATUR",
      roleText: "Donatur VIP",
      menuItems: menuItems,
      bottomMenuItems: bottomMenuItems,
      activeRoute: "/dashboard-donatur?index=$_selectedIndex",
      child: _buildMainContent(isMobile),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    String pageTitle = "";
    Widget contentView;

    switch (_selectedIndex) {
      case 0:
        pageTitle = "Beranda";
        contentView = DashboardView(
          isMobile: isMobile,
          onNavigateToDonasi: () => setState(() {
            _selectedIndex = 1;
          }),
        );
        break;
      case 1:
        pageTitle = "Formulir Donasi VIP";
        contentView = FormDonasiView(
          isMobile: isMobile,
          user: user,
          onDonasiSuccess: () {
            setState(() => _selectedIndex = 2);
          },
        );
        break;
      case 2:
        pageTitle = "Riwayat Donasi";
        contentView = RiwayatDonasiView(isMobile: isMobile);
        break;
      case 3:
        pageTitle = "Laporan Transparan";
        contentView = LaporanView(isMobile: isMobile);
        break;
      case 4:
        pageTitle = "Data Diri";
        contentView = DataDiriView(isMobile: isMobile, user: user);
        break;
      case 5:
        pageTitle = "Ganti Password";
        contentView = GantiPasswordView(isMobile: isMobile);
        break;
      default:
        pageTitle = "Beranda";
        contentView = DashboardView(
          isMobile: isMobile,
          onNavigateToDonasi: () => setState(() => _selectedIndex = 1),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 20 : 32,
            isMobile ? 20 : 32,
            20,
            16,
          ),
          child: Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        Expanded(
          child: PrimaryScrollController(
            controller: _scrollController,
            child: Stack(
              children: [
                contentView,

                if (_showBackToTopButton)
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF435EFE),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
