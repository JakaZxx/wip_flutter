import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/borrowing_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/class_provider.dart';
import '../models/borrowing.dart';
import '../models/borrowing_item.dart';
import '../theme/app_theme.dart';
import 'borrowing_detail_screen.dart';

class BorrowingStatusScreen extends StatefulWidget {
  const BorrowingStatusScreen({super.key});

  @override
  State<BorrowingStatusScreen> createState() => _BorrowingStatusScreenState();
}

class _BorrowingStatusScreenState extends State<BorrowingStatusScreen> {
  // Filter state
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilterStatus;
  String? _selectedFilterJurusan;
  String? _selectedFilterClass;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().fetchBorrowings();
      context.read<ClassProvider>().fetchClasses();
    });
  }

  // Helper function to check if item matches officer's jurusan
  bool _itemMatchesJurusan(BorrowingItem item, String officerJurusan) {
    if (officerJurusan.isEmpty) return true;
    final itemJurusan = (item.jurusan ?? '').toLowerCase().trim();
    final officerJurusanLower = officerJurusan.toLowerCase();
    if (itemJurusan == officerJurusanLower) return true;
    final keywords = officerJurusanLower.split(' ').where((w) => w.length > 2).toList();
    for (final keyword in keywords) {
      if (itemJurusan.contains(keyword)) return true;
    }
    return false;
  }

  List<Borrowing> _filterBorrowings(
    List<Borrowing> borrowings,
    String? userRole,
    String officerJurusan,
  ) {
    List<Borrowing> filtered = borrowings;

    // For officers, filter borrowings based on jurusan
    if (userRole == 'officers' && officerJurusan.isNotEmpty) {
      filtered = filtered.where((borrowing) {
        return borrowing.items.any((item) => _itemMatchesJurusan(item, officerJurusan));
      }).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((borrowing) {
        return borrowing.studentName.toLowerCase().contains(searchTerm) ||
               borrowing.studentClassName.toLowerCase().contains(searchTerm) ||
               borrowing.tujuan?.toLowerCase().contains(searchTerm) == true ||
               borrowing.items.any((item) =>
                   item.commodityName?.toLowerCase().contains(searchTerm) == true);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilterStatus != null && _selectedFilterStatus!.isNotEmpty) {
      filtered = filtered.where((borrowing) => borrowing.status == _selectedFilterStatus).toList();
    }

    // Apply jurusan filter
    if (_selectedFilterJurusan != null && _selectedFilterJurusan!.isNotEmpty) {
      filtered = filtered.where((borrowing) {
        return borrowing.items.any((item) =>
            item.jurusan?.toLowerCase() == _selectedFilterJurusan!.toLowerCase());
      }).toList();
    }

    // Apply class filter
    if (_selectedFilterClass != null && _selectedFilterClass!.isNotEmpty) {
      filtered = filtered.where((borrowing) =>
          borrowing.studentClassName.toLowerCase() == _selectedFilterClass!.toLowerCase()).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final borrowingProvider = context.watch<BorrowingProvider>();
    final userRole = authProvider.user?.role;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(userRole),
            SliverToBoxAdapter(
              child: _buildFilterSection(context, borrowingProvider.borrowings),
            ),
          ],
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTabList(context, 'all', borrowingProvider),
              _buildTabList(context, 'active', borrowingProvider),
              _buildTabList(context, 'completed', borrowingProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(String? role) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      leading: (role == 'officers' || role == 'admin')
        ? Builder(builder: (context) => IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ))
        : null,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Aktivitas Peminjaman',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(Icons.history_edu_rounded, size: 200, color: Colors.white.withValues(alpha: 0.08)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Monitoring Aset',
                      style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 4),
                    Container(height: 2, width: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: TabBar(
            indicatorColor: AppTheme.primaryBlue,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
            tabs: const [Tab(text: 'Semua'), Tab(text: 'Aktif'), Tab(text: 'Riwayat')],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, List<Borrowing> allBorrowings) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user?.role == 'students') return const SizedBox(height: 20);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() {}),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari peminjam atau barang...',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('Status', _selectedFilterStatus ?? 'Semua', () => _showStatusFilter(context)),
                const SizedBox(width: 10),
                _buildFilterChip('Kelas', _selectedFilterClass ?? 'Semua Kelas', () => _showClassFilter(context)),
                const SizedBox(width: 10),
                _buildFilterChip('Jurusan', _selectedFilterJurusan ?? 'Semua Jurusan', () => _showJurusanFilter(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Text('$label: ', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
            Text(value, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildTabList(BuildContext context, String mode, BorrowingProvider provider) {
    final authProvider = context.read<AuthProvider>();
    final role = authProvider.user?.role;
    final officerJurusan = (authProvider.user?.jurusan ?? '').toLowerCase().trim();

    List<Borrowing> borrowings = _filterBorrowings(provider.borrowings, role, officerJurusan);

    if (mode == 'active') {
      borrowings = borrowings.where((b) => ['pending', 'approved', 'partially_approved', 'partially_returned'].contains(b.status.toLowerCase())).toList();
    } else if (mode == 'completed') {
      borrowings = borrowings.where((b) => ['returned', 'rejected'].contains(b.status.toLowerCase())).toList();
    }

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    }

    if (borrowings.isEmpty) {
      return _buildEmptyState(mode);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: borrowings.length,
      itemBuilder: (context, index) => BorrowingCardPremium(
        borrowing: borrowings[index],
        userRole: role,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BorrowingDetailScreen(borrowing: borrowings[index]))),
      ),
    );
  }

  Widget _buildEmptyState(String mode) {
    String msg = 'Belum ada catatan aktivitas.';
    if (mode == 'active') msg = 'Tidak ada peminjaman aktif.';
    if (mode == 'completed') msg = 'Belum ada riwayat selesai.';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Text(msg, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  void _showStatusFilter(BuildContext context) {
    _showFilterDialog('Status Transaksi', [null, 'pending', 'approved', 'returned', 'rejected'], (v) => _selectedFilterStatus = v);
  }

  void _showClassFilter(BuildContext context) {
    final classes = context.read<ClassProvider>().classes.map((c) => c.name).toList();
    _showFilterDialog('Filter Kelas', [null, ...classes], (v) => _selectedFilterClass = v);
  }

  void _showJurusanFilter(BuildContext context) {
    _showFilterDialog('Filter Jurusan', [null, 'RPL', 'TKJ', 'DKV', 'MM'], (v) => _selectedFilterJurusan = v);
  }

  void _showFilterDialog(String title, List<String?> options, Function(String?) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(options[index] ?? 'Semua', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {
                    setState(() => onSelect(options[index]));
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BorrowingCardPremium extends StatelessWidget {
  final Borrowing borrowing;
  final String? userRole;
  final VoidCallback onTap;

  const BorrowingCardPremium({super.key, required this.borrowing, required this.userRole, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(borrowing.studentName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(borrowing.studentClassName, style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(borrowing.status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoTag(Icons.calendar_today_rounded, DateFormat('dd MMM yyyy').format(borrowing.borrowDate)),
                      const SizedBox(width: 12),
                      _buildInfoTag(Icons.inventory_2_outlined, '${borrowing.items.length} Aset'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
              child: Row(
                children: [
                  Text('Lihat Detail', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primaryBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppTheme.primaryBlue.withValues(alpha: 0.1), const Color(0xFF2563EB).withValues(alpha: 0.05)]),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          borrowing.studentName[0].toUpperCase(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    IconData icon = Icons.info_outline;
    String text = 'UNKNOWN';

    switch (status.toLowerCase()) {
      case 'pending': color = const Color(0xFFF59E0B); icon = Icons.timer_outlined; text = 'MENUNGGU'; break;
      case 'approved': color = const Color(0xFF10B981); icon = Icons.check_circle_outline_rounded; text = 'DISETUJUI'; break;
      case 'returned': color = AppTheme.primaryBlue; icon = Icons.assignment_turned_in_outlined; text = 'KEMBALI'; break;
      case 'rejected': color = const Color(0xFFEF4444); icon = Icons.cancel_outlined; text = 'DITOLAK'; break;
      case 'partially_returned': color = const Color(0xFF0D9488); icon = Icons.published_with_changes_rounded; text = 'SEBAGIAN KEMBALI'; break;
      case 'partially_approved': color = const Color(0xFF6366F1); icon = Icons.check_circle_outline_rounded; text = 'DISETUJUI SEBAGIAN'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
