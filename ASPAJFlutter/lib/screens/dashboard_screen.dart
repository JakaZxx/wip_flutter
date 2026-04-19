import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/user.dart';
import '../models/dashboard_stats.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    await context.read<DashboardProvider>().fetchDashboardStats();
  }

  Future<void> _handleLogout() async {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) return const SizedBox.shrink();

    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final stats = dashboardProvider.dashboardStats;

        return RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppTheme.primaryBlue,
          edgeOffset: 160,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dashboardProvider.isLoading)
                        _buildLoadingState()
                      else if (stats != null)
                        _buildDashboardContent(user, stats)
                      else
                        _buildErrorState(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(User user) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      leading: !user.isStudent
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
                right: -40,
                bottom: -40,
                child: Opacity(opacity: 0.1, child: FaIcon(FontAwesomeIcons.cube, size: 220, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildUserAvatar(user),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PUSAT KENDALI', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(user.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                child: Text(_getRoleLabel(user.role), style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22), 
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada notifikasi baru')));
          }
        ),
        IconButton(
          icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 22),
          onPressed: _handleLogout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildUserAvatar(User user) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1)),
      child: Container(
        width: 64, height: 64,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: ClipOval(
          child: (user.profilePictureUrl != null || user.profilePicture != null)
              ? Image.network(
                  ApiService.fixPhotoUrl(user.profilePictureUrl ?? user.profilePicture!)!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(user.name[0].toUpperCase(), style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontSize: 26, fontWeight: FontWeight.w900)),
                  ),
                )
              : Center(child: Text(user.name[0].toUpperCase(), style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontSize: 26, fontWeight: FontWeight.w900))),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(User user, DashboardStats stats) {
    if (user.isAdmin) return _buildAdminDashboard(stats);
    if (user.isOfficer) return _buildOfficerDashboard(stats);
    return _buildStudentDashboard(stats);
  }

  Widget _buildAdminDashboard(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('RINGKASAN SISTEM', 'Infrastruktur Utama'),
        const SizedBox(height: 20),
        _buildStatsGrid([
          _StatData('PENGGUNA TERDAFTAR', stats.totalUsers?.toString() ?? '0', FontAwesomeIcons.users, const Color(0xFF6366F1)),
          _StatData('JUMLAH ASET', stats.totalAssets?.toString() ?? '0', FontAwesomeIcons.boxesStacked, const Color(0xFF8B5CF6)),
          _StatData('PENGGUNA PENDING', stats.pendingUsersCount?.toString() ?? '0', FontAwesomeIcons.userPlus, const Color(0xFFF59E0B)),
          _StatData('TOTAL PEMINJAMAN', stats.totalBorrowings?.toString() ?? '0', FontAwesomeIcons.arrowsRotate, const Color(0xFF10B981)),
        ]),
        const SizedBox(height: 32),
        if (stats.recentUsers != null && stats.recentUsers!.isNotEmpty) ...[
          _buildActivitySection('PENGGUNA BARU', 'Menunggu Persetujuan atau Terbaru'),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.recentUsers!.length,
            itemBuilder: (context, i) => _buildRecentUserItem(stats.recentUsers![i]),
          ),
          const SizedBox(height: 32),
        ],
        _buildSectionHeader('PANEL KONTROL', 'Tindakan Admin'),
        const SizedBox(height: 16),
        _buildActionGrid([
          _ActionData('Kelola Pengguna', FontAwesomeIcons.idCard, () => Navigator.pushNamed(context, '/admin-users')),
          _ActionData('Daftar Aset', FontAwesomeIcons.database, () => context.read<NavigationProvider>().setSelectedIndex(1)),
          _ActionData('Kelola Kelas', FontAwesomeIcons.graduationCap, () => Navigator.pushNamed(context, '/admin-classes')),
          _ActionData('Log Aktivitas', FontAwesomeIcons.clockRotateLeft, () {
            Navigator.pushNamed(context, '/admin-logs');
          }),
        ]),
      ],
    );
  }

  Widget _buildOfficerDashboard(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('STATUS OPERASIONAL', 'Permintaan Aktif'),
        const SizedBox(height: 20),
        _buildStatsGrid([
          _StatData('MENUNGGU PERSETUJUAN', stats.pendingRequestsCount?.toString() ?? '0', FontAwesomeIcons.clock, const Color(0xFFF59E0B)),
          _StatData('SEDANG DIPINJAM', stats.activeBorrowingsCount?.toString() ?? '0', FontAwesomeIcons.handHolding, const Color(0xFF3B82F6)),
          _StatData('PENGAJUAN DITOLAK', stats.rejectedBorrowingsCount?.toString() ?? '0', FontAwesomeIcons.circleXmark, const Color(0xFFEF4444)),
          _StatData('BARANG KEMBALI', stats.returnedBorrowingsCount?.toString() ?? '0', FontAwesomeIcons.circleCheck, const Color(0xFF10B981)),
        ]),
        const SizedBox(height: 32),
        if (stats.recentBorrowings != null && stats.recentBorrowings!.isNotEmpty) ...[
          _buildActivitySection('PENGAJUAN TERBARU', 'Aktivitas Transaksi'),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.recentBorrowings!.length,
            itemBuilder: (context, i) => _buildRecentBorrowingItem(stats.recentBorrowings![i]),
          ),
          const SizedBox(height: 32),
        ],
        _buildSectionHeader('AKSI CEPAT', 'Panel Petugas'),
        const SizedBox(height: 16),
        _buildActionGrid([
          _ActionData('Proses Pengajuan', FontAwesomeIcons.clipboardCheck, () => context.read<NavigationProvider>().setSelectedIndex(2)),
          _ActionData('Audit Inventaris', FontAwesomeIcons.listCheck, () => context.read<NavigationProvider>().setSelectedIndex(1)),
          _ActionData('Daftar Kembali', FontAwesomeIcons.boxOpen, () => context.read<NavigationProvider>().setSelectedIndex(2)),
          _ActionData('Laporan Masalah', FontAwesomeIcons.triangleExclamation, () {
            Navigator.pushNamed(context, '/help');
          }),
        ]),
      ],
    );
  }

  Widget _buildActivitySection(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildSectionHeader(title, subtitle)),
        TextButton(
          onPressed: () {}, 
          child: Text('LIHAT SEMUA', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
        ),
      ],
    );
  }

  Widget _buildRecentUserItem(RecentUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: user.profilePictureUrl != null
                  ? Image.network(
                      ApiService.fixPhotoUrl(user.profilePictureUrl)!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF64748B)),
                    )
                  : const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(user.email, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Text(user.role.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBorrowingItem(RecentRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: request.profilePictureUrl != null
                  ? Image.network(
                      ApiService.fixPhotoUrl(request.profilePictureUrl)!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, size: 20, color: AppTheme.primaryBlue),
                    )
                  : const Icon(Icons.inventory_2_outlined, size: 20, color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.studentName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(request.items.join(', '), style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8), height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          _buildSmallStatusBadge(request.status),
        ],
      ),
    );
  }

  Widget _buildSmallStatusBadge(String? status) {
    Color color = Colors.orange;
    if (status == 'approved') color = const Color(0xFF10B981);
    if (status == 'rejected') color = Colors.red;
    if (status == 'returned') color = AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(_translateStatus(status), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
    );
  }

  String _translateStatus(String? status) {
    if (status == null) return 'MENUNGGU';
    switch (status.toLowerCase()) {
      case 'pending': return 'MENUNGGU';
      case 'approved': return 'DISETUJUI';
      case 'partial':
      case 'partially_approved': return 'DISETUJUI SEBAGIAN';
      case 'partially_returned': return 'SEBAGIAN KEMBALI';
      case 'rejected': return 'DITOLAK';
      case 'returned': return 'KEMBALI';
      default: return status.toUpperCase();
    }
  }

  Widget _buildStudentDashboard(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('DASHBOARD SISWA', 'Aktivitas Saya'),
        const SizedBox(height: 20),
        _buildStatsGrid([
          _StatData('PINJAMAN AKTIF', stats.myActiveBorrowingsCount?.toString() ?? '0', FontAwesomeIcons.handHolding, const Color(0xFF3B82F6)),
          _StatData('MENUNGGU DISETUJUI', stats.pendingBorrowingsCount?.toString() ?? '0', FontAwesomeIcons.clock, const Color(0xFFF59E0B)),
          _StatData('TOTAL KEMBALI', stats.returnedBorrowingsCount?.toString() ?? '0', FontAwesomeIcons.circleCheck, const Color(0xFF10B981)),
          _StatData('TOTAL DITOLAK', stats.rejectedBorrowingsCount?.toString() ?? '0', FontAwesomeIcons.circleXmark, const Color(0xFFEF4444)),
        ]),
        const SizedBox(height: 32),
        _buildSectionHeader('JELAJAHI ASET', 'Peminjaman Mandiri'),
        const SizedBox(height: 16),
        _buildActionGrid([
          _ActionData('Pinjam Barang', FontAwesomeIcons.cartPlus, () => context.read<NavigationProvider>().setSelectedIndex(1)),
          _ActionData('Riwayat Pinjam', FontAwesomeIcons.clockRotateLeft, () => context.read<NavigationProvider>().setSelectedIndex(2)),
          _ActionData('Pusat Bantuan', FontAwesomeIcons.circleQuestion, () => Navigator.pushNamed(context, '/help')),
          _ActionData('Profil Saya', FontAwesomeIcons.shieldHalved, () => Navigator.pushNamed(context, '/profile')),
        ]),
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

  Widget _buildStatsGrid(List<_StatData> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildStatCard(items[i]),
    );
  }

  Widget _buildStatCard(_StatData item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: FaIcon(item.icon, color: item.color, size: 18),
          ),
          const Spacer(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(item.value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label, 
                  style: GoogleFonts.outfit(fontSize: 8, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(List<_ActionData> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildActionCard(items[i]),
    );
  }

  Widget _buildActionCard(_ActionData item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            FaIcon(item.icon, size: 16, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Expanded(child: Text(item.label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155)))),
          ],
        ),
      ),
    );
  }


  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return 'ADMINISTRATOR';
      case 'officers': return 'PETUGAS ASET';
      case 'students': return 'SISWA / PEMINJAM';
      default: return role.toUpperCase();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppTheme.primaryBlue),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          FaIcon(FontAwesomeIcons.wifi, size: 60, color: Colors.red.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text('GANGGUAN KONEKSI', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('Sinkronisasi infrastruktur terhenti. Menghubungkan ulang...', style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: Text('COBA LAGI', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final dynamic icon;
  final Color color;
  _StatData(this.label, this.value, this.icon, this.color);
}

class _ActionData {
  final String label;
  final dynamic icon;
  final VoidCallback onTap;
  _ActionData(this.label, this.icon, this.onTap);
}

