import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'return_screen.dart';
import '../models/borrowing.dart';
import '../models/borrowing_item.dart';
import '../models/commodity.dart';
import '../providers/borrowing_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'return_item_screen.dart';

class BorrowingDetailScreen extends StatefulWidget {
  final Borrowing borrowing;

  const BorrowingDetailScreen({super.key, required this.borrowing});

  @override
  State<BorrowingDetailScreen> createState() => _BorrowingDetailScreenState();
}

class _BorrowingDetailScreenState extends State<BorrowingDetailScreen> {
  late Borrowing _borrowing;
  bool _isLoadingCommodities = false;
  final Set<int> _selectedItemIds = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _borrowing = widget.borrowing;
    _fetchMissingCommodities();
  }

  Future<void> _fetchMissingCommodities() async {
    final itemsWithoutCommodity = _borrowing.items.where((item) => item.commodity == null).toList();
    if (itemsWithoutCommodity.isEmpty) return;

    setState(() => _isLoadingCommodities = true);

    try {
      final updatedItems = <BorrowingItem>[];
      for (final item in _borrowing.items) {
        if (item.commodity != null) {
          updatedItems.add(item);
        } else {
          final commodity = await ApiService().getCommodityDetail(item.commodityId);
          updatedItems.add(item.copyWith(commodity: commodity));
        }
      }

      setState(() {
        _borrowing = _borrowing.copyWith(items: updatedItems);
        _isLoadingCommodities = false;
      });
    } catch (e) {
      debugPrint('Error fetching commodity details: $e');
      if (mounted) setState(() => _isLoadingCommodities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final borrowingProvider = context.watch<BorrowingProvider>();
    final userRole = authProvider.user?.role;
    final userJurusan = authProvider.user?.jurusan?.toLowerCase();
    
    // Sync with provider state
    final borrowing = borrowingProvider.borrowings.firstWhere(
      (b) => b.id == widget.borrowing.id,
      orElse: () => _borrowing,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(borrowing),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildStatusTimeline(borrowing),
                  const SizedBox(height: 24),
                  _buildParticipantCard(borrowing),
                  const SizedBox(height: 24),
                  _buildRequestDetailsCard(borrowing),
                  const SizedBox(height: 32),
                  _buildSectionHeader('DAFTAR BARANG', '${borrowing.items.length} Barang'),
                  const SizedBox(height: 16),
                  if (_isLoadingCommodities)
                    _buildLoadingState()
                  else
                    ...borrowing.items.map((item) => _buildItemCard(context, item, userRole, userJurusan, borrowing)),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildActionZone(context, borrowing, userRole, userJurusan),
    );
  }

  Widget _buildSliverAppBar(Borrowing borrowing) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              const Positioned(
                right: -40,
                top: -40,
                child: Opacity(
                  opacity: 0.1,
                  child: FaIcon(FontAwesomeIcons.fileSignature, size: 280, color: Colors.white),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.inventory_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PENGAJUAN #${borrowing.id}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(borrowing.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.white;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; return _buildStatusBadgeUI('MENUNGGU', color);
      case 'approved': color = const Color(0xFF10B981); return _buildStatusBadgeUI('DISETUJUI', color);
      case 'partial':
      case 'partially_approved': color = const Color(0xFF6366F1); return _buildStatusBadgeUI('DISETUJUI SEBAGIAN', color);
      case 'partially_returned': color = const Color(0xFF0D9488); return _buildStatusBadgeUI('SEBAGIAN KEMBALI', color);
      case 'returned': color = Colors.blue; return _buildStatusBadgeUI('DIKEMBALIKAN', color);
      case 'rejected': color = Colors.red; return _buildStatusBadgeUI('DITOLAK', color);
      default: return _buildStatusBadgeUI(status.toUpperCase(), color);
    }
  }

  Widget _buildStatusBadgeUI(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: color, letterSpacing: 1),
      ),
    );
  }

  Widget _buildStatusTimeline(Borrowing borrowing) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep('Diajukan', true, true),
              _buildTimelineConnector(borrowing.status != 'pending'),
              _buildTimelineStep('Disetujui', ['approved', 'returned', 'partially_returned', 'partially_approved', 'partial'].contains(borrowing.status.toLowerCase()), borrowing.status != 'rejected'),
              _buildTimelineConnector(borrowing.status == 'returned'),
              _buildTimelineStep('Kembali', borrowing.status == 'returned', true),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getTimelineDescription(borrowing),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isDone, bool isNormal) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone ? (isNormal ? const Color(0xFF10B981) : Colors.red) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? (isNormal ? Icons.check : Icons.close) : Icons.circle,
            size: 14,
            color: isDone ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: isDone ? Colors.black : const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildTimelineConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
      ),
    );
  }

  String _getTimelineDescription(Borrowing b) {
    if (b.status == 'pending') return 'Permintaan Anda sedang menunggu persetujuan petugas.';
    if (b.status == 'rejected') return 'Permintaan ini ditolak. Silakan hubungi administrasi.';
    if (['approved', 'partially_approved', 'partial', 'partially_returned'].contains(b.status.toLowerCase())) {
      return 'Terverifikasi! Barang siap digunakan atau sedang dalam masa peminjaman.';
    }
    if (b.status == 'returned') return 'Selesai. Semua barang telah dikembalikan dan divalidasi.';
    return 'Memproses transaksi...';
  }

  Widget _buildParticipantCard(Borrowing borrowing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, Color(0xFFFAFBFF)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: borrowing.student?.user?.profilePictureUrl != null
                  ? Image.network(
                      ApiService.fixPhotoUrl(borrowing.student!.user!.profilePictureUrl)!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          borrowing.studentName[0].toUpperCase(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        borrowing.studentName[0].toUpperCase(),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(borrowing.studentName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(borrowing.studentClassName, style: GoogleFonts.poppins(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetailsCard(Borrowing b) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.history_edu_rounded, 'TUJUAN', b.tujuan ?? 'Tidak ada keterangan tujuan', isLongText: true),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              Expanded(child: _buildTimeDetail('PENGAMBILAN', b.borrowDate, b.borrowTime)),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9), margin: const EdgeInsets.symmetric(horizontal: 16)),
              Expanded(child: _buildTimeDetail('ESTIMASI KEMBALI', b.returnDate, b.returnTime)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail(String label, DateTime? date, String? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(date != null ? DateFormat('dd MMM yyyy').format(date) : '-', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
        if (time != null) Text(time, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLongText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                  height: isLongText ? 1.5 : 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: const Color(0xFF475569))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(badge, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryBlue)),
        ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, BorrowingItem item, String? role, String? userJurusan, Borrowing borrowing) {
    final isPending = (item.status ?? '').toLowerCase() == 'pending';
    final isSelected = _selectedItemIds.contains(item.id);
    
    final itemJurusan = item.commodity?.jurusan?.toLowerCase().trim();
    final isOfficerForJurusan = role == 'officers' && 
        (itemJurusan == userJurusan || itemJurusan == 'semua' || itemJurusan == null);
    final canProcess = (isOfficerForJurusan || role == 'admin') && isPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white, width: 2),
      ),
      child: InkWell(
        onTap: canProcess ? () => _toggleSelection(item.id!) : null,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildItemThumbnail(item.commodity),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.commodityName ?? 'Unknown Asset', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.tag, size: 10, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(item.commodity?.code ?? 'N/A', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                            const SizedBox(width: 12),
                            const Icon(Icons.inventory_2_outlined, size: 10, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text('Qty: ${item.quantity}', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSmallStatusBadge(item.status),
                ],
              ),
              if (canProcess) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (item.status == 'pending') ...[
                      Expanded(
                        child: _buildItemControlButton(
                          'TOLAK',
                          Icons.close_rounded,
                          const Color(0xFFEF4444),
                          () => _processBulkAction(context, borrowing, 'reject', singleItemId: item.id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildItemControlButton(
                          'SETUJUI',
                          Icons.check_rounded,
                          const Color(0xFF10B981),
                          () => _processBulkAction(context, borrowing, 'approve', singleItemId: item.id),
                        ),
                      ),
                    ] else if (item.status == 'approved') ...[
                      Expanded(
                        child: _buildItemControlButton(
                          'KEMBALIKAN',
                          Icons.assignment_return_rounded,
                          AppTheme.primaryBlue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReturnScreen(
                                borrowing: borrowing,
                                initialSelectedItemIds: [item.id!],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (item.status == 'approved' && role == 'students') ...[
                const SizedBox(height: 16),
                _buildActionButton('KEMBALIKAN BARANG', Icons.assignment_return_rounded, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReturnItemScreen(item: item)));
                }),
              ],
              if (item.status == 'returned') _buildReturnInfo(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemThumbnail(Commodity? c) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
      child: c?.fixedPhotoUrl != null
          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(c!.fixedPhotoUrl!, fit: BoxFit.cover))
          : const Icon(Icons.inventory_2_rounded, color: Color(0xFFCBD5E1)),
    );
  }

  Widget _buildSmallStatusBadge(String? status) {
    Color color = const Color(0xFF94A3B8);
    String label = status?.toUpperCase() ?? 'N/A';
    switch (status?.toLowerCase()) {
      case 'approved': color = const Color(0xFF10B981); label = 'DISETUJUI'; break;
      case 'rejected': color = const Color(0xFFEF4444); label = 'DITOLAK'; break;
      case 'returned': color = AppTheme.primaryBlue; label = 'KEMBALI'; break;
      case 'pending': color = Colors.orange; label = 'MENUNGGU'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: color)),
    );
  }

  Widget _buildReturnInfo(BorrowingItem item) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dikembalikan dalam kondisi ${item.returnCondition ?? "Baik"}.',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF0369A1)),
            ),
          ),
          if (item.returnPhotoUrl != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _showPhotoDialog(context, item.returnPhotoUrl!),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('LIHAT', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
            ),
          ],
        ],
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                ApiService.fixPhotoUrl(url)!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image_rounded, size: 64, color: AppTheme.dangerRed),
                      const SizedBox(height: 16),
                      Text('Image not found', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(ApiService.fixPhotoUrl(url) ?? 'Invalid URL', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionZone(BuildContext context, Borrowing b, String? role, String? userJurusan) {
    if (role == 'students') return const SizedBox.shrink();
    
    final hasPending = b.items.any((i) {
      final isPending = i.status == 'pending';
      final itemJurusan = i.commodity?.jurusan?.toLowerCase().trim();
      final isOfficerForJurusan = role == 'officers' && 
          (itemJurusan == userJurusan || itemJurusan == 'semua' || itemJurusan == null);
      return isPending && (isOfficerForJurusan || role == 'admin');
    });

    final hasApproved = b.items.any((i) {
      final isApproved = i.status == 'approved';
      final itemJurusan = i.commodity?.jurusan?.toLowerCase().trim();
      final isOfficerForJurusan = role == 'officers' && 
          (itemJurusan == userJurusan || itemJurusan == 'semua' || itemJurusan == null);
      return isApproved && (isOfficerForJurusan || role == 'admin');
    });

    if (!hasPending && !hasApproved) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasPending)
                  Row(
                    children: [
                      Expanded(
                        child: _buildBulkActionBtn('TOLAK', Icons.close_rounded, const Color(0xFFEF4444), () => _processBulkAction(context, b, 'reject')),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildBulkActionBtn('SETUJUI TERPILIH', Icons.check_rounded, const Color(0xFF10B981), () => _processBulkAction(context, b, 'approve')),
                      ),
                    ],
                  ),
                if (hasPending && hasApproved) const SizedBox(height: 12),
                if (hasApproved)
                  SizedBox(
                    width: double.infinity,
                    child: _buildBulkActionBtn(
                      'KEMBALIKAN TERPILIH', 
                      Icons.assignment_return_rounded, 
                      AppTheme.primaryBlue, 
                      () {
                        final targets = _selectedItemIds.isEmpty 
                          ? b.items.where((i) {
                              final isApproved = i.status == 'approved';
                              final itemJurusan = i.commodity?.jurusan?.toLowerCase().trim();
                              final isOfficerForJurusan = role == 'officers' && 
                                  (itemJurusan == userJurusan || itemJurusan == 'semua' || itemJurusan == null);
                              return isApproved && (isOfficerForJurusan || role == 'admin');
                            }).map((i) => i.id!).toList()
                          : _selectedItemIds.toList();
                        
                        if (targets.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih barang yang sudah disetujui')));
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReturnScreen(
                              borrowing: b,
                              initialSelectedItemIds: targets,
                            ),
                          ),
                        ).then((_) => setState(() {})); // Refresh on return
                      }
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildBulkActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: color.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildItemControlButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  Future<void> _processBulkAction(BuildContext context, Borrowing b, String action, {int? singleItemId}) async {
    final authProvider = context.read<AuthProvider>();
    final role = authProvider.user?.role;
    final userJurusan = authProvider.user?.jurusan?.toLowerCase();

    final targets = singleItemId != null 
        ? [singleItemId] 
        : (_selectedItemIds.isEmpty 
            ? b.items.where((i) {
                final isPending = (i.status ?? '').toLowerCase() == 'pending';
                final itemJurusan = i.commodity?.jurusan?.toLowerCase().trim();
                final isOfficerForJurusan = role == 'officers' && 
                    (itemJurusan == userJurusan || itemJurusan == 'semua' || itemJurusan == null);
                return isPending && (isOfficerForJurusan || role == 'admin');
              }).map((i) => i.id!).toList() 
            : _selectedItemIds.toList());
    
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih Barang untuk Diproses.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      final provider = context.read<BorrowingProvider>();
      if (action == 'approve') {
        await provider.approveBorrowingItems(b.id, targets);
      } else {
        await provider.rejectBorrowingItems(b.id, targets);
      }
      
      setState(() {
        _selectedItemIds.clear();
        _isProcessing = false;
      });
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil memproses ${targets.length} barang.'), backgroundColor: const Color(0xFF10B981)),
      );
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildLoadingState() {
    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.primaryBlue)));
  }
}

