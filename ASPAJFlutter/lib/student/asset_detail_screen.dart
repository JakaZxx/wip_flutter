import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/commodity_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/borrowing_provider.dart';
import '../models/commodity.dart';
import '../screens/edit_asset_screen.dart';
import '../theme/app_theme.dart';

class AssetDetailScreen extends StatefulWidget {
  final Commodity commodity;

  const AssetDetailScreen({super.key, required this.commodity});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late Commodity _commodity;

  @override
  void initState() {
    super.initState();
    _commodity = widget.commodity;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCommodityDetail());
  }

  Future<void> _loadCommodityDetail() async {
    try {
      final detail = await context.read<CommodityProvider>().getCommodityDetail(_commodity.id);
      if (detail != null && mounted) {
        setState(() => _commodity = detail);
      }
    } catch (e) {
      if (mounted) {
        _showError('Connection failed: $e');
      }
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppTheme.dangerRed, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.user?.role;
    final isAuthorized = userRole == 'admin' || userRole == 'officers';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroHeader(context, isAuthorized),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildMainIdentity(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('SPESIFIKASI TEKNIS'),
                  const SizedBox(height: 12),
                  _buildSpecificationGrid(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('DESKRIPSI ASET'),
                  const SizedBox(height: 12),
                  _buildDescriptionCard(),
                  const SizedBox(height: 32),
                  _buildSystemInfo(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context, userRole),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isAuthorized) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: isAuthorized ? [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
            onPressed: () => _navigateToEdit(),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ),
      ] : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _commodity.fixedPhotoUrl != null
                ? Image.network(_commodity.fixedPhotoUrl!, fit: BoxFit.cover)
                : Container(
                    decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                    child: const Center(child: Opacity(opacity: 0.2, child: FaIcon(FontAwesomeIcons.toolbox, size: 120, color: Colors.white))),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(10)),
                    child: Text(_commodity.code ?? 'CODE: N/A', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      _commodity.name,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 28, color: Colors.white, height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainIdentity() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori Aset', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.5)),
              const SizedBox(height: 2),
              Text(_commodity.jurusan ?? 'Umum', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _commodity.stock > 0 ? const Color(0xFF10B981).withValues(alpha: 0.1) : AppTheme.dangerRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2_rounded, size: 14, color: _commodity.stock > 0 ? const Color(0xFF10B981) : AppTheme.dangerRed),
              const SizedBox(width: 8),
              Text(
                _commodity.stock > 0 ? '${_commodity.stock} TERSEDIA' : 'STOK HABIS',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11, color: _commodity.stock > 0 ? const Color(0xFF10B981) : AppTheme.dangerRed),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatItem(Icons.location_on_rounded, 'LOKASI', _commodity.lokasi ?? 'N/A')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(Icons.auto_awesome_rounded, 'MERK', _commodity.merk ?? 'Standar')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(Icons.history_rounded, 'TAHUN', _commodity.tahun?.toString() ?? 'N/A')),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: const Color(0xFF475569)));
  }

  Widget _buildSpecificationGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _buildSpecRow('Kode Serial', _commodity.code ?? '-'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildSpecRow('Asal / Sumber', _commodity.sumber ?? 'Dana Sekolah'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildSpecRow('Status Aset', _commodity.stock > 0 ? 'Berfungsi Baik' : 'Butuh Perbaikan'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Text(
        _commodity.deskripsi ?? 'Tidak ada deskripsi tambahan untuk aset ini.',
        style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: const Color(0xFF475569)),
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSystemTimestamp('TERDAFTAR', _commodity.createdAt),
          _buildSystemTimestamp('SYNC TERAKHIR', _commodity.updatedAt),
        ],
      ),
    );
  }

  Widget _buildSystemTimestamp(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(DateFormat('dd/MM/yyyy • HH:mm').format(date), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, String? role) {
    if (role != 'students') return const SizedBox.shrink();

    return Consumer<BorrowingProvider>(
      builder: (context, bp, child) {
        final isInCart = bp.cartItems.any((item) => item.commodityId == _commodity.id);
        
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _commodity.stock > 0 ? () => _showAddToCartDialog(context) : null,
              icon: Icon(isInCart ? Icons.check_circle_rounded : Icons.shopping_bag_rounded, color: Colors.white),
              label: Text(
                isInCart ? 'DALAM KERANJANG' : (_commodity.stock > 0 ? 'PINJAM ASET' : 'TIDAK TERSEDIA'),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isInCart ? const Color(0xFF10B981) : (_commodity.stock > 0 ? AppTheme.primaryBlue : const Color(0xFFCBD5E1)),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: (isInCart ? const Color(0xFF10B981) : AppTheme.primaryBlue).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToEdit() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditAssetScreen(commodity: _commodity))).then((_) => _loadCommodityDetail());
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus Aset', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Konfirmasi penghapusan permanen "${_commodity.name}" dari sistem?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('BATAL', style: GoogleFonts.outfit(color: const Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCommodity();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('HAPUS', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCommodity() async {
    try {
      await context.read<CommodityProvider>().deleteCommodity(_commodity.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aset berhasil dihapus.'), backgroundColor: AppTheme.dangerRed, behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showAddToCartDialog(BuildContext context) {
    int quantity = 1;
    String? condition = 'good';
    final descC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Text('Pengajuan Pinjaman', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
              Text('Tentukan jumlah dan kondisi barang', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B))),
              const SizedBox(height: 32),
              
              Text('JUMLAH', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 2)),
              const SizedBox(height: 12),
              Row(
                children: [
                   _buildQtyBtn(Icons.remove, () => quantity > 1 ? setModalState(() => quantity--) : null),
                   Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('$quantity', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold))),
                   _buildQtyBtn(Icons.add, () => quantity < _commodity.stock ? setModalState(() => quantity++) : null),
                   const Spacer(),
                   Text('MAX: ${_commodity.stock}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ],
              ),
              const SizedBox(height: 32),
 
              Text('KONDISI BARANG', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 2)),
              const SizedBox(height: 12),
              _buildConditionSelector(condition, (v) => setModalState(() => condition = v)),
              const SizedBox(height: 32),

              _buildInputField('CATATAN TAMBAHAN', descC),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<BorrowingProvider>().addToCart(_commodity.id, quantity, condition: condition, description: descC.text);
                    Navigator.pop(context);
                    _showSuccessSnack('Barang dimasukkan ke keranjang.');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text('KONFIRMASI PILIHAN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
      ),
    );
  }

  Widget _buildConditionSelector(String? current, Function(String) onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['good', 'fair', 'poor'].map((c) {
          final isSelected = current == c;
          String label = c.toUpperCase();
          if (c == 'good') label = 'BAIK';
          if (c == 'fair') label = 'RUSAK RINGAN';
          if (c == 'poor') label = 'RUSAK BERAT';
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF64748B))),
              selected: isSelected,
              onSelected: (_) => onSelect(c),
              selectedColor: AppTheme.primaryBlue,
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 2)),
        const SizedBox(height: 12),
        TextField(
          controller: c,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Permintaan khusus (opsional)...',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _showSuccessSnack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating));
  }
}

