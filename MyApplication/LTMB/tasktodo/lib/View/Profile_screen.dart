import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasktodo/models/user_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel?> _userFuture;
  File? _newPickedImageFile;
  String? _base64Avatar;

  // Định nghĩa màu chủ đạo cho giao diện
  final Color _primaryColor = Colors.teal;
  final Color _primaryColorLight = Colors.teal.shade300;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu người dùng khi màn hình được tạo
    _userFuture = _fetchUserData();
  }

  // Hàm lấy dữ liệu người dùng từ Firestore
  Future<UserModel?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final userData = UserModel.fromMap(doc.data()!, doc.id);
        if (_newPickedImageFile == null) {
          _base64Avatar = userData.avatar;
        }
        return userData;
      } else {
        if (mounted) {
          // Hiển thị thông báo nếu dữ liệu không tồn tại
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dữ liệu người dùng không tồn tại.'), backgroundColor: Colors.orangeAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Hiển thị thông báo lỗi nếu không tải được dữ liệu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải dữ liệu người dùng: $e')),
        );
      }
    }
    return null;
  }

  // Hàm cập nhật trường dữ liệu trong Firestore
  Future<void> _updateField(String field, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({field: value});
      setState(() {
        // Cập nhật lại giao diện sau khi thay đổi dữ liệu
        _userFuture = _fetchUserData();
      });
      if (mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật ${field == "name" ? "tên người dùng" : "ảnh đại diện"} thành công!'),
            backgroundColor: _primaryColorLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Hiển thị thông báo lỗi khi cập nhật thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật ${field == "name" ? "tên người dùng" : "avatarBase64"}: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Hàm chọn và tải ảnh đại diện lên Firestore
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() {
      _newPickedImageFile = file;
      _base64Avatar = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        // Hiển thị thông báo nếu người dùng chưa đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để cập nhật ảnh.'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    try {
      // Đọc và mã hóa ảnh thành Base64
      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;
      if (fileSize > 700 * 1024) { // Giới hạn 700KB
        throw Exception('Ảnh quá lớn (giới hạn 700KB). Vui lòng chọn ảnh nhỏ hơn.');
      }
      final base64String = base64Encode(bytes);

      // Lưu chuỗi Base64 vào Firestore
      await _updateField('avatar', base64String);
      setState(() {
        _newPickedImageFile = null;
        _base64Avatar = base64String;
      });
    } catch (e) {
      if (mounted) {
        // Hiển thị thông báo lỗi nếu xử lý ảnh thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xử lý ảnh: $e'), backgroundColor: Colors.redAccent),
        );
      }
      setState(() {
        _newPickedImageFile = null;
      });
    }
  }

  // Hiển thị hộp thoại chỉnh sửa thông tin
  void _showEditDialog(String fieldName, String firebaseFieldName, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Nhập $fieldName mới'),
          keyboardType: firebaseFieldName == 'email' ? TextInputType.emailAddress : TextInputType.text,
        ),
        actions: [
          // Nút hủy
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          // Nút lưu thông tin
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _updateField(firebaseFieldName, controller.text.trim());
                Navigator.pop(context);
              } else {
                // Hiển thị thông báo nếu trường để trống
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$fieldName không được để trống'), backgroundColor: Colors.orangeAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng hàng thông tin người dùng
  Widget _buildUserInfoRow({
    required String label,
    required String value,
    IconData? editIcon,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (editIcon != null && onEdit != null)
            IconButton(
              icon: Icon(editIcon, size: 20, color: _primaryColor),
              onPressed: onEdit,
              tooltip: 'Chỉnh sửa $label',
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Hiển thị vòng tròn tải khi đang lấy dữ liệu
            return Center(child: CircularProgressIndicator(color: _primaryColor));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            // Hiển thị thông báo lỗi hoặc không tìm thấy dữ liệu
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    snapshot.hasError ? Icons.error_outline : Icons.person_off_outlined,
                    size: 50,
                    color: snapshot.hasError ? Colors.redAccent : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.hasError
                        ? 'Đã xảy ra lỗi khi tải dữ liệu: ${snapshot.error}'
                        : 'Không tìm thấy dữ liệu người dùng.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Thử tải lại dữ liệu
                        _userFuture = _fetchUserData();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                    child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          final createdAtString = user.createdAt != null ? dateFormat.format(user.createdAt!) : 'N/A';
          final lastActiveString = user.lastActive != null ? dateFormat.format(user.lastActive!) : 'N/A';

          // Hiển thị danh sách thông tin người dùng
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Hiển thị ảnh đại diện
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: _primaryColor.withOpacity(0.2),
                      backgroundImage: _newPickedImageFile != null
                          ? FileImage(_newPickedImageFile!) as ImageProvider
                          : _base64Avatar != null && _base64Avatar!.isNotEmpty
                          ? MemoryImage(base64Decode(_base64Avatar!))
                          : null,
                      child: (_newPickedImageFile == null && (_base64Avatar == null || _base64Avatar!.isEmpty))
                          ? Icon(Icons.person, size: 70, color: _primaryColor.withOpacity(0.8))
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: _primaryColor,
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      // Hiển thị thông tin tên người dùng
                      _buildUserInfoRow(
                        label: 'Tên người dùng',
                        value: user.username.isNotEmpty ? user.username : 'Chưa đặt tên',
                        editIcon: Icons.edit,
                        onEdit: () => _showEditDialog('Tên người dùng', 'name', user.username),
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      // Hiển thị thông tin email
                      _buildUserInfoRow(
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      // Hiển thị ngày tạo tài khoản
                      _buildUserInfoRow(
                        label: 'Ngày tạo tài khoản',
                        value: createdAtString,
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      // Hiển thị lần hoạt động cuối
                      _buildUserInfoRow(
                        label: 'Lần hoạt động cuối',
                        value: lastActiveString,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}