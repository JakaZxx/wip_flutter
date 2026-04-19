import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final navProvider = context.watch<NavigationProvider>();

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(32))),
      child: Column(
        children: [
          _buildLuxuryHeader(context, user),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectorHeader('OPERASIONAL'),
                _buildPremiumItem(context, icon: FontAwesomeIcons.chartPie, label: 'Analitik Dashboard', index: 0, currentIndex: navProvider.selectedIndex, onTap: () => _updateIndex(context, 0)),
                _buildPremiumItem(context, icon: FontAwesomeIcons.boxesStacked, label: 'Data Aset', index: 1, currentIndex: navProvider.selectedIndex, onTap: () => _updateIndex(context, 1)),
                
                if (user?.isAdmin == true || user?.isOfficer == true) ...[
                  _buildSectorHeader('ADMINISTRASI'),
                  _buildPremiumItem(context, icon: FontAwesomeIcons.clipboardCheck, label: 'Validasi Peminjaman', index: 2, currentIndex: navProvider.selectedIndex, onTap: () => _updateIndex(context, 2)),
                  if (user?.isAdmin == true)
                    _buildPremiumItem(context, icon: FontAwesomeIcons.userShield, label: 'Manajemen Pengguna', onTap: () => _navigate(context, '/admin-users')),
                  _buildPremiumItem(context, icon: FontAwesomeIcons.graduationCap, label: 'Data Kelas', onTap: () => _navigate(context, '/admin-classes')),
                ],

                _buildSectorHeader('AKUN & PENGATURAN'),
                _buildPremiumItem(context, icon: FontAwesomeIcons.solidCircleUser, label: 'Profil Saya', onTap: () => _navigate(context, '/profile')),
                _buildPremiumItem(context, icon: FontAwesomeIcons.powerOff, label: 'Keluar', onTap: () => _handleLogout(context, authProvider), color: AppTheme.dangerRed),
              ],
            ),
          ),
          _buildProfessionalFooter(),
        ],
      ),
    );
  }

  Widget _buildLuxuryHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 64, 28, 32),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1)),
            child: Container(
              width: 76, height: 76,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(
                child: user?.profilePicture != null || user?.profilePictureUrl != null
                    ? Image.network(
                        ApiService.fixPhotoUrl(user?.profilePictureUrl ?? user?.profilePicture)!, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'U', 
                          style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontSize: 32, fontWeight: FontWeight.w900))
                        ),
                      )
                    : Center(child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'U', style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontSize: 32, fontWeight: FontWeight.w900))),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(user?.name ?? 'System Entity', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(user?.role?.toUpperCase() ?? 'IDENTIFIED', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
              if (user?.jurusan != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user!.jurusan, 
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectorHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 2)),
    );
  }

  Widget _buildPremiumItem(BuildContext context, {required dynamic icon, required String label, int? index, int? currentIndex, VoidCallback? onTap, Color? color}) {
    final isSelected = index != null && index == currentIndex;
    final activeColor = color ?? AppTheme.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: FaIcon(icon, size: 18, color: isSelected ? activeColor : (color ?? const Color(0xFF64748B))),
              title: Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, color: isSelected ? activeColor : (color ?? const Color(0xFF334155)))),
              trailing: isSelected ? Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: activeColor)) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Divider(color: Colors.grey[100]),
          const SizedBox(height: 12),
          Text('CORE PLATFORM v4.0.2', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFFCBD5E1), letterSpacing: 2)),
        ],
      ),
    );
  }

  void _updateIndex(BuildContext context, int index) {
    Navigator.of(context).pop();
    context.read<NavigationProvider>().setSelectedIndex(index);
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(route);
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              title: Text('KELUAR?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1)),
              content: Text('Apakah Anda yakin ingin keluar dari akun ini?', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B))),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('BATAL', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w900))),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await authProvider.logout();
                    if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                  child: Text('KELUAR', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
