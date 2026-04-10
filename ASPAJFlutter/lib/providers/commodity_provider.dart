import 'package:flutter/material.dart';
import '../models/commodity.dart';
import '../services/api_service.dart';

class CommodityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Commodity> _commodities = [];
  bool _isLoading = false;
  String? _error;

  List<Commodity> get commodities => _commodities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCommodities({String? search, String? jurusan}) async {
    print('CommodityProvider.fetchCommodities: Starting to fetch commodities with search: $search, jurusan: $jurusan');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('CommodityProvider.fetchCommodities: Calling ApiService.getCommodities');
      _commodities = await _apiService.getCommodities(search: search, jurusan: jurusan);
      print('CommodityProvider.fetchCommodities: Successfully fetched ${_commodities.length} commodities');
    } catch (e, stackTrace) {
      print('CommodityProvider.fetchCommodities: Exception occurred: $e');
      print('CommodityProvider.fetchCommodities: Stack trace: $stackTrace');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCommodities(String query) async {
    print('CommodityProvider.searchCommodities: Searching commodities with query: $query');
    await fetchCommodities(search: query);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> createCommodity(Map<String, dynamic> commodityData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCommodity = await _apiService.createCommodity(commodityData);
      _commodities.insert(0, newCommodity); // Add to beginning of list
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCommodity(int id, Map<String, dynamic> commodityData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCommodity = await _apiService.updateCommodity(id, commodityData);
      final index = _commodities.indexWhere((c) => c.id == id);
      if (index != -1) {
        _commodities[index] = updatedCommodity;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCommodity(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteCommodity(id);
      _commodities.removeWhere((c) => c.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Commodity?> getCommodityDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _apiService.getCommodityDetail(id);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
