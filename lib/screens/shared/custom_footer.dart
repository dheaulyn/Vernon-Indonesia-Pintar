import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20.0 : 30.0, 
        horizontal: 20.0,
      ),
      color: Colors.grey[200],
      width: double.infinity, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            
            '© 2026 Vernon Indonesia Pintar. All rights reserved.',
            textAlign: TextAlign.center, 
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 12 : 14, 
            ),
          ),
          const SizedBox(height: 12.0),
          
          
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 10.0 : 20.0, 
            runSpacing: 10.0, 
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Terms of Service',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}