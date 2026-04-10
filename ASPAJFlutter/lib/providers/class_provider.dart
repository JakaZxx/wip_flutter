import 'package:flutter/material.dart';
import '../models/school_class.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class ClassProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<SchoolClass> _classes = [];
  List<String> _levels = [];
  List<String> _programStudies = [];
  bool _isLoading = false;
  String? _error;

  List<SchoolClass> get classes => _classes;
  List<String> get levels => _levels;
  List<String> get programStudies => _programStudies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classes = await _apiService.getSchoolClasses();
      // Extract unique levels and program studies from classes
      _levels = _classes.map((c) => c.level).where((l) => l != null).cast<String>().toSet().toList()..sort();
      _programStudies = _classes.map((c) => c.programStudy).where((p) => p != null).cast<String>().toSet().toList()..sort();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass(Map<String, dynamic> classData) async {
    try {
      await _apiService.createSchoolClass(classData);
      await fetchClasses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateClass(int classId, Map<String, dynamic> classData) async {
    try {
      await _apiService.updateSchoolClass(classId, classData);
      await fetchClasses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteClass(int classId) async {
    try {
      await _apiService.deleteSchoolClass(classId);
      await fetchClasses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Student>> getClassStudents(int classId) async {
    try {
      return await _apiService.getClassStudents(classId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> moveStudents(int fromClassId, int toClassId, List<int> studentIds) async {
    try {
      await _apiService.moveStudents(fromClassId, toClassId, studentIds);
      await fetchClasses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteStudentsFromClass(int classId) async {
    print('ClassProvider.deleteStudentsFromClass: Attempting to delete all students from class $classId');
    try {
      await _apiService.deleteStudentsFromClass(classId);
      print('ClassProvider.deleteStudentsFromClass: API call successful, fetching updated classes');
      await fetchClasses();
      print('ClassProvider.deleteStudentsFromClass: Classes fetched successfully');
      return true;
    } catch (e) {
      print('ClassProvider.deleteStudentsFromClass: Error occurred: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> removeStudentFromClass(int classId, int studentId) async {
    print('ClassProvider.removeStudentFromClass: Attempting to remove student $studentId from class $classId');
    try {
      await _apiService.removeStudentFromClass(classId, studentId);
      print('ClassProvider.removeStudentFromClass: API call successful, fetching updated classes');
      await fetchClasses();
      print('ClassProvider.removeStudentFromClass: Classes fetched successfully');
    } catch (e) {
      print('ClassProvider.removeStudentFromClass: Error occurred: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
