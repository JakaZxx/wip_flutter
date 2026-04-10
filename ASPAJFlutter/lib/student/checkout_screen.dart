import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/borrowing_provider.dart';
import '../providers/auth_provider.dart';
import '../models/borrowing_item.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _borrowDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();

  DateTime? _borrowDate;
  DateTime? _returnDate;

  @override
  void initState() {
    super.initState();
    // Load cart data to ensure it's fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().loadCart();
    });

    _borrowDate = DateTime.now();
    _borrowDateController.text = DateFormat('yyyy-MM-dd').format(_borrowDate!);
    _returnDate = DateTime.now().add(const Duration(days: 7));
    _returnDateController.text = DateFormat('yyyy-MM-dd').format(_returnDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<BorrowingProvider>(
            builder: (context, borrowingProvider, child) {
              final cartItemCount = borrowingProvider.cartItemCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/borrowing-create'),
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          cartItemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
        ],
      ),
      body: Consumer<BorrowingProvider>(
        builder: (context, borrowingProvider, child) {
          if (borrowingProvider.cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Barang yang Dipinjam',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...borrowingProvider.cartItems.map((item) => CartItemCard(
                        item: item,
                        onRemove: () => borrowingProvider.removeFromCart(item.commodityId),
                        onUpdateQuantity: (quantity) => borrowingProvider.updateCartItemQuantity(item.commodityId, quantity),
                      )),
                  const SizedBox(height: 24),
                  const Text(
                    'Detail Peminjaman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _purposeController,
                    decoration: const InputDecoration(
                      labelText: 'Tujuan',
                      hintText: 'Masukkan tujuan peminjaman',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan tujuan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _borrowDateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Peminjaman',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan pilih tanggal peminjaman';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _returnDateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pengembalian',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, false),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan pilih tanggal pengembalian';
                      }
                      if (_returnDate != null &&
                          _borrowDate != null &&
                          _returnDate!.isBefore(_borrowDate!)) {
                        return 'Tanggal pengembalian harus setelah tanggal peminjaman';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: borrowingProvider.isLoading
                          ? null
                          : () => _submitBorrowing(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: borrowingProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Kirim Permintaan Peminjaman'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Anda kosong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan barang dari halaman Aset',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/assets'),
            icon: const Icon(Icons.inventory),
            label: const Text('Jelajahi Aset'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isBorrowDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBorrowDate ? _borrowDate ?? DateTime.now() : _returnDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isBorrowDate) {
          _borrowDate = picked;
          _borrowDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _returnDate = picked;
          _returnDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _submitBorrowing(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final borrowingProvider = context.read<BorrowingProvider>();
    final authProvider = context.read<AuthProvider>();

    final borrowingData = {
      'borrow_date': _borrowDateController.text,
      'return_date': _returnDateController.text,
      'tujuan': _purposeController.text,
      'items': borrowingProvider.cartItems.map((item) => {
        'commodity_id': item.commodityId,
        'quantity': item.quantity,
      }).toList(),
    };

    try {
      await borrowingProvider.createBorrowing(borrowingData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan peminjaman berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim permintaan peminjaman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _borrowDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }
}

class CartItemCard extends StatelessWidget {
  final BorrowingItem item;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Condition: ${item.condition ?? 'Not specified'}'),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text('Description: ${item.description}'),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: item.quantity > 1
                      ? () => onUpdateQuantity(item.quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  item.quantity.toString(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => onUpdateQuantity(item.quantity + 1),
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
