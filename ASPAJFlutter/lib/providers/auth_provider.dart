import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  final ApiService _apiService = ApiService();

  // Cek apakah user sudah login saat aplikasi dimulai
  Future<void> checkAuthStatus() async {
    debugPrint('AuthProvider.checkAuthStatus: Starting to check auth status');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      debugPrint('AuthProvider.checkAuthStatus: Token from prefs: ${token != null ? 'present' : 'null'}');

      if (token != null && token.isNotEmpty) {
        debugPrint('AuthProvider.checkAuthStatus: Token found, getting current user');
        // Token ada, coba dapatkan data user
        _user = await _apiService.getCurrentUser();
        debugPrint('AuthProvider.checkAuthStatus: User loaded: ${_user?.name}, role: ${_user?.role}, approved: ${_user?.isApproved}');

        // Check verification status for students and officers
        /* DISABLING FORCED VERIFICATION FOR NOW
        if (_user!.isStudent && _user!.emailVerifiedAt == null) {
          debugPrint('AuthProvider.checkAuthStatus: Student email not verified, logging out');
          await _logoutLocally();
          _error = 'Silahkan lakukan verifikasi email melalui website';
        } else 
        */
        if (_user!.isOfficer && !_user!.isApproved) {
          debugPrint('AuthProvider.checkAuthStatus: Officer not approved, logging out');
          await _logoutLocally();
          _error = 'Akun mu belum terverifikasi silahkan login pada halaman website';
        }
      } else {
        debugPrint('AuthProvider.checkAuthStatus: No token found');
      }
    } catch (e, stackTrace) {
      debugPrint('AuthProvider.checkAuthStatus: Exception occurred: $e');
      debugPrint('AuthProvider.checkAuthStatus: Stack trace: $stackTrace');
      // Token tidak valid atau error, hapus token
      await _logoutLocally();
      _error = 'Sesi login telah berakhir';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    debugPrint('AuthProvider.login: Starting login process');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('AuthProvider.login: Calling ApiService.login');
      final response = await _apiService.login(email, password);
      debugPrint('AuthProvider.login: ApiService response: $response');

      // Check if login was successful (token should be set)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null && token.isNotEmpty) {
        debugPrint('AuthProvider.login: Token found, getting user data');
        // Get user data after successful login
        final user = await _apiService.getCurrentUser();
        debugPrint('AuthProvider.login: User data loaded: ${user.name}, role: ${user.role}, approved: ${user.isApproved}');

        // Check verification status for students and officers
        /* DISABLING FORCED VERIFICATION FOR NOW
        if (user!.isStudent && user.emailVerifiedAt == null) {
          debugPrint('AuthProvider.login: Student email not verified, logging out');
          await _logoutLocally();
          _error = 'Silahkan lakukan verifikasi email melalui website';
          _isLoading = false;
          notifyListeners();
          return false;
        } else 
        */
        if (user.isOfficer && !user.isApproved) {
          debugPrint('AuthProvider.login: Officer not approved, logging out');
          await _logoutLocally();
          _error = 'Akun mu belum terverifikasi silahkan login pada halaman website';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Set user only if approved
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('AuthProvider.login: No token found, login failed');
        _error = response['message'] ?? 'Login gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('AuthProvider.login: Exception occurred: $e');
      debugPrint('AuthProvider.login: Stack trace: $stackTrace');
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      // Error saat logout dari API, tapi tetap lanjutkan logout lokal
      debugPrint('Error saat logout dari API: $e');
    }

    await _logoutLocally();
    _isLoading = false;
    notifyListeners();
  }

  // Logout hanya dari lokal storage
  Future<void> _logoutLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    _error = null;
  }

  // Update user data
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

