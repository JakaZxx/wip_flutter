import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/commodity_provider.dart';
import '../providers/auth_provider.dart'; // Added this import
import '../providers/borrowing_provider.dart';
import '../models/commodity.dart';
import 'edit_asset_screen.dart';

class AssetDetailScreen extends StatefulWidget {
  final Commodity commodity;

  const AssetDetailScreen({super.key, required this.commodity});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late Commodity _commodity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commodity = widget.commodity;
    // Schedule loading after first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCommodityDetail());
  }

  Future<void> _loadCommodityDetail() async {
    // Avoid calling setState synchronously during build/initState.
    _isLoading = true;
    try {
      final detail = await context.read<CommodityProvider>().getCommodityDetail(_commodity.id);
      if (detail != null && mounted) {
        setState(() => _commodity = detail);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading detail: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Unit Kerja'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userRole = authProvider.user?.role;
              if (userRole == 'admin' || userRole == 'officers') {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAssetScreen(commodity: _commodity),
                          ),
                        ).then((_) => _loadCommodityDetail());
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context),
                      tooltip: 'Hapus',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset Image
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: FutureBuilder<bool>(
                        future: Future(() async {
                          if (_commodity.fixedPhotoUrl == null) return false;
                          try {
                            print('Detail Screen - Trying to load image from: ${_commodity.fixedPhotoUrl}');
                            print('Detail Screen - Original photo URL: ${_commodity.photoUrl}');
                            
                            final response = await http.head(Uri.parse(_commodity.fixedPhotoUrl!));
                            return response.statusCode == 200;
                          } catch (e) {
                            print('Detail Screen - Pre-check error: $e');
                            return false;
                          }
                        }),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final bool imageExists = snapshot.data ?? false;
                          if (!imageExists || _commodity.fixedPhotoUrl == null) {
                            return const Icon(
                              Icons.inventory_2,
                              size: 64,
                              color: Colors.grey,
                            );
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _commodity.fixedPhotoUrl!,
                              fit: BoxFit.cover,
                              headers: const {
                                'Accept': '*/*',
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  print('Detail Screen - Image loaded successfully');
                                  return child;
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Detail Screen - Image Error: $error');
                                print('Detail Screen - Stack Trace: $stackTrace');
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error loading image',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information
                  _buildInfoCard(
                    'Informasi Dasar',
                    [
                      _buildInfoRow('Nama', _commodity.name),
                      _buildInfoRow('Kode', _commodity.code ?? 'N/A'),
                      _buildInfoRow('Stok', _commodity.stock.toString()),
                      _buildInfoRow('Jurusan', _commodity.jurusan ?? 'N/A'),
                      _buildInfoRow('Lokasi', _commodity.lokasi ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Information
                  _buildInfoCard(
                    'Informasi Tambahan',
                    [
                      if (_commodity.merk != null) _buildInfoRow('Merk', _commodity.merk!),
                      if (_commodity.sumber != null) _buildInfoRow('Sumber', _commodity.sumber!),
                      if (_commodity.tahun != null) _buildInfoRow('Tahun', _commodity.tahun.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (_commodity.deskripsi != null && _commodity.deskripsi!.isNotEmpty)
                    _buildInfoCard(
                      'Deskripsi',
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _commodity.deskripsi!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Timestamps
                  _buildInfoCard(
                    'Informasi Sistem',
                    [
                      _buildInfoRow('Dibuat', _formatDate(_commodity.createdAt)),
                      _buildInfoRow('Diubah', _formatDate(_commodity.updatedAt)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Add to Cart Button for Students
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final userRole = authProvider.user?.role;
                      if (userRole == 'students') {
                        return Consumer<BorrowingProvider>(
                          builder: (context, borrowingProvider, child) {
                            final isInCart = borrowingProvider.cartItems
                                .any((item) => item.commodityId == _commodity.id);

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _commodity.stock > 0
                                    ? () => _showAddToCartDialog(context)
                                    : null,
                                icon: Icon(
                                  isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                ),
                                label: Text(
                                  isInCart ? 'Sudah di Keranjang' : 'Tambah ke Keranjang',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _commodity.stock > 0
                                      ? (isInCart ? Colors.orange : Colors.green)
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus "${_commodity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _deleteCommodity();
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

  Future<void> _deleteCommodity() async {
    setState(() => _isLoading = true);
    try {
      await context.read<CommodityProvider>().deleteCommodity(_commodity.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_commodity.name} berhasil dihapus')),
        );
        Navigator.of(context).pop(); // Go back to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddToCartDialog(BuildContext context) {
    int quantity = 1;
    String? condition;
    String? description;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Tambah ${_commodity.name} ke Keranjang'),
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
                    onPressed: quantity < _commodity.stock
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
                  labelText: 'Kondisi',
                  border: OutlineInputBorder(),
                ),
                initialValue: condition,
                items: const [
                  DropdownMenuItem(value: 'good', child: Text('Baik')),
                  DropdownMenuItem(value: 'fair', child: Text('Cukup')),
                  DropdownMenuItem(value: 'poor', child: Text('Buruk')),
                ],
                onChanged: (value) => setState(() => condition = value),
              ),

              const SizedBox(height: 16),

              // Description
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
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
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BorrowingProvider>().addToCart(
                      _commodity.id,
                      quantity,
                      condition: condition,
                      description: description,
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_commodity.name} ditambahkan ke keranjang'),
                    action: SnackBarAction(
                      label: 'Lihat Keranjang',
                      onPressed: () {
                        // Navigate to cart screen (to be implemented)
                      },
                    ),
                  ),
                );
              },
              child: const Text('Tambah ke Keranjang'),
            ),
          ],
        ),
      ),
    );
  }
}
