import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72, // Reduced from 85 to be more compact
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, FontAwesomeIcons.house, 'Beranda'),
              _buildNavItem(1, FontAwesomeIcons.boxesStacked, 'Aset'),
              _buildNavItem(2, FontAwesomeIcons.clockRotateLeft, 'Riwayat'),
              _buildNavItem(3, FontAwesomeIcons.solidCircleUser, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, dynamic icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppTheme.primaryBlue : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: FaIcon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 4 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

