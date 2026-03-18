import 'package:flutter/material.dart';
import '../../data/models/program_model.dart';
import '../../core/app_colors.dart';
import 'shared/custom_navbar.dart';

class ProgramDetailScreen extends StatefulWidget {
  final ProgramModel program;
  final VoidCallback onHomeTap;
  final VoidCallback onProgramTap;

  const ProgramDetailScreen({
    super.key,
    required this.program,
    required this.onHomeTap,
    required this.onProgramTap,
  });

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showNavbar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showNavbar) {
        setState(() {
          _showNavbar = true;
        });
      } else if (_scrollController.offset <= 200 && _showNavbar) {
        setState(() {
          _showNavbar = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: isMobile ? 350 : 450, 
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.program.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),

          
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: isMobile ? 100 : 130), 

                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        widget.program.judul.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 26 : 38, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                widget.onHomeTap,
                              );
                            },
                            child: Text(
                              "Home",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 13 : 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "  /  ",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isMobile ? 13 : 15,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                widget.onProgramTap,
                              );
                            },
                            child: Text(
                              "Jenis Beasiswa",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 13 : 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "  /  ${widget.program.judul}",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isMobile ? 13 : 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                
                Container(
                  width: double.infinity,
                  
                  margin: EdgeInsets.only(
                    top: isMobile ? 40 : 60,
                    left: isMobile ? 20 : 60,
                    right: isMobile ? 20 : 60,
                    bottom: isMobile ? 40 : 80,
                  ),
                  padding: EdgeInsets.all(isMobile ? 30 : 60),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.program.deskripsi,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 18, 
                          height: 1.8,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: isMobile ? 40 : 60),

                      
                      _buildModernSection(
                        "Benefit Beasiswa",
                        widget.program.benefit,
                        Icons.stars_rounded,
                        Colors.orange,
                        isMobile, 
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 30 : 40),
                        child: const Divider(color: Colors.black12, thickness: 1),
                      ),

                      
                      _buildModernSection(
                        "Persyaratan Pendaftaran",
                        widget.program.syarat,
                        Icons.check_circle,
                        Colors.green,
                        isMobile,
                      ),

                      SizedBox(height: isMobile ? 40 : 60),

                      
                      Center(
                        child: SizedBox(
                          height: isMobile ? 50 : 55,
                          width: isMobile ? double.infinity : 300, 
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                              shadowColor: AppColors.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            child: Text(
                              "DAFTAR SEKARANG",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          
          Positioned(
            top: isMobile ? 20 : 40, 
            left: isMobile ? 10 : 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: isMobile ? 24 : 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            top: _showNavbar ? 0 : -120, 
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              child: CustomNavbar(
                onHomeTap: () {
                  Navigator.pop(context);
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    widget.onHomeTap,
                  );
                },
                onAboutTap: () => Navigator.pop(context),
                onProgramTap: () {
                  Navigator.pop(context);
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    widget.onProgramTap,
                  );
                },
                onContactTap: () => Navigator.pop(context),
                onFAQTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildModernSection(
    String title,
    List<String> items,
    IconData icon,
    Color iconColor,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 22 : 26, 
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: isMobile ? 20 : 24),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 17, 
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}