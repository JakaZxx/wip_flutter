import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  // Gunakan getter untuk memastikan key selalu terinisialisasi
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int get selectedIndex => _selectedIndex;
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void openDrawer() {
    // Tambahkan pengecekan ekstra untuk keamanan di Web
    try {
      if (_scaffoldKey.currentState != null) {
        _scaffoldKey.currentState!.openDrawer();
      }
    } catch (e) {
      debugPrint("Gagal membuka drawer: $e");
    }
  }
}
