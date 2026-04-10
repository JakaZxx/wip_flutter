import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Tambahkan ini
import 'package:http/http.dart' as http; // Tambahkan ini
import '../models/borrowing.dart';
import '../models/borrowing_item.dart';
import '../services/api_service.dart';
import 'return_item_screen.dart'; // We will create this screen next

class BorrowingDetailScreen extends StatefulWidget {
  final Borrowing borrowing;

  const BorrowingDetailScreen({super.key, required this.borrowing});

  @override
  State<BorrowingDetailScreen> createState() => _BorrowingDetailScreenState();
}

class _BorrowingDetailScreenState extends State<BorrowingDetailScreen> {
  late Borrowing _borrowing;
  bool _isLoadingCommodities = false;

  @override
  void initState() {
    super.initState();
    _borrowing = widget.borrowing;
    _fetchMissingCommodities();
  }

  Future<void> _fetchMissingCommodities() async {
    final itemsWithoutCommodity = _borrowing.items
        .where((item) => item.commodity == null)
        .toList();
    if (itemsWithoutCommodity.isEmpty) return;

    setState(() => _isLoadingCommodities = true);

    try {
      final updatedItems = <BorrowingItem>[];
      for (final item in _borrowing.items) {
        if (item.commodity != null) {
          updatedItems.add(item);
        } else {
          // Fetch commodity details
          final commodity = await ApiService().getCommodityDetail(
            item.commodityId,
          );
          final updatedItem = BorrowingItem(
            id: item.id,
            borrowingId: item.borrowingId,
            commodityId: item.commodityId,
            quantity: item.quantity,
            status: item.status,
            returnCondition: item.returnCondition,
            returnPhoto: item.returnPhoto,
            condition: item.condition,
            description: item.description,
            photoPath: item.photoPath,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            commodityName: item.commodityName,
            commodity: commodity,
          );
          updatedItems.add(updatedItem);
        }
      }

      setState(() {
        _borrowing = _borrowing.copyWith(items: updatedItems);
        _isLoadingCommodities = false;
      });
    } catch (e) {
      print('Error fetching commodity details: $e');
      setState(() => _isLoadingCommodities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing Details'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoadingCommodities
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(context),
                  const SizedBox(height: 20),
                  _buildItemsSection(context),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Borrowing Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _buildDetailRow('Borrowing ID:', '#${_borrowing.id}'),
            _buildDetailRow('Purpose:', _borrowing.tujuan ?? '-'),
            _buildDetailRow(
              'Borrow Date:',
              '${DateFormat('d MMM yyyy').format(_borrowing.borrowDate)} ${_borrowing.borrowTime ?? ''}',
            ),
            _buildDetailRow(
              'Expected Return:',
              _borrowing.returnDate != null
                  ? '${DateFormat('d MMM yyyy').format(_borrowing.returnDate!)} ${_borrowing.returnTime ?? ''}'
                  : '-',
            ),
            _buildDetailRow('Status:', _borrowing.status, isStatus: true),
            if (_borrowing.status == 'returned')
              _buildDetailRow(
                'Actual Return Date:',
                DateFormat('d MMM yyyy, HH:mm').format(_borrowing.updatedAt),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Borrowed Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_borrowing.items.isEmpty)
          const Text('No items found for this borrowing.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _borrowing.items.length,
            itemBuilder: (context, index) {
              final item = _borrowing.items[index];
              return _buildItemCard(context, item);
            },
          ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, BorrowingItem item) {
    final commodity = item.commodity;
    final canBeReturned = item.status == 'approved';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Commodity Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: commodity?.fixedPhotoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            commodity!.fixedPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                'Error loading image for ${commodity?.name ?? 'Unknown'}: $error, URL: ${commodity.photoUrl}',
                              );
                              _logHttpResponse(
                                commodity.photoUrl,
                              ); // Panggil fungsi baru untuk logging
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    'Error loading image',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2,
                          size: 24,
                          color: Colors.grey,
                        ),
                ),
                const SizedBox(width: 12),
                // Commodity Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commodity?.name ?? 'Unknown Item',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text('Code: ${commodity?.code ?? '-'}'),
                      Text('Quantity: ${item.quantity}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(item.status ?? 'unknown'),
                if (canBeReturned)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReturnItemScreen(item: item),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Return Item'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: isStatus ? _buildStatusBadge(value) : Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      case 'returned':
        color = Colors.blue;
        text = 'Returned';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Tambahkan fungsi ini di luar build method, di dalam class BorrowingDetailScreen
Future<void> _logHttpResponse(String? imageUrl) async {
  if (imageUrl == null) return;
  try {
    final response = await http.get(Uri.parse(imageUrl));
    print('HTTP Response for image URL: $imageUrl');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    // Hanya cetak body jika status bukan 200 OK atau jika body kecil
    if (response.statusCode != 200 || response.bodyBytes.length < 1000) {
      print(
        'Body (first 500 chars): ${response.body.substring(0, min(response.body.length, 500))}',
      );
    } else {
      print('Body is large, not printing full content.');
    }
  } catch (e) {
    print('Error during HTTP request for image: $e');
  }
}
