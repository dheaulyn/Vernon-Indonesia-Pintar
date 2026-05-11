import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../data/mock_database.dart';

import 'dashboard_view.dart';
import 'form_donasi_view.dart';
import 'riwayat_donasi.dart';
import 'laporan_view.dart';
import 'data_diri.dart';
import 'ganti_password.dart';

class DonaturDashboardScreen extends StatefulWidget {
  const DonaturDashboardScreen({super.key});

  @override
  State<DonaturDashboardScreen> createState() => _DonaturDashboardScreenState();
}

class _DonaturDashboardScreenState extends State<DonaturDashboardScreen> {
  late Map<String, dynamic> user;
  late List<DonationHistory> allHistories;
  late List<DonationHistory> successDonations;

  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarCollapsed = false;
  bool _isAkunExpanded = false;

  // 👇 WIDGET BARU: Kontroler untuk mendeteksi scroll layar
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    user =
        MockDatabase.currentUser ??
        {'name': 'Dhea Aulyanti', 'email': 'dhea@mail.com'};
    _refreshData();

    // 👇 WIDGET BARU: Memantau apakah layar sudah di-scroll ke bawah
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showBackToTopButton) {
        setState(() => _showBackToTopButton = true);
      } else if (_scrollController.offset <= 300 && _showBackToTopButton) {
        setState(() => _showBackToTopButton = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Jangan lupa dibersihkan
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      allHistories = MockDatabase.getDonationHistory(user['email']);
      allHistories.sort((a, b) => b.date.compareTo(a.date));
      successDonations = allHistories
          .where((h) => h.status == 'Sukses')
          .toList();
    });
  }

  void _handleLogout() {
    MockDatabase.logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile)) : null,
      body: Column(
        children: [
          _buildTopNavbar(isMobile),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) _buildSidebar(isMobile),
                Expanded(child: _buildMainContent(isMobile)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavbar(bool isMobile) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            splashRadius: 24,
            onPressed: () {
              if (isMobile) {
                _scaffoldKey.currentState?.openDrawer();
              } else {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                  if (_isSidebarCollapsed) _isAkunExpanded = false;
                });
              }
            },
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/logo.png',
            height: 28,
            errorBuilder: (c, e, s) => const Icon(
              Icons.volunteer_activism,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "PORTAL DONATUR",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
          const Spacer(),

          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              tooltip: 'Menu Profil',
              onSelected: (String value) {
                if (value == 'logout')
                  _handleLogout();
                else if (value == 'password') {
                  setState(() {
                    _isAkunExpanded = true;
                    _selectedIndex = 5;
                    _isSidebarCollapsed = false;
                  });
                }
              },
              child: Row(
                children: [
                  if (!isMobile) ...[
                    Text(
                      user['name'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade400,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                ],
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  enabled: false,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade400,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'].toString().toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Donatur VIP",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'password',
                  child: Row(
                    children: [
                      Icon(
                        Icons.vpn_key_outlined,
                        color: Colors.black54,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Ubah Password',
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black54, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isMobile) {
    final bool isCollapsed = isMobile ? false : _isSidebarCollapsed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isCollapsed ? 70 : 250,
      color: const Color(0xFF2C313C),
      child: Column(
        crossAxisAlignment: isCollapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (!isCollapsed)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                "MENU",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(0, Icons.home_filled, "Beranda", isCollapsed),
                _buildMenuItem(
                  1,
                  Icons.volunteer_activism,
                  "Formulir Donasi",
                  isCollapsed,
                ),
                _buildMenuItem(
                  2,
                  Icons.receipt_long_rounded,
                  "Riwayat Donasi",
                  isCollapsed,
                ),
                _buildMenuItem(
                  3,
                  Icons.pie_chart_outline,
                  "Laporan Transparan",
                  isCollapsed,
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                _buildExpandableAkunMenu(isCollapsed),
              ],
            ),
          ),
          InkWell(
            onTap: _handleLogout,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 20,
                vertical: 20,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 16),
                    const Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    int index,
    IconData icon,
    String title,
    bool isCollapsed,
  ) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _isAkunExpanded = false;
        });
        if (MediaQuery.of(context).size.width < 850 &&
            _scaffoldKey.currentState?.isDrawerOpen == true)
          Navigator.pop(context);

        // Reset scroll saat pindah menu
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 0 : 20,
          vertical: 16,
        ),
        child: Row(
          mainAxisAlignment: isCollapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade500,
              size: 20,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableAkunMenu(bool isCollapsed) {
    final bool isAnySubSelected = _selectedIndex == 4 || _selectedIndex == 5;
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isCollapsed) {
                _isSidebarCollapsed = false;
                _isAkunExpanded = true;
              } else {
                _isAkunExpanded = !_isAkunExpanded;
              }
            });
          },
          child: Container(
            color: _isAkunExpanded
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 20,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.person_rounded,
                  color: isAnySubSelected || _isAkunExpanded
                      ? AppColors.primary
                      : Colors.grey.shade500,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Akun Saya",
                      style: TextStyle(
                        color: isAnySubSelected || _isAkunExpanded
                            ? Colors.white
                            : Colors.grey.shade400,
                        fontWeight: isAnySubSelected || _isAkunExpanded
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    _isAkunExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isAkunExpanded && !isCollapsed)
          Container(
            color: Colors.black.withValues(alpha: 0.1),
            child: Column(
              children: [
                _buildSubMenuItem(4, "Data Diri"),
                _buildSubMenuItem(5, "Ganti Password"),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(int index, String title) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (MediaQuery.of(context).size.width < 850 &&
            _scaffoldKey.currentState?.isDrawerOpen == true)
          Navigator.pop(context);
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 56,
          right: 20,
          top: 12,
          bottom: 12,
        ),
        width: double.infinity,
        color: isSelected
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              Icons.chevron_right,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
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
          successDonations: successDonations,
          allHistories: allHistories,
          onNavigateToDonasi: () => setState(() {
            _selectedIndex = 1;
            _isAkunExpanded = false;
          }),
        );
        break;
      case 1:
        pageTitle = "Formulir Donasi VIP";
        contentView = FormDonasiView(
          isMobile: isMobile,
          user: user,
          onDonasiSuccess: () {
            _refreshData();
            setState(() => _selectedIndex = 2);
          },
        );
        break;
      case 2:
        pageTitle = "Riwayat Donasi";
        contentView = RiwayatDonasiView(
          isMobile: isMobile,
          allHistories: allHistories,
        );
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
          successDonations: successDonations,
          allHistories: allHistories,
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

        // 👇 WIDGET BARU: Pembungkus untuk tombol Back to Top
        Expanded(
          child: PrimaryScrollController(
            controller: _scrollController,
            child: Stack(
              children: [
                contentView,

                // Menampilkan tombol kotak biru panah atas jika sudah di-scroll
                if (_showBackToTopButton)
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _scrollController.animateTo(
                            0, // Kembali ke posisi atas
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF435EFE,
                            ), // Biru persis seperti di gambar
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
