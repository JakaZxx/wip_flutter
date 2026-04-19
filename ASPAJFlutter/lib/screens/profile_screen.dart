import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../providers/auth_provider.dart';
import '../providers/borrowing_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? _profileImage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final borrowingProvider = context.watch<BorrowingProvider>();
    final user = authProvider.user;

    final totalBorrowings = borrowingProvider.borrowings.length;
    final pendingBorrowings = borrowingProvider.borrowings.where((b) => b.status == 'pending').length;
    final activeBorrowings = borrowingProvider.borrowings.where((b) => b.status == 'approved').length;

    String? profilePictureUrl;
    if (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) {
      profilePictureUrl = ApiService.fixPhotoUrl(user.profilePicture!);
    } else if (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty) {
      profilePictureUrl = ApiService.fixPhotoUrl(user.profilePictureUrl!);
    }

    ImageProvider? displayImage;
    if (_profileImage != null) {
      displayImage = kIsWeb ? NetworkImage(_profileImage!.path) : FileImage(File(_profileImage!.path)) as ImageProvider;
    } else if (profilePictureUrl != null) {
      displayImage = NetworkImage(profilePictureUrl);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(user, displayImage),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(totalBorrowings, pendingBorrowings, activeBorrowings),
                  const SizedBox(height: 32),
                  _buildSectionHeader('DATA IDENTITAS', 'Informasi Pribadi'),
                  const SizedBox(height: 16),
                  _buildInfoCard(user),
                  const SizedBox(height: 32),
                  _buildSectionHeader('KEAMANAN & BANTUAN', 'Akses Infrastruktur'),
                  const SizedBox(height: 16),
                  _buildActionsCard(context),
                  if (_profileImage != null) ...[
                    const SizedBox(height: 48),
                    _buildSaveAction(),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(User? user, ImageProvider? displayImage) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : (user?.role == 'admin' || user?.role == 'officers')
              ? IconButton(
                  icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 28),
                  onPressed: () => context.read<NavigationProvider>().openDrawer(),
                )
              : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              const Positioned(
                bottom: -50,
                right: -30,
                child: Opacity(opacity: 0.1, child: FaIcon(FontAwesomeIcons.userShield, size: 240, color: Colors.white)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildProfileAvatar(displayImage),
                    const SizedBox(height: 24),
                    Text(user?.name ?? 'System Entity', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text(user?.role.toUpperCase() ?? 'IDENTIFIED', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
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

  Widget _buildProfileAvatar(ImageProvider? displayImage) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5)),
          child: Container(
            width: 130, height: 130,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: ClipOval(
              child: displayImage != null
                  ? Image(image: displayImage, fit: BoxFit.cover)
                  : const FaIcon(FontAwesomeIcons.solidUser, size: 50, color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        Positioned(
          bottom: 5, right: 5,
          child: InkWell(
            onTap: _pickAndCropImage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))]),
              child: const FaIcon(FontAwesomeIcons.camera, color: AppTheme.primaryBlue, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(int total, int pending, int active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBubble('TOTAL', total.toString(), FontAwesomeIcons.arrowsSpin, const Color(0xFF6366F1)),
          _buildDivider(),
          _buildStatBubble('PENDING', pending.toString(), FontAwesomeIcons.hourglassHalf, const Color(0xFFF59E0B)),
          _buildDivider(),
          _buildStatBubble('AKTIF', active.toString(), FontAwesomeIcons.satellite, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 30, width: 1, color: const Color(0xFFF1F5F9));

  Widget _buildStatBubble(String label, String value, dynamic icon, Color color) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(icon, color: color, size: 14)),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFF1E293B))),
        ),
        Text(label, style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF475569), letterSpacing: 2)),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildInfoCard(User? user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _buildInfoSector(FontAwesomeIcons.envelope, 'EMAIL', user?.email ?? '-'),
          _buildTileDivider(),
          _buildInfoSector(FontAwesomeIcons.shieldHalved, 'STATUS VERIFIKASI', user?.emailVerifiedAt != null ? 'TERVERIFIKASI' : 'PENDING', isStatus: true, statusColor: user?.emailVerifiedAt != null ? const Color(0xFF10B981) : Colors.orange),
          _buildTileDivider(),
          _buildInfoSector(FontAwesomeIcons.graduationCap, 'INSTITUSI', user?.student?.schoolClass?.name ?? user?.jurusan ?? '-'),
          if (user?.nis != null) ...[
            _buildTileDivider(),
            _buildInfoSector(FontAwesomeIcons.idBadge, 'NIS', user!.nis!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSector(dynamic icon, String label, String value, {bool isStatus = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
            child: FaIcon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 9, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                    if (isStatus) ...[
                      const SizedBox(width: 8),
                      FaIcon(FontAwesomeIcons.solidCircleCheck, size: 14, color: statusColor),
                      if (statusColor == Colors.orange) ...[
                        const Spacer(),
                        TextButton(
                          onPressed: _isLoading ? null : _resendVerification,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('VERIFIKASI SEKARANG', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileDivider() => const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 68);

  Widget _buildActionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _buildActionPortal(FontAwesomeIcons.circleQuestion, 'PUSAT BANTUAN', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
          _buildTileDivider(),
          _buildActionPortal(FontAwesomeIcons.circleInfo, 'TENTANG APLIKASI', _showAboutDialog),
          _buildTileDivider(),
          _buildActionPortal(FontAwesomeIcons.powerOff, 'KELUAR', _logout, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildActionPortal(dynamic icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? AppTheme.dangerRed : const Color(0xFF334155);
    return ListTile(
      onTap: onTap,
      leading: FaIcon(icon, size: 16, color: color),
      title: Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
      trailing: FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: isDestructive ? color.withValues(alpha: 0.5) : const Color(0xFFCBD5E1)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: AppTheme.primaryBlue, size: 28),
            const SizedBox(width: 12),
            Text('4LLASET', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 1, color: AppTheme.primaryBlue)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi Sistem Peminjaman Aset Jurusan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Text(
              'Aplikasi ini dirancang untuk memudahkan manajemen dan pemantauan penggunaan aset di lingkungan jurusan sekolah.',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'DIRANCANG OLEH:',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            Text(
              'TEAM XII RPL 3',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'DONATUR & INSTITUSI:',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            Text(
              'SMKN 4 BANDUNG',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            Text(
              'Versi 1.0.0 • © 2026',
              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFCBD5E1)),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: Text('TUTUP', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveAction() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 12,
          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('SIMPAN PERUBAHAN', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
      ),
    );
  }

  Future<void> _logout() async {
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
                    await context.read<AuthProvider>().logout();
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

  Future<void> _pickAndCropImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile == null) return;

      if (!mounted) return;

      // image_cropper only supports Android, iOS, and Web.
      // On Windows, skip cropping to avoid MissingPluginException.
      bool isMobileOrWeb = kIsWeb;
      if (!isMobileOrWeb) {
        try {
          isMobileOrWeb = Platform.isAndroid || Platform.isIOS;
        } catch (_) {
          isMobileOrWeb = false;
        }
      }

      if (isMobileOrWeb) {
        final webSettings = WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 400, height: 400),
        );
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(toolbarTitle: 'Kalibrasi Identitas', toolbarColor: AppTheme.primaryBlue, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: true),
            IOSUiSettings(title: 'Kalibrasi Identitas'),
            webSettings,
          ],
        );

        if (mounted) setState(() => _profileImage = XFile(croppedFile?.path ?? pickedFile.path));
      } else {
        // Direct assignment for Windows/Desktop
        if (mounted) setState(() => _profileImage = XFile(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kalibrasi identitas gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isLoading = true);
    try {
      await ApiService().resendVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verifikasi berhasil dikirim. Silakan cek inbox/spam Anda.'), backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim verifikasi: $e'), backgroundColor: AppTheme.dangerRed, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      if (_profileImage == null) return;
      final imageBytes = await _profileImage!.readAsBytes();
      final updatedUser = await ApiService().updateProfile(imageBytes: imageBytes, imageFileName: 'identity.jpg');
      if (mounted) {
        context.read<AuthProvider>().updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Identitas berhasil disinkronkan.'), backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating));
        setState(() => _profileImage = null);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal: $e'),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
