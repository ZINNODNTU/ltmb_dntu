import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tasktodo/View/login_screen.dart';
import 'package:tasktodo/View/admin/admin_task_creation_screen.dart';
import 'package:tasktodo/View/user/user_task_creation_screen.dart';
import 'package:tasktodo/View/admin/admin_task_list_screen.dart';
import 'package:tasktodo/View/user/user_task_list_screen.dart';
import 'package:tasktodo/View/TaskCalendarScreen.dart';
import 'package:tasktodo/View/profile_screen.dart';

/// Màn hình chính của Admin
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0; // Chỉ mục đang chọn trên BottomNavigationBar

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final adminId = user?.uid ?? ''; // Lấy ID admin hiện tại

    // Danh sách các trang
    final List<Widget> _pages = [
      TaskListScreenAdmin(adminId: adminId), // Trang danh sách công việc
      TaskCalendarScreen(isAdmin: true), // Trang lịch
      const ProfileScreen(), // Trang hồ sơ
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển Admin'), // Tiêu đề AppBar
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất', // Tooltip khi hover nút logout
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Đăng xuất Firebase
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()), // Chuyển về màn Login
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Hiển thị trang tương ứng
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Mục đang chọn
        selectedItemColor: Colors.teal, // Màu item đang chọn
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Đổi trang
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Công việc', // Label tiếng Việt
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch', // Label tiếng Việt
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ', // Label tiếng Việt
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskCreationScreen(adminId: adminId), // Chuyển đến màn tạo task
            ),
          );
        },
        child: const Icon(Icons.add), // Nút thêm
        tooltip: 'Thêm công việc', // Tooltip tiếng Việt
      )
          : null,
    );
  }
}

/// Màn hình chính của User
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _selectedIndex = 0; // Chỉ mục đang chọn

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? ''; // Lấy ID user hiện tại

    // Danh sách các trang
    final List<Widget> _pages = [
      TaskListScreenUser(userId: userId), // Trang danh sách công việc
      TaskCalendarScreen(isAdmin: false), // Trang lịch
      const ProfileScreen(), // Trang hồ sơ
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển Người dùng'), // Tiêu đề AppBar
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất', // Tooltip
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut(); // Đăng xuất Firebase
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()), // Chuyển về màn Login
                );
              } catch (e) {
                // Nếu lỗi khi đăng xuất, hiển thị SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đăng xuất thất bại: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Hiển thị trang tương ứng
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Đổi trang
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Công việc', // Label tiếng Việt
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch', // Label tiếng Việt
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ', // Label tiếng Việt
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskCreationScreenuser(), // Chuyển đến màn tạo task user
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm công việc', // Tooltip tiếng Việt
      )
          : null,
    );
  }
}
