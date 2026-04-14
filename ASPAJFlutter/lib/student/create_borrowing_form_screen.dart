
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/borrowing_provider.dart';
import '../providers/auth_provider.dart';
import '../models/borrowing_item.dart';

class CreateBorrowingFormScreen extends StatefulWidget {
  const CreateBorrowingFormScreen({super.key});

  @override
  State<CreateBorrowingFormScreen> createState() => _CreateBorrowingFormScreenState();
}

class _CreateBorrowingFormScreenState extends State<CreateBorrowingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _borrowDateController = TextEditingController();
  final TextEditingController _borrowTimeController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _returnTimeController = TextEditingController();

  DateTime? _borrowDate;
  TimeOfDay? _borrowTime;
  DateTime? _returnDate;
  TimeOfDay? _returnTime;

  @override
  void initState() {
    super.initState();
    debugPrint('CreateBorrowingFormScreen.initState: Initializing borrowing create screen');
    // Load cart data to ensure it's fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().loadCart();
    });

    // Set default dates and times
    _borrowDate = DateTime.now();
    _borrowTime = TimeOfDay.now();
    _returnDate = DateTime.now().add(const Duration(days: 7));
    _returnTime = TimeOfDay.now();

    // Format dates (times will be formatted in didChangeDependencies)
    _borrowDateController.text = DateFormat('yyyy-MM-dd').format(_borrowDate!);
    _returnDateController.text = DateFormat('yyyy-MM-dd').format(_returnDate!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Format times using the current context
    _borrowTimeController.text = _borrowTime?.format(context) ?? '';
    _returnTimeController.text = _returnTime?.format(context) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Permintaan Pinjam'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Consumer<BorrowingProvider>(
            builder: (context, borrowingProvider, child) {
              final cartItemCount = borrowingProvider.cartItemCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => _showCartDialog(context),
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
                  // Cart Items Section
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

                  // Borrowing Details Section
                  const Text(
                    'Detail Peminjaman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Purpose
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
                        return 'Tujuan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Borrow Date and Time
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _borrowDateController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Pinjam',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih tanggal pinjam';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _borrowTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Jam',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih jam';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Return Date and Time
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
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
                              return 'Pilih tanggal kembali';
                            }
                            if (_returnDate != null && _borrowDate != null &&
                                _returnDate!.isBefore(_borrowDate!)) {
                              return 'Tanggal kembali harus setelah tanggal pinjam';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _returnTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Jam',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, false),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih jam';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
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
                          : const Text('Kirim Pengajuan Pinjam'),
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
            'Keranjang Anda Kosong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan barang di layar Aset',
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

  void _showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<BorrowingProvider>(
        builder: (context, borrowingProvider, child) {
          return AlertDialog(
            title: const Text('Isi Keranjang'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: borrowingProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final item = borrowingProvider.cartItems[index];
                  return ListTile(
                    title: Text(item.displayName),
                    subtitle: Text('Jumlah: ${item.quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        borrowingProvider.removeFromCart(item.commodityId);
                        if (borrowingProvider.cartItems.isEmpty) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: borrowingProvider.cartItems.isNotEmpty
                    ? () => Navigator.of(context).pop()
                    : null,
                child: const Text('Lanjutkan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isBorrowTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBorrowTime ? _borrowTime ?? TimeOfDay.now() : _returnTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBorrowTime) {
          _borrowTime = picked;
          _borrowTimeController.text = picked.format(context);
        } else {
          _returnTime = picked;
          _returnTimeController.text = picked.format(context);
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
      'user_id': authProvider.user?.id,
      'tujuan': _purposeController.text,
      'borrow_date': _borrowDateController.text,
      'borrow_time': _borrowTimeController.text,
      'return_date': _returnDateController.text,
      'return_time': _returnTimeController.text,
      'status': 'pending',
      'items': borrowingProvider.cartItems.map((item) => {
        'commodity_id': item.commodityId,
        'quantity': item.quantity,
        'condition': item.condition,
        'description': item.description,
      }).toList(),
    };

    try {
      await borrowingProvider.createBorrowing(borrowingData);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan peminjaman berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Go back to previous screen
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim permintaan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _borrowDateController.dispose();
    _borrowTimeController.dispose();
    _returnDateController.dispose();
    _returnTimeController.dispose();
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
                  Text('Kondisi: ${item.condition ?? 'Tidak ditentukan'}'),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text('Deskripsi: ${item.description}'),
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

