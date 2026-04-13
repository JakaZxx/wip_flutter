import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/borrowing.dart';
import '../models/borrowing_item.dart';
import '../services/api_service.dart';

class BorrowingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Borrowing> _borrowings = [];
  List<BorrowingItem> _cartItems = [];
  bool _isLoading = false;
  bool _isSavingCart = false;
  String? _error;

  List<Borrowing> get borrowings => _borrowings;
  List<BorrowingItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter state
  String? _searchQuery;
  String? _statusFilter;
  String? _jurusanFilter;
  String? _classFilter;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  final int _perPage = 10;

  // Getters for filter state
  String? get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get jurusanFilter => _jurusanFilter;
  String? get classFilter => _classFilter;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  int get perPage => _perPage;

  // Set filter methods
  void setSearchQuery(String? query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page when filtering
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    _currentPage = 1;
    notifyListeners();
  }

  void setJurusanFilter(String? jurusan) {
    _jurusanFilter = jurusan;
    _currentPage = 1;
    notifyListeners();
  }

  void setClassFilter(String? classId) {
    _classFilter = classId;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _statusFilter = null;
    _jurusanFilter = null;
    _classFilter = null;
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> fetchBorrowings({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      debugPrint(
        'BorrowingProvider.fetchBorrowings: Fetching with filters - search: $_searchQuery, status: $_statusFilter, jurusan: $_jurusanFilter, class: $_classFilter, page: $_currentPage',
      );
      final result = await _apiService.getBorrowings(
        search: _searchQuery,
        status: _statusFilter,
        jurusan: _jurusanFilter,
        classId: _classFilter,
        page: _currentPage,
        perPage: _perPage,
      );

      _borrowings = result['borrowings'] as List<Borrowing>;
      _currentPage = (result['current_page'] as int?) ?? 1;
      _lastPage = (result['last_page'] as int?) ?? 1;
      _total = (result['total'] as int?) ?? _borrowings.length;

      debugPrint(
        'BorrowingProvider.fetchBorrowings: Successfully fetched ${_borrowings.length} borrowings (page $_currentPage of $_lastPage, total $_total)',
      );
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.fetchBorrowings: Exception occurred: $e');
      debugPrint('BorrowingProvider.fetchBorrowings: Stack trace: $stackTrace');
      _error = e.toString();
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> createBorrowing(Map<String, dynamic> borrowingData) async {
    debugPrint(
      'BorrowingProvider.createBorrowing: Starting to create borrowing with data: $borrowingData',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint(
        'BorrowingProvider.createBorrowing: Calling ApiService.createBorrowing',
      );
      final newBorrowing = await _apiService.createBorrowing(borrowingData);
      _borrowings.insert(0, newBorrowing);
      // Clear local cart immediately after successful borrowing creation
      _cartItems.clear();
      // Reload cart to ensure synchronization with server
      await loadCart();
      debugPrint(
        'BorrowingProvider.createBorrowing: Successfully created borrowing with ID: ${newBorrowing.id} and cart reloaded',
      );
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.createBorrowing: Exception occurred: $e');
      debugPrint('BorrowingProvider.createBorrowing: Stack trace: $stackTrace');
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateBorrowingStatus(int borrowingId, String status) async {
    debugPrint(
      'BorrowingProvider.updateBorrowingStatus: Updating borrowing $borrowingId to status: $status',
    );
    try {
      debugPrint(
        'BorrowingProvider.updateBorrowingStatus: Calling ApiService.updateBorrowingStatus',
      );
      final updatedBorrowing = await _apiService.updateBorrowingStatus(
        borrowingId,
        status,
      );
      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = updatedBorrowing;
        debugPrint(
          'BorrowingProvider.updateBorrowingStatus: Successfully updated borrowing status',
        );
        notifyListeners();
      } else {
        debugPrint(
          'BorrowingProvider.updateBorrowingStatus: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.updateBorrowingStatus: Exception occurred: $e');
      debugPrint(
        'BorrowingProvider.updateBorrowingStatus: Stack trace: $stackTrace',
      );
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> returnBorrowing(
    int borrowingId,
    Map<String, dynamic> returnData,
  ) async {
    debugPrint(
      'BorrowingProvider.returnBorrowing: Returning borrowing $borrowingId with data: $returnData',
    );
    try {
      // 1. Upload photo if present
      Map<String, dynamic> apiData = Map.from(returnData);
      if (returnData['return_photo'] != null) {
        if (returnData['return_photo'] is XFile) {
          final imageFile = returnData['return_photo'] as XFile;
          final bytes = await imageFile.readAsBytes();
          final photoPath = await _apiService.uploadBytes(bytes, imageFile.name, 'file');
          apiData['return_photo'] = photoPath;
        } else if (returnData['return_photo'] is File) {
          final file = returnData['return_photo'] as File;
          final bytes = await file.readAsBytes();
          final photoPath = await _apiService.uploadBytes(bytes, file.path.split('/').last, 'file');
          apiData['return_photo'] = photoPath;
        }
      }

      debugPrint(
        'BorrowingProvider.returnBorrowing: Calling ApiService.returnBorrowing',
      );
      final updatedBorrowing = await _apiService.returnBorrowing(
        borrowingId,
        apiData,
      );
      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = updatedBorrowing;
        debugPrint(
          'BorrowingProvider.returnBorrowing: Successfully returned borrowing',
        );
        notifyListeners();
      } else {
        debugPrint(
          'BorrowingProvider.returnBorrowing: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.returnBorrowing: Exception occurred: $e');
      debugPrint('BorrowingProvider.returnBorrowing: Stack trace: $stackTrace');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> returnBorrowingItem(
    int borrowingId,
    int itemId,
    Map<String, dynamic> returnData,
  ) async {
    debugPrint(
      'BorrowingProvider.returnBorrowingItem: Returning item $itemId in borrowing $borrowingId',
    );
    try {
      // 1. Upload the photo first to get the path
      String? photoPath;
      if (returnData['return_photo'] != null &&
          returnData['return_photo'] is XFile) {
        final imageFile = returnData['return_photo'] as XFile;
        final bytes = await imageFile.readAsBytes();
        // Use the generic uploadBytes method from ApiService. The field name 'photo' is for the /upload endpoint.
        photoPath = await _apiService.uploadBytes(bytes, imageFile.name, 'file');
      }

      // 2. Prepare data for the actual return API call
      final Map<String, dynamic> apiData = {
        'condition': returnData['condition'],
        'return_photo': photoPath, // Send the path as a string
      };

      debugPrint(
        'BorrowingProvider.returnBorrowingItem: Calling ApiService.returnBorrowingItem with data: $apiData',
      );

      // 3. Call the (now modified) returnBorrowingItem method
      final updatedBorrowing = await _apiService.returnBorrowingItem(
        borrowingId,
        itemId,
        apiData, // Pass the new map with the photo path
      );

      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = updatedBorrowing;
        debugPrint(
          'BorrowingProvider.returnBorrowingItem: Successfully returned borrowing item',
        );
        notifyListeners();
      } else {
        debugPrint(
          'BorrowingProvider.returnBorrowingItem: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.returnBorrowingItem: Exception occurred: $e');
      debugPrint('BorrowingProvider.returnBorrowingItem: Stack trace: $stackTrace');
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw the exception to be caught by the UI
    }
  }

  Future<void> approveBorrowingItems(int borrowingId, List<int> itemIds) async {
    debugPrint(
      'BorrowingProvider.approveBorrowingItems: Approving items $itemIds for borrowing $borrowingId',
    );
    try {
      final updatedBorrowing = await _apiService.approveBorrowingItems(
        borrowingId,
        itemIds,
      );
      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = updatedBorrowing;
        debugPrint(
          'BorrowingProvider.approveBorrowingItems: Successfully approved items',
        );
        notifyListeners();
      } else {
        debugPrint(
          'BorrowingProvider.approveBorrowingItems: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.approveBorrowingItems: Exception occurred: $e');
      debugPrint(
        'BorrowingProvider.approveBorrowingItems: Stack trace: $stackTrace',
      );
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectBorrowingItems(int borrowingId, List<int> itemIds) async {
    debugPrint(
      'BorrowingProvider.rejectBorrowingItems: Rejecting items $itemIds for borrowing $borrowingId',
    );
    try {
      final updatedBorrowing = await _apiService.rejectBorrowingItems(
        borrowingId,
        itemIds,
      );
      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = updatedBorrowing;
        debugPrint(
          'BorrowingProvider.rejectBorrowingItems: Successfully rejected items',
        );
        notifyListeners();
      } else {
        debugPrint(
          'BorrowingProvider.rejectBorrowingItems: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.rejectBorrowingItems: Exception occurred: $e');
      debugPrint('BorrowingProvider.rejectBorrowingItems: Stack trace: $stackTrace');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addToCart(
    int commodityId,
    int quantity, {
    String? condition,
    String? description,
  }) async {
    debugPrint(
      'BorrowingProvider.addToCart: Adding to cart commodityId: $commodityId, quantity: $quantity',
    );
    try {
      // update local cart representation immediately
      final index = _cartItems.indexWhere((c) => c.commodityId == commodityId);
      if (index != -1) {
        // Recreate item with updated quantity (BorrowingItem has no copyWith)
        final existing = _cartItems[index];
        _cartItems[index] = BorrowingItem(
          id: existing.id,
          borrowingId: existing.borrowingId,
          commodityId: existing.commodityId,
          quantity: quantity,
          status: existing.status,
          returnCondition: existing.returnCondition,
          returnPhoto: existing.returnPhoto,
          condition: existing.condition,
          description: existing.description,
          photoPath: existing.photoPath,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
          commodityName: existing.commodityName,
          commodity: existing.commodity,
        );
      } else {
        // create a temporary BorrowingItem-like object — best effort: loadCart will correct it
        final temp = BorrowingItem(
          id: -1,
          borrowingId: null,
          commodityId: commodityId,
          quantity: quantity,
          status: null,
          returnCondition: null,
          returnPhoto: null,
          condition: null,
          description: null,
          photoPath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          commodityName: null,
          commodity: null,
        );
        _cartItems.add(temp);
      }
      // Save cart immediately
      await saveCart();
      notifyListeners();
      debugPrint('BorrowingProvider.addToCart: Cart updated and saved');
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.addToCart: Exception occurred: $e');
      debugPrint('BorrowingProvider.addToCart: Stack trace: $stackTrace');
      _error = 'Gagal menambahkan ke keranjang: $e';
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int commodityId) async {
    debugPrint(
      'BorrowingProvider.removeFromCart: Removing from cart commodityId: $commodityId',
    );
    try {
      // Update local representation immediately
      _cartItems.removeWhere((c) => c.commodityId == commodityId);
      // Save cart immediately
      await saveCart();
      notifyListeners();
      debugPrint('BorrowingProvider.removeFromCart: Cart updated and saved');
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.removeFromCart: Exception occurred: $e');
      debugPrint('BorrowingProvider.removeFromCart: Stack trace: $stackTrace');
      _error = 'Gagal menghapus dari keranjang: $e';
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantity(int commodityId, int quantity) async {
    debugPrint(
      'BorrowingProvider.updateCartItemQuantity: Updating cart item commodityId: $commodityId, quantity: $quantity',
    );
    try {
      // Update local representation immediately
      final index = _cartItems.indexWhere((c) => c.commodityId == commodityId);
      if (index != -1) {
        final existing = _cartItems[index];
        _cartItems[index] = BorrowingItem(
          id: existing.id,
          borrowingId: existing.borrowingId,
          commodityId: existing.commodityId,
          quantity: quantity,
          status: existing.status,
          returnCondition: existing.returnCondition,
          returnPhoto: existing.returnPhoto,
          condition: existing.condition,
          description: existing.description,
          photoPath: existing.photoPath,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
          commodityName: existing.commodityName,
          commodity: existing.commodity,
        );
      } else {
        final temp = BorrowingItem(
          id: -1,
          borrowingId: null,
          commodityId: commodityId,
          quantity: quantity,
          status: null,
          returnCondition: null,
          returnPhoto: null,
          condition: null,
          description: null,
          photoPath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          commodityName: null,
          commodity: null,
        );
        _cartItems.add(temp);
      }
      // Save cart immediately
      await saveCart();
      notifyListeners();
      debugPrint('BorrowingProvider.updateCartItemQuantity: Cart updated and saved');
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.updateCartItemQuantity: Exception occurred: $e');
      debugPrint(
        'BorrowingProvider.updateCartItemQuantity: Stack trace: $stackTrace',
      );
      _error = 'Gagal memperbarui jumlah item: $e';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    debugPrint('BorrowingProvider.clearCart: Clearing cart');
    try {
      await _apiService.clearCart();
      _cartItems.clear();
      debugPrint('BorrowingProvider.clearCart: Successfully cleared cart');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.clearCart: Exception occurred: $e');
      debugPrint('BorrowingProvider.clearCart: Stack trace: $stackTrace');
      _error = 'Gagal membersihkan keranjang: $e';
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    try {
      _cartItems = await _apiService.getCart();
      notifyListeners();
    } catch (e) {
      debugPrint('BorrowingProvider.loadCart: Failed to load cart: $e');
      _error = 'Gagal memuat keranjang';
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    if (_isSavingCart) {
      debugPrint('BorrowingProvider.saveCart: Already saving cart, skipping...');
      return;
    }

    _isSavingCart = true;
    _error = null; // Clear previous error on new save attempt

    try {
      final items = _cartItems
          .where((item) => item.quantity > 0)
          .map(
            (item) => {
              'commodity_id': item.commodityId,
              'quantity': item.quantity,
            },
          )
          .toList();
      debugPrint(
        'BorrowingProvider.saveCart: Attempting to save cart with ${items.length} items: $items',
      );
      if (items.isNotEmpty) {
        await _apiService.saveCart(items);
      } else {
        // Send empty list to clear cart on backend
        await _apiService.saveCart([]);
        _cartItems.clear();
      }
      debugPrint('BorrowingProvider.saveCart: Cart saved successfully');
    } catch (e, stackTrace) {
      debugPrint('BorrowingProvider.saveCart: Failed to save cart: $e');
      debugPrint('BorrowingProvider.saveCart: Stack trace: $stackTrace');
      debugPrint(
        'BorrowingProvider.saveCart: Cart items at time of error: $_cartItems',
      );
      _error = 'Gagal menyimpan keranjang: $e';
      notifyListeners();
    } finally {
      _isSavingCart = false;
    }
  }

  int get cartItemCount => _cartItems.length;

  int get totalCartQuantity =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Bulk operations
  Future<void> bulkApprove(List<int> borrowingIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final borrowingId in borrowingIds) {
        await _apiService.updateBorrowingStatus(borrowingId, 'approved');
        final index = _borrowings.indexWhere((b) => b.id == borrowingId);
        if (index != -1) {
          _borrowings[index] = _borrowings[index].copyWith(status: 'approved');
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> bulkReject(List<int> borrowingIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final borrowingId in borrowingIds) {
        await _apiService.updateBorrowingStatus(borrowingId, 'rejected');
        final index = _borrowings.indexWhere((b) => b.id == borrowingId);
        if (index != -1) {
          _borrowings[index] = _borrowings[index].copyWith(status: 'rejected');
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }
}
