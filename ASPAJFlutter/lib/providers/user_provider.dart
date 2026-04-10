import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers({String? search, String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, we'll use the existing getUsers method
      // Later we can add search and filter parameters to the API
      _users = await _apiService.getUsers();

      // Apply client-side filtering if needed
      if (search != null && search.isNotEmpty) {
        _users = _users.where((user) =>
          user.name.toLowerCase().contains(search.toLowerCase()) ||
          user.email.toLowerCase().contains(search.toLowerCase())
        ).toList();
      }

      if (role != null && role.isNotEmpty) {
        _users = _users.where((user) => user.role == role).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      await _apiService.createUser(userData);
      await fetchUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      // TODO: Implement update user API call
      await fetchUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      // TODO: Implement delete user API call
      await fetchUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveUser(int userId) async {
    try {
      await _apiService.approveUser(userId);
      await fetchUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectUser(int userId) async {
    try {
      await _apiService.rejectUser(userId);
      await fetchUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
