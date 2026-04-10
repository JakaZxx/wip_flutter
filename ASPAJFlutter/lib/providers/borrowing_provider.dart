import 'dart:async';
import 'package:flutter/material.dart';
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

  // Debounce variables (removed as we now save immediately)
  // Map<int, int> _pendingUpdates = {};
  // Timer? _cartSaveTimer;
  // static const Duration _cartSaveDebounce = Duration(milliseconds: 500);

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
      print(
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

      print(
        'BorrowingProvider.fetchBorrowings: Successfully fetched ${_borrowings.length} borrowings (page $_currentPage of $_lastPage, total $_total)',
      );
    } catch (e, stackTrace) {
      print('BorrowingProvider.fetchBorrowings: Exception occurred: $e');
      print('BorrowingProvider.fetchBorrowings: Stack trace: $stackTrace');
      _error = e.toString();
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> createBorrowing(Map<String, dynamic> borrowingData) async {
    print(
      'BorrowingProvider.createBorrowing: Starting to create borrowing with data: $borrowingData',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'BorrowingProvider.createBorrowing: Calling ApiService.createBorrowing',
      );
      final newBorrowing = await _apiService.createBorrowing(borrowingData);
      _borrowings.insert(0, newBorrowing);
      // Clear local cart immediately after successful borrowing creation
      _cartItems.clear();
      // Reload cart to ensure synchronization with server
      await loadCart();
      print(
        'BorrowingProvider.createBorrowing: Successfully created borrowing with ID: ${newBorrowing.id} and cart reloaded',
      );
      notifyListeners();
    } catch (e, stackTrace) {
      print('BorrowingProvider.createBorrowing: Exception occurred: $e');
      print('BorrowingProvider.createBorrowing: Stack trace: $stackTrace');
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateBorrowingStatus(int borrowingId, String status) async {
    print(
      'BorrowingProvider.updateBorrowingStatus: Updating borrowing $borrowingId to status: $status',
    );
    try {
      print(
        'BorrowingProvider.updateBorrowingStatus: Calling ApiService.updateBorrowingStatus',
      );
      final updatedBorrowing = await _apiService.updateBorrowingStatus(
        borrowingId,
        status,
      );
      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = updatedBorrowing;
        print(
          'BorrowingProvider.updateBorrowingStatus: Successfully updated borrowing status',
        );
        notifyListeners();
      } else {
        print(
          'BorrowingProvider.updateBorrowingStatus: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      print('BorrowingProvider.updateBorrowingStatus: Exception occurred: $e');
      print(
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
    print(
      'BorrowingProvider.returnBorrowing: Returning borrowing $borrowingId with data: $returnData',
    );
    try {
      print(
        'BorrowingProvider.returnBorrowing: Calling ApiService.returnBorrowing',
      );
      final updatedBorrowing = await _apiService.returnBorrowing(
        borrowingId,
        returnData,
      );
      final index = _borrowings.indexWhere((b) => b.id == borrowingId);
      if (index != -1) {
        _borrowings[index] = updatedBorrowing;
        print(
          'BorrowingProvider.returnBorrowing: Successfully returned borrowing',
        );
        notifyListeners();
      } else {
        print(
          'BorrowingProvider.returnBorrowing: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      print('BorrowingProvider.returnBorrowing: Exception occurred: $e');
      print('BorrowingProvider.returnBorrowing: Stack trace: $stackTrace');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> returnBorrowingItem(
    int borrowingId,
    int itemId,
    Map<String, dynamic> returnData,
  ) async {
    print(
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

      print(
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
        print(
          'BorrowingProvider.returnBorrowingItem: Successfully returned borrowing item',
        );
        notifyListeners();
      } else {
        print(
          'BorrowingProvider.returnBorrowingItem: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      print('BorrowingProvider.returnBorrowingItem: Exception occurred: $e');
      print('BorrowingProvider.returnBorrowingItem: Stack trace: $stackTrace');
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw the exception to be caught by the UI
    }
  }

  Future<void> approveBorrowingItems(int borrowingId, List<int> itemIds) async {
    print(
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
        print(
          'BorrowingProvider.approveBorrowingItems: Successfully approved items',
        );
        notifyListeners();
      } else {
        print(
          'BorrowingProvider.approveBorrowingItems: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      print('BorrowingProvider.approveBorrowingItems: Exception occurred: $e');
      print(
        'BorrowingProvider.approveBorrowingItems: Stack trace: $stackTrace',
      );
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectBorrowingItems(int borrowingId, List<int> itemIds) async {
    print(
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
        print(
          'BorrowingProvider.rejectBorrowingItems: Successfully rejected items',
        );
        notifyListeners();
      } else {
        print(
          'BorrowingProvider.rejectBorrowingItems: Borrowing with ID $borrowingId not found in local list',
        );
      }
    } catch (e, stackTrace) {
      print('BorrowingProvider.rejectBorrowingItems: Exception occurred: $e');
      print('BorrowingProvider.rejectBorrowingItems: Stack trace: $stackTrace');
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
    print(
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
      print('BorrowingProvider.addToCart: Cart updated and saved');
    } catch (e, stackTrace) {
      print('BorrowingProvider.addToCart: Exception occurred: $e');
      print('BorrowingProvider.addToCart: Stack trace: $stackTrace');
      _error = 'Gagal menambahkan ke keranjang: $e';
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int commodityId) async {
    print(
      'BorrowingProvider.removeFromCart: Removing from cart commodityId: $commodityId',
    );
    try {
      // Update local representation immediately
      _cartItems.removeWhere((c) => c.commodityId == commodityId);
      // Save cart immediately
      await saveCart();
      notifyListeners();
      print('BorrowingProvider.removeFromCart: Cart updated and saved');
    } catch (e, stackTrace) {
      print('BorrowingProvider.removeFromCart: Exception occurred: $e');
      print('BorrowingProvider.removeFromCart: Stack trace: $stackTrace');
      _error = 'Gagal menghapus dari keranjang: $e';
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantity(int commodityId, int quantity) async {
    print(
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
      print('BorrowingProvider.updateCartItemQuantity: Cart updated and saved');
    } catch (e, stackTrace) {
      print('BorrowingProvider.updateCartItemQuantity: Exception occurred: $e');
      print(
        'BorrowingProvider.updateCartItemQuantity: Stack trace: $stackTrace',
      );
      _error = 'Gagal memperbarui jumlah item: $e';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    print('BorrowingProvider.clearCart: Clearing cart');
    try {
      await _apiService.clearCart();
      _cartItems.clear();
      print('BorrowingProvider.clearCart: Successfully cleared cart');
      notifyListeners();
    } catch (e, stackTrace) {
      print('BorrowingProvider.clearCart: Exception occurred: $e');
      print('BorrowingProvider.clearCart: Stack trace: $stackTrace');
      _error = 'Gagal membersihkan keranjang: $e';
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    try {
      _cartItems = await _apiService.getCart();
      notifyListeners();
    } catch (e) {
      print('BorrowingProvider.loadCart: Failed to load cart: $e');
      _error = 'Gagal memuat keranjang';
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    if (_isSavingCart) {
      print('BorrowingProvider.saveCart: Already saving cart, skipping...');
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
      print(
        'BorrowingProvider.saveCart: Attempting to save cart with ${items.length} items: $items',
      );
      if (items.isNotEmpty) {
        await _apiService.saveCart(items);
      } else {
        // Send empty list to clear cart on backend
        await _apiService.saveCart([]);
        _cartItems.clear();
      }
      print('BorrowingProvider.saveCart: Cart saved successfully');
    } catch (e, stackTrace) {
      print('BorrowingProvider.saveCart: Failed to save cart: $e');
      print('BorrowingProvider.saveCart: Stack trace: $stackTrace');
      print(
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
