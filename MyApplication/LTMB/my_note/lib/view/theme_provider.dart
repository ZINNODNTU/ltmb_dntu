import 'package:flutter/material.dart';

// Lớp ThemeProvider sử dụng ChangeNotifier để quản lý chế độ giao diện (theme)
class ThemeProvider with ChangeNotifier {
  // Biến lưu trữ chế độ giao diện hiện tại, mặc định là theo hệ thống
  ThemeMode _themeMode = ThemeMode.system;

  // Getter để lấy chế độ giao diện hiện tại
  ThemeMode get themeMode => _themeMode;

  // Phương thức để chuyển đổi giữa chế độ sáng và tối
  void toggleTheme(bool isDark) {
    // Cập nhật chế độ giao diện dựa trên tham số isDark
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Thông báo cho các listener rằng có sự thay đổi
    notifyListeners();
  }
}