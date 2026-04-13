import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_stats.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DashboardStats? _dashboardStats;
  DashboardStats? get dashboardStats => _dashboardStats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stats = await _apiService.getDashboardStats();
      _dashboardStats = stats;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}