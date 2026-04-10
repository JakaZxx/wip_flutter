import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/borrowing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../models/borrowing.dart';
import '../../models/borrowing_item.dart';
import '../../models/school_class.dart';
import '../../services/api_service.dart';
import 'borrowing_detail_screen.dart';
import 'return_item_screen.dart';

class BorrowingStatusScreen extends StatefulWidget {
  const BorrowingStatusScreen({super.key});

  @override
  State<BorrowingStatusScreen> createState() => _BorrowingStatusScreenState();
}

class _BorrowingStatusScreenState extends State<BorrowingStatusScreen> {
  final Set<int> _selectedItems = {};
  // bool _isApproving = false; // Removed unused field

  // Return dialog state
  String? _returnCondition;
  String _returnNotes = '';

  // Filter state
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilterStatus;
  String? _selectedFilterJurusan;
  String? _selectedFilterClass;

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

  @override
  void initState() {
    super.initState();

    // Fetch borrowings and classes when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().fetchBorrowings();
      context.read<ClassProvider>().fetchClasses();
    });
  }

  List<Borrowing> _filterBorrowings(
    List<Borrowing> borrowings,
    String? userRole,
    String officerJurusan,
  ) {
    // The backend should ideally filter borrowings for students based on the authenticated user.

    // The frontend will display whatever the backend returns.

    List<Borrowing> filtered = borrowings;

    // For officers, filter items based on jurusan
    if (userRole == 'officers' && officerJurusan.isNotEmpty) {
      filtered = filtered.where((borrowing) {
        return borrowing.items.any((item) => _itemMatchesJurusan(item, officerJurusan));
      }).toList();
      // Also filter the items within each borrowing
      filtered = filtered.map((borrowing) {
        final filteredItems = borrowing.items.where((item) => _itemMatchesJurusan(item, officerJurusan)).toList();
        return borrowing.copyWith(items: filteredItems);
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle_outline;
      case 'returned':
        return Icons.assignment_turned_in;
      default:
        return Icons.inventory_2;
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'pending':
        return 'No pending borrowing records found';
      case 'approved':
        return 'No approved borrowing records found';
      case 'returned':
        return 'No returned borrowing records found';
      default:
        return 'No borrowing records found';
    }
  }

  Future<void> _updateBorrowingStatus(int borrowingId, String status) async {
    try {
      await context.read<BorrowingProvider>().updateBorrowingStatus(
        borrowingId,
        status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Borrowing status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkApproveItems(Borrowing borrowing) async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select items to approve'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // setState(() => _isApproving = true); // Removed unused

    try {
      await context.read<BorrowingProvider>().approveBorrowingItems(
        borrowing.id,
        _selectedItems.toList(),
      );
      setState(() => _selectedItems.clear());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected items approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // setState(() => _isApproving = false); // Removed unused
    }
  }

  Future<void> _bulkRejectItems(Borrowing borrowing) async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select items to reject'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // setState(() => _isApproving = true); // Removed unused

    try {
      await context.read<BorrowingProvider>().rejectBorrowingItems(
        borrowing.id,
        _selectedItems.toList(),
      );
      setState(() => _selectedItems.clear());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected items rejected successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // setState(() => _isApproving = false); // Removed unused
    }
  }

  void _showReturnDialog(BuildContext context, Borrowing borrowing) {
    final _formKey = GlobalKey<FormState>();
    String? selectedCondition = _returnCondition;
    String notes = _returnNotes;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Borrowing'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Return Condition',
                  border: OutlineInputBorder(),
                ),
                value: selectedCondition,
                items: const [
                  DropdownMenuItem(value: 'good', child: Text('Good')),
                  DropdownMenuItem(value: 'fair', child: Text('Fair')),
                  DropdownMenuItem(value: 'poor', child: Text('Poor')),
                  DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                ],
                onChanged: (value) {
                  selectedCondition = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a return condition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: notes,
                decoration: const InputDecoration(
                  labelText: 'Return Notes (Optional)',
                  hintText: 'Any additional notes about the return',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  notes = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
                setState(() {
                  _returnCondition = selectedCondition;
                  _returnNotes = notes;
                });
                _returnBorrowing(borrowing.id);
              }
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  Future<void> _returnBorrowing(int borrowingId) async {
    try {
      await context.read<BorrowingProvider>().returnBorrowing(borrowingId, {
        'return_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'return_condition': _returnCondition,
        'return_notes': _returnNotes,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Borrowing marked as returned'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to return borrowing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReturnPhotos(BuildContext context, Borrowing borrowing) {
    // Import ApiService if not already imported at the top of the file
    final returnPhotos = borrowing.items
        .where(
          (item) =>
              item.status == 'returned' &&
              item.returnPhoto != null &&
              item.returnPhoto!.isNotEmpty,
        )
        .map((item) {
          final fixedUrl = ApiService.fixPhotoUrl(item.returnPhoto);
          if (fixedUrl == null) {
            print(
              'Warning: Could not fix photo URL for item ${item.id}: ${item.returnPhoto}',
            );
          }
          return {
            'url': fixedUrl ?? item.returnPhoto!,
            'name': item.commodityName ?? 'Unknown Item',
            'condition': item.returnCondition ?? 'Tidak ada informasi kondisi', // Add this line
          };
        })
        .toList();

    if (returnPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada foto bukti pengembalian'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Foto Bukti Pengembalian',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: returnPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = returnPhotos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column( // Change to Column to stack text widgets
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Barang: ${photo['name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4), // Add some spacing
                                Text(
                                  'Kondisi: ${photo['condition']}', // Display the condition
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            key: Key('photo-${photo['name']}'),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            child: Image.network(
                              photo['url'].toString(),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                print(
                                  'Loading image from URL: ${photo['url']}',
                                );
                                if (loadingProgress == null) {
                                  print('Image loaded successfully');
                                  return child;
                                }
                                print(
                                  'Loading progress: ${loadingProgress.cumulativeBytesLoaded} / ${loadingProgress.expectedTotalBytes}',
                                );
                                return Center(
                                  heightFactor: 2,
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Gagal memuat foto',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    print('BorrowingStatusScreen: Current user role: $userRole');

    final officerJurusan = (authProvider.user?.jurusan ?? '').toLowerCase().trim();

    final borrowings = _filterBorrowings(
      borrowingProvider.borrowings,
      userRole,
      officerJurusan,
    );

    // Compute unique values for filters
    final Set<String> uniqueJurusan = borrowings
        .expand((b) => b.items.map((i) => i.jurusan))
        .where((j) => j != null && j.isNotEmpty)
        .map((j) => j!.toLowerCase())
        .toSet();

    final Set<String> uniqueClasses = borrowings
        .map((b) => b.studentClassName.toLowerCase())
        .where((c) => c.isNotEmpty)
        .toSet();

    // For students, show without tabs
    if (userRole == 'students') {
      // If we're loading, show a loading indicator
      if (borrowingProvider.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Borrowing Status')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      // If there's an error, show it
      if (borrowingProvider.error != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Borrowing Status')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${borrowingProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    borrowingProvider.clearError();
                    borrowingProvider.fetchBorrowings();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Borrowing Status')),
        body: _buildBorrowingList(context, borrowings, userRole, borrowingProvider.borrowings),
      );
    }

    // For officers and admin, show all borrowings
    final filteredBorrowings = borrowings;

    // If we're loading, show a loading indicator
    if (borrowingProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Borrowing Status')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If there's an error, show it
    if (borrowingProvider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Borrowing Status')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${borrowingProvider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  borrowingProvider.clearError();
                  borrowingProvider.fetchBorrowings();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Borrowing Status')),
      body: _buildBorrowingList(context, filteredBorrowings, userRole, borrowingProvider.borrowings),
    );
  }

  Widget _buildBorrowingList(
    BuildContext context,
    List<Borrowing> borrowings,
    String? userRole,
    List<Borrowing> allBorrowings,
  ) {
    final classProvider = context.watch<ClassProvider>();
    final Set<String> uniqueJurusan = allBorrowings
        .expand((b) => b.items.map((i) => i.jurusan))
        .where((j) => j != null && j.isNotEmpty)
        .map((j) => j!.toLowerCase())
        .toSet();

    final Set<String> uniqueClasses = classProvider.classes
        .map((c) => c.name)
        .where((c) => c.isNotEmpty)
        .toSet();

    Widget listWidget = borrowings.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getStatusIcon('pending'), size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage('pending'),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: borrowings.length,
            itemBuilder: (context, index) {
              final borrowing = borrowings[index];
              final List<BorrowingItem> filteredItems = borrowing.items;
              return BorrowingCard(
                borrowing: borrowing,
                userRole: userRole,
                selectedItems: _selectedItems,
                onItemSelectionChanged: (id, selected) {
                  setState(() {
                    if (selected) {
                      _selectedItems.add(id);
                    } else {
                      _selectedItems.remove(id);
                    }
                  });
                },
                onStatusUpdate: (status) =>
                    _updateBorrowingStatus(borrowing.id, status),
                onReturn: () => _showReturnDialog(context, borrowing),
                onBulkApprove: () => _bulkApproveItems(borrowing),
                onBulkReject: () => _bulkRejectItems(borrowing),
                onViewPhotos: () => _showReturnPhotos(context, borrowing),
                filteredItems: filteredItems, // Pass filtered items to BorrowingCard
              );
            },
          );

    if (userRole == 'admin') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFilterStatus,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Status')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'returned', child: Text('Returned')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                          DropdownMenuItem(value: 'partial', child: Text('Partial')),
                          DropdownMenuItem(value: 'partially_approved', child: Text('Partially Approved')),
                          DropdownMenuItem(value: 'partially_returned', child: Text('Partially Returned')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterStatus = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Jurusan',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFilterJurusan,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Jurusan')),
                          ...uniqueJurusan.map((j) => DropdownMenuItem(value: j, child: Text(j.toUpperCase()))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterJurusan = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFilterClass,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Classes')),
                          ...uniqueClasses.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterClass = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: listWidget),
        ],
      );
    } else if (userRole == 'officers') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFilterStatus,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Status')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'returned', child: Text('Returned')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                          DropdownMenuItem(value: 'partial', child: Text('Partial')),
                          DropdownMenuItem(value: 'partially_approved', child: Text('Partially Approved')),
                          DropdownMenuItem(value: 'partially_returned', child: Text('Partially Returned')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterStatus = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFilterClass,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Classes')),
                          ...uniqueClasses.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterClass = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: listWidget),
        ],
      );
    } else {
      return listWidget;
    }
  }
}

class BorrowingCard extends StatelessWidget {
  final Borrowing borrowing;
  final String? userRole;
  final Set<int> selectedItems;
  final Function(int, bool) onItemSelectionChanged;
  final Function(String) onStatusUpdate;
  final VoidCallback onReturn;
  final VoidCallback onBulkApprove;
  final VoidCallback onBulkReject;
  final VoidCallback onViewPhotos;
  final List<BorrowingItem>? filteredItems; // Accept filtered items

  const BorrowingCard({
    super.key,
    required this.borrowing,
    required this.userRole,
    required this.selectedItems,
    required this.onItemSelectionChanged,
    required this.onStatusUpdate,
    required this.onReturn,
    required this.onBulkApprove,
    required this.onBulkReject,
    required this.onViewPhotos,
    this.filteredItems,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil data dari helper getter
    final studentName = borrowing.studentName;
    final studentClass = borrowing.studentClassName;
    final tujuan = borrowing.tujuan ?? '-';
    final borrowDate = borrowing.borrowDate;
    final borrowTime = borrowing.borrowTime ?? '';
    final returnDate = borrowing.returnDate;
    final returnTime = borrowing.returnTime ?? '';
    final returnCondition = borrowing.returnCondition ?? '-';
    final returnedBy = borrowing.returnedByUserName;
    // Get profile photo URL from the API (use profile_picture_url from user)
    final profilePhotoUrl = borrowing.student?.user?.profilePictureUrl;

    final firstItem = borrowing.items.isNotEmpty ? borrowing.items.first : null;
    final firstItemPhotoUrl = firstItem?.commodity?.fixedPhotoUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (firstItemPhotoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: firstItemPhotoUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            if (firstItemPhotoUrl != null) const SizedBox(height: 12),
            // Header: Foto profile, nama, kelas, status
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    print('Profile photo URL: $profilePhotoUrl');
                    if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
                      return CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.grey,
                        ),
                      );
                    }

                    final fixedUrl = ApiService.fixPhotoUrl(profilePhotoUrl);
                    print('Fixed profile photo URL: $fixedUrl');

                    return CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: fixedUrl ?? profilePhotoUrl,
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print('Error loading profile image: $error');
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        studentClass,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(borrowing.status),
              ],
            ),
            const SizedBox(height: 10),

            // Tujuan
            Row(
              children: [
                const Text(
                  'Tujuan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(tujuan)),
              ],
            ),
            const SizedBox(height: 8),

            // Info container for dates and times
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal & Jam Peminjaman
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.login,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Peminjaman',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd MMM yyyy').format(borrowDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (borrowTime.isNotEmpty)
                              Text(
                                borrowTime,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tanggal & Jam Pengembalian
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pengembalian',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              returnDate != null
                                  ? DateFormat('dd MMM yyyy').format(returnDate)
                                  : '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (returnDate != null && returnTime.isNotEmpty)
                              Text(
                                returnTime,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Kondisi pengembalian
            Row(
              children: [
                const Text(
                  'Kondisi Pengembalian:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(returnCondition)),
              ],
            ),
            const SizedBox(height: 4),

            // Dikembalikan oleh
            Row(
              children: [
                const Text(
                  'Dikembalikan oleh:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(returnedBy)),
              ],
            ),
            const SizedBox(height: 12),

            // Items
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...((filteredItems ?? borrowing.items).map((item) {
              final borrowingItem = item;
              return Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '• ${borrowingItem.commodityName ?? 'Unknown Item'} (${borrowingItem.quantity} unit) - ${borrowingItem.status ?? 'Unknown'}',
                        style: TextStyle(
                          color: borrowingItem.status == 'approved'
                              ? Colors.green
                              : borrowingItem.status == 'rejected'
                              ? Colors.red
                              : borrowingItem.status == 'returned'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                    if (userRole == 'officers' || userRole == 'admin')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (borrowingItem.status == 'pending')
                            Checkbox(
                              value: selectedItems.contains(borrowingItem.id),
                              onChanged: (bool? value) {
                                if (borrowingItem.id != null) {
                                  onItemSelectionChanged(
                                    borrowingItem.id!,
                                    value ?? false,
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                  ],
                ),
              );
            })),

            const SizedBox(height: 12),

            // Bulk Action Buttons for officers/admins
            if ((userRole == 'officers' || userRole == 'admin') &&
                (filteredItems ?? borrowing.items).any(
                  (item) => item.status == 'pending',
                ))
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onBulkApprove,
                    child: const Text('Approve Selected'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onBulkReject,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject Selected'),
                  ),
                ],
              ),

            // Return Photos Button and Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            BorrowingDetailScreen(borrowing: borrowing),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Detail'),
                ),
                Row(children: [
                  // Show View Photos button for admins/officers if there are photos
                  if (userRole == 'admin' || userRole == 'officers')
                    if (borrowing.items.any((item) =>
                        item.status == 'returned' &&
                        item.returnPhoto != null &&
                        item.returnPhoto!.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextButton.icon(
                          onPressed: onViewPhotos,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Lihat Foto'),
                        ),
                      ),
                  ..._buildActionButtons(context)
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'returned':
        color = Colors.blue;
        label = 'Returned';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  bool _shouldShowActions(String? userRole, String status) {
    if (userRole == 'students') {
      return status == 'approved';
    } else if (userRole == 'officers' || userRole == 'admin') {
      return status == 'pending' ||
          status == 'approved' ||
          status == 'returned';
    }
    return false;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    if (userRole == 'students') {
      final itemsToReturn = (filteredItems ?? borrowing.items)
          .where((item) => item.status == 'approved')
          .toList();
      if (itemsToReturn.isNotEmpty) {
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton(
              onPressed: () {
                _showReturnItemsDialog(context, itemsToReturn);
              },
              child: const Text('Kembalikan'),
            ),
          ),
        );
      }
    }

    return buttons;
  }

  void _showReturnItemsDialog(BuildContext context, List<BorrowingItem> items) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Barang untuk Dikembalikan'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.commodityName ?? 'Unknown Item'),
                  subtitle: Text('Jumlah: ${item.quantity}'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReturnItemScreen(item: item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
