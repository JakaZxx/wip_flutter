import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Tambahkan ini
import 'package:http/http.dart' as http; // Tambahkan ini
import '../providers/commodity_provider.dart';
import '../providers/borrowing_provider.dart';
import '../providers/auth_provider.dart';
import '../models/commodity.dart';
import 'add_asset_screen.dart';
import 'edit_asset_screen.dart';
import 'asset_detail_screen.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    print('AssetsScreen.initState: Initializing assets screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('AssetsScreen.initState: Post frame callback, fetching commodities');
      // Load cart data first to ensure it's fresh
      context.read<BorrowingProvider>().loadCart();
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user?.role == 'officers') {
        // For officers, fetch only commodities from their jurusan
        context.read<CommodityProvider>().fetchCommodities(jurusan: user?.jurusan);
      } else {
        // For admin, fetch all commodities
        context.read<CommodityProvider>().fetchCommodities();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdminOrOfficer = authProvider.user?.isAdmin == true || authProvider.user?.isOfficer == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdminOrOfficer ? 'Kelola Unit Kerja' : 'Assets'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: isAdminOrOfficer ? _buildManagementView() : _buildBorrowingView(),
      floatingActionButton: isAdminOrOfficer ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAssetScreen()),
          ).then((_) => context.read<CommodityProvider>().fetchCommodities());
        },
        tooltip: 'Tambah Barang',
        child: const Icon(Icons.add),
      ) : Consumer<BorrowingProvider>(
        builder: (context, borrowingProvider, child) {
          final cartItemCount = borrowingProvider.cartItems.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                onPressed: () => Navigator.of(context).pushNamed('/borrowing-create'),
                tooltip: 'Create New Borrowing',
                child: const Icon(Icons.shopping_cart),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildManagementView() {
    final authProvider = context.watch<AuthProvider>();
    return Column(
      children: [
        // Action Buttons
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddAssetScreen()),
                  ).then((_) => context.read<CommodityProvider>().fetchCommodities());
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Barang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Show import dialog
                },
                icon: const Icon(Icons.upload),
                label: const Text('Import Barang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

            ],
          ),
        ),

        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama / kode barang',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      onChanged: (value) {
                        context.read<CommodityProvider>().searchCommodities(value);
                      },
                    ),
                  ),
                  if (authProvider.user?.isAdmin == true) ...[
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('Semua Jurusan')),
                        DropdownMenuItem(value: 'Teknik Instalasi Tenaga Listrik', child: Text('Teknik Instalasi Tenaga Listrik')),
                        DropdownMenuItem(value: 'Teknik Audio Video', child: Text('Teknik Audio Video')),
                        DropdownMenuItem(value: 'Teknik Otomasi Industri', child: Text('Teknik Otomasi Industri')),
                        DropdownMenuItem(value: 'Teknik Komputer Jaringan', child: Text('Teknik Komputer Jaringan')),
                        DropdownMenuItem(value: 'Desain Komunikasi Visual', child: Text('Desain Komunikasi Visual')),
                        DropdownMenuItem(value: 'Rekayasa Perangkat Lunak', child: Text('Rekayasa Perangkat Lunak')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                        context.read<CommodityProvider>().fetchCommodities(jurusan: value == 'All' ? null : value);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Assets Grid
        Expanded(
          child: Consumer<CommodityProvider>(
            builder: (context, commodityProvider, child) {
              if (commodityProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (commodityProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${commodityProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => commodityProvider.fetchCommodities(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final commodities = commodityProvider.commodities;

              if (commodities.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Tidak ada aset yang ditemukan'),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: commodities.length,
                itemBuilder: (context, index) {
                  final commodity = commodities[index];
                  return ManagementAssetCard(commodity: commodity);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBorrowingView() {
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search assets...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                onChanged: (value) {
                  context.read<CommodityProvider>().searchCommodities(value);
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == 'All',
                      onSelected: (selected) {
                        setState(() => _selectedCategory = 'All');
                        context.read<CommodityProvider>().fetchCommodities();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Available'),
                      selected: _selectedCategory == 'Available',
                      onSelected: (selected) {
                        setState(() => _selectedCategory = 'Available');
                        context.read<CommodityProvider>().fetchCommodities(jurusan: 'available');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Borrowed'),
                      selected: _selectedCategory == 'Borrowed',
                      onSelected: (selected) {
                        setState(() => _selectedCategory = 'Borrowed');
                        context.read<CommodityProvider>().fetchCommodities(jurusan: 'borrowed');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Assets List
        Expanded(
          child: Consumer<CommodityProvider>(
            builder: (context, commodityProvider, child) {
              if (commodityProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (commodityProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${commodityProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => commodityProvider.fetchCommodities(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final commodities = commodityProvider.commodities;

              if (commodities.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No assets found'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                key: const PageStorageKey('assets_list'),
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: commodities.length,
                itemBuilder: (context, index) {
                  final commodity = commodities[index];
                  return AssetCard(commodity: commodity);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class AssetCard extends StatelessWidget {
  final Commodity commodity;

  const AssetCard({super.key, required this.commodity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(commodity: commodity),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Asset Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: commodity.fixedPhotoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          commodity.fixedPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image for ${commodity.name}: $error, URL: ${commodity.photoUrl}');
                            _logHttpResponse(commodity.photoUrl); // Panggil fungsi baru untuk logging
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                Text(
                                  'Error loading image',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2,
                        size: 32,
                        color: Colors.grey,
                      ),
              ),

              const SizedBox(width: 16),

              // Asset Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commodity.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commodity.deskripsi ?? 'No description',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          commodity.jurusan ?? 'No department',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.inventory,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${commodity.stock} available',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add to Cart Button
              Consumer<BorrowingProvider>(
                builder: (context, borrowingProvider, child) {
                  final isInCart = borrowingProvider.cartItems
                      .any((item) => item.commodityId == commodity.id);

                  return IconButton(
                    onPressed: commodity.stock > 0
                        ? () async {
                            try {
                              print('AssetsScreen: Attempting to add ${commodity.name} (ID: ${commodity.id}) to cart');
                              await borrowingProvider.addToCart(commodity.id, 1);
                              print('AssetsScreen: Successfully added ${commodity.name} to cart');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${commodity.name} added to cart'),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/checkout');
                                    },
                                  ),
                                ),
                              );
                            } catch (e, stackTrace) {
                              print('AssetsScreen: Error adding ${commodity.name} to cart: $e');
                              print('AssetsScreen: Stack trace: $stackTrace');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding to cart: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    icon: Icon(
                      isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                      color: commodity.stock > 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context, Commodity commodity) {
    int quantity = 1;
    String? condition;
    String? description;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add ${commodity.name} to Cart'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () => setState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    quantity.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: quantity < commodity.stock
                        ? () => setState(() => quantity++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Condition Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                initialValue: condition,
                items: const [
                  DropdownMenuItem(value: 'good', child: Text('Good')),
                  DropdownMenuItem(value: 'fair', child: Text('Fair')),
                  DropdownMenuItem(value: 'poor', child: Text('Poor')),
                ],
                onChanged: (value) => setState(() => condition = value),
              ),

              const SizedBox(height: 16),

              // Description
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BorrowingProvider>().addToCart(
                      commodity.id,
                      quantity,
                      condition: condition,
                      description: description,
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${commodity.name} added to cart'),
                    action: SnackBarAction(
                      label: 'View Cart',
                      onPressed: () {
                        Navigator.of(context).pushNamed('/checkout');
                      },
                    ),
                  ),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManagementAssetCard extends StatelessWidget {
  final Commodity commodity;

  const ManagementAssetCard({super.key, required this.commodity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asset Image with Stock Badge
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: commodity.fixedPhotoUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          commodity.fixedPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image for ${commodity.name}: $error, URL: ${commodity.photoUrl}');
                            _logHttpResponse(commodity.photoUrl); // Panggil fungsi baru untuk logging
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                Text(
                                  'Error loading image',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: Colors.grey,
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: commodity.stock == 0
                        ? Colors.red
                        : commodity.stock <= 5
                            ? Colors.orange
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stok: ${commodity.stock}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Asset Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode: ${commodity.code ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        commodity.lokasi ?? 'N/A',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        commodity.jurusan ?? 'N/A',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (commodity.merk != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.copyright,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          commodity.merk!,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetDetailScreen(commodity: commodity),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Detail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAssetScreen(commodity: commodity),
                      ),
                    ).then((_) => context.read<CommodityProvider>().fetchCommodities());
                  },
                  icon: const Icon(Icons.edit),
                  color: Colors.orange,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus "${commodity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CommodityProvider>().deleteCommodity(commodity.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${commodity.name} berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Tambahkan fungsi ini di luar build method, di dalam class _AssetsScreenState
Future<void> _logHttpResponse(String? imageUrl) async {
  if (imageUrl == null) return;
  try {
    final response = await http.get(Uri.parse(imageUrl));
    print('HTTP Response for image URL: $imageUrl');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    // Hanya cetak body jika status bukan 200 OK atau jika body kecil
    if (response.statusCode != 200 || response.bodyBytes.length < 1000) {
      print('Body (first 500 chars): ${response.body.substring(0, min(response.body.length, 500))}');
    } else {
      print('Body is large, not printing full content.');
    }
  } catch (e) {
    print('Error during HTTP request for image: $e');
  }
}
