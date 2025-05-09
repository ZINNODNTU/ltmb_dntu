import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasktodo/models/user_model.dart';
import 'package:tasktodo/Service/auth_service.dart';
import 'dart:convert'; // Để giải mã Base64 nếu cần

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = 'user';
  String? _avatarUrl;

  @override
  void dispose() {
    // Giải phóng bộ điều khiển để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Hiển thị hộp thoại để chỉnh sửa thông tin người dùng
  void _showUserDialog({required UserModel user}) {
    // Điền dữ liệu người dùng vào các trường nhập liệu
    _nameController.text = user.username;
    _emailController.text = user.email;
    _avatarUrl = user.avatar;
    _role = 'user'; // Lấy vai trò từ Firestore nếu có

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa người dùng'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trường nhập tên
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                  validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                // Trường nhập email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập email' : null,
                ),
                // Trường nhập URL ảnh đại diện
                TextFormField(
                  initialValue: _avatarUrl,
                  decoration: const InputDecoration(labelText: 'URL ảnh đại diện'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.isAbsolute) {
                        return 'Vui lòng nhập URL hợp lệ';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) => _avatarUrl = value,
                ),
                // Trường chọn vai trò
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: ['admin', 'user']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _role = value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Nút hủy
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          // Nút cập nhật thông tin người dùng
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final result = await _authService.signup(
                  name: _nameController.text,
                  email: _emailController.text,
                  password: 'temporary_password', // Mật khẩu tạm thời
                  role: _role,
                  avatar: _avatarUrl,
                );
                if (result == null) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $result')),
                  );
                }
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Lắng nghe dữ liệu người dùng từ Firestore
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Chuyển dữ liệu từ Firestore thành danh sách người dùng
          final users = snapshot.data!.docs
              .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          // Hiển thị danh sách người dùng
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: _buildAvatar(user.avatar),
                title: Text(user.username),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút chỉnh sửa thông tin người dùng
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showUserDialog(user: user),
                    ),
                    // Nút gửi email đặt lại mật khẩu
                    IconButton(
                      icon: const Icon(Icons.lock_reset),
                      onPressed: () async {
                        await _authService.sendPasswordResetEmail(user.email);
                      },
                    ),
                    // Nút xóa người dùng
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.id)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hàm xây dựng ảnh đại diện
  Widget _buildAvatar(String? avatar) {
    if (avatar == null || avatar.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person));
    }

    // Xử lý ảnh Base64
    if (avatar.startsWith('data:image') || RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(avatar)) {
      try {
        final bytes = base64Decode(avatar.split(',').last);
        return CircleAvatar(
          backgroundImage: MemoryImage(bytes),
          onBackgroundImageError: (error, stackTrace) => const Icon(Icons.error),
        );
      } catch (e) {
        return const CircleAvatar(child: Icon(Icons.error));
      }
    }

    // Xử lý ảnh từ URL
    return CircleAvatar(
      backgroundImage: NetworkImage(avatar),
      onBackgroundImageError: (error, stackTrace) => const Icon(Icons.error),
      child: const Icon(Icons.person),
    );
  }
}