import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/commodity_provider.dart';
import '../providers/borrowing_provider.dart';
import '../providers/auth_provider.dart';
import '../models/commodity.dart';
import '../screens/add_asset_screen.dart';
import '../screens/edit_asset_screen.dart';
import 'asset_detail_screen.dart';
import '../theme/app_theme.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().loadCart();
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user?.role == 'officers') {
      context.read<CommodityProvider>().fetchCommodities(jurusan: user?.jurusan);
    } else {
      context.read<CommodityProvider>().fetchCommodities();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAdminOrOfficer = user?.role == 'admin' || user?.role == 'officers';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isAdminOrOfficer),
          SliverToBoxAdapter(
            child: _buildSearchAndFilterHeader(isAdminOrOfficer),
          ),
          Consumer<CommodityProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                );
              }

              if (provider.error != null) {
                return SliverFillRemaining(
                  child: _buildErrorState(provider.error!),
                );
              }

              final filtered = provider.commodities.where((c) {
                if (_selectedCategory == 'All') return true;
                if (_selectedCategory == 'Tersedia') return c.stock > 0;
                if (_selectedCategory == 'Habis') return c.stock <= 0;
                return c.jurusan == _selectedCategory;
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: isAdminOrOfficer 
                  ? _buildManagementGrid(filtered)
                  : _buildBorrowingGrid(filtered),
              );
            },
          ),
        ],
      ),
      floatingActionButton: isAdminOrOfficer ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [AppTheme.primaryBlue, Color(0xFF2563EB)]),
          boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAssetScreen()),
            ).then((_) => _fetchInitialData());
          },
          label: Text('TAMBAH ASET', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          icon: const Icon(Icons.add_task_rounded),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ) : null,
    );
  }

  Widget _buildSliverAppBar(bool isAdminOrOfficer) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      leading: isAdminOrOfficer
        ? Builder(builder: (context) => IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ))
        : null,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          isAdminOrOfficer ? 'Inventaris Sekolah' : 'Katalog Peminjaman',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(Icons.inventory_2_outlined, size: 150, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (!isAdminOrOfficer) _buildCartBadge(),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildCartBadge() {
    return Consumer<BorrowingProvider>(
      builder: (context, provider, child) {
        final count = provider.cartItems.length;
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/checkout'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryBlue, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Center(
                        child: Text(
                          '$count',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilterHeader(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => context.read<CommodityProvider>().searchCommodities(v),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari aset / kode barang...',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCategoryChips(isAdmin),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(bool isAdmin) {
    final categories = isAdmin 
      ? ['All', 'RPL', 'TKJ', 'DKV', 'TOI', 'TITL', 'TAV']
      : ['All', 'Tersedia', 'Habis', 'RPL', 'TKJ'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected 
                    ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
                  border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.poppins(
                    fontSize: 12, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManagementGrid(List<Commodity> commodities) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => ManagementAssetCardPremium(commodity: commodities[index], onRefresh: _fetchInitialData),
        childCount: commodities.length,
      ),
    );
  }

  Widget _buildBorrowingGrid(List<Commodity> commodities) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => BorrowingAssetCardPremium(commodity: commodities[index]),
        childCount: commodities.length,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
          ),
          const SizedBox(height: 20),
          Text('Waduh, ada masalah!', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Coba Lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Text('Aset Tidak Ditemukan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          Text('Coba kata kunci lain atau filter yang berbeda.', style: GoogleFonts.poppins(color: const Color(0xFFCBD5E1))),
        ],
      ),
    );
  }
}

class ManagementAssetCardPremium extends StatelessWidget {
  final Commodity commodity;
  final VoidCallback onRefresh;
  const ManagementAssetCardPremium({super.key, required this.commodity, required this.onRefresh});

  void _handleDelete(BuildContext context) async {
    final provider = context.read<CommodityProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Aset', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Anda yakin ingin menghapus ${commodity.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await provider.deleteCommodity(commodity.id);
        onRefresh();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: SizedBox(
                    width: double.infinity,
                    child: commodity.fixedPhotoUrl != null
                        ? Image.network(commodity.fixedPhotoUrl!, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _buildMiniAction(Icons.edit_rounded, Colors.orange, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditAssetScreen(commodity: commodity)),
                        ).then((_) => onRefresh());
                      }),
                      const SizedBox(width: 4),
                      _buildMiniAction(Icons.delete_outline_rounded, Colors.red, () => _handleDelete(context)),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      commodity.code ?? 'NO-CODE',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stok: ${commodity.stock}',
                      style: GoogleFonts.outfit(
                        fontSize: 11, 
                        fontWeight: FontWeight.bold,
                        color: commodity.stock > 0 ? const Color(0xFF10B981) : Colors.red,
                      ),
                    ),
                    Text(
                      commodity.jurusan ?? 'Semua',
                      style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class BorrowingAssetCardPremium extends StatelessWidget {
  final Commodity commodity;
  const BorrowingAssetCardPremium({super.key, required this.commodity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => AssetDetailScreen(commodity: commodity))
        ),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SizedBox(
                      width: double.infinity,
                      child: commodity.fixedPhotoUrl != null
                          ? Image.network(commodity.fixedPhotoUrl!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                            ),
                    ),
                  ),
                  if (commodity.stock <= 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                          child: Text('HABIS', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                      child: Icon(Icons.favorite_border_rounded, size: 18, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commodity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    commodity.lokasi ?? 'Lokasi tidak diatur',
                    style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${commodity.stock} Item',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      _buildAddButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final borrows = context.watch<BorrowingProvider>();
    final isInCart = borrows.cartItems.any((item) => item.commodityId == commodity.id);

    return InkWell(
      onTap: commodity.stock > 0 ? () {
        if (!isInCart) {
          borrows.addToCart(commodity.id, 1);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${commodity.name} ditambahkan ke keranjang'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32, // Added fixed size for better alignment
        height: 32,
        decoration: BoxDecoration(
          color: isInCart ? const Color(0xFF10B981) : (commodity.stock > 0 ? AppTheme.primaryBlue : Colors.grey[200]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            isInCart ? Icons.check_rounded : Icons.add_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

