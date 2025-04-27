import 'package:flutter/material.dart';
import '../api/AccountAPIService.dart';
import '../model/Account.dart';

// Màn hình đăng ký tài khoản
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Khởi tạo các controller và biến cần thiết
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false; // Để hiển thị loading khi đăng ký
  bool _obscurePassword = true; // Ẩn/hiện mật khẩu

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi widget bị hủy
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Hàm thực hiện đăng ký
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Kiểm tra tên đăng nhập đã tồn tại chưa
        final exists = await AccountAPIService.instance.isUsernameExists(_usernameController.text);
        if (exists) {
          _showErrorDialog('Đăng ký thất bại', 'Tên đăng nhập đã tồn tại.');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Tạo tài khoản mới
        final now = DateTime.now().toIso8601String();
        final randomId = DateTime.now().millisecondsSinceEpoch; // ID random theo thời gian

        final newAccount = Account(
          id: randomId,
          userId: randomId, // userId trùng id (hoặc tùy chỉnh sau)
          username: _usernameController.text,
          password: _passwordController.text,
          status: 'active',
          lastLogin: now,
          createdAt: now,
        );

        // Gửi yêu cầu tạo tài khoản
        await AccountAPIService.instance.createAccount(newAccount);

        setState(() {
          _isLoading = false;
        });

        // Hiển thị dialog đăng ký thành công
        _showSuccessDialog('Đăng ký thành công', 'Bạn có thể đăng nhập ngay bây giờ.');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Hiển thị lỗi nếu có ngoại lệ
        _showErrorDialog('Lỗi đăng ký', 'Đã xảy ra lỗi: $e');
      }
    }
  }

  // Hiển thị dialog lỗi
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog thành công
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Quay về màn hình trước (login)
            },
            child: Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Form key để validate
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // Icon minh họa
              Icon(
                Icons.person_add,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 40),

              // Ô nhập tên đăng nhập
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Ô nhập mật khẩu
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Ẩn/hiện mật khẩu
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Đổi trạng thái ẩn/hiện
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Ô xác nhận mật khẩu
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Nút đăng ký
              ElevatedButton(
                onPressed: _isLoading ? null : _register, // Nếu đang loading thì disable nút
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white) // Loading spinner
                    : Text(
                  'ĐĂNG KÝ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
